# Infrastructure as a Service with Microsoft Azure
A proof of concept (POC) for implementing a hybrid IT environment using Microsoft Azure'a IaaS. This repo simulates an on-premises domain controller.

To be able to run successful Appveyor builds, you need to configure WinRM to enable PowerShell remoting after you provisioned the VM in Azure. For the complete guide, please refer to this [link](https://blogs.technet.microsoft.com/uktechnet/2016/02/11/configuring-winrm-over-https-to-enable-powershell-remoting/). The ```Deploy-InfraDC.ps1``` helper script can serve as a starting point in provisioning the necessary resources in Azure.

## Other related repos
[Management Tier](https://github.com/rbernardino/InfraClient)

[Network Tier](https://github.com/rbernardino/InfraNetworking)

Web Tier (TODO)

## Resources
[TestDomainCreator](https://github.com/adbertram/TestDomainCreator)

This is the repo where this project was based. Great stuff by Adam Bertram.

[Azure SPN](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal)

[Manage Role-Based Access Control with Azure PowerShell](https://docs.microsoft.com/en-us/azure/active-directory/role-based-access-control-manage-access-powershell)




