* Define your project name and set it as a variable
```
$ export project_name=<YOUR PROJECT NAME>
```
* Define your owncloud admin's password
```
$ export owncloud_admin_pass=<A STRONG PASSWORD>
```
* Set your repository URL and branch
```
$ export repository='https://github.com/andreyev/tf-puppet.git'
$ export branch=master
```
* Clone this repository
```
$ git clone ${repository} .
$ git checkout ${branch}
```
* Create a SSH key pair to this project (without a passphase for your convenience)
```
$ echo -e "\n" | ssh-keygen -N "" -f ~/.ssh/tf-puppet_${project_name}
```
* Install Terraform binary from https://www.terraform.io/downloads.html
* Initialiaze terraform
```
$ terraform init
```
* To use AWS create a credential on console (https://console.aws.amazon.com/iam/home) and add it to your ~/.aws/credentials
```
$ cat << EOF > ~/.aws/credentials-${project_name}
[default]
aws_access_key_id=<YOUR ACCESS KEY>
aws_secret_access_key=<YOUR SECRET KEY>
EOF
```
* To use Azure run `az login` and follow the instructions.
* Choose your provider (`aws` or `azure`):
```
$ export provider=<YOUR PROVIDER>
```
* Deploy your project
```
$ terraform apply -var "public_key_path=~/.ssh/tf-puppet_${project_name}.pub" -var "private_key_path=~/.ssh/tf-puppet_${project_name}"  -var "project_name=${project_name}" -var "repository=${repository}" -var "branch=${branch}" -var "owncloud_admin_pass=${owncloud_admin_pass}" ${provider}
```
* It's done! Get your credentials and URL with:
```
$ terraform output ready
```
* When done, destroy everything:
```
$ terraform destroy -force -var "public_key_path=~/.ssh/tf-puppet_${project_name}.pub" -var "private_key_path=~/.ssh/tf-puppet_${project_name}"  -var "project_name=${project_name}" -var "repository=${repository}" -var "branch=${branch}" -var "owncloud_admin_pass=${owncloud_admin_pass}" ${provider}
```
