terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

locals {
    resource_prefix = "${var.project_name}-${var.environment}"
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_prefix}"
  location = var.location
}

resource "azurerm_storage_account" "web" {
  name                     = "${replace(local.resource_prefix, "-", "")}web"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
    static_website {
        index_document = "index.html"
        error_404_document = "index.html"
    }
}

resource "azurerm_cdn_profile" "main" {
  name                = "cdn-profile-${local.resource_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "main" {
  name                = "cdn-endpoint-${local.resource_prefix}"
  profile_name        = azurerm_cdn_profile.main.name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  origin {
    name = "blob-origin"
    host_name = azurerm_storage_account.web.primary_web_host
  }
    delivery_rule {
        name = "EnforceHTTPS"
        order = 1

    request_scheme_condition {
        match_values = ["HTTP"]
    }
    url_redirect_action {
        redirect_type = "Found"
        protocol = "Https"
        }
    }
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-analytics-workspace-${local.resource_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "cdn" {
  name               = "cdn-diagnostic-logs"
  target_resource_id = azurerm_cdn_endpoint.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "AccessLog"
  }
  metric {
    category = "AllMetrics"
    enabled = true
  }
}