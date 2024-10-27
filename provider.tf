terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = "0a9a10c1-c50a-4e9b-9bce-3c63a15baccd"
}