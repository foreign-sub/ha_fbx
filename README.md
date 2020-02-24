# ha_fbx

## Installation

* Download latest release from https://github.com/foreign-sub/ha_fbx/releases
* Extract image to /Freebox/VMs
* Setup VM

## Configuration

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
```
