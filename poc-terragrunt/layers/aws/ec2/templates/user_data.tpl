#!/bin/bash -xe
echo "EC2 - ${ec2_name}"
USERNAME="ec2-user"

echo "Installing CloudWatch Agent"
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/
cat <<CLOUDWATCH_LOGS >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/cloud-init.log",
            "log_group_name": "/${project_name}/${ec2_name}/cloud-init.log"
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "/${project_name}/${ec2_name}/cloud-init-output.log"
          }
        ]
      }
    }
  }
}
CLOUDWATCH_LOGS
cd /tmp
yum install -y https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
systemctl enable amazon-cloudwatch-agent
systemctl restart amazon-cloudwatch-agent

yum install -y unzip jq tmux htop

echo "Installing pip"
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py
python get-pip.py
rm -f get-pip.py

pip uninstall awscli -y

echo "Installing Git"
yum -y install git
pip install git-remote-codecommit

echo "Installing Terraform"
curl "https://releases.hashicorp.com/terraform/${stack.terraform}/terraform_${stack.terraform}_linux_amd64.zip" -o "terraform_linux_amd64.zip"
unzip -q ./terraform_linux_amd64.zip -d /usr/bin
rm -f ./terraform_linux_amd64.zip

echo "Installing Terragrunt"
curl "https://github.com/gruntwork-io/terragrunt/releases/download/v${stack.terragrunt}/terragrunt_linux_amd64" -Lo "/usr/bin/terragrunt"
chmod +x /usr/bin/terragrunt

echo "Installing MySQL Client"
sudo rpm --import ${mysql_gpg_key_url}
sudo yum install -y ${mysql_url}
sudo yum install -y mysql-community-client

echo "Installing AWS CLI v2"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install -i /usr/aws-cli -b /usr/bin --update
rm -f awscliv2.zip

echo "Checking versions"
aws --version
terraform --version
terragrunt --version

mv /root/.aws /home/$USERNAME/
chown $USERNAME: -R /home/$USERNAME/.aws

echo "Setting hostname"
hostnamectl set-hostname "${ec2_name}"

echo "Provisioning Complete"
