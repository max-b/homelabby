variable "do_token" {
}

variable "ssh_fingerprint" {
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "personal-droplet-1" {
  image    = "ubuntu-20-04-x64"
  name     = "personal-droplet-1"
  region   = "sfo3"
  size     = "s-1vcpu-1gb"
  ssh_keys = [var.ssh_fingerprint]
}


# create an ansible inventory file
resource "null_resource" "ansible-provision" {
  depends_on = [
    digitalocean_droplet.personal-droplet-1,
  ]

  # NOTE if additional droplets are added this needs to change
  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.personal-droplet-1.name} ansible_host=${digitalocean_droplet.personal-droplet-1.ipv4_address} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3' > ../ansible/inventory"
  }
}

# output the load balancer ip
output "droplet-ip" {
  value = digitalocean_droplet.personal-droplet-1.ipv4_address
}

