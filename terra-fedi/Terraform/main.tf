provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
  //storage_account_id       = "/subscriptions/8dad328f-8daa-4be3-96fa-4713fd77f8fa/resourceGroups/cloud-shell-storage-westeurope/providers/Microsoft.Storage/storageAccounts/csb10032001f02bce76"

}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name            = "system"
    node_count      = var.system_node_count
    vm_size         = "Standard_B2s"
    type                = "VirtualMachineScaleSets"
    availability_zones  = [1, 2, 3]
    enable_auto_scaling = false
  }

  # service_principal {
  #   client_id     = var.appId
  #   client_secret = var.password
  # }
  identity{
           type = "SystemAssigned"
       }
}

resource "azurerm_role_assignment" "role_acrpull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
