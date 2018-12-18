# Configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = "${var.azure_subscription_id}"
    client_id       = "${var.azure_client_id}"
    client_secret   = "${var.azure_client_secret}"
    tenant_id       = "${var.azure_tenant_id}"
}

# Configure Digital Ocean Provider
provider "digitalocean" {
    token = "${var.do_token}"
}

# Configure Google Cloud Platform
#provider "google" {
#    credentials = "${file("google-credentials.json")}"
#    project     = "durable-timing-100905"
#    region      = "us-west1"
#}

# Configure AWS Provider
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "us-west-1"
}

provider "alicloud" {
    access_key = "${var.ac_access_key}"
    secret_key = "${var.ac_secret_key}"
    region     = "us-east-1"
}
