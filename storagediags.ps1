# enables diagnostics logging for storage accounts to a log analytics workspace, and can remove diagnostics as well
# can (and likely should) be changed to accept resourceIDs instead of separate params to enable easier automation

[CmdletBinding()]
Param(
    # REQUIRED input:
    [Parameter(Mandatory=$true)][string]$StorageAccountSub,
    [Parameter(Mandatory=$true)][string]$StorageAccountRG,
    [Parameter(Mandatory=$true)][string]$StorageAccountName, 
    [Parameter(Mandatory=$true)][string]$WorkspaceSub, 
    [Parameter(Mandatory=$true)][string]$WorkspaceRG, 
    [Parameter(Mandatory=$true)][string]$WorkspaceName,

    # OPTIONAL input:
    [string]$DiagnosticSettingName = 'storagediags1',
    [switch]$DisableMode = $false # default is false (enable diagnostic logging on storage), set to true to REMOVE diagnostic logging
)

Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true" # warnings about model changes were annoying

# Make sure the user is logged in.
Write-Output 'Checking if the user is logged in...'
if (!(Get-AzContext))
{
	Write-Output 'User is not logged in. Attempting to log in...'
	Connect-AzAccount
}

$ResourceId = "/subscriptions/" + $StorageAccountSub + "/resourceGroups/" + $StorageAccountRG + "/providers/Microsoft.Storage/storageAccounts/" + $StorageAccountName
$WorkspaceId = "/subscriptions/" + $WorkspaceSub + "/resourcegroups/" + $WorkspaceRG + "/providers/microsoft.operationalinsights/workspaces/" + $WorkspaceName

if (!$DisableMode) {
    Write-Output 'Enabling storage account diagnostic logging to workspace'
    $metric = New-AzDiagnosticDetailSetting -Metric -RetentionEnabled -Category AllMetrics -Enabled
    $setting = New-AzDiagnosticSetting -Name $DiagnosticSettingName -ResourceId $ResourceId -WorkspaceId $WorkspaceId -Setting $metric
    Set-AzDiagnosticSetting -InputObject $setting

    $metric = New-AzDiagnosticDetailSetting -Metric -RetentionEnabled -Category AllMetrics -Enabled
    $readlog = New-AzDiagnosticDetailSetting -Log -RetentionEnabled -Category StorageRead -Enabled
    $writelog = New-AzDiagnosticDetailSetting -Log -RetentionEnabled -Category StorageWrite -Enabled
    $deletelog = New-AzDiagnosticDetailSetting -Log -RetentionEnabled -Category StorageDelete -Enabled
    $Ids = @($ResourceId + "/blobServices/default"
            $ResourceId + "/fileServices/default"
            $ResourceId + "/queueServices/default"
            $ResourceId + "/tableServices/default"
    )
    Write-Output 'Enabling storage account services diagnostic logging to workspace'
    $Ids | ForEach-Object {
        $setting = New-AzDiagnosticSetting -Name $DiagnosticSettingName -ResourceId $_ -WorkspaceId $WorkspaceId -Setting $metric,$readlog,$writelog,$deletelog
        Set-AzDiagnosticSetting -InputObject $setting
    }
}
else {
    Write-Output 'Removing diagnostic settings from storage account'
    Remove-AzDiagnosticSetting -ResourceID $ResourceID -Name $DiagnosticSettingName

    $Ids = @($ResourceId + "/blobServices/default"
            $ResourceId + "/fileServices/default"
            $ResourceId + "/queueServices/default"
            $ResourceId + "/tableServices/default"
    )
    Write-Output 'Removing diagnostic settings from storage account services'
    $Ids | ForEach-Object {
        Remove-AzDiagnosticSetting -ResourceID $_ -Name $DiagnosticSettingName
    }
}
