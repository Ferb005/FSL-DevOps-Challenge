output "cdn_endpoint_url" {
  value       = "https://${azurerm_cdn_frontdoor_endpoint.main.host_name}"
  description = "Public URL of the Front Door endpoint"
}

output "storage_account_name" {
  value       = azurerm_storage_account.web.name
  description = "Storage account name for blob uploads"
}

output "log_analytics_workspace_id" {
  value       = azurerm_log_analytics_workspace.main.id
  description = "Log analytics workspace ID for monitoring"
}

output "resource_group_name" {
  value       = azurerm_resource_group.main.name
  description = "Resource group name"
}

output "frontdoor_profile_name" {
  value       = azurerm_cdn_frontdoor_profile.main.name
  description = "Azure Front Door profile name"
}

output "frontdoor_endpoint_name" {
  value       = azurerm_cdn_frontdoor_endpoint.main.name
  description = "Azure Front Door endpoint name"
}
