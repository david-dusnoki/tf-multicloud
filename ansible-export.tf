data "template_file" "hosts" {
    template = "${file("${path.module}/hosts.cfg")}"
    depends_on = [
        "azurerm_public_ip.test-publicip",
        "digitalocean_droplet.do-test-droplet"
    ]
    vars {
        azure-ip = "${data.azurerm_public_ip.test-publicip.ip_address}"
        do-ip = "${digitalocean_droplet.do-test-droplet.ipv4_address}"
    }
}

resource "null_resource" "hosts" {
    triggers {
        template_rendered = "${data.template_file.hosts.rendered}"
    }
    provisioner "local-exec" {
        command = "echo '${data.template_file.hosts.rendered}' > hosts"
    }
}
