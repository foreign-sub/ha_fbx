# ha_fbx

## Installation

* Download latest release from https://github.com/foreign-sub/ha_fbx/releases
* Extract image to /Freebox/VMs
* Setup VM

## VM Configuration

- Cloud-init : [x]
- Hostname : hafbx
- cloud-init user-data :
```
#cloud-config
system_info:
  default_user:
    name: ha
password: pass
chpasswd: { expire: False }
ssh_pwauth: True
runcmd:
  - [ chmod, +x, /usr/bin/init_ha.sh ]
  - [ /usr/bin/init_ha.sh ]
```
