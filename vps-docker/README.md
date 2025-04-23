# Deploy python using a VPS and docker

Start my connection to your instance with ssh 
```bash
ssh -i /path/to/ssh/key root@<server_ip_address>
```

Once you've successfully connect to the instance, start by adding a service user

```bash
useradd service -r -U -G sudo -m -s bash
```
This command creates a user name 'service' and adds that user to the 'sudo' group and sets default 
shell for the user to 'bash'. Run `man useradd` for details. 


Now you need to update the sudoers group to allow passwordless sudo

```bash
sed -ri "s/%sudo.*ALL=\(ALL\:ALL\).*ALL/%sudo ALL=(ALL) NOPASSWD: ALL/g" /etc/sudoers
```

Then you should also update the ssh config to no rely on ssh key auth only since passwords can be cracked

```bash
sed -ri "s/PermitRootLogin yes/PermitRootLogin prohibit-password/g" /etc/ssh/sshd_config
```

Now restart the ssh service

```bash
service ssh restart
```

Make sure you're ssh authorized_keys file from whatever you logged in with first is copied to your service user .ssh/authorized_keys

```bash
mkdir -p /home/service/.ssh
touch /home/service/.ssh/authorized_keys
cat /root/.ssh/authorized_keys  >> /home/service/.ssh/authorized_keys
chown -R service: /home/service/.ssh
chmod 0700 /home/service/.ssh
chmod 0644 /home/service/.ssh/authorized_keys
```

Now you should be able to ssh in as your service user or just switch using the shell

```bash
sudo su service
```

To exit the `service` session use `exit` and you will be root again. 

Next you need to install docker. Here is how I recommend you do so

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

You can validate that docker is install but running `sudo docker run hello-world`

You now need to make sure there is a docker user group and add your service user to that group. This will allow your service user to initiate `docker compose` commands

```
sudo groupadd docker
sudo usermod -aG docker service
```

Now simply upload your project to a folder in your service user directory i.e. `/home/serives/app` 

From your local machine you can rsync this files using: 

```bash 
rsync -avzu ./your-app/ service@<server_ip_address>:app/
```

Then back on the server make sure all those files are owned by the service user: 

```bash
cd /home/service/app
sudo chown -R service: .
find . -type f -exec chmod 0755 {} \;
```

Now create a docker-compose.yaml that looks something like:

```yaml
services:
  python:
    build: .
    ports:
      - 8080:8080

  nginx:
    depends_on:
      - python
    image: valian/docker-nginx-auto-ssl
    restart: on-failure
    ports:
      - 80:80
      - 443:443
    volumes:
      - ssl_data:/etc/resty-auto-ssl
    environment:
      ALLOWED_DOMAINS: "example.com"
      SITES: "example.com=python:8080"

volumes:
  ssl_data:
```

Run `docker compose up --build -d` to run your service as a system daemon. 

For the ssl to properly provision the domain `example.com` should be replaced with your hostname and that host should be pointed at the IP address for your server. 
