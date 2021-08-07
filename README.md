# packer-ubuntu_focal-parallels
Packer manifest for building ubuntu 20.04 pvm-image for Parallels.

## Ubuntu autoinstall with Cloud-init
Cloud-init options for autoinstall can be changed in *./http/user-data*.
Empty file for metada must be present at *./http/meta-data*.

## Postinstall operations with Ansible
Postinstall tasks can be configured inside *./postinstall.yaml* playbook.

## Resulting artifact
Resulting PVM image for paralles will be created inside *./output-ubuntu_focal* directory.

## Building PVM with Hashicorp Packer
```
packer init .
packer fmt .
packer build .
```