<#
    .NAME
        Search-SDPRequest
    .SYNOPSIS
        Search for requests in ServiceDesk Plus

    .SYNTAX
    Search-SDPRequest [-RequesterName] <string> [[-subject] <string>] [[-serviceCategory] <string>] [[-serviceTemplate] <string>] [[-category] <string>] [[-subCategory] <string>] [[-Item] <string>] [[-status] <string>] [[-resultSize] <int>] [[-apiKey] <string>] [[-SDPUrl] <string>]

    .DESCRIPTION
        The Search-SDPRequest function allows users to search for requests in ServiceDesk Plus using different criteria like RequesterName, subject, category, status and others.

    .PARAMETERS
        -RequesterName <string>
            Name of the ServiceDesk Plus requester. This parameter is mandatory.

        -subject <string>
            Name of the ServiceDesk Plus request subject. This parameter is optional.
    
        -serviceCategory <string>
            Name of the ServiceDesk Plus service request category. This parameter is optional and it is used in conjunction with the parameter set "servicerequest".
    
        -serviceTemplate <string>
            Name of the ServiceDesk Plus service request template. This parameter is optional and it is used in conjunction with the parameter set "servicerequest".
    
        -category <string>
            Name of the ServiceDesk Plus request category. This parameter is optional and it is used in conjunction with the parameter set "generalrequest".
    
        -subCategory <string>
            Name of the ServiceDesk Plus request subcategory. This parameter is optional and it is used in conjunction with the parameter set "generalrequest".
    
        -Item <string>
            Name of the ServiceDesk Plus request item. This parameter is optional and it is used in conjunction with the parameter set "generalrequest".
    
        -status <string>
            Name of the ServiceDesk Plus request status. This parameter is optional and it is used in conjunction with the parameter set "generalrequest".
    
        -resultSize <int>
            Specify result size. Default value is 2. This parameter is optional.
    
        -apiKey <string>
            ServiceDesk Plus API KEY. This parameter is optional and it will take the value of $SDPConf.ApiKey if not specified.
    
        -SDPUrl <string>
            Base URI of the ServiceDesk Plus server, i.e. https://sdp.example.com. This parameter is optional and it will take the value of $SDPConf.Url if not specified.
    
    .INPUTS
        None, You cannot pipe input to this function.
    
    .OUTPUTS
        The function returns a collection of custom objects with the following properties:
        -Id
            ServiceDesk Plus request ID.
    
        -Status
            ServiceDesk Plus request status.
    
        -Subject
            ServiceDesk Plus request subject.
    
        -RequesterName
            Name of the ServiceDesk Plus requester.
    
        -RequesterEmail
            Email address of the ServiceDesk Plus requester.
    
        -Department
            Name of the ServiceDesk Plus requester department.
    
        -Category
            Name of the ServiceDesk Plus request category.
    
        -isServiceRequest
            True if the request is a service request, False otherwise.
    
        -TechnicianName
            Name of the technician assigned to the request.
    
        -TechnicianEmail
            Email address of the technician assigned to the request.
    
        -Group
            Name of the ServiceDesk Plus group assigned to the request.
    
        -Priority
            Name of the ServiceDesk Plus request priority.
    
        -Site
            Name of the ServiceDesk Plus site assigned to the request.

    
    .EXAMPLE
        PS C:\> "12345", "67890" | Get-SDPRequest
        Search-SDPRequest -SDPUrl "https://ticket.domain.com" -apiKey "BEHRA278-0EF9-9900-ZB74-AM87IA00R80I" -requesterName "Behrouz Amiri" -serviceTemplate "BI Access Request"
#>

