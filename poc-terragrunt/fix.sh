#!/bin/bash

find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
find . -type f -name ".terraform.locl.hcl" -prune -exec rm -rf {} \;

terraform fmt -recursive
terragrunt hclfmt