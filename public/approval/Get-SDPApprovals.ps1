<#
    .SYNOPSIS
        Returns a list of ServiceDesk Plus approvals for an entity. 

    .DESCRIPTION
        The Get-SDPApprovals function retrieves information on approval levels and approvals for a specific ServiceDesk Plus request. The function takes the ID of the request, and can filter by request, change, or release. The function also requires the ServiceDesk Plus API key and base URI.

        To use the function, call it with the ID of the request as an argument. The function will retrieve all the approval levels associated with the request, and then retrieve all the approvals for each level. The function will return a PowerShell custom object with information on each approval, including the approval ID, approval level, associated entity, status, comments, approver information, organizational role, sent and action taken dates, and approval level details.
        
        Note that the function requires the ServiceDesk Plus API key and base URI, which can be passed as arguments or set in the $SDPConf object. If these values are not provided, the function will use the default values set in $SDPConf.
        
    .NOTES
        Note that the function will return a custom object with information on each approval, which can be further manipulated and used in PowerShell scripts.

    .EXAMPLE
            Get-SDPApprovals -Id 12345
            Example 1: Get approvals for a ServiceDesk Plus request with ID 12345

            Get-SDPApprovals -Id 54321 -release
            Example 2: Get approvals for a ServiceDesk Plus release with ID 54321

            Get-SDPApprovals -Id 98765 -apiKey "myCustomApiKey" -SDPUrl "https://mycustomsdpsite.com"
            Example 3: Get approvals for a ServiceDesk Plus request with ID 98765, using a custom API key and base URI
        #>

function Get-SDPApprovals {
    param (
        # ID of the ServiceDesk Plus request
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int]
        $Id,
        
        # ID of the ServiceDesk Plus request
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [switch]
        $request, $change, $release, $purchase,

        # ServiceDesk Plus API KEY
        [Parameter(Mandatory = $false, Position = 1)][ValidateNotNullOrEmpty()]
        [string] $apiKey = $SDPConf.ApiKey,
    
        # Base URI of the ServiceDesk Plus server, i.e. https://sdp.example.com
        [Parameter(Mandatory = $false, Position = 2)][ValidateNotNullOrEmpty()]
        [string] $SDPUrl = $SDPConf.Url
    )

    process {
        
        #   determine module to build API endpoint address
        if($request){
            $sdpModule = "requests"
        } elseif ($change) {
            $sdpModule = "change"
        } elseif ($release) {
            $sdpModule = "release"
        } elseif ($purchase) {
            $sdpModule = "purchase"
        } else {
            # let's just default to requests module
            $sdpModule = "requests"
        }

        # lets get all the levels available in the entity
        $Parameters = @{
            Header = @{
                TECHNICIAN_KEY = $apiKey
            }
            Method = "Get"
            Uri    = "$SDPUrl/api/v3/$sdpModule/$Id/approval_levels"
        }
        $ApprovalLevels = Invoke-RestMethod @Parameters
        if (!$ApprovalLevels.approval_levels) {
            return $null
        }
        foreach ($Level in $ApprovalLevels.approval_levels) {
            $Parameters = @{
                Header = @{
                    TECHNICIAN_KEY = $apiKey
                }
                Method = "Get"
                Uri    = "$SDPUrl/api/v3/requests/$Id/approval_levels/$($Level.Id)/approvals"
            }
            $Approvals = Invoke-RestMethod @Parameters
            if (!$Approvals.approvals) {
                continue
            }
            foreach ($Approval in $Approvals.approvals) {
                # Create the returning object
                [PSCustomObject] @{
                    Id                 = $Approval.id
                    ApprovalLevel      = $Approval.approval_level.level
                    AssociatedEntity   = $Level.associated_entity
                    Status             = $Approval.status.name
                    Comments           = $Approval.comments
                    Approver           = $Approval.approver.name
                    ApproverMail       = $Approval.approver.email_id
                    OrganizationalRole = $Approval.org_role.name
                    SentOn             = if ($Approval.sent_on) { $Approval.sent_on.display_value | Get-Date } else { $null }
                    SentBy             = $Approval.sent_by.email_id
                    ActionBy           = $Approval.action_by.name
                    ActionTakenOn      = if ($Approval.action_taken_on) { $Approval.action_taken_on.display_value | Get-Date } else { $null }
                    Deleted            = $Approval.deleted
                    LevelId            = $approval.approval_level.id
                    LevelName          = $Approval.approval_level.name
                    LevelStatus        = $level.status.name
                }
            }
        }
    }
}