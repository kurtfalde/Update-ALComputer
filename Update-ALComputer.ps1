<#

.SYNOPSIS
Retrieves computer names from a specified group in Active Directory and remotely performs various operations against these
systems in support of AppLocker configuration. Requires administrative access to the remote systems Requires Active Directory cmdlets 

.PARAMETER Computer
Specifies an input name of a target workstation

.PARAMETER ADGroupName
Specifies the name of the computer group that should be used to query and perform operations against the member systems

.PARAMETER klist
If set this will perform a purge of all system kerberos tickets on the target systems forcing them to get new tickets 
 and subsequently new computer group membership information

u.PARAMETER gpupdate
If set this will perform a forced group policy refresh of the computer settings on the target systems

.PARAMETER startal
If set this will set the appidsvc service to automatic and attempt to start the appidsvc on the target systems


.EXAMPLE

 Update-ALcomputer -ADGroupName AppLocker-Audit -klist -gpupdate -startal

 #>

function Update-ALComputer {
    [CmdletBinding()]
    param (
        [string]$Computer,
        
        [string]$adgroupname,
        
        [switch]$klist,
        
        [switch]$gpupdate,

        [switch]$startal
        
    )
    PROCESS {
   
    $Computers = @()
    
    #Add the Computer parameter to the Computers array
    If($computer){$Computers += $Computer}
        
    #Get the AD Group members based on the AD Group name variable
    If($adgroupname){$Computers += (Get-ADGroupMember $adgroupname).name}
    
    If(($Computers.Count) -eq 0){Write-host -foregroundcolor Red "No input systems specified... exiting"}
    Else{
    
    
    If($klist){ Write-Verbose "klist was set remotely clearing Kerberos tickets for all targets"
        foreach($Computer in $Computers){
            #Cycle through each computer remotely running klist to clear all tickets via WMI (in case of no PoSH remoting)
            Write-Verbose "Clearing Kerberos tickets for $Computer"
            Invoke-WmiMethod -ComputerName $Computer -Class Win32_Process -Name Create -ArgumentList "klist -lh 0 -li 0x3e7 purge"
        }
    }

    If($gpupdate){Write-Verbose "gpupdate was set remotely forcing gpupdate /force /target:computer"
        foreach($Computer in $Computers){
            #Cycle through each computer remotely running gpudpate to force any new GPO's based on computer group membership
            Write-Verbose "Running gpupdate for $Computer"
            Invoke-WmiMethod -ComputerName $Computer -Class Win32_Process -Name Create -ArgumentList "gpupdate /force /target:computer"
        }
    }

    If($startal){Write-Verbose "startal was set"
        foreach($Computer in $Computers){
            #Cycle through each computer and attempt to set the appidsvc to automatic and start the service
            Write-Verbose "Setting appidsvc for $Computer to automatic"
            Invoke-WmiMethod -ComputerName $Computer -Class Win32_Process -Name Create -ArgumentList "sc config appidsvc start=auto"
            Write-Verbose "Attempting to start appidsvc on $Computer"
            Invoke-WmiMethod -ComputerName $Computer -Class Win32_Process -Name Create -ArgumentList "sc start appidsvc"
        }
    
        }
        }
    }
}
