

 terraform init
 terraform plan -var-file="hostnames.tfvars"
 terraform apply -var-file="hostnames.tfvars" -auto-approve


#LOOP
 terraform refresh -var-file="hostnames.tfvars"

 for host in $(terraform output -raw ALL_HOSTS); do
  ssh mdc@$host
done

for i in $ALL_HOSTS; do ssh -q $i "uptime"; done

virsh list --all

terraform destroy -var-file="hostnames.tfvars" -auto-approve




