resource "aws_route53_zone" "main" {
  name = "${var.domain}"
}
resource "aws_route53_record" "k8s-master" {
  name    = "k8s-master.${aws_route53_zone.main.name}"
  zone_id = "${aws_route53_zone.main.zone_id}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.k8s-master.*.public_ip}"]
}

resource "aws_route53_record" "k8s-node" {
  name    = "k8s-node.${aws_route53_zone.main.name}"
  zone_id = "${aws_route53_zone.main.zone_id}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.k8s-node.*.public_ip}"]
}