# Agent variables
variable "agent_project_id" {
  type        = string
  description = "agent project_id"
}

variable "agent_network" {
  type        = string
  description = "agent network name"
}

variable "agent_region" {
  type        = string
  description = "Region of the agent network"
}

variable "agent_asn" {
  type        = string
  description = "ASN of the agent network"
}

variable "agent_subnet_ip_cidr_range" {
  type        = string
  description = "Subnet ip cidr range of the agent network"
}

variable "agent_source_ranges" {
  type        = list(string)
  description = "Firewall source ranges in the agent network"
}

variable "agent_bgp_cr_session_range" {
  type        = list(string)
  description = "The ip range of the internal VPN"
}

variable "agent_bgp_remote_session_address" {
  type        = list(string)
  description = "The ip list of the remote"
}

# Onprem variables
variable "onprem_project_id" {
  type        = string
  description = "onprem project_id"
}

variable "onprem_network" {
  type        = string
  description = "onprem network name"
}

variable "onprem_region" {
  type        = string
  description = "Region of the onprem network"
}

variable "onprem_asn" {
  type        = string
  description = "ASN of the onprem network"
}

variable "onprem_subnet_ip_cidr_range" {
  type        = string
  description = "Subnet ip cidr range of the onprem network"
}

variable "onprem_source_ranges" {
  type        = list(string)
  description = "Firewall source ranges in the onprem network"
}

variable "onprem_bgp_cr_session_range" {
  type        = list(string)
  description = "The ip range of the internal VPN"
}

variable "onprem_bgp_remote_session_address" {
  type        = list(string)
  description = "The ip list of the remote"
}

variable "shared_secret" {
  type        = string
  description = "secret to encrypt the traffic must be configured on both ends of tunnel"
}