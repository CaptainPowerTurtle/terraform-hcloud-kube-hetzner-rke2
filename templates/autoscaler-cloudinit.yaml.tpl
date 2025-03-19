#cloud-config

debug: True

write_files:

${cloudinit_write_files_common}

- content: ${base64encode(rke2_config)}
  encoding: base64
  path: /tmp/config.yaml

- content: ${base64encode(install_rke2_agent_script)}
  encoding: base64
  path: /var/pre_install/install-rke2-agent.sh

# Add ssh authorized keys
ssh_authorized_keys:
%{ for key in sshAuthorizedKeys ~}
  - ${key}
%{ endfor ~}

# Resize /var, not /, as that's the last partition in MicroOS image.
growpart:
    devices: ["/var"]

# Make sure the hostname is set correctly
hostname: ${hostname}
preserve_hostname: true

runcmd:

${cloudinit_runcmd_common}

# Start the install-rke2-agent service
- ['/bin/bash', '/var/pre_install/install-rke2-agent.sh']
