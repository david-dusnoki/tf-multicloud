data "template_file" "dev_hosts" {
    template = "${file("${path.module}/hosts.cfg")}"
    depends_on = [
        "azurerm_public_ip.test-publicip",
        "digitalocean_droplet.do-test-droplet"
    ]
    vars {
        azure-ip = "${azurerm_public_ip.test-publicip.ip_address}"
        do-ip = "${digitalocean_droplet.do-test-droplet.ipv4_address}"
    }
}

resource "null_resource" "dev-hosts" {
    triggers {
        template_rendered = "${data.template_file.dev_hosts.rendered}"
    }
    provisioner "local-exec" {
        command = "echo '${data.template_file.dev_hosts.rendered}' > hosts"
    }
}
