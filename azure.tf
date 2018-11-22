# Create a resource group
resource "azurerm_resource_group" "test-group" {
    name     = "production"
    location = "eastus"

    tags {
        environment = "Terraform Demo"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "test-network" {
    name                = "test-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.test-group.name}"

    tags {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "test-subnet" {
    name                 = "test-subnet"
    resource_group_name  = "${azurerm_resource_group.test-group.name}"
    virtual_network_name = "${azurerm_virtual_network.test-network.name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "test-publicip" {
    name                         = "test-publicip"
    location                     = "eastus"
    resource_group_name          = "${azurerm_resource_group.test-group.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "test-sg" {
    name                = "test-securitygroup"
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.test-group.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Terraform Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "test-nic" {
    name                      = "test-nic"
    location                  = "eastus"
    resource_group_name       = "${azurerm_resource_group.test-group.name}"
    network_security_group_id = "${azurerm_network_security_group.test-sg.id}"

    ip_configuration {
        name                          = "test-nic"
        subnet_id                     = "${azurerm_subnet.test-subnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.test-publicip.id}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.test-group.name}"
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "test-storageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "${azurerm_resource_group.test-group.name}"
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags {
        environment = "Terraform Demo"
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "test-vm" {
    name                  = "test-vm"
    location              = "eastus"
    resource_group_name   = "${azurerm_resource_group.test-group.name}"
    network_interface_ids = ["${azurerm_network_interface.test-nic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "test-disk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "test-vm"
        admin_username = "${var.azure_username}"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "${var.azure_ssh_key}"
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.test-storageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "Terraform Demo"
    }
}
