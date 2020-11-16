<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| activate\_apis | List of APIs to enable in the Jenkins Master project. | `list(string)` | <pre>[<br>  "serviceusage.googleapis.com",<br>  "servicenetworking.googleapis.com",<br>  "compute.googleapis.com",<br>  "logging.googleapis.com",<br>  "bigquery.googleapis.com",<br>  "cloudresourcemanager.googleapis.com",<br>  "cloudbilling.googleapis.com",<br>  "iam.googleapis.com",<br>  "admin.googleapis.com",<br>  "appengine.googleapis.com",<br>  "storage-api.googleapis.com",<br>  "cloudkms.googleapis.com"<br>]</pre> | no |
| billing\_account | The ID of the billing account to associate projects with. | `string` | n/a | yes |
| default\_region | Default region to create resources where applicable. | `string` | `"us-central1"` | no |
| folder\_id | The ID of a folder to host this project | `string` | `""` | no |
| group\_org\_admins | Google Group for GCP Organization Administrators | `string` | n/a | yes |
| jenkins\_master\_gce\_machine\_type | Jenkins Master GCE Instance type. | `string` | `"n1-standard-1"` | no |
| jenkins\_master\_gce\_name | Jenkins Master GCE Instance name. | `string` | `"jenkins-master-01"` | no |
| jenkins\_master\_gce\_ssh\_user | Jenkins Master GCE Instance SSH username. | `string` | `"jenkins"` | no |
| jenkins\_master\_sa\_email | Email for Jenkins Master service account. | `string` | `"jenkins-master-gce"` | no |
| org\_id | GCP Organization ID | `string` | n/a | yes |
| project\_labels | Labels to apply to the project. | `map(string)` | `{}` | no |
| project\_prefix | Name prefix to use for projects created. | `string` | `"prj"` | no |
| service\_account\_prefix | Name prefix to use for service accounts. | `string` | `"sa"` | no |
| terraform\_version | Default terraform version. | `string` | `"0.12.24"` | no |
| terraform\_version\_sha256sum | sha256sum for default terraform version. | `string` | `"602d2529aafdaa0f605c06adb7c72cfb585d8aa19b3f4d8d189b42589e27bf11"` | no |
| tpl\_github\_repo\_environments | The environments Github repository name. This value is used in the jcac.yaml file. | `string` | n/a | yes |
| tpl\_github\_repo\_networks | The networks Github repository name. This value is used in the jcac.yaml file. | `string` | n/a | yes |
| tpl\_github\_repo\_org | The org Github repository name. This value is used in the jcac.yaml file. | `string` | n/a | yes |
| tpl\_github\_repo\_projects | The projects Github repository name. This value is used in the jcac.yaml file. | `string` | n/a | yes |
| tpl\_github\_token | The Github user token used to connect with the repositories. To genrate one follow the instructions on here: https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token .This value is used in the jcac.yaml file. | `string` | n/a | yes |
| tpl\_github\_username | The Github user used to connect with the repositories. This value is used in the jcac.yaml file. | `string` | n/a | yes |
| tpl\_jenkins\_agent\_ip\_addr | The IP Address of the Jenkins Agent. This value is used in the jcac.yaml file. This IP Address is reachable through the VPN that exists between on-prem (Jenkins Master) and GCP (CICD Project, where the Jenkins Agent is located). | `string` | n/a | yes |
| tpl\_jenkins\_agent\_name | The name of the Jenkins Agent. This value is used in the jcac.yaml file. | `string` | `"jenkins-agent-01"` | no |
| tpl\_jenkins\_web\_ui\_admin\_email | The admin user password in the instance. This value is used in the jcac.yaml file. | `string` | `"admin@admin.com"` | no |
| tpl\_jenkins\_web\_ui\_admin\_password | The admin user password in the instance. This value is used in the jcac.yaml file. | `string` | n/a | yes |
| tpl\_jenkins\_web\_ui\_admin\_user | The admin user created in the instance. This value is used in the jcac.yaml file. | `string` | `"admin"` | no |

## Outputs

| Name | Description |
|------|-------------|
| jenkins\_master\_gce\_instance\_id | Jenkins Master GCE Instance id. |
| jenkins\_master\_project\_id | Project where the Jenkins Master resides. |
| jenkins\_sa\_email | Email for privileged custom service account for Jenkins Master GCE instance. |
| jenkins\_sa\_name | Fully qualified name for privileged custom service account for Jenkins Master GCE instance. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
