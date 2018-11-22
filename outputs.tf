# Azure
output "azure_public_ip" {
    value = "${azurerm_public_ip.test-publicip.ip_address}"
}

output "azure_username" {
    value = "${var.azure_username}"
}
