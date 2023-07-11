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

function Send-ApiRequest {
    <#
    .SYNOPSIS
    Build requests and send it to the Psat Api.

    #>
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Endpoint,

        [ValidateSet('GET')]
        [String] $Method = 'GET',
        
        [ValidateSet('0.1.0', '0.2.0', '0.3.0')]
        [String] $ApiVersion = "0.1.0",

        [hashtable] $Body

    )
        
    If ($null -eq $env:PsatApiToken) {
        Throw [Data.NoNullAllowedException]::new('No token has been provided.  Please run Connect-Psat.')
    }

    $Hostname = "results.us.securityeducation.com"    

    $Arguments = @{
        'Method'  = "GET"
        'Uri'     = "https://$Hostname/api/reporting/v$ApiVersion$Endpoint"
        'Body'    = $Body
        'Headers' = @{
            'x-apikey-token' = $env:PsatApiToken
            'User-Agent'     = "PowerShell/$($PSVersionTable.PSVersion)"
            'Content-Type'   = "application/json"
            'Accept'         = 'application/json'
        }
    }

  
    Return (Invoke-RestMethod @Arguments)                
}

function Set-RequestCommonParameters {
    <#
    .SYNOPSIS
    Helper function to simplify the building of the request parameters hashtable

    #>
    param (
        [Int32] $PageSize = 20,    
        [Int32] $PageNumber,            
        [String[]] $UserEmailAddress,        
        [String[]] $CampaignName,        
        [String[]] $Action,
        [String] $EventTimestampStart,
        [String] $EventTimestampEnd,
        [String] $CampaignStartDateStart,
        [String] $CampaignStartDateEnd,        
        [String] $ReportedDateStart,
        [String] $ReportedDateEnd,
        [String] $ReceivedDateStart,
        [String] $ReceivedDateEnd
    )

    $RequestParameters = @{}
    
    if ($PageSize) {
        $RequestParameters.Add("page[size]", $PageSize)
    }

    if ($PageNumber) {
        $RequestParameters.Add("page[number]", $PageNumber)
    }

    if ($UserEmailAddress) {
        $FormattedString = $UserEmailAddress -join ","
        $RequestParameters.Add("filter[_useremailaddress]", "[$FormattedString]")                
    }    

    if ($CampaignName) {
        $FormattedString = $CampaignName -join ","
        $RequestParameters.Add("filter[_campaignname]", "[$FormattedString]")
    }

    if ($Action) {
        $FormattedString = $Action -join ","
        $RequestParameters.Add("filter[_action]", "[$FormattedString]")
        
    }   

    if ($EventTimestampStart) {
        $RequestParameters.Add("filter[_eventtimestamp_start]", $EventTimestampStart)
    }

    if ($EventTimestampEnd) {
        $RequestParameters.Add("filter[_eventtimestamp_end]", $EventTimestampEnd)
    }

    if ($CampaignStartDateStart) {
        $RequestParameters.Add("filter[_campaignstartdate_start]", $CampaignStartDateStart)
    }

    if ($CampaignStartDateEnd) {
        $RequestParameters.Add("filter[_campaignstartdate_end]", $CampaignStartDateEnd)
    }

    if ($ReportedDateStart) {
        $RequestParameters.Add("filter[_reporteddate_start]", $ReportedDateStart)
    }

    if ($ReportedDateEnd) {
        $RequestParameters.Add("filter[_reporteddate_end]", $ReportedDateEnd)
    }

    if ($ReceivedDateStart) {
        $RequestParameters.Add("filter[_receiveddate_start]", $ReceivedDateStart)
    }

    if ($ReceivedDateEnd) {
        $RequestParameters.Add("filter[_receiveddate_end]", $ReceivedDateEnd)
    }
        
    Return $RequestParameters
    
}

