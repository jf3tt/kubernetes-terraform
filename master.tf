resource "aws_instance" "k8s-master" {
  instance_type = "t2.micro"
  ami = "ami-0194c504244182155"
  key_name = "ssh_key"
  subnet_id = "${aws_subnet.default.id}"
  security_groups = ["${aws_security_group.allow_ssh.id}", "${aws_security_group.master-api.id}"]
  
  tags = {
    Name = "k8s-master"
  }
  connection {
    type = "ssh"
    user = "core"
    private_key = "${file("keys/aws_terraform")}"
  }
  provisioner "remote-exec" {
    inline = [
		"CNI_VERSION=${var.CNI_VERSION}",
		"echo $CNI_VERSION > /tmp/sni_version",
		"sudo mkdir -p /opt/cni/bin",
		"curl -L https://github.com/containernetworking/plugins/releases/download/$${CNI_VERSION}/cni-plugins-amd64-$${CNI_VERSION}.tgz | sudo tar -C /opt/cni/bin -xz",

		"CRICTL_VERSION=${var.CRICTL_VERSION}",
		"sudo mkdir -p /opt/bin",
		"curl -L https://github.com/kubernetes-incubator/cri-tools/releases/download/$${CRICTL_VERSION}/crictl-$${CRICTL_VERSION}-linux-amd64.tar.gz | sudo tar -C /opt/bin -xz",

		"RELEASE=$(curl -sSL https://dl.k8s.io/release/stable.txt)",

		"sudo mkdir -p /opt/bin",
		"cd /opt/bin",
		"sudo curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/$${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}",
		"sudo chmod +x {kubeadm,kubelet,kubectl}",

		"sudo curl -sSL https://raw.githubusercontent.com/kubernetes/kubernetes/$${RELEASE}/build/debs/kubelet.service | sudo sed \"s:/usr/bin:/opt/bin:g\" > /tmp/kubelet.service",
		"sudo mv /tmp/kubelet.service /etc/systemd/system/kubelet.service",
		"sudo mkdir -p /etc/systemd/system/kubelet.service.d",
		"sudo curl -sSL https://raw.githubusercontent.com/kubernetes/kubernetes/$${RELEASE}/build/debs/10-kubeadm.conf | sudo sed \"s:/usr/bin:/opt/bin:g\" > /tmp/10-kubeadm.conf",
		"sudo mv /tmp/10-kubeadm.conf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf",

		"sudo systemctl enable --now kubelet",
		"sudo systemctl enable docker.service",
    "sudo kubeadm init --ignore-preflight-errors=NumCPU --apiserver-advertise-address=${self.private_ip}",
		"sudo kubeadm token list | grep signing | awk '{print $1}'"

	]
  }
}