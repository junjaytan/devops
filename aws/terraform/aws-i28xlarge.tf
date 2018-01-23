# Modify this to link to your credentials file
provider "aws" {
  shared_credentials_file = "/path/to/your/aws/credentials"
  region     = "us-east-1"
}

resource "aws_instance" "MyEC2Instances" {
  # Red Hat Enterprise Linux 7.3 (HVM)
  ami = "ami-9e2f0988"
  count = 4
  instance_type = "i2.8xlarge"
  availability_zone = "us-east-1a"
  key_name = "YOUR_KEY_NAME"
  placement_group = "YOUR_PLACEMENT_GROUP_NAME"
  subnet_id = "YOUR_SUBNET_ID"
  vpc_security_group_ids = ["YOUR_SECURITY_GROUP_ID"]
  ebs_optimized = false

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = 500
    volume_type = "gp2"
    #iops = 3000
    delete_on_termination = true
  }

	# This instance type has instance stores
  ephemeral_block_device {
    device_name = "/dev/sdj"
    virtual_name = "ephemeral0"
  }

  ephemeral_block_device {
    device_name = "/dev/sdk"
    virtual_name = "ephemeral1"
  }

  ephemeral_block_device {
    device_name = "/dev/sdl"
    virtual_name = "ephemeral2"
  }

  ephemeral_block_device {
    device_name = "/dev/sdm"
    virtual_name = "ephemeral3"
  }

  tags {
    Name = "MYEC2-${count.index}"
    Owner = "YOUR_NAME"
    Description = "Some description"
		# class name is useful if you want to use ansible to provision, for example.
    class = "some class name"
  }
}
