variable aws_region {
	default = "us-east-1"
}

variable www_domain_name {
    default = "www.kylecrawshaw.com"
}

variable "root_domain_name" {
    default = "kylecrawshaw.com"
}


variable bucket_name {
	description = "name of the bucket that will use as origin for CDN"
	default = "kylecrawshaw.com"
}

variable retain_on_delete {
	description = "Instruct CloudFront to simply disable the distribution instead of delete"
	default = false
}

variable price_class {
	description = "Price classes provide you an option to lower the prices you pay to deliver content out of Amazon CloudFront"
	default = "PriceClass_All"
}

variable domain_name {
  description = "Name of the domain where record(s) need to create"
  default = "kylecrawshaw.com"
}

variable route53_record_name {
	description = "Name of the record that you want to create for CDN"
	default = "cdn"
}

variable alias_zone_id {
	description = "Fixed hardcoded constant zone_id that is used for all CloudFront distributions"
	default = "Z2FDTNDATAQYW2"
}
