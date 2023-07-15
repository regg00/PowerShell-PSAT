<#
    .SYNOPSIS
        Core test suite for the NinjaOne module.
#>

BeforeAll {    
    $ModulePath = Split-Path -Parent -Path (Split-Path -Parent -Path $PSCommandPath)
    $ModuleName = 'PSPsat'
    $ManifestPath = "$($ModulePath)\$($ModuleName).psd1"
    if (Get-Module -Name $ModuleName) {
        Remove-Module $ModuleName -Force
    }
    Import-Module $ManifestPath -Verbose:$False
    $Script:ModuleInformation = Import-Module -Name $ManifestPath -PassThru
}

# Test the manifest
Describe 'Core' {
    It 'Manifest is valid' {
        {
            Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should -Not -Throw
    }

    It 'Root module is correct' {
        $Script:ModuleInformation.RootModule | Should -Be "$($ModuleName).psm1"
    }

    It 'Has a description' {
        $Script:ModuleInformation.Description | Should -Not -BeNullOrEmpty
    }

    It 'GUID is correct' {
        $Script:ModuleInformation.GUID | Should -Be 'cd09f0fe-045e-4b64-b20f-15296fb6a475'
    }

    It 'Version is valid' {
        $Script:ModuleInformation.Version -As [Version] | Should -Not -BeNullOrEmpty
    }

    It 'Copyright is present' {
        $Script:ModuleInformation.Copyright | Should -Not -BeNullOrEmpty
    }    

    It 'Project URI is correct' {
        $Script:ModuleInformation.ProjectUri | Should -Be 'https://github.com/regg00/PowerShell-PSAT'
    }

    It 'PowerShell Gallery tags is not empty' {
        $Script:ModuleInformation.Tags.count | Should -Not -BeNullOrEmpty 
    }

    It 'PowerShell Gallery tags do not contain spaces' {
        foreach ($Tag in $Script:ModuleInformation.Tags) {
            $Tag -NotMatch '\s' | Should -Be $True
        }
    }
}

Describe 'Module' {
    BeforeAll {
        $JsonContent = [PSCustomObject]@{
            apiToken = "fake-api-token"
        }
        $JsonContent | ConvertTo-Json | Out-File ( New-Item -Path "$env:USERPROFILE/.psat/psat.json" -Force )
    }
    It 'Module loads' {
        Get-Module -Name 'PSPsat' | Should -Not -Be $null
    }

    It 'Asks for api key on connect' {
        { Connect-Psat *>$null } | Should -Not -Throw
    }

}