function Get-PsatUsers {
    param (
        [Int32] $PageNumber,    
        [Int32] $PageSize,
        [String[]] $UserEmailAddress,
        [Switch] $IncludeDeletedUsers,                
        [Switch] $FormatJson
    )
    
    $Params = Set-RequestCommonParameters -PageSize $PageSize `
        -PageNumber $PageNumber `
        -UserEmailAddress $UserEmailAddress        
    
    if ($IncludeDeletedUsers) {
        $Params.Add("filter[_includedeletedusers]", "TRUE")        
    }
    
    if ($FormatJson) {
        Return (Send-ApiRequest -Endpoint '/users' -Body $Params) | ConvertTo-Json -Depth 5
    }
    else {
        $Data = (Send-ApiRequest -Endpoint '/users' -Body $Params).Data
        $FormattedData = $Data | Select-Object -Property id, type -ExpandProperty attributes
        Return $FormattedData
    }                
}

function Get-PsatPhishing {
    param (
        [Int32] $PageNumber,    
        [Int32] $PageSize,
        [String[]] $UserEmailAddress,
        [String[]] $CampaignName,
        [Switch] $IncludeDeletedUsers,             
        [Switch] $FormatJson,
        [String] $EventTimestampStart,
        [String] $EventTimestampEnd,
        [String] $CampaignStartDateStart,
        [String] $CampaignStartDateEnd,
        [Switch] $IncludeNoAction,
        [Switch] $IncludeArchivedCampaigns        
    )
    
    $Params = Set-RequestCommonParameters -PageSize $PageSize `
        -PageNumber $PageNumber `
        -UserEmailAddress $UserEmailAddress `
        -CampaignName $CampaignName `
        -EventTimestampStart $EventTimestampStart `
        -EventTimestampEnd $EventTimestampEnd `
        -CampaignStartDateStart $CampaignStartDateStart `
        -CampaignStartDateEnd $CampaignStartDateEnd        

    if ($IncludeNoAction) {
        $RequestParameters.Add("filter[_includenoaction]", "TRUE")
    }
    
    if ($IncludeArchivedCampaigns) {
        $RequestParameters.Add("filter[_includearchivedcampaigns]", "TRUE")
    }

    if ($IncludeDeletedUsers) {
        $Params.Add("filter[_includedeletedusers]", "TRUE")        
    }

    if ($FormatJson) {
        Return (Send-ApiRequest -ApiVersion '0.3.0' -Endpoint '/phishing' -Body $Params) | ConvertTo-Json -Depth 5
    }
    else {
        $Data = (Send-ApiRequest -ApiVersion '0.3.0' -Endpoint '/phishing' -Body $Params).Data
        $FormattedData = $Data | Select-Object -Property id, type -ExpandProperty attributes
        Return $FormattedData
    }                
}

function Get-PsatPhishAlarm {
    param (
        [Int32] $PageNumber,    
        [Int32] $PageSize,
        [String[]] $UserEmailAddress,
        [ValidateSet("Opened", "Opened in Preview Pane", "Unopened")]        
        [String[]] $Action,   
        [Switch] $IncludeDeletedUsers,             
        [Switch] $FormatJson,
        [String] $ReportedDateStart,
        [String] $ReportedDateEnd,
        [String] $ReceivedDateStart,
        [String] $ReceivedDateEnd,
        [Switch] $IncludePlatformNotification
        
    )
    
    $Params = Set-RequestCommonParameters -PageSize $PageSize `
        -PageNumber $PageNumber `
        -UserEmailAddress $UserEmailAddress `
        -CampaignName $CampaignName `
        -ReportedDateStart $ReportedDateStart `
        -ReportedDateEnd $ReportedDateEnd `
        -ReceivedDateStart $ReceivedDateStart `
        -ReceivedDateEnd $ReceivedDateEnd
    

    if ($IncludeNoAction) {
        $RequestParameters.Add("filter[_includenoaction]", "TRUE")
    }
    
    if ($IncludePlatformNotification) {
        $RequestParameters.Add("filter[_includeplatformnotifications]", "TRUE")
    }

    if ($IncludeDeletedUsers) {
        $Params.Add("filter[_includedeletedusers]", "TRUE")        
    }

    if ($FormatJson) {
        Return (Send-ApiRequest -Endpoint '/phishalarm' -Body $Params) | ConvertTo-Json -Depth 5
    }
    else {
        $Data = (Send-ApiRequest -Endpoint '/phishalarm' -Body $Params).Data
        $FormattedData = $Data | Select-Object -Property id, type -ExpandProperty attributes
        Return $FormattedData
    }                
}


<#
TODO:
    - Knowledge Assessment
    - Training
    - Training Enrollments
#>