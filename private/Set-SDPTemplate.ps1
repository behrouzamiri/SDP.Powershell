<#
    .SYNOPSIS
        Gets HTML content and replaces the ___placeholder___ with provided values. 

    .DESCRIPTION
        The function `Set-SDPTemplate` retrieves HTML content from the selected `Template` and replaces the ___placeholder___ with provided values. the Parameter Template is mandatory, which is in fact the file name of the desired template from the files located within the Template directory, without the .html extention.

    .EXAMPLE
        PS C:\> Set-SDPTemplate approvalmessage -Subject $obj.request.subject -Details "This is a Bot generated message, please report back any issues"
        sets the provided placeholders on the `approvalmessage` .html template and returns the resulting markup to the caller
#>
function Set-SDPTemplate {
    param (
        [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()]
        [string] $Template,

        [Parameter(Mandatory = $false, Position = 1)]
        [string] $CustomName,

        [Parameter(Mandatory = $false, Position = 2)]
        [string] $Subject,

        [Parameter(Mandatory = $false, Position = 3)]
        [string] $TicketID,

        [Parameter(Mandatory = $false, Position = 4)]
        [string] $Message,

        [Parameter(Mandatory = $false, Position = 5)]
        [string] $Link,

        [Parameter(Mandatory = $false, Position = 6)]
        [string] $Details,

        [Parameter(Mandatory = $false, Position = 7)]
        [string] $Header,

        [Parameter(Mandatory = $false, Position = 8)]
        [string] $Footer,

        [Parameter(Mandatory = $false, Position = 9)]
        [string] $Copyright
    )
    
    #Get the content of the template
    $templatePath = "$PSScriptRoot\..\templates\$Template.html"
    if(!(Test-Path $templatePath)){
    throw [System.IO.IOException]::new("Template file not found in $templatePath")
    }

    $HTMLContent = Get-Content "$PSScriptRoot\..\templates\$Template.html" -raw

    #replacing each placeholder if the corresponding parameter is provided
    if($CustomName){
        $HTMLContent = $HTMLContent.Replace('___customname___',$CustomName)
    }
    if($Subject){
        $HTMLContent = $HTMLContent.Replace('___subject___',$Subject)
    }
    if($TicketID){
        $HTMLContent = $HTMLContent.Replace('___ticketid___',$TicketID)
    }
    if($Message){
        $HTMLContent = $HTMLContent.Replace('___message___',$Message)
    }
    if($Link){
        $HTMLContent = $HTMLContent.Replace('___link___',$Link)
    }
    if($Details){
        $HTMLContent = $HTMLContent.Replace('___details___',$Details)
    }
    if($Header){
        $HTMLContent = $HTMLContent.Replace('___header___',$Header)
    }
    if($Footer){
        $HTMLContent = $HTMLContent.Replace('___footer___',$Footer)
    }
    if($Copyright){
        $HTMLContent = $HTMLContent.Replace('___copyright___',$Copyright)
    }

    return $HTMLContent

}