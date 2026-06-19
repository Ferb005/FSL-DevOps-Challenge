# In this file put the variables related to the deployment
variable "environment_name" {
    type = string
    description = "Environment name: devel or stage"
}

variable "location" {
    type = string
    description = "Azure region"
    default = "eastus"
}

variable "project_name" {
    type = string
    description = "Project name prefix for resources"
    default = "rdicidr"
}