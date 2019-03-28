variable "name" {
  description = "Name of hosted zone. Should be domain name."
}

variable "dkim_record" {
  description = "DKIM record provided by gmail. Optional"
  default     = ""
}
