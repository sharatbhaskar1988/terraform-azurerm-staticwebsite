variable "location" {
  description = "The Azure Region in which all resources groups should be created."
  type        = string
}

variable "virtual_network" {
  description = "The virtual network"
  type        = string
  
}
variable "myrg" {
  description = "The name of the resource group"
  type        = string
}

variable "address_space" {
  description = "network address space"
  type        = list(string)
}

variable "address_prefixes" {
  description = "network address space"
  type        = list(string)
}

variable "security_rule_ports" {

  description = "security rules"
  type        = list(string)
  
}

variable "countnum" {

  description = "count variable"
  type        = number
  
}