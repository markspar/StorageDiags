# StorageDiags
Configures storage account diagnostic settings, including setting and removing, with logging to a log analytics workspace
This was created to enable tracking of usage of storage accounts, which would be enabled periodically as specific storage accounts are evaluated
This could be done with policy easily to make a standard implementation instead of running a script.


Sample command-line for enabling diags:

.\storagediags.ps1 -StorageAccountSub x -StorageAccountRG myrg1 -StorageAccountName mystore1 -WorkspaceSub x -WorkspaceRG myrg2 -WorkspaceName myLAW1 -DiagnosticSettingName storagediags1

Sample for disabling diags (yes, it does stupidly require a LAW parameter even when disabling and the LAW might not even exist - will be fixed later):

.\storagediags.ps1 -StorageAccountSub x -StorageAccountRG myrg1 -StorageAccountName mystore1 -WorkspaceSub x -WorkspaceRG myrg2 -WorkspaceName myLAW1 -DiagnosticSettingName storagediags1 -DisableMode

