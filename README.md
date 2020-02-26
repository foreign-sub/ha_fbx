# ha_fbx

## Installation

* Download latest release from https://github.com/foreign-sub/ha_fbx/releases
* Extract image to /Freebox/VMs
* Setup VM
* Launch VM and wait for setup to complete

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
  - [ chmod, +x, /root/init_ha.sh ]
  - [ /root/init_ha.sh ]
```
