output "vm_ip" {
  description = "Address used to reach the VM, selected by connect_via."
  value = (
    var.connect_via == "floating_ipv4" ? openstack_networking_floatingip_v2.fip[0].address :
    var.connect_via == "fixed_ipv6" ? openstack_compute_instance_v2.vm.network[0].fixed_ip_v6 :
    openstack_compute_instance_v2.vm.network[0].fixed_ip_v4
  )
}

output "vm_name" {
  value = openstack_compute_instance_v2.vm.name
}

output "key_pair_name" {
  value = openstack_compute_keypair_v2.deploy.name
}