#Requires -RunAsAdministrator
<#
.SYNOPSIS
Script to help developers capture traces of the PlayFabMultiplayer C++ client library
#>
param(
    # A label to append to the end of your tracefile to make it easier to identify
    # e.g. "Repro1"
    [Parameter(Mandatory=$true)]
    [string]$TraceLabel
    )

$traceFileName = "pfm_trace_$TraceLabel.etl"

# Lobby WPP - No verbose traces
$lobbyWppProvider  = "provider={12F0DBB7-BB3F-48DB-BB36-BBE50B15DBC5} keywords=0xFFFFFFFFFFE5552F level=5"
# PubSub WPP - No verbose traces
$pubSubWppProvider = "provider={8A3540B9-E562-4C93-8A8F-F4204993AFEB} keywords=0xFFFFFFFFFFFC955F level=5"
# XNUP WPP - No verbose traces
$xnupWppProvider = "provider={48EA4DB0-8D7E-419B-B465-E5B572F30305} keywords=0xFFFFFFFFFFFFFF9F level=5"
# MU WPP - No verbose traces
$muWppProvider   = "provider={7F3BF311-D4F4-47D4-B5A0-575C0AFA01DD} keywords=0xFFFFFFFFFFFFFFF7 level=5"
# XPN WPP - No verbose traces
$xpnWppProvider  = "provider={EE5FF703-7DEE-4E68-BD10-54F1BC71B349} keywords=0xFFFFFFFFFFFFFFEF level=5"

$providersString = @($lobbyWppProvider, $pubSubWppProvider, $xnupWppProvider, $muWppProvider, $xpnWppProvider) -Join " "
$netshStartCmd = "netsh trace start buffersize=512 overwrite=no tracefile=`"$traceFileName`" report=disable $providersString"

Write-Host $netshStartCmd
cmd /c $netshStartCmd

Read-Host "Run your scenario. Hit any key to stop the trace"

cmd /c "netsh trace stop"

Write-Host "Trace file written to $traceFileName"
