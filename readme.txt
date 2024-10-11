

 terraform init
 terraform plan -var-file="hostnames.tfvars"
 terraform apply -var-file="hostnames.tfvars"


#LOOP
 terraform refresh -var-file="hostnames.tfvars"

 for host in $(terraform output -raw ALL_HOSTS); do
  ssh mdc@$host
done



