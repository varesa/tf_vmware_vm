variable "name" {}
variable "template" {}

variable "hostname" {}
variable "network" {}
variable "address" {}
variable "gateway" {}

variable "role" {
    default = ""
}
variable "puppet_psk" {
    default = "none"
}

data "template_file" "network" {
    template = "${file("${path.module}/templates/network.tpl")}"

    vars {
        address = "${var.address}"
        gateway = "${var.gateway}"
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
        psk = "${var.puppet_psk}"
    }
}

data "template_file" "userdata" {
    template = "${file("${path.module}/templates/userdata.tpl")}"

    vars {
        role = "${var.role}"
        csr_attributes = "${data.template_file.csr_attributes.rendered}"
    }
}

data "vsphere_virtual_machine" "template" {
  name          = "Z_Templates/${var.template}"
  datacenter_id = "${data.vsphere_datacenter.tampere-dc.id}"
}

data "vsphere_network" "network" {
  name          = "${var.network}"
  datacenter_id = "${data.vsphere_datacenter.tampere-dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
    name             = "${var.name}"
    resource_pool_id = "${data.vsphere_compute_cluster.vsan-cluster.resource_pool_id}"
    datastore_id     = "${data.vsphere_datastore.vsan-datastore.id}"

    num_cpus = 2
    memory   = 1024
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



