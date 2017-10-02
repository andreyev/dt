provider "azurerm" {
}

resource "azurerm_resource_group" "default" {
  name     = "${var.project_name}"
  location = "East US"
}

resource "azurerm_virtual_network" "default" {
  name                = "${var.project_name}"
  address_space       = ["10.0.0.0/16"]
  location            = "East US"
  resource_group_name = "${azurerm_resource_group.default.name}"
}

resource "azurerm_subnet" "default" {
  name                 = "${var.project_name}"
  resource_group_name  = "${azurerm_resource_group.default.name}"
  virtual_network_name = "${azurerm_virtual_network.default.name}"
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_public_ip" "default" {
  name                         = "${var.project_name}"
  count                        = 1
  location                     = "East US"
  resource_group_name          = "${azurerm_resource_group.default.name}"
  public_ip_address_allocation = "dynamic"
  # workaround to avoid https://github.com/hashicorp/terraform/issues/6634
  domain_name_label            = "${format("client%02d-%.8s",count.index,  uuid())}"

  lifecycle {
    # ignore because we are generating with uuid()
    ignore_changes = ["domain_name_label"]
  }
}

resource "azurerm_network_security_group" "default" {
  name                = "${var.project_name}"
  location            = "East US"
  resource_group_name = "${azurerm_resource_group.default.name}"

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
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "default" {
  name                      = "${var.project_name}"
  location                  = "East US"
  resource_group_name       = "${azurerm_resource_group.default.name}"
  network_security_group_id = "${azurerm_network_security_group.default.id}"

  ip_configuration {
    name                          = "${var.project_name}"
    subnet_id                     = "${azurerm_subnet.default.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.default.id}"
  }
}

resource "random_id" "randomId" {
  keepers = {
    resource_group = "${azurerm_resource_group.default.name}"
  }

  byte_length = 8
}

resource "azurerm_virtual_machine" "default" {
  name                  = "${var.project_name}"
  location              = "East US"
  resource_group_name   = "${azurerm_resource_group.default.name}"
  network_interface_ids = ["${azurerm_network_interface.default.id}"]
  vm_size               = "Standard_DS1_v2"

  connection {
    host = "${element(azurerm_public_ip.default.*.fqdn, count.index)}"
    user = "centos"
    private_key = "${file(var.private_key_path)}"
  }

  storage_os_disk {
    name              = "${var.project_name}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.3"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.project_name}"
    admin_username = "centos"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/centos/.ssh/authorized_keys"
      key_data = "${file(var.public_key_path)}"
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y git",
      "sudo git clone ${var.repository} /opt/${var.project_name}",
      "cd /opt/${var.project_name} && sudo git checkout ${var.branch}",
      "cd /opt/${var.project_name} && sudo bash -x ./install.sh -p ${var.project_name} -a ${var.owncloud_admin_pass} -d ${azurerm_public_ip.default.fqdn}"
    ]
  }
}

output "ready" {
  value = "Please login on https://${azurerm_public_ip.default.fqdn} with admin/${var.owncloud_admin_pass}"
}
