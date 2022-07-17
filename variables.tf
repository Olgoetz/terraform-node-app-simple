variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "Region to be used"
}

variable "default_tags" {
  type        = map(any)
  default     = {}
  description = "Default tags to apply to all taggable resources"
}
