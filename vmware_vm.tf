
//
// Module inputs
// 

variable "name" {}      // VM Name
variable "hostname" {}  // VM Hostname (DNS)
variable "address" {}   // VM IP Address

// Template specification + variables (e.g. PSK for puppet autosign)
variable "template_config" { type = "map" }
// Optional puppet role
variable "role" { default = "" }

// Network configuration (portgroup + gateway)
variable "network_config" { 
    type = "map" 
    default = {
        network = "vm-16-guest"
        gateway = "192.168.16.1"
    }
}

// Resource configuration (CPU + RAM)
variable "resource_config" { 
    type = "map" 
    default = {
        cpu_cores = 1
        ram_mb = 1024
    }
}

//
// Config templates
//

data "template_file" "network" {
    template = "${file("${path.module}/templates/network.tpl")}"

    vars {
        address = "${var.address}"
        gateway = "${var.network_config["gateway"]}"
    }
}

data "template_file" "metadata" {
    template = "${file("${path.module}/templates/metadata.tpl")}"

    vars {
        hostname = "${var.hostname}"
        network_config = "${data.template_file.network.rendered}"
    }
}

data "template_file" "csr_attributes" {
    template = "${file("${path.module}/templates/csr_attributes.tpl")}"

    vars {
        psk = "${var.template_config["puppet_psk"]}"
    }
}

data "template_file" "userdata" {
    template = "${file("${path.module}/templates/userdata.tpl")}"

    vars {
        role = "${var.role}"
        csr_attributes = "${data.template_file.csr_attributes.rendered}"
    }
}

//
// VMware resources
//

data "vsphere_virtual_machine" "template" {
  name          = "Z_Templates/${var.template_config["name"]}"
  datacenter_id = "${data.vsphere_datacenter.tampere-dc.id}"
}

data "vsphere_network" "network" {
  name          = "${var.network_config["network"]}"
  datacenter_id = "${data.vsphere_datacenter.tampere-dc.id}"
}

//
// The VM itself
//

resource "vsphere_virtual_machine" "vm" {
    name             = "${var.name}"
    resource_pool_id = "${data.vsphere_compute_cluster.vsan-cluster.resource_pool_id}"
    datastore_id     = "${data.vsphere_datastore.vsan-datastore.id}"

    num_cpus = "${var.resource_config["cpu_cores"]}"
    memory   = "${var.resource_config["ram_mb"]}"
    guest_id = "${data.vsphere_virtual_machine.template.guest_id}"

    network_interface {
        network_id = "${data.vsphere_network.network.id}"
    }

    disk {
        label = "disk0"
        size  = "${data.vsphere_virtual_machine.template.disks.0.size}"
    }

    extra_config {
        guestinfo.metadata = "${base64encode("${data.template_file.metadata.rendered}")}"
        guestinfo.metadata.encoding = "base64"
        guestinfo.userdata = "${base64encode("${data.template_file.userdata.rendered}")}"
        guestinfo.userdata.encoding = "base64"
    }

    clone {
        template_uuid = "${data.vsphere_virtual_machine.template.id}"
    }
}



