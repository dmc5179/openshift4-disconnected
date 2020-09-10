
## Customize the env.sh.example file for your environment:

```bash
cp env.sh.example env.sh
```

## Customize the install-config.yaml for your environment:

```bash
cp install-config.yaml.example install-config.yaml
```
Change the values of the following inside install-config.yaml for your environemt:
* baseDomain
* metadata.name
* pullSecret

## Download the `filetranspile` python script:

```bash
wget https://raw.githubusercontent.com/ashcrow/filetranspiler/master/filetranspile -O /usr/local/bin/filetranspile && chmod a+x /usr/local/bin/filetranspile 
```
## Install the python-magic and python-yaml dependencies for transpile:
```bash
dnf install -y python3-yaml python3-magic
```

## Ensure the following are located in `/usr/local/bin`:  
* kubectl
* openshift-install
* aws

## Then, run Scripts in this order:
* aws/create_sg.sh
* aws/create_infra.sh
* route53.sh #optional
* create_ignition.sh  
* stage_ignition.sh  # Optional, this assumes httpd is running locally and is accessible to the nodes
* install.sh
* post_install.sh  

