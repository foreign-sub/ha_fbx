# ha_fbx

*Home assistant VM image for Freebox Delta (arm64)*

## How it works

### Build

* Using github actions, a [debian cloud-image](http://cdimage.debian.org/images/cloud/) is pulled and seeded. (you can see which image was used in the release notes)
* The release process is fully automated.

### Setup

* The install script gather all the necessary components and install them for you on the first startup.

## Installation

* Download the latest [release](https://glare.now.sh/foreign-sub/ha_fbx/hafbx
)
* Extract `hafbx-debian-(version).zip` to `/Freebox/VMs`
* Setup VM
  * [x] Sélectionner une image de disque virtuel existante
  * Pick the `hafbx-debian-(version).qcow2` file

* Launch the VM and wait around 20 mins for setup to complete
* Default setup

  * Hostname : hafbx
  * Username: ha
  * Password: password
  * 2GB swap space
  * Hacs

```text
Startup finished in 4.828s (kernel) + 20min 43.396s (userspace) = 20min 48.224s.
```

* Once the setup process is finished the vm will reboot once

* Open <http://hafbx.local:8123/>

* You can also use SSH to access your VM using the default username and password :

```bash
ssh ha@hafbx.local
```

* Enjoy !

## Advanced VM Configuration

  * While the default setup should work for most users, you can also choose to make your own custom setup
  * Add the `VM Configuration` settings as below

> Cloud-init : [x]  
> Hostname : mycustomhahostname # (or hafbx)

* Edit and paste the content from [no-cloud/user-data](https://raw.githubusercontent.com/foreign-sub/ha_fbx/master/nocloud-net/user-data) in the cloud-init user-data field

### Resources

* [Cloud config examples](https://cloudinit.readthedocs.io/en/latest/topics/examples.html)

## Notes
* HA versions reported in the release notes are the available versions at the time of the release.
* The script will always install the latest release from Home Assistant, so it may differ from the release notes.
* HACS addons usually requires home assistant to restart or at least a browser refresh.
* Remember to enable "Advanced mode" in your user profile (Click on your name in the bottom left of the HA UI), this will allow you to configure the Lovelace dashboard ressources through the UI (Configuration -> Lovelace -> Ressources).

## Support

* Please understand that neither Home Assistant or HACS will provide any support regarding installation issues, if you encounter a bug during the setup process, please open a [ticket](https://github.com/foreign-sub/ha_fbx/issues) describing the issue.
* Init logs can be found in /var/log/cloud-init-output.log
* Home assistant configuration files : /usr/share/hassio/homeassistant/
