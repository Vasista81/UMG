# UMG
UMG Assignment
---------------------------------------------------------------------------------------------------------
Problem:

Assume an existing VPC.
Write a Terraform script to create an EC2 auto-scaling group, RDS instance and attended security groups etc
Ensure that the EC2 hosts have Docker engine installed as part of the creation
This must be done in an automated fashion and not use a pre-existing AMI

---------------------------------------------------------------------------------------------------------

Solution:
---------

Files:
------
- main_umg.tf  -- Main Terraform File
- vars.tf      -- Variables
- userdata.sh  -- Shell script that's used to install docker on AMI

Pre-Requisites:
---------------

Login to Amazon Console and create IAM Credentials:

  -- User Access Key and Secret Key
  -- Create a key pair with name "umgKey".

Description:
------------
For security reasons the Access Key & Secret Key that I have used is been removed in the code and replaced with place holders <ACCESS_KEY> & <SECRET_KEY>.
Please make sure <ACCESS_KEY> & <SECRET_KEY> in vars.tf are replaced with real values before running the terraform script.

How to run:
-----------
1. Extract the source to directory terraform
2. Change directory to terraform
3. Execute following commands:

  a) terraform init
  b) terraform plan - to verify provider and resources that are going to be created
  c) terraform apply - which does the following
          i) Creates the AWS Provider using the IAM Access details (Access key & Secret key)
          ii) AWS launch Configuration which defines the AWS Image and instance type 
          iii) Load Balancer to distribute the Load
          iv) Security Groups for ELB and the instance
          v) RDS - Postgres Dabatbase instance with 5 GB data storage
  d) terraform destroy - to destroy the instance and it's associated resources on AWS
  
  Improvements/ Enhancements:
  ---------------------------
  1. Username and Password for RDS instance can be stored in variables and also make them more secure.
  2. AMI can be created by using other tools like Packer etc.
  
 Known Issues:
 -------------
 
 Because the Load Balancer Health Check is failed the primary AWS instance that's created is terminated after every timeout minutes.
 Due to lack of time I couldn't troubleshoot the same.
