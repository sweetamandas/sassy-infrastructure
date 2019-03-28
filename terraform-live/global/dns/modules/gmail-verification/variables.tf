variable "zone_id" {
  description = "Route 53 hosted zone id to apply records to"
}

variable "name" {
  description = "Name of record. Should match hosted zone domain"
}

variable "dkim_record" {
  description = "DKIM record provided by gmail"
  default     = ""
}
