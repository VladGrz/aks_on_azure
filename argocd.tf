data "azurerm_kubernetes_cluster" "this" {
    name = "${local.env}-${local.eks_name}"
    resource_group_name = local.resource_group_name
    depends_on = [
        azurerm_kubernetes_cluster.machine
    ]
}

provider "helm" {
    kubernetes {
        host = data.azurerm_kubernetes_cluster.this.kube_config.0.host
        client_certificate = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.client_certificate)
        client_key = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.client_key)
        cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.cluster_ca_certificate)
        config_path = "~/.kube/config"
    }
}

resource "helm_release" "argocd" {
    name = "argocd"

    repository = "https://argoproj.github.io/argo-helm"
    chart = "argo-cd"
    namespace = "argocd"
    create_namespace = true
    version = "3.35.4"
    values = [file("values/argocd.yaml")]
}