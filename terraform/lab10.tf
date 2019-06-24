resource "azurerm_resource_group" "itea-aks" {
  name     = "${var.prefix}-k8s-resources"
  location = "${var.location}"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-k8s"
  location            = "${azurerm_resource_group.itea-aks.location}"
  resource_group_name = "${azurerm_resource_group.itea-aks.name}"
  dns_prefix          = "${var.prefix}-k8s"

  agent_pool_profile {
    name            = "default"
    count           = 2
    vm_size         = "Standard_D1_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${var.kubernetes_client_id}"
    client_secret = "${var.kubernetes_client_secret}"
  }

  tags = {
    Environment = "Dev"
  }
}