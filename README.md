# ha_fbx
*Home assistant VM image for Freebox Delta (arm64)*

## How it works

### Build

* Using github actions, a debian cloud-image is pulled (you can see which image was used in the release notes)
* The install scripts are placed in the `/root` folder, then the image is resized and published
* The release process is fully automated
* Note: HA versions reported in the release notes are the available versions at the time of the release

### Install

* The install script gather all the necessary components and install them for you on the first startup
* Note: The script will always install the latest release from Home Assistant, so it may differ from the release notes.

## Installation

* Download latest release asset `hafbx-debian-(version).zip` from [Releases](https://github.com/foreign-sub/ha_fbx/releases)
* Extract `hafbx-debian-(version).zip` to `/Freebox/VMs`
* Setup VM
  * [x] Sélectionner une image de disque virtuel existante
  * Pick the `hafbx-debian-(version).qcow2` file
  * Add the `VM Configuration` settings as below

* Launch VM and wait around 15 mins for setup to complete
* Open http://hafbx.local:8123/
* Enjoy

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
