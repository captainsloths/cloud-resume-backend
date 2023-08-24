provider "aws_s3_bucket"  "wwwzerocool-zone-clone" {
    bucket = "${var.bucket_name}"
    acl = "${var.acl_value}"

}