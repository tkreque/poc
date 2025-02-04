# HOW TO USE

## Versions

```
terraform
 *1.10.5 (Due to the MAC)
  1.5.7 (It works as well)
terragrunt
 *0.72.6
```

## Commands

From the root folder:

```
terragrunt run-all <plan|apply|destroy> --terragrunt-working-dir="./live/dev/" 
terragrunt run-all <plan|apply|destroy> --terragrunt-working-dir="./live/dev/aws"
terragrunt run-all <plan|apply|destroy> --terragrunt-working-dir="./live/dev" --terragrunt-exclude-dir="**/db/**"
terragrunt run-all <plan|apply|destroy> --terragrunt-working-dir="./live/" --terragrunt-exclude-dir="**/db/**"

terragrunt <plan|apply|destroy> --terragrunt-working-dir="./live/dev/ec2"
```

From the exact folder

```
cd live/dev/aws/vpc
terragrunt <plan|apply|destroy>

cd live/dev
terragrunt run-all <plan|apply|destroy>
terragrunt run-all <plan|apply|destroy> --terragrunt-exclude-dir="**/db/**"

cd live
terragrunt run-all <plan|apply|destroy>
terragrunt run-all <plan|apply|destroy> --terragrunt-exclude-dir="**/db/**"
terragrunt run-all <plan|apply|destroy> --terragrunt-exclude-dir="**/db/**" --terragrunt-exclude-dir="/test/**"
```

To format the `.tf` and `.hcl` files

```
terraform fmt -recursive
terragrunt hclfmt
```

To clean the init, cache and locks

```
find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
find . -type f -name ".terraform.locl.hcl" -prune -exec rm -rf {} \;
```

There is a helper created for that at the root folder

```
chmod +x ./fix.sh
./fix.sh
```