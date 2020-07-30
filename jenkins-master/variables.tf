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

/******************************************
  Required variables
*******************************************/

variable "org_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate projects with."
  type        = string
}

variable "group_org_admins" {
  description = "Google Group for GCP Organization Administrators"
  type        = string
}

variable "default_region" {
  description = "Default region to create resources where applicable."
  type        = string
  default     = "us-central1"
}

/* ----------------------------------------
    Specific to Jenkins Master Project
   ---------------------------------------- */
variable "jenkins_master_gce_name" {
  description = "Jenkins Master GCE Instance name."
  type        = string
  default     = "jenkins-master-01"
}

variable "jenkins_master_gce_machine_type" {
  description = "Jenkins Master GCE Instance type."
  type        = string
  default     = "n1-standard-1"
}

variable "jenkins_master_gce_ssh_user" {
  description = "Jenkins Master GCE Instance SSH username."
  type        = string
  default     = "jenkins"
}

variable "jenkins_master_sa_email" {
  description = "Email for Jenkins Master service account."
  type        = string
  default     = "jenkins-master-gce"
}

variable "tpl_jenkins_agent_ip_addr" {
  description = "The IP Address of the Jenkins Agent. This value is used in the jcac.yaml file. This IP Address is reachable through the VPN that exists between on-prem (Jenkins Master) and GCP (CICD Project, where the Jenkins Agent is located)."
  type        = string
}

/******************************************
  Optional variables
*******************************************/

variable "project_labels" {
  description = "Labels to apply to the project."
  type        = map(string)
  default     = {}
}

variable "project_prefix" {
  description = "Name prefix to use for projects created."
  type        = string
  default     = "prj"
}

variable "activate_apis" {
  description = "List of APIs to enable in the Jenkins Master project."
  type        = list(string)

  default = [
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "bigquery.googleapis.com", // TODO(caleonardo): confirm if Jenkins Master Project needs BQ
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "iam.googleapis.com",
    "admin.googleapis.com",
    "appengine.googleapis.com", // TODO(caleonardo): confirm if Jenkins Master Project needs GAE
    "storage-api.googleapis.com",
    "cloudkms.googleapis.com"
  ]
}

variable "service_account_prefix" {
  description = "Name prefix to use for service accounts."
  type        = string
  default     = "sa"
}

variable "folder_id" {
  description = "The ID of a folder to host this project"
  type        = string
  default     = ""
}

variable "terraform_version" {
  description = "Default terraform version."
  type        = string
  default     = "0.12.24"
}

variable "terraform_version_sha256sum" {
  description = "sha256sum for default terraform version."
  type        = string
  default     = "602d2529aafdaa0f605c06adb7c72cfb585d8aa19b3f4d8d189b42589e27bf11"
}
