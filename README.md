At a glance, create a simple/single VM on AWS or Azure and use Puppet to deploy some Docker containers to provide OwnCloud server.

* Define your project name and set it as a variable:
```
$ export project_name=<YOUR PROJECT NAME>
```
* Define your owncloud admin's password:
```
$ export owncloud_admin_pass=<A STRONG PASSWORD>
```
* Set your repository URL and branch:
```
$ export repository='https://github.com/andreyev/dt.git'
$ export branch=master
```
* Clone this repository:
```
$ mkdir ${project_name}
$ cd $_
$ git clone ${repository} .
$ git checkout ${branch}
```
* Create a SSH key pair to this project (without a passphase for your convenience):
```
$ echo -e "\n" | ssh-keygen -N "" -f ~/.ssh/tf-puppet_${project_name}
```
* Install Terraform binary from https://www.terraform.io/downloads.html
* Choose your provider (`aws` or `azure`):
```
$ export provider=<YOUR PROVIDER>
```
* Initialiaze terraform to install provider modules:
```
$ terraform init
```
* To use AWS create a credential on console (https://console.aws.amazon.com/iam/home) and add it to your ~/.aws/credentials:
```
$ cat << EOF > ~/.aws/credentials-${project_name}
[default]
aws_access_key_id=<YOUR ACCESS KEY>
aws_secret_access_key=<YOUR SECRET KEY>
EOF
```
* To use Azure run `az login` and follow the instructions (you must have Azure CLI previously installed).
```
* Deploy your project:
```
$ terraform apply -var "public_key_path=~/.ssh/tf-puppet_${project_name}.pub" -var "private_key_path=~/.ssh/tf-puppet_${project_name}"  -var "project_name=${project_name}" -var "repository=${repository}" -var "branch=${branch}" -var "owncloud_admin_pass=${owncloud_admin_pass}" ${provider}
```
* It's ready! Get your credentials and URL with:
```
$ terraform output ready
```
* When done, destroy everything:
```
$ terraform destroy -force -var "public_key_path=~/.ssh/tf-puppet_${project_name}.pub" -var "private_key_path=~/.ssh/tf-puppet_${project_name}"  -var "project_name=${project_name}" -var "repository=${repository}" -var "branch=${branch}" -var "owncloud_admin_pass=${owncloud_admin_pass}" ${provider}
```
