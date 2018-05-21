break

#region Create Application ID
  $displayName = 'mycloudlab-app'
  $domain = 'mycompany.com'
  $password = '<replace_w_your_pw>'

  $appIdSplat = @{
    'Displayname'    = $displayName
    'HomePage'       = "https://$domain/$displayName"
    'IdentifierUris' = "https://$domain/$displayName"
    'Password'       = ConvertTo-SecureString -String $password -AsPlainText -Force
  }
  $app = New-AzureRmADApplication @appIdSplat
  New-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId.Guid
#endregion

#region Create Azure Automation Account
  #region Azure Automation Account
    $location = 'southeastasia'
    $rg = 'dsclab-automation-rg'
    $automationAccount = 'dsclab-automation'
    $splat = @{
      'Location' = $location
      'Name'     = $rg
    }
    New-AzureRmResourceGroup @splat

    New-AzureRmAutomationAccount -Name $automationAccount -ResourceGroupName $rg  -Location $location

    Get-AzureRmAutomationAccount
  #endregion

  #region Azure Automation Assets
    $securestring = '<replace_w_your_pw>' | ConvertTo-SecureString -AsPlainText -Force
    $credential = [pscredential]::new('winadmin', $securestring)
    $splat = @{
      'Name' = 'Default AD User Password'
      'Description' = 'Default AD User Password'
      'Value' = $credential
      'ResourceGroupName' = $rg
      'AutomationAccountName' = $automationAccount
    }
    New-AzureRmAutomationCredential @splat

    $splat.Name = 'Domain safe mode'
    $splat.Description = 'Domain safe mode password'
    New-AzureRmAutomationCredential @splat
  #endregion

  #region Install DSC Resources that are not included by default
    # You can go to the portal and browse the gallery to install the ff modules
    #   1. xActiveDirectory
  #endregion

  # Cleanup if needed
  Remove-AzureRmResourceGroup -Name $rg -Force -Verbose

#endregion

#region Deploy the VM
{
  $location = 'Southeast Asia'
  $resourceGroupName = 'dscLabDCs'
  $resourceDeploymentName = 'dscLabDCs-deployment'
  $templateFile = '.\AzRmTemplates\dc.json'
  $templateParameterFile = '.\AzRmTemplates\dc.parameters.json'

  # You can use Azure Key Vault to store credentials and retrieve them in parameters.json
  $password = '<replace_w_your_pw>'
  $securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
  $additionalParams = New-Object -TypeName Hashtable
  $additionalParams['vmAdminPassword'] = $securePassword

  New-AzureRmJsonTemplateDeployment `
    -ResourceGroupName $resourceGroupName `
    -DeploymentName $resourceDeploymentName `
    -Location $location `
    -Path $templateFile `
    -TemplateParameterFile $templateParameterFile `
    -Verbose -Force `
    -AdditionalParams $additionalParams

  # Cleanup if needed
  Remove-AzureRmResourceGroup `
    -Name $resourceGroupName `
    -Force -Verbose
}
#endregion

#region Give appropriate access to 'mycloudlab-app' Application ID
  # Get Application id
  $id = Get-AzureRmADServicePrincipal -SearchString 'mycloudlab-app' |
    Select-Object -ExpandProperty Id

  # Give Contributor access to 'dsclabdcs' resource group
  New-AzureRmRoleAssignment -ObjectId $id.Guid -RoleDefinitionName 'Virtual Machine Contributor' -ResourceGroupName 'dsclabdcs'

  # Give Contributor access to the automation account resource group
  New-AzureRmRoleAssignment -ObjectId $id.Guid -RoleDefinitionName 'Contributor' -ResourceGroupName 'dsclab-automation-rg'

  # Remove Access if needed
  Remove-AzureRmRoleAssignment -ObjectId $id.Guid -RoleDefinitionName 'Virtual Machine Contributor' -ResourceGroupName 'dsclabdcs'
  Remove-AzureRmRoleAssignment -ObjectId $id.Guid -RoleDefinitionName 'Contributor' -ResourceGroupName 'dsclab-automation-rg'

#endregion

#region Quick Notes
  # 1. The Application ID needs read access to the subscription
  # 2. The Application ID needs at least Contributor role to the 'dsclabdcs' resource group
#endregion
