
 terraform plan -var="hostnames=[\"aap11emc6\", \"aap12emc6\"]" -var="memory=2048" -var="vcpus=2" -var="disk_size=40"

 terraform apply -var="hostnames=[\"aap11emc6\", \"aap12emc6\"]" -var="memory=2048" -var="vcpus=2" -var="disk_size=40"

 terraform destroy -var="hostnames=[\"aap11emc6\", \"aap12emc6\"]"


SINGLE NODE:

 terraform plan -var="hostnames=[\"aap11emc6\"]" -var="memory=2048" -var="vcpus=2" -var="disk_size=80"

 terraform plan -var="hostnames=[\"control\"]" -var="memory=2048" -var="vcpus=2"
 #terraform refresh

 ssh ec2-user@

#NOTE:
#If you want to resize:
# qemu-img create -f qcow2 -o backing_file=/var/lib/libvirt/images/amazon/al2023-kvm-2023.5.20240916.0-kernel-6.1-x86_64.xfs.gpt.qcow2 new-expanded-image.qcow2 40G


