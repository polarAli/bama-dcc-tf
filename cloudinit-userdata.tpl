
#cloud-config
users:
  - default
  - name: ${username}
    groups: sudo
    lock_passwd: false
    passwd: ${hashedPassword}
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
    - ${sshPublicKey}
