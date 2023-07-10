function Connect-Psat {
    <#
    .SYNOPSIS
    Saves the Api token from Psat into an environment variable.

    #>
    param (
        [String] $ApiToken
    )    
    if ($ApiToken) {
        $env:PsatApiToken = $ApiToken
        Save-Token -ApiToken $ApiToken
        
    }
    elseif (Test-Path "$env:USERPROFILE/.psat/psat.json") {
        $env:PsatApiToken = (Get-Content "$env:USERPROFILE/.psat/psat.json" | Convertfrom-json).apiToken
        
    }
    else {
        $env:PsatApiToken = Read-Host "Please enter the Psat Api Key" -MaskInput
        Save-Token -ApiToken $env:PsatApiToken
    }
        
}

function Save-Token {
    <#
    .SYNOPSIS
    Prompts the user to save to Api token into a file for later use.

    #>
    param (
        [String] $ApiToken
    )   
    $Title = "Do you want to save this token in your user profile for later use?"
    $Prompt = "Enter your choice"
    $Choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No", "&Cancel")
    $Default = 1

    # Prompt for the choice
    $Choice = $host.UI.PromptForChoice($Title, $Prompt, $Choices, $Default)
    switch ($Choice) {
        0 { 
            $JsonContent = [PSCustomObject]@{
                apiToken = $ApiToken
            }
            $JsonContent | ConvertTo-Json | Out-File "$env:USERPROFILE/.psat/psat.json"
        }

        1 { Continue }
        2 { Exit }
    }
}


function Send-PsatApi {
    <#
    .SYNOPSIS
    Build requests to be sent to the Psat Api.

    #>
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $RequestToSend,

        [ValidateSet('GET', 'PUT', 'POST', 'DELETE')]
        [String] $Method = 'GET',
        
        [ValidateSet('0.1.0', '0.2.0', '0.3.0')]
        [String] $ApiVersion = "0.1.0"

    )
        
    If ($null -eq $env:PsatApiToken) {
        Throw [Data.NoNullAllowedException]::new('No secret access key has been provided.  Please run Set-NinjaRmmSecrets.')
    }

    $Hostname = "results.us.securityeducation.com"    

    $Arguments = @{
        'Method'  = "GET"
        'Uri'     = "https://$Hostname/api/reporting/v$ApiVersion$RequestToSend"
        'Headers' = @{
            'x-apikey-token' = $env:PsatApiToken
            'User-Agent'     = "PowerShell/$($PSVersionTable.PSVersion)"
            'Content-Type'   = "application/json"
            'Accept'         = 'application/json'
        }
    }

  
    Return (Invoke-RestMethod @Arguments)                
}

function Get-PsatUsers {
    param (
        [Int32] $PageNumber,    
        [Int32] $PageSize = 20,
        [String[]] $UserEmailAddress,
        [Switch] $IncludeDeletedUsers,                
        [Switch] $FormatJson
    )

    $RequestToSend = "/users?page[size]=$PageSize"

    if ($PageNumber) {
        $RequestToSend += "&page[number]=$PageNumber"
    }

    if ($UserEmailAddress) {
        $FormattedString = $UserEmailAddress -join ","
        $RequestToSend += "&filter[_useremailaddress]=[$FormattedString]"
        
    }

    if ($IncludeDeletedUsers) {
        $RequestToSend += "&filter[_includedeletedusers]=TRUE"
    }

    if ($FormatJson) {
        Return (Send-PsatApi -RequestToSend $RequestToSend) | ConvertTo-Json -Depth 5
    }
    else {
        $Data = (Send-PsatApi -RequestToSend $RequestToSend).Data
        $FormattedData = $Data | Select-Object -Property id, type -ExpandProperty attributes
        Return $FormattedData
    }                
}

function Get-PsatPhishing {
    param (
        [Int32] $PageNumber,    
        [Int32] $PageSize = 20,
        [String[]] $UserEmailAddress,
        [String[]] $CampaignName,
        [Switch] $IncludeDeletedUsers,             
        [Switch] $FormatJson
        # TODO: Add all parameters
    )

    $RequestToSend = "/phishing?page[size]=$PageSize"

    if ($PageNumber) {
        $RequestToSend += "&page[number]=$PageNumber"
    }

    if ($UserEmailAddress) {
        $FormattedString = $UserEmailAddress -join ","
        $RequestToSend += "&filter[_useremailaddress]=[$FormattedString]"
        
    }

    if ($CampaignName) {
        $FormattedString = $CampaignName -join ","
        $RequestToSend += "&filter[_campaignname]=[$FormattedString]"
    }

    if ($IncludeDeletedUsers) {
        $RequestToSend += "&filter[_includedeletedusers]=TRUE"
    }

    if ($FormatJson) {
        Return (Send-PsatApi -ApiVersion '0.3.0' -RequestToSend $RequestToSend) | ConvertTo-Json -Depth 5
    }
    else {
        $Data = (Send-PsatApi -ApiVersion '0.3.0' -RequestToSend $RequestToSend).Data
        $FormattedData = $Data | Select-Object -Property id, type -ExpandProperty attributes
        Return $FormattedData
    }                
}

function Get-PsatPhishAlarm {
    param (
        [Int32] $PageNumber,    
        [Int32] $PageSize = 20,
        [String[]] $UserEmailAddress,
        [ValidateSet("Opened", "Opened in Preview Pane", "Unopened")]        
        [String[]] $Action,   
        [Switch] $IncludeDeletedUsers,             
        [Switch] $FormatJson
        # TODO: Add all parameters
    )

    $RequestToSend = "/phishalarm?page[size]=$PageSize"

    if ($PageNumber) {
        $RequestToSend += "&page[number]=$PageNumber"
    }

    if ($UserEmailAddress) {
        $FormattedString = $UserEmailAddress -join ","
        $RequestToSend += "&filter[_useremailaddress]=[$FormattedString]"
        
    } 
    
    if ($Action) {
        $FormattedString = $Action -join ","
        $RequestToSend += "&filter[_action]=[$FormattedString]"
        
    }   

    if ($IncludeDeletedUsers) {
        $RequestToSend += "&filter[_includedeletedusers]=TRUE"
    }

    if ($FormatJson) {
        Return (Send-PsatApi -RequestToSend $RequestToSend) | ConvertTo-Json -Depth 5
    }
    else {
        $Data = (Send-PsatApi -RequestToSend $RequestToSend).Data
        $FormattedData = $Data | Select-Object -Property id, type -ExpandProperty attributes
        Return $FormattedData
    }                
}