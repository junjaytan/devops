provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

# Share one virtual network and subnet across all resources in this setup
resource "azurerm_network_security_group" "MyTestCluster-securitygroup" {
  name     = "${var.my_resource_prefix}"
  location = "${var.region}"
  resource_group_name = "${var.resource_group_name}"

  security_rule {
    name                       = "${var.my_resource_prefix}-securityrulein1"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "${var.allowed_ip}"
    destination_address_prefix = "*"
  }

  tags {
    environment = "${var.my_resource_prefix}"
  }
}

resource "azurerm_virtual_network" "MyTestCluster-virtualnetwork" {
  name                = "${var.my_resource_prefix}VirtualNetwork"
  address_space       = ["10.0.0.0/16"] 
  location            = "${var.region}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_subnet" "MyTestCluster-subnet" {
  name                 = "${var.my_resource_prefix}Subnet"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${azurerm_virtual_network.MyTestCluster-virtualnetwork.name}"
  address_prefix       = "10.0.1.0/24"
  network_security_group_id = "${azurerm_network_security_group.MyTestCluster-securitygroup.id}"
}

resource "azurerm_public_ip" "MyTestCluster-publicIP" {
  count = "${var.node_count}"
  name                         = "${var.my_resource_prefix}publicip-${count.index}"
  location                     = "${var.region}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "static"

  tags {
    environment = "${var.my_resource_prefix}"
  }
}

resource "azurerm_network_interface" "MyTestCluster-networkInterface" {
  count = "${var.node_count}"
  name                = "${var.my_resource_prefix}networkInterface-${count.index}"
  location            = "${var.region}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                          = "${var.my_resource_prefix}ipconfiguration-${count.index}"
    subnet_id                     = "${azurerm_subnet.MyTestCluster-subnet.id}"
    private_ip_address_allocation = "static"
    private_ip_address 		  = "10.0.1.${count.index + 10}"
    public_ip_address_id = "${element(azurerm_public_ip.MyTestCluster-publicIP.*.id, count.index)}"
  }
}

resource "azurerm_virtual_machine" "MyTestCluster-VM" {
  count = "${var.node_count}"
  name                  = "${var.my_resource_prefix}vm-${count.index}"
  location              = "${var.region}"
  resource_group_name   = "${var.resource_group_name}"
  network_interface_ids = ["${element(azurerm_network_interface.MyTestCluster-networkInterface.*.id, count.index)}"]
  vm_size               = "${var.vm_size}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.my_resource_prefix}-myosdisk0-${count.index}"
    #vhd_uri       = "${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}/myosdisk1.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  # Optional data disks
  storage_data_disk {
    name          = "${var.my_resource_prefix}-datadisk0-${count.index}"
  #  #vhd_uri       = "${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}/datadisk0.vhd"
    disk_size_gb  = "1000"
    create_option = "Empty"
    lun           = 0
  }

  os_profile {
    computer_name  = "${var.my_resource_prefix}vm-${count.index}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "${var.my_resource_prefix}"
  }
}
