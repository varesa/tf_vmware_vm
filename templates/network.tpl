version: 1
config:
  - type: physical
    name: ens192
    subnets:
      - type: static
        address: ${address}
        gateway: ${gateway}
        dns_nameservers:
          - 10.0.110.30
          - 10.60.10.30
        dns_search:
          - tre.esav.fi
          - esav.fi
