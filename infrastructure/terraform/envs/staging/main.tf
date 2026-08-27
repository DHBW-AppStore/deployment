# Module is used to define things in one place
# and achieve DRY
module "vm" {
  source = "../../modules/openstack_vm"

  name       = "staging-dhbw-appstore"
  image      = "Ubuntu 22.04"
  flavor     = "gp1.large"
  public_key = var.ssh_public_key

  # IPv6 works here only because the certificate is obtained over dns-01.
  # The CA cannot reach this host inbound: its own endpoint has no AAAA record,
  # and both inbound challenge types failed against DHBWV6:
  #
  #   http-01      "Could not fetch URL: http://.../.well-known/acme-challenge/..."
  #   tls-alpn-01  "Unable to retrieve server certificate for ..."
  #
  # dns-01 needs no inbound connection at all: Caddy writes a TXT record over
  # RFC 2136 and the CA reads it from DNS. See caddy/Caddyfile.
  #
  # Reachability itself was never the issue - a host outside the DHBW network
  # reached this VM over IPv6 on both 80 and 443.
  network_name = "DHBWV6"
  connect_via  = "fixed_ipv6"

  # Second interface so clients without IPv6 can reach the app. Ansible connects
  # over IPv6 as before; only the A record is new.
  secondary_network_name = "DHBWv4"

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

# The address the A record for APP_HOSTNAME points at.
output "vm_ipv4" {
  value = module.vm.secondary_ipv4
}

# Consumed by the Ansible step that writes the netplan config.
output "vm_ipv4_gateway" {
  value = module.vm.secondary_gateway_ipv4
}

output "vm_ipv4_mac" {
  value = module.vm.secondary_mac
}
