aws signup

go to iam user, create group with permission:
create user assign user to group

## install packer
download packer binary for osx
unzip move to /usr/local/bin

## installl aws cli
``
brew install awscli
``

### build server images
``
packer validate server-template.json
packer build server-template.json
packer build \
    -var 'aws_access_key=YOUR ACCESS KEY' \
    -var 'aws_secret_key=YOUR SECRET KEY' \
    example.json
``
#### packer logging
``
export PACKER_LOG=1
export PACKER_LOG_PATH="packerlog.txt"
``

### deploy
terraform init
terraform plan
terraform apply
terraform apply -auto-approve


       

## freebsd
ami-0855baa38c3a1fc55

## Graph
brew install graphviz
dot -Tpng DocName.dot -o DocName.png
terraform graph | dot -Tpng > graph.png

## confd config
sudo mkdir -p /etc/confd/{conf.d,templates}


confd -onetime -backend=ssm --prefix /dev -node "https://ssm.ap-southeast-2.amazonaws.com"
confd -onetime -backend=ssm -node "https://ssm.ap-southeast-2.amazonaws.com"

export AWS_REGION="ap-southeast-2"

