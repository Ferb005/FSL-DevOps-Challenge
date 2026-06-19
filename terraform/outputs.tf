output "cdn_endpoint_url" {
  value = "https://${azurerm_cdn_endpoint.main.fqdn}"
  description = "Public URL of the CDN endpoint"
}

output "storage_account_name" {
  value = azurerm_storage_account.web.name
  description = "Storage account name for blob uploads"
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.id
  description = "Log analytics workspace ID for monitoring"
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
  description = "Resource group name for the deployment"
}