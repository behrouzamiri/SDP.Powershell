# Load configuration file into all runspaces
$global:SDPConf = Import-PowerShellDataFile "$PSScriptRoot\Configuration.psd1"

# root path
$root = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

# load binaries if you have one like:
# Add-Type -AssemblyName System.Net.Http

# stop ansi colours in ps7.2+
#if ($PSVersionTable.PSVersion -ge [version]'7.2.0') {
#    $PSStyle.OutputRendering = 'PlainText'
#}

# load private functions
Get-ChildItem "$($root)/private" -Recurse -Include "*.ps1" | Resolve-Path | ForEach-Object { . $_ }

    # import everything
    $sysfuncs = Get-ChildItem Function:

# load public functions
Get-ChildItem "$($root)/public" -Recurse -Include "*.ps1" | Resolve-Path | ForEach-Object { . $_ }

# get functions from memory and compare to existing to find new functions added
$funcs = Get-ChildItem Function: | Where-Object { $sysfuncs -notcontains $_ }

# export the module's public functions
Export-ModuleMember -Function ($funcs.Name)