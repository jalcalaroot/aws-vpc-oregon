output "vpc_id" {
  value = "${aws_vpc.main.id}"
}
output "public-subnet-0" {
  value = "${aws_subnet.public-subnet-0.id}"
}
output "public-subnet-1" {
  value = "${aws_subnet.public-subnet-1.id}"
}
output "public-subnet-2" {
  value = "${aws_subnet.public-subnet-2.id}"
}
output "private-subnet-A0" {
  value = "${aws_subnet.private-subnet-A0.id}"
}
output "private-subnet-A1" {
  value = "${aws_subnet.private-subnet-A1.id}"
}
output "private-subnet-A2" {
  value = "${aws_subnet.private-subnet-A2.id}"
}
