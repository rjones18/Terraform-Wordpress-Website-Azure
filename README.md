# Terraform-Wordpress-Website-Azure

In this project, I've automated the deployment of a secure and scalable WordPress blog site on Microsoft Azure using Terraform for infrastructure provisioning and Packer for custom Machine Images. The WordPress codebase is configured to securely fetch database credentials from Azure Key Vault. Integrated with GitHub Actions, Defender for DevOps and Snyk provide real-time scanning of Infrastructure as Code (IaC) for potential vulnerabilities and misconfigurations, while Azure Database for MySQL servers manages user-generated content.

VM instances, part of a VM Scale Set, ensure scalability and are continuously monitored by Defender for Cloud via the Log Analytics Agent. Alerts are channeled to Microsoft Sentinel SIEM for swift detection and response. Web traffic is encrypted with an SSL certificate from Microsoft and managed via Azure DNS Zone integrated with GoDaddy DNS. A CDN Profile in front of the load balancer guarantees optimized content delivery, culminating in a high-performance and secure WordPress website on Azure.


## Application Breakdown

The application is broken down into the architecture below:

![wordpress](https://github.com/rjones18/Images/blob/main/Azure%20Wordpress%20(5).png)



Link to the 3 repos with Github Actions:

- [Infrastructure Pipeline](https://github.com/rjones18/Azure-Wp-Infrastructure)
- [VPC Pipeline](https://github.com/rjones18/Azure-Virtual-Network-Pipeline)
- [Database Pipeline](https://github.com/rjones18/Azure-Wp-MySQL-DB)

Links to the AMI-Build Repo for this Project:

- [Packer Machine Image Build](https://github.com/rjones18/Azure-Wordpress-Machine-Image-Build) 
