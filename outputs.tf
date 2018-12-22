# Azure
#output "azure_public_ip" {
#    value = "${azurerm_public_ip.test-publicip.ip_address}"
#}

output "azure_public_ip" {
    value = "${data.azurerm_public_ip.test-publicip.ip_address}"
}

output "azure_username" {
    value = "${var.azure_username}"
}

# Digital Ocean

output "do_public_ip" {
    value = "${digitalocean_droplet.do-test-droplet.ipv4_address}"
}

# AWS

output "aws_public_ip" {
    value = "${aws_instance.ec2-test.public_ip}"
}

# Alicloud

output "ac_public_ip" {
    value = "${alicloud_eip.eip.ip_address}"
}
