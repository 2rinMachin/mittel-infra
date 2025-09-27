provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "main_vpc" {
  id = var.vpc_id
}

data "aws_subnet" "subnet_a" {
  id = var.subnet_a_id
}

data "aws_subnet" "subnet_b" {
  id = var.subnet_b_id
}


locals {
  ecr_repos = [
    "users",
    "articles",
    "engagement",
    "discovery",
    "analyst",
    "ingesta-1",
    "ingesta-2",
    "ingesta-3"
  ]
}

resource "aws_ecr_repository" "repos" {
  for_each = toset(local.ecr_repos)
  name     = "mittel/${each.key}"
}

resource "aws_security_group" "alb_sg" {
  name        = "mittel-alb-sg"
  description = "Security groups for the Mittel ALB"

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "prod_sg" {
  name        = "mittel-prod-sg"
  description = "Security groups for the Mittel Prod VMs"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Users"
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "Articles"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "Engagement"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_sg" {
  name        = "mittel-db-sg"
  description = "Security groups for the Mittel DB VM"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "PostgreSQL"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.prod_sg.id, aws_security_group.ingesta_sg.id]
  }

  ingress {
    description     = "MySQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.prod_sg.id, aws_security_group.ingesta_sg.id]
  }

  ingress {
    description     = "MongoDB"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.prod_sg.id, aws_security_group.ingesta_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingesta_sg" {
  name        = "mittel-ingesta-sg"
  description = "Security groups for the Mittel Ingesta VM"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "vm_prod_1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = var.ec2_key_name
  subnet_id              = data.aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.prod_sg.id]

  tags = {
    Name = "Mittel Prod 1 VM"
  }
}

resource "aws_instance" "vm_prod_2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = var.ec2_key_name
  subnet_id              = data.aws_subnet.subnet_b.id
  vpc_security_group_ids = [aws_security_group.prod_sg.id]

  tags = {
    Name = "Mittel Prod 2 VM"
  }
}

resource "aws_instance" "vm_dbs" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  key_name               = var.ec2_key_name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  root_block_device {
    volume_size           = 40
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "Mittel Databases VM"
  }
}

resource "aws_instance" "vm_ingesta" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = var.ec2_key_name
  vpc_security_group_ids = [aws_security_group.ingesta_sg.id]

  tags = {
    Name = "Mittel Ingesta VM"
  }
}

resource "aws_acm_certificate" "main" {
  domain_name       = "*.${var.domain}"
  validation_method = "DNS"
}

data "aws_route53_zone" "main" {
  name         = var.domain
  private_zone = false
}

resource "aws_route53_record" "main" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.main : record.fqdn]
}

resource "aws_lb" "prod_alb" {
  name               = "mittel-prod-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [data.aws_subnet.subnet_a.id, data.aws_subnet.subnet_b.id]
}

locals {
  microservices = {
    "mittel-users"      = 4000
    "mittel-articles"   = 3000
    "mittel-engagement" = 8080
  }
}

resource "aws_lb_target_group" "prod_tgs" {
  for_each = local.microservices

  name     = "mittel-prod-${each.key}-tg"
  port     = tonumber(each.value)
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "prod_https_listener" {
  load_balancer_arn = aws_lb.prod_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.main.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_target_group_attachment" "prod_attachments_1" {
  for_each = local.microservices

  target_group_arn = aws_lb_target_group.prod_tgs[each.key].arn
  target_id        = aws_instance.vm_prod_1.id
  port             = each.value
}

resource "aws_lb_target_group_attachment" "prod_attachments_2" {
  for_each = local.microservices

  target_group_arn = aws_lb_target_group.prod_tgs[each.key].arn
  target_id        = aws_instance.vm_prod_2.id
  port             = each.value
}

resource "aws_lb_listener_rule" "prod_rules" {
  for_each = local.microservices

  listener_arn = aws_lb_listener.prod_https_listener.arn
  priority     = 10 + index(keys(local.microservices), each.key)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_tgs[each.key].arn
  }

  condition {
    host_header {
      values = ["${each.key}.${var.domain}"]
    }
  }
}

resource "aws_s3_bucket" "data_analysis_bucket" {
  bucket = var.data_analysis_bucket_name

  tags = {
    name = "Data Analysis Bucket"
  }
}

resource "aws_glue_catalog_database" "data_analysis_database" {
  name = "data-analysis-database"
}

resource "aws_glue_catalog_table" "aws_glue_catalog_table" {
  name          = "engagement_events"
  database_name = aws_glue_catalog_database.data_analysis_database.name

  storage_descriptor {
    location = "s3://${aws_s3_bucket.data_analysis_bucket.bucket}/engagement/events"

    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    columns {
      name = "id"
      type = "int"
    }

    columns {
      name = "user_id"
      type = "string"
    }

    columns {
      name = "kind"
      type = "string"
    }

    columns {
      name = "timestamp"
      type = "timestamp"
    }
  }
}
