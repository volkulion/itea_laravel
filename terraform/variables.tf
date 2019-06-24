variable "prefix" {
  description = "A prefix used for all resources in this example"
  default ="itea-volkulion"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be provisioned"
  default="westeurope"
}

variable "kubernetes_client_id" {
  description = "The Client ID for the Service Principal to use for this Managed Kubernetes Cluster"
  default ="72a50d3a-14f4-4483-a1f1-f53e95c375bb"
}

variable "kubernetes_client_secret" {
  description = "The Client Secret for the Service Principal to use for this Managed Kubernetes Cluster"
  default ="be9598ce-15ed-4716-ac67-e365f4643847"
}


#Manually create a service principal
#https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal
#az ad sp create-for-rbac --skip-assignment
