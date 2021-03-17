# Homelabby
Documentation and configuration-as-code for the little homelab I've been tinkering with.

# Terraform
```
$ terraform init
$ terraform apply
```

# Ansible
```
$ ansible-galaxy install -r roles_requirements.yml
$ ansible-galaxy collection install -r collections_requirements.yml
```

```
$ ansible-playbook -i inventory ansible.yml
```

```
$ ansible-playbook -i inventory --tags users ansible.yml
```
