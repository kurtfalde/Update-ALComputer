<#

.SYNOPSIS
Retrieves computer names from a specified group in Active Directory and remotely performs various operations against these
systems in support of AppLocker configuration.
Requires administrative access to the remote systems
Requires Active Directory cmdlets 

.PARAMETER ADGroupName
Specifies the name of the computer group that should be used to query and perform operations against the member systems

.PARAMETER klist
If set this will perform a purge of all system kerberos tickets on the target systems forcing them to get new tickets 
and subsequently new computer group membership information

.PARAMETER gpupdate
If set this will perform a forced group policy refresh of the computer settings on the target systems

.PARAMETER startal
If set this will set the appidsvc service to automatic and attempt to start the appidsvc on the target systems

.EXAMPLE
Update-ALcomputer -ADGroupName AppLocker-Audit -klist -gpupdate -startal

#>

function Update-ALComputer {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string[]]$adgroupname,
        
        [parameter(Mandatory=$false)]
        [alias("klist")]
        [switch]$klist,
        
        [parameter(Mandatory=$false)]
        [alias("gpupdate")]
        [switch]$gpupdate,

        [parameter(Mandatory=$false)]
        [alias("startal")]
        [switch]$startal
        
    )
    PROCESS {
    }
}