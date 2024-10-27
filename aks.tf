resource "azurerm_user_assigned_identity" "base" {
  name                = "base"
  location            = azurerm_resource_group.machine.location
  resource_group_name = azurerm_resource_group.machine.name
}

resource "azurerm_role_assignment" "base" {
  scope                = azurerm_resource_group.machine.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.base.principal_id
}

resource "azurerm_kubernetes_cluster" "machine" {
  name                = "${local.env}-${local.eks_name}"
  location            = azurerm_resource_group.machine.location
  resource_group_name = azurerm_resource_group.machine.name
  dns_prefix          = "devaks1"

  kubernetes_version      = local.eks_version
  private_cluster_enabled = false
  node_resource_group     = "${local.resource_group_name}-${local.env}-${local.eks_version}"

  sku_tier                  = "Free"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.0.64.10"
    service_cidr   = "10.0.64.0/19"
  }

  default_node_pool {
    name                 = "general"
    vm_size              = "Standard_F2"
    vnet_subnet_id       = azurerm_subnet.machine_subnet_1.id
    orchestrator_version = local.eks_version
    type                 = "VirtualMachineScaleSets"
    auto_scaling_enabled = true
    node_count           = 1
    min_count            = 1
    max_count            = 10

    node_labels = {
      role = "general"
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.base.id]
  }

  tags = {
    env = local.env
  }

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }

  depends_on = [
    azurerm_role_assignment.base
  ]
}