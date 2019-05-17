# my fork of packer-windoze

This repo is a fork that tries to do the following that the original doesn't do:

- run ansible in docker for Windows because trying to get it running in Cygwin is a PITA
- separate the following stages of the pipeline so that if something happens, you don't have to start from scratch:
  - generating packer configuration (this is already separate in the original repo)
  - initial setup of running packer to install Windows and creating a base box
  - Using ansible to configure Windows to customise the base box
- no more sysprep

There are some steps that you have to do manually, unfortunately:

- packer somehow fails to shutdown VM gracefully so you have to be the one to press the button.
- you have to manually package the resulting VM after customisation using `vagrant package`
- you have to manually fix the ip address in the generated hosts.ini

Here's an walkthrough of what I did to create [this box](https://app.vagrantup.com/zhansongl/boxes/2019):

```
# generate packer configuration
docker-compose run --rm ansible ansible-playbook packer-setup.yml \
   -e opt_packer_setup_builder=hyperv -e opt_packer_setup_box_tag=zhansongl/2019-base \
   -e man_packer_setup_host_type=2019 -e opt_packer_setup_hyperv_switch=external \
   -e man_personalize_choco_packages="'["notepadplusplus.install", "7zip.install"]'" -vv

# run packer to create the base box
sudo packer build -force 2019/packer.json
cd 2019
sudo vagrant box add hyperv.box --name=zhansongl/2019-base

# start the base box
copy vagrantfile.template vagrant
sudo vagrant up

# manually fix the ip address in 2019/hosts.ini

# provisioning
docker-compose run --rm ansible ansible-playbook main.yml -i 2019/hosts.ini -e opt_packer_install_updates=true -vv

# manually install all packages if chocolatey fails

# make sure the box is pingable using ping
ping <box-ip-address>

# make sure the box is pingable with ansible
docker-compose run --rm ansible ansible -m win_ping packer-host -i 2019/hosts.ini

# make sure RPD works

# repackage
sudo vagrant package

# upload the resulting package.box to app.vagrantup.com
```

