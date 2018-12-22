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
    name                = "${var.name}-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.test-group.name}"

    tags {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "test-subnet" {
    name                 = "${var.name}-subnet"
    resource_group_name  = "${azurerm_resource_group.test-group.name}"
    virtual_network_name = "${azurerm_virtual_network.test-network.name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IP
resource "azurerm_public_ip" "test-publicip" {
    name                         = "${var.name}-publicip"
    location                     = "eastus"
    resource_group_name          = "${azurerm_resource_group.test-group.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "Terraform Demo"
    }

    depends_on = [
        "azurerm_resource_group.test-group",
    ]
}

# Store Public IP
data "azurerm_public_ip" "test-publicip" {
    name                = "${azurerm_public_ip.test-publicip.name}"
    resource_group_name = "${azurerm_virtual_machine.test-vm.resource_group_name}"

    depends_on = [
        "azurerm_public_ip.test-publicip",
    ]
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "test-sg" {
    name                = "${var.name}-securitygroup"
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

    security_rule {
        name                       = "HTTP"
        priority                   = 1100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Terraform Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "test-nic" {
    name                      = "${var.name}-nic"
    location                  = "eastus"
    resource_group_name       = "${azurerm_resource_group.test-group.name}"
    network_security_group_id = "${azurerm_network_security_group.test-sg.id}"

    ip_configuration {
        name                          = "${var.name}-nic"
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
    name                  = "${var.name}-vm"
    location              = "eastus"
    resource_group_name   = "${azurerm_resource_group.test-group.name}"
    network_interface_ids = ["${azurerm_network_interface.test-nic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "${var.name}-disk"
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
        computer_name  = "${var.name}-vm"
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

resource "azurerm_virtual_machine_extension" "test-machine-extension" {
    name                 = "${var.name}-vm"
    location             = "${azurerm_resource_group.test-group.location}"
    resource_group_name  = "${azurerm_resource_group.test-group.name}"
    virtual_machine_name = "${azurerm_virtual_machine.test-vm.name}"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"
    depends_on           = ["azurerm_virtual_machine.test-vm"]


    settings = <<SETTINGS
        {
            "fileUris": ["https://raw.githubusercontent.com/david-dusnoki/tf-multicloud/master/init.sh"],
            "commandToExecute": "bash init.sh"
        }
    SETTINGS

    tags {
        environment = "Test"
    }
}
