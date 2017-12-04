##########################################################
# Provider and Access details
##########################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}


##########################################################
data "aws_availability_zones" "all" {}
##########################################################


##########################################################
# Search for Ubuntu Image
##########################################################
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


##########################################################
# AWS Launch Configuration
##########################################################
resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "umg-launch-configuration-"
  image_id      = "${data.aws_ami.ubuntu.id}"
  security_groups = ["${aws_security_group.instance.id}"]
  instance_type = "t2.micro"
  key_name = "${var.aws_key_name}"

  # Run a remote provisioner on the instance after creating it.
  # In this case, we just install Docker and start it. 
  user_data = "${file("userdata.sh")}"

  lifecycle {
    create_before_destroy = true
  }
}


##########################################################
# AWS Auto Scaling Group
##########################################################
resource "aws_autoscaling_group" "as_grp" {
  name                 = "umg-autoscaling-group"
  launch_configuration = "${aws_launch_configuration.as_conf.name}"
  min_size             = 1
  max_size             = 2
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  load_balancers = ["${aws_elb.umgexample.name}"]
  health_check_type = "ELB"

  tag {
    key = "Name"
    value = "umg-elb"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}


##########################################################
# AWS Security Group for ELB
##########################################################
resource "aws_security_group" "elb" {
  name = "umg-example-elb"

  # Allow all outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTP from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


##########################################################
# AWS Security Group For Instance
##########################################################
resource "aws_security_group" "instance" {
  name = "umg-example-instance"

  # Inbound SSH from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound traffic to Postgres Endpoint
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Inbound HTTP from anywhere - Health Check
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # just to ensure the replacement of a resource is created before the original is destroyed
  lifecycle {
    create_before_destroy = true
  }
}

##########################################################
# AWS Elastic Load Balancer for the distributing the load
##########################################################
resource "aws_elb" "umgexample" {
  name = "umg-elb"
  security_groups = ["${aws_security_group.elb.id}"]
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:${var.server_port}/"
  }

  # Listener for incoming HTTP requests.
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "${var.server_port}"
    instance_protocol = "http"
  }
}


##########################################################
# Postrgres Database Resource
##########################################################
resource "aws_db_instance" "umgdb" {  
  allocated_storage        = 5   # in GB
  engine                   = "postgres"
  engine_version           = "9.5.4"
  identifier               = "umgdb"
  instance_class           = "db.t2.micro"
  multi_az                 = false
  name                     = "umgdb"
  username                 = "umgdb"
  password                 = "Umgdb123"
  port                     = 5432
  publicly_accessible      = true
  storage_type             = "gp2"
  skip_final_snapshot      = true
  vpc_security_group_ids   = ["${aws_security_group.instance.id}"]
}
