output "service_status" {
  value = {}
  depends_on = [kubernetes_deployment.deployment]
}