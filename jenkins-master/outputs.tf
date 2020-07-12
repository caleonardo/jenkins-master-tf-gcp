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

/* ----------------------------------------
    Specific to Jenkins Master Project
   ---------------------------------------- */
output "jenkins_master_project_id" {
  description = "Project where the Jenkins Master resides."
  value       = module.jenkins_master_project.project_id
}

output "jenkins_master_gce_instance_id" {
  description = "Jenkins Master GCE Instance id."
  value       = google_compute_instance.jenkins_master_gce_instance.id
}

output "jenkins_sa_email" {
  description = "Email for privileged custom service account for Jenkins Master GCE instance."
  value       = google_service_account.jenkins_master_gce_sa.email
}

output "jenkins_sa_name" {
  description = "Fully qualified name for privileged custom service account for Jenkins Master GCE instance."
  value       = google_service_account.jenkins_master_gce_sa.name
}

