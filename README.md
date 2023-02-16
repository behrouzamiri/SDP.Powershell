# SDP.PowerShell

PowerShell module offering Cmdlets and functions required to interact with ManageEngine ServiceDesk Plus.


This module is actually a wrapper that interacts with the ManageEngine v3 API. for more information, please refer to the ManageEngine v3 API [here](https://www.manageengine.com/products/service-desk/sdpod-v3-api/)


Contribution is highly appreciated

# Installation:
    simply install this module like any other powershell module.

    alternatively, you can CD into the module directory, then use `Import-Modlue` to import it without installation:
    ```
    cd /Users/behrouz/PS/sdp.powershell
    Import-Module ./sdp.powershell.psm1 -Force -Verbose
    ```