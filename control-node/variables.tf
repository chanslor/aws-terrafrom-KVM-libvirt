variable "hostnames" {
  description = "List of hostnames to create"
  type        = list(string)
}


variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "memory" {
  description = "Memory size in MB"
  type        = number
  default     = 2048
}

variable "vcpus" {
  description = "Number of vCPUs"
  type        = number
  default     = 2
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}

