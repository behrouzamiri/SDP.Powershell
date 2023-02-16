<#
    .SYNOPSIS
        Returns a ServiceDesk Plus request by id. 

    .DESCRIPTION
        This function retrieves details of ServiceDesk Plus requests by their IDs. It accepts an array of request IDs as input and returns various attributes associated with each request such as ID, status, subject, requestor, department, category, item, technician, priority, site, description, etc. It uses the ServiceDesk Plus REST API to fetch this information. 
        
        Includes additional fields than Search-SDPRequest.

        Syntax
            Get-SDPRequest [-Id] <int[]> [-apiKey <string>] [-SDPUrl <string>]

        Parameters
            -Id: Specifies the array of request IDs to retrieve details for. This parameter is mandatory and accepts input from the pipeline or property name.

            -apiKey: Specifies the ServiceDesk Plus API KEY for authentication. This parameter is optional and defaults to the value set in the $SDPConf.ApiKey variable.

            -SDPUrl: Specifies the base URI of the ServiceDesk Plus server. This parameter is optional and defaults to the value set in the $SDPConf.Url variable.

    .OUTPUTS
        This function outputs an array of custom objects with the following attributes for each request ID specified in the input array:
        Id
        Status
        Subject
        Requestor
        Department
        Category
        SubCategory
        Item
        Technician
        Group
        Priority
        Site
        Description
        isServiceRequest
        Template
        SLA
        ClosureAcknowledged
        ClosureType
        CreatedTime
        AssignedTime
        FirstResponseDueTime
        DueTime
        ResolvedTime
        CompletedTime
        LastUpdatedTime
        ElapsedTime
        approval status (either "pending approval-id:1","Denied-id:3")
    .EXAMPLE
        PS C:\> Get-SDPRequest -Id 123456, 7891011 -apiKey "myApiKey" -SDPUrl "https://mycompany.servicedeskplus.com"
        Returns two ServiceDesk Plus requests with ID 123456 and 7891011

    .EXAMPLE
        PS C:\> Get-SDPRequest -Id 12345
        Return ServiceDesk Plus request with id 12345, and uses the APIKey and URL from the config file

    .EXAMPLE
        PS C:\> "12345", "67890" | Get-SDPRequest
        Return ServiceDesk Plus requests 12345 and 67890 and uses the APIKey and URL from the config file
#>

function Get-SDPRequest {
    param (
        # ID of the ServiceDesk Plus request
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int[]]
        $Id,

        # ServiceDesk Plus API KEY
        [Parameter(Mandatory = $false, Position = 1)][ValidateNotNullOrEmpty()]
        [string] $apiKey = $SDPConf.ApiKey,
    
        # Base URI of the ServiceDesk Plus server, i.e. https://sdp.example.com
        [Parameter(Mandatory = $false, Position = 2)][ValidateNotNullOrEmpty()]
        [string] $SDPUrl = $SDPConf.Url
    )

    process {
        
        foreach ($RequestId in $Id) {
            $Parameters = @{
                Body   = @{
                    TECHNICIAN_KEY = $apiKey
                }
                Method = "Get"
                Uri    = "$SDPUrl/api/v3/requests/$RequestId"
            }

            $Response = Invoke-RestMethod @Parameters
            

            [PSCustomObject] @{
                Id                   = $Response.request.id
                Status               = $Response.request.status.name
                Subject              = $Response.request.subject
                Requester            = $Response.request.requester.name
                RequesterMail        = $Response.request.requester.email_id
                Department           = $Response.request.department.name
                Category             = $Response.request.category.name
                SubCategory          = $Response.request.subcategory.name
                Item                 = $Response.request.item.name
                Technician           = $Response.request.technician.name
                TechnicianEmail      = $Response.request.technician.email_id
                Group                = $Response.request.group.name
                Priority             = $Response.request.priority.name
                Site                 = $Response.request.site.name
                Description          = $Response.request.description
                isServiceRequest     = $Response.request.is_service_request
                ServiceCategory      = $Response.request.service_category.name
                Template             = $Response.request.template.name
                SLA                  = $Response.request.sla.name
                ApprovalStatus       = $Response.request.approval_status.name
                ClosureAcknowledged  = [System.Convert]::ToBoolean($Response.request.closure_info.requester_ack_resolution)
                ClosureType          = $Response.request.closure_info.requester_ack_comments
                CreatedTime          = if ($Response.request.created_time) { $Response.request.created_time.display_value | Get-Date } else { $null }
                AssignedTime         = if ($Response.request.assigned_time) { $Response.request.assigned_time.display_value | Get-Date } else { $null }
                FirstResponseDueTime = if ($Response.request.first_response_due_by_time) { $Response.request.first_response_due_by_time.display_value | Get-Date } else { $null }
                DueTime              = if ($Response.request.due_by_time) { $Response.request.due_by_time.display_value | Get-Date } else { $null }
                ResolvedTime         = if ($Response.request.resolved_time) { $Response.request.resolved_time.display_value | Get-Date } else { $null }
                CompletedTime        = if ($Response.request.completed_time) { $Response.request.completed_time.display_value | Get-Date } else { $null }
                LastUpdatedTime      = if ($Response.request.last_updated_time) { $Response.request.last_updated_time.display_value | Get-Date } else { $null }
                ElapsedTime          = $Response.request.time_elapsed.display_value
            }
        }
    }
}