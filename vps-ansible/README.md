# Ansible Example

This is an example of using ansible to manage your server. To use

Update the values in `hosts` to match your server

Update the values in `vars/default.yaml` to match your service needs

Then run: 

To setup the server
```
ansible-playbook -i ./hosts setup.yaml -e "servers=dev" -e "env=dev" -v
```
To deploy your app
```
ansible-playbook -i ./hosts setup.yaml -e "servers=dev" -e "env=dev" -v
```
