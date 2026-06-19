output "cdn_endpoint_url" {
  value = "https://${azurerm_cdn_endpoint.main.name}.azureedge.net"
  description = "PUblic URL of the CDN endpoint"
}

output "storage_account_name" {
    value = azurerm_storage_account.web.name
    description = "Name of the storage account"
}

output "log_analytics_workspace_id" {
    value = azurerm_log_analytics_workspace.main.id
    description = "ID of the log analytics workspace"
}

output "resource_group_name" {
    value = azurerm_resource_group.main.name
    description = "Name of the resource group"
}