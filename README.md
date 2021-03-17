# Homelabby
Documentation and configuration-as-code for the little homelab I've been tinkering with.

# Terraform and Ansible
Terraform and Ansible are probably overkill for this project, but they're commonly used tools and they more or less match my use case 🤷.

## Installation and Setup
```
$ virtualenv -p /usr/bin/python3 venv
$ source venv/bin/activate
$ pip install -r requirements.txt
```

Installing Terraform is generally just downloading a binary

Copy the `./terraform/terraform.tfvars.example` file to `./terraform/terraform.tfvars` and put in your `do_token` and `ssh_fingerprint`

## Terraform
Terraform in particular is way overkill for this project. I'm currently using it to spin up a single droplet 🙃.

It's also surprisingly difficult to interface with ansible, so for the moment, I've got a bit of a hacky solution to that.

After installation:
```
$ cd terraform
$ terraform init
$ terraform apply
```

## Ansible
You must have a public key for root access to the DO droplet at `~/.ssh/id_rsa_ec.pub`

To install the requisite roles and collections:
```
$ cd ansible
$ ansible-galaxy install -r roles_requirements.yml
$ ansible-galaxy collection install -r collections_requirements.yml
```

To run all tasks in the main.yml playbook
```
$ ansible-playbook -i inventory main.yml
```

```
$ ansible-playbook -i inventory --tags users main.yml
```

### Wireguard
Ansible will currently setup a wireguard server on the DO droplet and add a wireguard client configuration to the local machine at `~/wg0.conf`.

To bring that wireguard connection up you can then:
```
$ sudo wg-quick up ~/wg0.conf
```
