param ($KVName, $ClientId, $ChartVersion, $TenantId)
$ErrorActionPreference = "SilentlyContinue"
$env:HELM_EXPERIMENTAL_OCI=1
            
$response = Invoke-WebRequest -Uri "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&client_id=$($ClientId)&resource=https://vault.azure.net" -Method GET -Usebasicparsing -Headers @{Metadata="true"}
$content = $response.Content | ConvertFrom-Json
$ArmToken = $content.access_token

Add-AzAccount -TenantId $TenantId -KeyVaultAccessToken $ArmToken -AccessToken $ArmToken -AccountId $ClientId |  out-null

$SP_Name = Get-AzKeyVaultSecret -VaultName $KVName -Name sp-name -AsPlainText
$Sp_Secret = Get-AzKeyVaultSecret -VaultName $KVName -Name sp-secret -AsPlainText
            
helm registry login akspvtacr002.azurecr.io -u $SP_Name -p $Sp_Secret

helm chart pull "akspvtacr002.azurecr.io/ingress/ingress-nginx:$($ChartVersion)"
            
helm chart export "akspvtacr002.azurecr.io/ingress/ingress-nginx:$($ChartVersion)"