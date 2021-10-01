# ha_fbx

*Home assistant VM image for Freebox Delta (arm64)*

## How it works

### Build

* Using github actions, a [debian cloud-image](http://cdimage.debian.org/images/cloud/) is pulled. (you can see which image was used in the release notes)
* The install scripts are placed in the `/root` folder, then the image is resized and published.
* The release process is fully automated.
* Note: HA versions reported in the release notes are the available versions at the time of the release.

### Setup

* The install script gather all the necessary components and install them for you on the first startup.
* Note: The script will always install the latest release from Home Assistant, so it may differ from the release notes.

## Installation

* Download the latest release asset `hafbx-debian-(version).zip` from [Releases](https://github.com/foreign-sub/ha_fbx/releases)
* Extract `hafbx-debian-(version).zip` to `/Freebox/VMs`
* Setup VM

  * [x] Sélectionner une image de disque virtuel existante
  * Pick the `hafbx-debian-(version).qcow2` file
  * Add the `VM Configuration` settings as below
* Launch the VM and wait around 20 mins for setup to complete

```text
Startup finished in 4.388s (kernel) + 19min 19.850s (userspace) = 19min 24.239s.
```

* Open <http://hafbx.local:8123/>

* You can also use SSH to access your VM using the username and password you've defined in the #cloud-config below, by default :

```bash
ssh ha@hafbx.local
```

* Enjoy !

## VM Configuration

> Cloud-init : [x]  
> Hostname : hafbx

### Basic setup

* This is the minimum configuration required, but you probably want to use the [Recommended configuration](#recommanded-configuration) below.

* cloud-init user-data :

```yaml
#cloud-config
system_info:
  default_user:
    name: ha
password: password
chpasswd: { expire: False }
ssh_pwauth: True
runcmd:
  - [ /root/init_ha.sh ]
```

#### Adding swap

* Because system RAM can be scarce, adding a swapfile helps avoiding OOM issues.
* To add a 2GB swapfile to your system, add the following commands to your '#cloud-config' configuration above.

```yaml
swap:
    filename: /swapfile
    size: 2147483648
```

#### Install HACS

* For your convenience, the script can also setup [HACS](https://hacs.xyz/) during the installation process.
* First please check the [prerequisites](https://hacs.xyz/docs/installation/prerequisites), if in doubt, do not proceed further.
  (You must have at least a github account to be able to use HACS)
* To setup HACS, replace the line below 'runcmd:' of the cloud config before you attempt to start the vm for the first time with the following, using the --with-hacs option :

```yaml
  - [ /root/init_ha.sh, --with-hacs ]
```

* Setup will be a bit longer but because of onboarding HA may appear to be ready while the init process is still ongoing.

```text
Startup finished in 4.697s (kernel) + 31min 46.696s (userspace) = 31min 51.394s.
```

* Once initial setup is complete, restart Home Assistant at least once, then you can finish HACS setup through the integrations panel.
* Please note that HACS addons also requires home assistant to restart or at least a browser refresh.
* Also remember to enable "Advanced mode" in your user profile (Click on your name in the bottom left of the HA UI), this will allow you to configure the Lovelace dashboard ressources through the UI (Configuration -> Lovelace -> Ressources).

### Recommended configuration

* cloud-init user-data :

```yaml
#cloud-config
system_info:
  default_user:
    name: ha
password: password
chpasswd: { expire: False }
ssh_pwauth: True
runcmd:
  - [ /root/init_ha.sh, --with-hacs ]
swap:
    filename: /swapfile
    size: 2147483648
```

### Resources

* [Cloud config examples](https://cloudinit.readthedocs.io/en/latest/topics/examples.html)

## Support

* Please understand that neither Home Assistant or HACS will provide any support regarding installation issues, if you encounter a bug during the setup process, please open a [ticket](https://github.com/foreign-sub/ha_fbx/issues) describing the issue.
* Init logs can be found in /var/log/cloud-init-output.log
* Home assistant configuration files : /usr/share/hassio/homeassistant/
