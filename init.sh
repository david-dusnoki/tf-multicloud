#!/bin/bash

echo "Running apt update & upgrade"
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive UCF_FORCE_CONFFNEW=YES apt upgrade -yq
echo "Installing Python"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive UCF_FORCE_CONFFNEW=YES apt-get install python -yq
echo "Setting up Ansiblee user"
sudo useradd -m -s /bin/bash maintain
echo "Setting up sudo access for maintain"
sudo usermod -aG sudo maintain
echo 'maintain  ALL=(ALL) NOPASSWD:ALL' | sudo tee -a /etc/sudoers
sudo mkdir /home/maintain/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoaBmrUIJXf8o7fYGlGe4qA42iBsKHo4lnQkSspjfmZweJ/Ff+i6mtgQt7zwfxVzagbYEgRYfxLQeTaRcgOg00fcPSRDpnLvVo5Nv14gW/9FmwYL4aOah+vAwmtz9qZbjMJq2YztUyJ07VMP0yga9nAMtfjjrS9GiGXBJ3en+SESJSfWb4BYdP/p0sm61GlkbQ0OVoqOPdspDEZpMSDTXQ69wNXeKc22gmaqLpnc9z/JCOdym1q9H9DnrTOFee/9/EpQjBTBFbKNNN8jUd9B92Oe3i1Oo9X3JKMb8ILST21GaI0sGYtecyJQHWYSXoi6VfmnYGTVwez4WqpDykpn9Zau+IcyzOMcT9p3DPMqPnSUWIkYxPt5r4MIfY858TbsbP+fX+n7m0hwX9IZwAjNaDArrz2Qc4Dvzj/i3dlAohEx8BPRpJyQnNHDMsWtSwLlh6gJgI3OSwAKzLsqOgr7i+HyO31IYDSrJQE0gDAfZ1tythA7oL06t+ve7IUUneo42i1mnQ2iZ0nh+LodLfvGat++l6lMGE2lWkWg7vWDnxjiw0/3O4J9Coen8BhakDCqrfv78XXmvSWFQh0mYeb10XKmek+8vnucBRopOAQOGiAfyX0WeqiWCei9GmJlpRbndAR/8OUwd3eH/kyYfquQBz7qId5X3Sx+NVcHOL3FKY5Q== ddusnoki@ddusnoki-laptop" | sudo tee -a /home/maintain/.ssh/authorized_keys
sudo chown maintain:maintain -R /home/maintain/.ssh
sudo chmod 700 /home/maintain/.ssh
sudo chmod 600 /home/maintain/.ssh/authorized_keys

exit 0
