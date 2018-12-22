resource "alicloud_vpc" "vpc" {
    name       = "${var.name}-vpc"
    cidr_block = "10.1.0.0/16"
}

resource "alicloud_vswitch" "vswitch" {
    vpc_id		= "${alicloud_vpc.vpc.id}"
    cidr_block		= "10.1.0.0/24"
    availability_zone	= "us-east-1a"
}

resource "alicloud_slb" "slb" {
    name	= "${var.name}-slb"
    vswitch_id	= "${alicloud_vswitch.vswitch.id}"
}

resource "alicloud_eip" "eip" {}

resource "alicloud_eip_association" "eip_asso" {
    allocation_id = "${alicloud_eip.eip.id}"
    instance_id   = "${alicloud_instance.test-instance.id}"
    depends_on = [
        "alicloud_instance.test-instance",
    ]
}

resource "alicloud_security_group" "default" {
    name	= "default"
    description	= "${var.name} security group"
    vpc_id	= "${alicloud_vpc.vpc.id}"
}

resource "alicloud_security_group_rule" "allow_all_inbound" {
    type              = "egress"
    ip_protocol       = "all"
#    nic_type          = "internet"
    policy            = "accept"
    port_range        = "-1/-1"
    priority          = 1
    security_group_id = "${alicloud_security_group.default.id}"
    cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "ssh" {
    type              = "ingress"
    ip_protocol       = "tcp"
    policy            = "accept"
    port_range        = "22/22"
    priority          = 2
    security_group_id = "${alicloud_security_group.default.id}"
    cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "http" {
    type              = "ingress"
    ip_protocol       = "tcp"
#    nic_type          = "internet"
    policy            = "accept"
    port_range        = "80/80"
    priority          = 3
    security_group_id = "${alicloud_security_group.default.id}"
    cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_instance" "test-instance" {
    image_id			= "ubuntu_16_0402_64_20G_alibase_20170818.vhd"
    internet_charge_type	= "PayByBandwidth"

    instance_type		= "ecs.t5-lc2m1.nano"
    system_disk_category	= "cloud_efficiency"
    security_groups		= ["${alicloud_security_group.default.id}"]
    instance_name		= "web"
    vswitch_id			= "${alicloud_vswitch.vswitch.id}"
    user_data			= "${file("${path.module}/init.sh")}"
}