function Search-SDPRequest {
    param (
        # Name of the ServiceDesk Plus requester
        [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()]
        [string]
        $RequesterName,

        # Name of the ServiceDesk Plus request subject
        [Parameter(Mandatory = $false, Position = 1)][ValidateNotNullOrEmpty()]
        [string]
        $subject,

        # Name of the ServiceDesk Plus service request category
        [Parameter(Mandatory = $false, Position = 3, ParameterSetName = "servicerequest")][ValidateNotNullOrEmpty()]
        [string]
        $serviceCategory,

        # Name of the ServiceDesk Plus service request template
        [Parameter(Mandatory = $false, Position = 4, ParameterSetName = "servicerequest")][ValidateNotNullOrEmpty()]
        [string]
        $serviceTemplate,

        # Name of the ServiceDesk Plus request category
        [Parameter(Mandatory = $false, Position = 3, ParameterSetName = "generalrequest")][ValidateNotNullOrEmpty()]
        [string]
        $category,

        # Name of the ServiceDesk Plus request subcategory
        [Parameter(Mandatory = $false, Position = 4, ParameterSetName = "generalrequest")][ValidateNotNullOrEmpty()]
        [string]
        $subCategory,

        # Name of the ServiceDesk Plus request item
        [Parameter(Mandatory = $false, Position = 5, ParameterSetName = "generalrequest")][ValidateNotNullOrEmpty()]
        [string]
        $Item,

        # Name of the ServiceDesk Plus request status
        [Parameter(Mandatory = $false, Position = 2, ParameterSetName = "generalrequest")][ValidateNotNullOrEmpty()]
        [string]
        $status,

        # specify result size. default to 2
        [Parameter(Mandatory = $false, Position = 6)][ValidateNotNullOrEmpty()]
        [int]
        $resultSize = 2,

        # ServiceDesk Plus API KEY
        [Parameter(Mandatory = $false, Position = 7)][ValidateNotNullOrEmpty()]
        [string] $apiKey = $SDPConf.ApiKey,
    
        # Base URI of the ServiceDesk Plus server, i.e. https://sdp.example.com
        [Parameter(Mandatory = $false, Position = 8)][ValidateNotNullOrEmpty()]
        [string] $SDPUrl = $SDPConf.Url

    )

    process {
        # Building the API Endpoint
        $endpoint = "$SDPUrl/api/v3/requests"
  
        # Build the headers for the API call
        $technician_key = @{"authtoken" = $apiKey }

        $body = @{
            "list_info" = @{
                "row_count"       = $resultSize
                "start_index"     = 1
                "sort_field"      = "created_time"
                "sort_order"      = "desc"
                "get_total_count" = $true
                "search_fields"   = @{
                    "requester.name" = $requesterName
                }
            }
        }
        if ($subject) {
            $body.list_info.search_fields.Add("subject", $subject)
        }
        if ($serviceCategory) {
            $body.list_info.search_fields.Add("service_category.name", $serviceCategory)
        }
        if ($serviceTemplate) {
            $body.list_info.search_fields.Add("template.name", $serviceTemplate)
        }
        if ($category) {
            $body.list_info.search_fields.Add("category.name", $category)
        }
        if ($subCategory) {
            $body.list_info.search_fields.Add("subcategory.name", $subCategory)
        }
        if ($Item) {
            $body.list_info.search_fields.Add("item.name", $Item)
        }
        if ($Status) {
            $body.list_info.search_fields.Add("status.name", $Status)
        }

        $data = @{ 'input_data' = ($body | ConvertTo-Json -Depth 3) }

        # Make the API call to add the approval
        # Important note:
        # We're not doing https response error handling, because DotNet is doning this natively. the only downside with this is that if you set $ErrorActionPreference to a non-stoppable value, this may cause unexpected behaviour.
        # if direct error handling is prefered here, return HttpResponseException or HttpResponseException::new($Search.response_status.messages[0] might be something to start with.
        $Search = Invoke-RestMethod -Method Get -Uri $endpoint -Headers $technician_key -Body $data -ContentType "application/x-www-form-urlencoded" 

        # proceed if there search succeeded AND we have anyresults
        if (($Search.response_status.status_code -eq 2000) -and ($Search.requests.Count -ge 1)) {

            foreach ($returnedRequest in $Search.requests) {
                [PSCustomObject] @{
                    Id                          = $returnedRequest.id
                    Status                      = $returnedRequest.status.name
                    Subject                     = $returnedRequest.subject
                    RequesterName               = $returnedRequest.requester.name
                    RequesterEmail              = $returnedRequest.requester.email_id
                    Department                  = $returnedRequest.requester.department.name
                    Category                    = $returnedRequest.category.name
                    isServiceRequest            = $returnedRequest.is_service_request
                    TechnicianName              = $returnedRequest.technician.name
                    TechnicianEmail             = $returnedRequest.technician.email_id
                    Group                       = $returnedRequest.group.name
                    Priority                    = $returnedRequest.priority.name
                    Site                        = $returnedRequest.site.name
                    Description                 = $returnedRequest.short_description
                    Template                    = $returnedRequest.template.name
                    cancel_requested            = $returnedRequest.cancel_requested
                    cancel_requested_is_pending = $returnedRequest.cancel_requested_is_pending
                    CreatedTime                 = if ($returnedRequest.created_time) { $returnedRequest.created_time.display_value | Get-Date } else { $null }
                }
            }
        }
    }
}