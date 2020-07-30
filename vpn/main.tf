# Agent
# Agent network
resource "google_compute_network" "agent_network" {
  project = var.agent_project_id
  name    = "vpc-b-agent"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "agent_subnetwork" {
  name          = "sb-b-agent"
  ip_cidr_range = var.agent_subnet_ip_cidr_range # Example: "10.0.0.0/21"
  project       = var.agent_project_id
  region        = var.agent_region
  network       = google_compute_network.agent_network.id
}

resource "google_compute_firewall" "fw_allow_ssh_into_agent" {
  project       = var.agent_project_id
  name          = "fw-1000-i-a-all-all-tcp-22"
  description   = "Allow the Jenkins Master (Client) to connect to the Jenkins Agents (Servers) using SSH."
  network       = google_compute_network.agent_network.name
  source_ranges = var.onprem_source_ranges
  priority      = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "fw_allow_icmp_into_agent" {
  project       = var.agent_project_id
  name          = "fw-1000-i-a-all-all-icmp"
  description   = "Allow the Jenkins Master (Client) to connect to the Jenkins Agents (Servers) using ICMP."
  network       = google_compute_network.agent_network.name
  source_ranges = var.onprem_source_ranges
  priority      = 1000

  allow {
    protocol = "icmp"
  }
}

# Agent VPN
resource "google_compute_router" "cr-agent-to-onprem-vpc" {
  name    = "cr-agent-to-onprem-vpc-tunnels"
  region  = var.agent_region
  project = var.agent_project_id
  network = google_compute_network.agent_network.name
  # network = var.agent_network

  bgp {
    asn = var.agent_asn   #"64516"
  }
}

module "vpn-agent-to-onprem" {
  source             = "terraform-google-modules/vpn/google"
  project_id         = var.agent_project_id
  network            = google_compute_network.agent_network.name
  # network = var.agent_network
  region             = var.agent_region
  gateway_name       = "gw-agent-to-onprem"
  tunnel_name_prefix = "tn-agent-to-onprem"
  shared_secret      = var.shared_secret
  tunnel_count       = 1
  peer_ips           = [module.vpn-onprem-to-agent.gateway_ip] // the vpn-onprem-to-agent.gateway_ip

  cr_name                  = google_compute_router.cr-agent-to-onprem-vpc.name
  cr_enabled               = true
  bgp_cr_session_range     = var.agent_bgp_cr_session_range // Example: ["169.254.1.1/30"] so this is the IP for the internal network in the tunnel.
  bgp_remote_session_range = var.agent_bgp_remote_session_address // Example: ["169.254.1.2"] based on the example below for the agent side.
  peer_asn                 = [var.onprem_asn]
}


# Onprem
# Onprem network
resource "google_compute_network" "onprem_network" {
  project = var.onprem_project_id
  name    = "vpc-b-onprem-${var.onprem_region}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "onprem_subnetwork" {
  name          = "sb-b-onprem-${var.onprem_region}"
  ip_cidr_range = var.onprem_subnet_ip_cidr_range #"10.2.0.0/16"
  project       = var.onprem_project_id
  region        = var.onprem_region
  network       = google_compute_network.onprem_network.id
}

resource "google_compute_firewall" "fw_allow_ssh_into_onprem" {
  project       = var.onprem_project_id
  name          = "fw-${google_compute_network.onprem_network.name}-1000-i-a-all-all-tcp-22"
  description   = "Allow the Jenkins Agent to connect to the Jenkins Master using SSH."
  network       = google_compute_network.onprem_network.name
  source_ranges = var.agent_source_ranges
  priority      = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "fw_allow_icmp_into_onprem" {
  project       = var.onprem_project_id
  name          = "fw-${google_compute_network.onprem_network.name}-1000-i-a-all-all-icmp"
  description   = "Allow the Jenkins Agent to connect to the Jenkins Master using SSH."
  network       = google_compute_network.onprem_network.name
  source_ranges = var.agent_source_ranges
  priority      = 1000

  allow {
    protocol = "icmp"
  }
}

Onprem VPN
resource "google_compute_router" "cr-onprem-to-agent-vpc" {
  name    = "cr-onprem-to-agent-vpc-tunnels"
  region  = var.onprem_region
  project = var.onprem_project_id
  network = google_compute_network.onprem_network.name

  bgp {
    asn = var.onprem_asn  # a value like "64515"
  }
}

module "vpn-onprem-to-agent" {
  source             = "terraform-google-modules/vpn/google"
  project_id         = var.onprem_project_id
  network            = google_compute_network.onprem_network.name
  region             = var.onprem_region
  gateway_name       = "gw-onprem-to-agent"
  tunnel_name_prefix = "tn-onprem-to-agent"
  shared_secret      = var.shared_secret
  tunnel_count       = 1
  peer_ips           = [module.vpn-agent-to-onprem.gateway_ip] // the vpn-agent-to-onprem.gateway_ip

  cr_name                  = google_compute_router.cr-onprem-to-agent-vpc.name
  cr_enabled               = true
  bgp_cr_session_range     = var.onprem_bgp_cr_session_range // Example: ["169.254.1.2/30"] so this is the IP for the internal network in the tunnel.
  bgp_remote_session_range = var.onprem_bgp_remote_session_address // Example: ["169.254.1.1"] based on the example above for the agent side.
  peer_asn                 = [var.agent_asn]
}
