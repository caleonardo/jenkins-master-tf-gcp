/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  jenkins_master_project_name = format("%s-%s", var.project_prefix, "jenkins-master")
  jenkins_apis                = ["compute.googleapis.com", "sourcerepo.googleapis.com", "cloudkms.googleapis.com"]
  activate_apis               = distinct(var.activate_apis)
  jenkins_gce_fw_tags         = ["http-jenkins-master", "ssh-jenkins-master"]
}

/******************************************
  Jenkins Master project
*******************************************/
module "jenkins_master_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 9.2"
  name                        = local.jenkins_master_project_name
  random_project_id           = true
  disable_services_on_destroy = false
  folder_id                   = var.folder_id
  org_id                      = var.org_id
  billing_account             = var.billing_account
  activate_apis               = local.activate_apis
  labels                      = var.project_labels
}

resource "google_project_service" "jenkins_apis" {
  for_each           = toset(local.jenkins_apis)
  project            = module.jenkins_master_project.project_id
  service            = each.value
  disable_on_destroy = false
}

/******************************************
  Jenkins Master GCE instance
*******************************************/
resource "google_service_account" "jenkins_master_gce_sa" {
  project      = module.jenkins_master_project.project_id
  account_id   = format("%s-%s", var.service_account_prefix, var.jenkins_master_sa_email)
  display_name = "Jenkins Master (GCE instance) custom Service Account"
}

data "template_file" "jenkins_master_jcac_yaml" {
  template = file("${path.module}/files/master-container/jcac.tpl.yaml")
  vars = {
    # Jenkins Agent Admin
    tpl_JENKINS_AGENT_NAME       = var.tpl_jenkins_agent_name
    tpl_JENKINS_AGENT_IP_ADDR    = var.tpl_jenkins_agent_ip_addr
    tpl_JENKINS_AGENT_REMOTE_DIR = "/home/jenkins/jenkins_agent_dir"

    # Jenkins Master web UI login
    tpl_JENKINS_WEB_UI_ADMIN_USER   = var.tpl_jenkins_web_ui_admin_user
    tpl_JENKINS_WEB_UI_ADMIN_PASSWD = var.tpl_jenkins_web_ui_admin_password
    tpl_JENKINS_WEB_UI_ADMIN_EMAIL  = var.tpl_jenkins_web_ui_admin_email

    # Pipeline Variables: Github repository we want Jenkins Master to connect to
    tpl_GITHUB_USERNAME  = var.tpl_github_username
    tpl_GITHUB_TOKEN     = var.tpl_github_token
    tpl_GITHUB_REPO_ORG  = var.tpl_github_repo_org
    tpl_GITHUB_REPO_ENVS = var.tpl_github_repo_environments
    tpl_GITHUB_REPO_NET  = var.tpl_github_repo_networks
    tpl_GITHUB_REPO_PRJ  = var.tpl_github_repo_projects

    tpl_RSA_PRIVATE_KEY = file("${path.module}/files/master-container/sample-private-key.txt")
  }
}

// Creating the files needed to build and run the Jenkins Master container
data "template_file" "jenkins_master_gce_startup_script" {
  template = file("${path.module}/files/jenkins_gce_startup_script.tpl.sh")
  vars = {
    tpl_DOCKERFILE  = file("${path.module}/files/master-container/Dockerfile")
    tpl_JCAC_YAML   = data.template_file.jenkins_master_jcac_yaml.rendered
    tpl_PLUGINS_TXT = file("${path.module}/files/master-container/plugins.txt")

  }
}

resource "google_compute_instance" "jenkins_master_gce_instance" {
  project      = module.jenkins_master_project.project_id
  name         = var.jenkins_master_gce_name
  machine_type = var.jenkins_master_gce_machine_type
  zone         = "${var.default_region}-a"

  tags = local.jenkins_gce_fw_tags

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    // Internal and static IP configuration
    subnetwork = google_compute_subnetwork.jenkins_master_subnet.self_link
    network_ip = google_compute_address.jenkins_master_gce_static_ip.address

    access_config {
      // External and ephemeral IP configuration
      // TODO(caleonardo): This must not have an external IP. Only use for testing while developing a VPN resource
    }
  }

  // Adding ssh public keys to the GCE instance metadata, so the Jenkins Master can connect to this Master
  metadata = {
    enable-oslogin = "true"
  }

  metadata_startup_script = data.template_file.jenkins_master_gce_startup_script.rendered

  service_account {
    email = google_service_account.jenkins_master_gce_sa.email
    scopes = [
      // TODO(caleonardo): These scopes will need to change.
      "https://www.googleapis.com/auth/compute.readonly",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/userinfo.email",
    ]
  }

  // allow stopping the GCE instance to update some of its values
  allow_stopping_for_update = true
}

/******************************************
  Jenkins Master GCE Firewall rules
*******************************************/

resource "google_compute_firewall" "fw_allow_http_into_jenkins_agent" {
  project       = module.jenkins_master_project.project_id
  name          = "fw-${google_compute_network.jenkins_master.name}-1000-i-a-all-all-tcp-8080"
  description   = "Allow HTTP communication to the Jenkins Master."
  network       = google_compute_network.jenkins_master.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [local.jenkins_gce_fw_tags[0]]
  priority      = 1000

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
}

resource "google_compute_firewall" "fw_allow_ssh_into_jenkins_agent" {
  project       = module.jenkins_master_project.project_id
  name          = "fw-${google_compute_network.jenkins_master.name}-1000-i-a-all-all-tcp-22"
  description   = "Allow SSH communication to the Jenkins Master."
  network       = google_compute_network.jenkins_master.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [local.jenkins_gce_fw_tags[1]]
  priority      = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_network" "jenkins_master" {
  project = module.jenkins_master_project.project_id
  name    = "vpc-b-jenkinsmaster"
}

resource "google_compute_address" "jenkins_master_gce_static_ip" {
  // This internal IP address needs to be accessible via the VPN tunnel
  project      = module.jenkins_master_project.project_id
  name         = "jenkins-master-gce-static-ip"
  subnetwork   = google_compute_subnetwork.jenkins_master_subnet.self_link
  address_type = "INTERNAL"
  address      = "10.1.0.6"
  region       = var.default_region
  purpose      = "GCE_ENDPOINT"
  description  = "The static Internal IP address of the Jenkins Agent."
}

resource "google_compute_subnetwork" "jenkins_master_subnet" {
  project       = module.jenkins_master_project.project_id
  name          = "jenkins-masters-subnet"
  ip_cidr_range = "10.1.0.0/24"
  region        = var.default_region
  network       = google_compute_network.jenkins_master.self_link
}

/******************************************
  VPN Connectivity jenkins-master-project <--> CICD project
*******************************************/

// TODO(Amanda / Daniel): add VPN for connectivity between Jenkins Master on prem with Jenkins Agent in GCP
