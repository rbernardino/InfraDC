configuration New-DomainController
{
  Import-DscResource -ModuleName xActiveDirectory

  ## Authenticate to Azure
  #Login-AzureRmAccount

  ## This will be invoked by Azure Automation so grab the Azure Automation DSC credential asset and use it.
  $credParams = @{
    ResourceGroupName     = 'dsclab-automation-rg'
    AutomationAccountName = 'dsclab-automation'
  }
  $defaultAdUserCred = Get-AzureRmAutomationCredential -Name 'Default AD User Password' @credParams
  $domainSafeModeCred = Get-AzureRmAutomationCredential -Name 'Domain safe mode' @credParams

  Node $AllNodes.where( { $_.Purpose -eq 'Domain Controller' }).NodeName
  {

    @($ConfigurationData.NonNodeData.ADGroups).foreach( {
        xADGroup $_
        {
          Ensure    = 'Present'
          GroupName = $_
          DependsOn = '[xADDomain]ADDomain'
        }
      })

    @($ConfigurationData.NonNodeData.OrganizationalUnits).foreach( {
        xADOrganizationalUnit $_
        {
          Ensure    = 'Present'
          Name      = ($_ -replace '-')
          Path      = ('DC={0},DC={1}' -f ($ConfigurationData.NonNodeData.DomainName -split '\.')[0], ($ConfigurationData.NonNodeData.DomainName -split '\.')[1])
          DependsOn = '[xADDomain]ADDomain'
        }
      })

    @($ConfigurationData.NonNodeData.ADUsers).foreach( {
        xADUser "$($_.FirstName) $($_.LastName)"
        {
          Ensure     = 'Present'
          DomainName = $ConfigurationData.NonNodeData.DomainName
          GivenName  = $_.FirstName
          SurName    = $_.LastName
          UserName   = ('{0}{1}' -f $_.FirstName.SubString(0, 1), $_.LastName)
          Department = $_.Department
          Path       = ("OU={0},DC={1},DC={2}" -f $_.Department, ($ConfigurationData.NonNodeData.DomainName -split '\.')[0], ($ConfigurationData.NonNodeData.DomainName -split '\.')[1])
          JobTitle   = $_.Title
          Password   = $defaultAdUserCred
          DependsOn  = '[xADDomain]ADDomain'
        }
      })

    ($Node.WindowsFeatures).foreach( {
        WindowsFeature $_
        {
          Ensure = 'Present'
          Name   = $_
        }
      })

    xADDomain ADDomain
    {
      DomainName                    = $ConfigurationData.NonNodeData.DomainName
      DomainAdministratorCredential = $domainSafeModeCred
      SafemodeAdministratorPassword = $domainSafeModeCred
      DependsOn                     = '[WindowsFeature]AD-Domain-Services'
    }
  }
}
