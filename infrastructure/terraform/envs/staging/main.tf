# Module is used to define things in one place
# and achieve DRY
module "vm" {
  source = "../../modules/openstack_vm"

  name       = "staging-dhbw-appstore"
  image      = "Ubuntu 22.04"
  flavor     = "gp1.large"
  public_key = var.ssh_public_key

  network_name = "DHBWV6"
  connect_via  = "fixed_ipv6"

  # Referencing the resource rather than a bare name gives Terraform the
  # dependency, so the group and its rules exist before the instance is built.
  security_groups = ["default", openstack_networking_secgroup_v2.appstore_vm.name]

  docker_data_volume_size_gb = 0

  metadata = {
    env  = "staging"
    role = "docker"
  }
}

output "vm_ip" {
  value = module.vm.vm_ip
}
