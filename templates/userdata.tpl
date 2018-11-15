#cloud-config
write_files:
- encoding: b64
  content: ${base64encode("role=${role}\n")}
  path: /etc/puppetlabs/facter/facts.d/role.txt
- encoding: b64
  content: ${base64encode("${csr_attributes}")}
  path: /etc/puppetlabs/puppet/csr_attributes.yaml

runcmd:
- [ '/bin/systemctl', 'start', 'puppet' ]

users:
- name: test
  ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDi/o0Bu493Kz5wy7Z8pgoA0SY5X2pnu9lIkASd07r+ForgAkmrhn2rk/5vGpmL6L1EJu7MTlilPpuIpn34fvVdckm6y5JJm6IItDeq1p5VHIj33jdK5NCUB40NPQdaxfvKQAWIYav8jfYaeGAjroMGDUMZlsHwoB5nOmfy05l3DcSqvtSs2nn2lZNXn3kHQXLGBeHtoniFnGomGgg6/MAj1oT46xLncyEhlqjoAPqMg2mCC4KkuGSmTKyjBHeFzpeJOIo3bJDHv3RuShpVGMW6+OfFK783FIiIacMazErgakSOXZnXQzqNXV7wg4cenTL7MTiabfRjDMWgmogU9clV esa@desktop.tre.esav.fi
  groups: wheel

