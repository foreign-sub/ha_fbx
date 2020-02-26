# ha_fbx

## Installation

* Download latest release from https://github.com/foreign-sub/ha_fbx/releases
* Extract hafbx-debian-(version).zip to /Freebox/VMs
* Setup VM
* Launch VM and wait for setup to complete
* http://hafbx.local:8123/

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
