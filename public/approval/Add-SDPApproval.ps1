<#
    .SYNOPSIS
        Adds a ServiceDesk Plus request approval by request ID. 

    .DESCRIPTION
        The function "Add-SDPRequestApproval" submits a request for approval to ServiceDesk Plus using the API. The function requires the following parameters:

        $requestId: The ID of the request that requires approval.
        $approverEmail: The email address of the approver.
        $requesterName: The name of the person who made the request.
        $requestSubject: The subject of the request.
        Optional:
        $approvalSubject: The subject line of the approval email.
        $requestLink: The URL of the request in ServiceDesk Plus.
        $approvalMessage: The message to be included in the approval email.
        $apiKey: The API key for the ServiceDesk Plus account. If not provided, the function will use the API key stored in the $SDPConf.ApiKey variable.
        $SDPUrl: The base URL of the ServiceDesk Plus server. If not provided, the function will use the URL stored in the $SDPConf.Url         variable.

        Also, as note, if you don't want to use the templates, you can use bellow string as `message` parameter
        #"A request requires your approval. Please use <a href=`"`$ApprovalLink`">This Link</a> to either approve or reject this. ALSO, you can take action by simply reply to this message and write in the first line either `"approve`" or `"reject`" with no extra characters.</br>Regards, Your ITSM System - Your Company",

    .EXAMPLE
        PS C:\> Add-SDPRequestApproval 12345 "approver@example.com"
        Adds a ServiceDesk Plus request approval to request with ID 12345 for approver@example.com with the default subject and message.

    .EXAMPLE
        PS C:\> Add-SDPRequestApproval 12345 "approver@example.com" "Custom Subject" "Custom Message"
        Adds a ServiceDesk Plus request approval to request with ID 12345 for approver@example.com with a custom subject and message.

#>
function Add-SDPRequestApproval {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()]
    [int] $requestId,

    [Parameter(Mandatory = $true, Position = 1)][ValidateNotNullOrEmpty()]
    [string] $approverEmail,

    [Parameter(Mandatory = $false, Position = 2)]
    [string] $approvalSubject = "Approval Required for Request ID $requestId",
    
    [Parameter(Mandatory = $true, Position = 3)][ValidateNotNullOrEmpty()]
    [string] $requesterName,

    [Parameter(Mandatory = $true, Position = 4)][ValidateNotNullOrEmpty()]
    [string] $requestSubject,
    
    [Parameter(Mandatory = $false, Position = 6)]
    [string] $approvalMessageTemplate ,

    # ServiceDesk Plus API KEY
    [Parameter(Mandatory = $false, Position = 7)][ValidateNotNullOrEmpty()]
    [string] $apiKey = $SDPConf.ApiKey,
    
    # Base URI of the ServiceDesk Plus server, i.e. https://sdp.example.com
    [Parameter(Mandatory = $false, Position = 8)][ValidateNotNullOrEmpty()]
    [string] $SDPUrl = $SDPConf.Url
  )
  # Set the Approval link
  $requestLink = "$($SDPConf.Url)/WorkOrder.do?woMode=viewWO&woID=$requestId"
  # Set a default approval email template if not provided
  # Set a default approval email template if not provided
  if (!$approvalMessageTemplate) {
    $approvalMessage = Set-SDPTemplate -Template approvalmessage -CustomName $requesterName -Subject $requestSubject -TicketID $requestId -Link $requestLink
  }
  else {
    $approvalMessage = Set-SDPTemplate -Template $approvalMessageTemplate -CustomName $requesterName -Subject $requestSubject -TicketID $requestId -Link $requestLink
  }

  # Building the API Endpoint
  $endpoint = "$SDPUrl/api/v3/requests/$RequestId/submit_for_approval"
  
  # Build the headers for the API call
  $technician_key = @{"authtoken" = $apiKey }

  # Build the body of the API request
  $body = @{
    "approvals"    = @(
      @{
        "approver" = @{
          "email_id" = $approverEmail
        }
      }
    )
    "notification" = @{
      "title"       = $approvalSubject
      "description" = $approvalMessage
    }
  } | ConvertTo-Json -Depth 3


  $data = @{ 'input_data' = $body }

  # Make the API call to add the approval
  Invoke-RestMethod -Method Post -Uri $endpoint -Headers $technician_key -Body $data -ContentType "application/x-www-form-urlencoded"
}
