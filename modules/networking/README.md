\# modules/networking



VPC 10.30.0.0/16 + 6 subnets sur 2 AZ + NAT single + 2 VPC endpoints.



\## Inputs



* project\_name (string, required)
* environment (string, required)
* vpc\_cidr (string, default "10.30.0.0/16")
* azs (list(string), default \["eu-west-3a","eu-west-3b"])



\## Outputs



* vpc\_id, vpc\_cidr
* public\_subnet\_ids (map)
* private\_app\_subnet\_ids (map)
* private\_db\_subnet\_ids (map)
* nat\_gateway\_public\_ip
* vpc\_endpoints\_security\_group\_id



\## Usage



* module "networking" {
* source       = "../../modules/networking"
* project\_name = "kolab"
* environment  = "dev"

}



