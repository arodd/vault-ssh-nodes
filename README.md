# For Vault
```
export VAULT_ADDR=http://aworkman-c5e15f07-vault-elb-342595625.us-east-2.elb.amazonaws.com:8200
export VAULT_TOKEN=<super-user/root token>
vault secrets enable ssh
vault write ssh/roles/app key_type=otp default_user=centos cidr_list=0.0.0.0/0
```

# On App instance
```
sudo setenforce Permissive
wget https://releases.hashicorp.com/vault-ssh-helper/0.1.4/vault-ssh-helper_0.1.4_linux_amd64.zip
unzip vault-ssh-helper_0.1.4_linux_amd64.zip
sudo mv vault-ssh-helper /usr/bin/vault-ssh-helper
sudo chcon -t xdm_t /usr/bin/vault-ssh-helper
sudo chmod +x /usr/bin/vault-ssh-helper
sudo mkdir /etc/vault-ssh.d

cat << EOF > /etc/vault-ssh.d/config.hcl
vault_addr = "http://aworkman-c5e15f07-vault-elb-342595625.us-east-2.elb.amazonaws.com:8200"
ssh_mount_point = "ssh"
tls_skip_verify = true
allowed_roles = "app"

# This could be set to the bastion host ip/CIDR
allowed_cidr_list = "0.0.0.0/0" 
EOF

#CentOS 7(had to remove the auth substack password-auth line)

cat << EOF > /etc/pam.d/sshd
#%PAM-1.0
#

#Vault Specific
auth requisite pam_exec.so quiet expose_authtok log=/tmp/vaultssh.log /usr/bin/vault-ssh-helper -config=/etc/vault-ssh.d/config.hcl -dev
auth optional pam_unix.so not_set_pass use_first_pass nodelay

auth       required     pam_sepermit.so
auth       include      postlogin
# Used with polkit to reauthorize users in remote sessions
-auth      optional     pam_reauthorize.so prepare
account    required     pam_nologin.so
account    include      password-auth
password   include      password-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open env_params
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    include      password-auth
session    include      postlogin
# Used with polkit to reauthorize users in remote sessions
-session   optional     pam_reauthorize.so prepare
EOF
```
## Need to adjust to sed replacements below

Inside /etc/ssh/sshd_config
Set...

```
ChallengeResponseAuthentication yes # this was the only change needed in CentOS 7
UsePam yes
PasswordAuthentication no
```

`sudo systemctl restart sshd`