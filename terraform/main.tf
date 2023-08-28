//Define lamba function environment
resource "aws_lambda_function" "visitor-count" {
  filename         = data.archive_file.zip_python_file.output_path
  source_code_hash = data.archive_file.zip_python_file.output_base64sha256
  function_name    = "visitor-count"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "visitor-count.lambda_handler"
  runtime          = "python3.11"
}

//Define contact form lambda environment
resource "aws_lambda_function" "contact-form" {
  filename         = data.archive_file.contact_form_file.output_path
  source_code_hash = data.archive_file.contact_form_file.output_base64sha256
  function_name    = "contact-form"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "contact.lambda_handler"
  runtime          = "python3.11"
}

//Create IAM Role
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow"
      }
    ]
  })
}

//Create IAM policy for IAM role
resource "aws_iam_policy" "iam_policy_crc" {

  name        = "aws_iam_policy_for_terraform_crc_policy"
  path        = "/"
  description = "AWS IAM Policy for managing crc policy role"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "arn:aws:logs:*:*:*",
          "Effect" : "Allow"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:UpdateItem",
            "dynamodb:GetItem",
            "dynamodb:PutItem"
          ],
          "Resource" : "arn:aws:dynamodb:*:*:table/VisitorsTable"
        },
      ]
  })
}

// Create redirect bucket
resource "aws_s3_bucket" "redir_bucket" {
  provider = aws.aws-s3
  bucket   = "redir-bucket-crc"
  acl      = "private"

  tags = {
    Name = "Redirect CRC bucket"
  }
}

//Create primary bucket
resource "aws_s3_bucket" "primary_bucket" {
  provider = aws.aws-s3
  bucket   = "primary-bucket-crc"
  acl      = "private"

  tags = {
    Name = "Primary CRC bucket"
  }
}

//Attach policy to lambda IAM role
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_policy_crc.arn
}

//Create lambda artifact payload
data "archive_file" "zip_python_file" {
  type        = "zip"
  source_file = "${path.module}/lambda/visitor-count.py"
  output_path = "${path.module}/lambda/visitor-count.zip"
}

//Create contact form payload
data "archive_file" "contact_form_file" {
  type        = "zip"
  source_file = "${path.module}/lambda/contact.py"
  output_path = "${path.module}/lambda/contact.zip"
}

# //Create lambda function URL - Replace with API Gateway creation later
# resource "aws_lambda_function_url" "url1" {
#   function_name      = aws_lambda_function.visitor-count.function_name
#   authorization_type = "NONE"

#   cors {
#     allow_credentials = true
#     allow_origins     = ["*"]
#     allow_methods     = ["*"]
#     allow_headers     = ["date", "keep-alive"]
#     expose_headers    = ["keep-alive", "date"]
#     max_age           = 86400
#   }
# }
