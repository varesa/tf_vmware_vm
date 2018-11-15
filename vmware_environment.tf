data "vsphere_datacenter" "tampere-dc" {
  name = "Tampere"
}

data "vsphere_datastore" "vsan-datastore" {
  name          = "vsanDatastore"
  datacenter_id = "${data.vsphere_datacenter.tampere-dc.id}"
}

data "vsphere_compute_cluster" "vsan-cluster" {
  name          = "vsan"
  datacenter_id = "${data.vsphere_datacenter.tampere-dc.id}"
}
