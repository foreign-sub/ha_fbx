# ha_fbx

## Installation

* Download latest release from https://github.com/foreign-sub/ha_fbx/releases
* Extract hafbx-debian-(version).zip to /Freebox/VMs
* Setup VM
* Launch VM and wait around 15 mins for setup to complete
* Open http://hafbx.local:8123/

## VM Configuration

- Cloud-init : [x]
- Hostname : hafbx
- cloud-init user-data :
```
#cloud-config
system_info:
  default_user:
    name: ha
password: password
chpasswd: { expire: False }
ssh_pwauth: True
runcmd:
  - [ chmod, +x, /root/init_ha.sh ]
  - [ /root/init_ha.sh ]
```
