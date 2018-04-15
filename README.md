# Infrastructure As Code using PowerShell and DSC
A proof of concept for implementing Infrastructure As Code using PowerShell and DSC. This repo is one of four related repos that comprises an infrastructure of 1 Domain Controller, 1 client computer and 2 web servers.

To be able to run successful Appveyor builds, you need to configure WinRM to enable PowerShell remoting after you provisioned the VM in Azure. For the complete guide, please refer to this [link](https://blogs.technet.microsoft.com/uktechnet/2016/02/11/configuring-winrm-over-https-to-enable-powershell-remoting/). The ```Deploy-InfraDC.ps1``` helper script can serve as a starting point in provisioning the necessary resources in Azure.


# Resources
[TestDomainCreator](https://github.com/adbertram/TestDomainCreator)

This is the repo where this project was based. Great stuff by Adam Bertram.

[Azure SPN](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal)

[Manage Role-Based Access Control with Azure PowerShell](https://docs.microsoft.com/en-us/azure/active-directory/role-based-access-control-manage-access-powershell)




