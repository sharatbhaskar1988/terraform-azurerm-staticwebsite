output "resource_group_id" {
  description = "resource group id"
  value       = azurerm_resource_group.myrg.id
}
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.myrg.name
}
output "resource_group_location" {
  description = "resource group location"
  value       = azurerm_resource_group.myrg.location
}