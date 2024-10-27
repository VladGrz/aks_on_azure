resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.machine.id
  vm_size               = "Standard_F2"
  vnet_subnet_id        = azurerm_subnet.machine_subnet_1.id
  orchestrator_version  = local.eks_version
  priority              = "Spot"
  spot_max_price        = -1
  eviction_policy       = "Delete"

  auto_scaling_enabled = true
  node_count           = 1
  min_count            = 1
  max_count            = 10

  node_labels = {
    role                                 = "spot"
    "kubernetes.azure.com/scalesetpriority" = "spot"
  }

  node_taints = [
    "spot:NoSchedule",
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ]

  tags = {
    env = local.env
  }

  lifecycle {
    ignore_changes = [node_count]
  }
}