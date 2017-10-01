variable "owncloud_admin_pass" {
  description = "Password to log on Owncloud"
}

variable "project_name" {
  description = "Name of all resources of this project"
}

variable "repository" {
  description = "Project's repository to be cloned"
}

variable "branch" {
  description = "Branch to apply"
}

variable "public_key_path" {
  description = "Path to public key"
}

variable "private_key_path" {
  description = "Path to private key"
}
