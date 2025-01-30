
<#
.SYNOPSIS
Script to help developers capture traces of the PlayFab Multiplayer C++ client library
#>
#Requires -RunAsAdministrator
param(
    # Provides a descriptive label suffix (e.g., "ConnectAttempt1") to append
    # to the default output trace file name placed in the current directory,
    # in order to describe or distinguish what's being recorded in the
    # particular trace.
    # This parameter is required unless an -OutputFile file path parameter is
    # specified, in which case this parameter will be ignored.
    [string]$TraceLabel,

    # Provides the desired output file path where the result trace file will be
    # written.
    # If this parameter is not specified, then the separate -TraceLabel
    # parameter must be provided instead. If both this parameter and -TraceLabel
    # are specified, only this parameter is used.
    [string]$OutputFile,

    # Optional verbosity specification.
    [ValidateSet("Normal", "Verbose", "VerboseWithAllocations")]
    [string]$Verbosity = "Normal",

    # Whether to include a raw packet capture and Windows OS networking stack
    # entries in the trace file.
    # NOTE: Using this switch may record networking activity on the device
    # beyond that which directly involves PlayFab Party, and is not recommended
    # unless specifically requested for additional support.
    # Defaults to false if not specified.
    [switch]$IncludePackets,

    # Sets a maximum output file size, in megabytes, for long-running traces of
    # scenarios that can't be narrowed another way. A circular buffer is used,
    # where only the most recent entries are kept if the output file would
    # exceed the maximum.
    # If not specified, this parameter defaults to 0, which does not constrain
    # trace output file size.
    [int]$MaxSizeInMB
    )

if (($OutputFile -ne $null) -and ($OutputFile -ne ""))
{
    if (($TraceLabel -ne $null) -and ($TraceLabel -ne ""))
    {
        Write-Host "Ignoring trace label `"$TraceLabel`" because output file -OutputFile parameter specified."
    }

    $traceFileName = $OutputFile
    if (Test-Path $traceFileName)
    {
        $outputFileProperties = Get-ItemProperty $traceFileName
        $outputFilePath = $outputFileProperties.FullName
        throw "Output file `"$outputFilePath`" already exists! Please run again specifiying a different file name."
    }
}
else
{
    if (($TraceLabel -ne $null) -and ($TraceLabel -ne ""))
    {
        $traceFileName = "pfm_trace_$TraceLabel.etl"
        if (Test-Path $traceFileName)
        {
            $outputFileProperties = Get-ItemProperty $traceFileName
            $outputFilePath = $outputFileProperties.FullName
            throw "Output file `"$outputFilePath`"' already exists! Please run again specifiying a different trace label."
        }
    }
    else
    {
        throw "This script requires either the -TraceLabel or -OutputFile parameter to be specified! Run Get-Help -Detailed $PSCommandPath for usage."
    }
}

switch ($Verbosity)
{
    "Normal"
    {
        # Lobby WPP
        $lobbyWppProvider  = "provider={12F0DBB7-BB3F-48DB-BB36-BBE50B15DBC5} keywords=0xFFFFFFFFFFE5552F level=5"
        # PubSub WPP
        $pubSubWppProvider = "provider={8A3540B9-E562-4C93-8A8F-F4204993AFEB} keywords=0xFFFFFFFFFFFC955F level=5"
        # XNUP WPP
        $xnupWppProvider = "provider={48EA4DB0-8D7E-419B-B465-E5B572F30305} keywords=0xFFFFFFFFFFFFFF9F level=5"
        # MU WPP
        $muWppProvider   = "provider={7F3BF311-D4F4-47D4-B5A0-575C0AFA01DD} keywords=0xFFFFFFFFFFFFFFF7 level=5"
        # XPN WPP
        $xpnWppProvider  = "provider={EE5FF703-7DEE-4E68-BD10-54F1BC71B349} keywords=0xFFFFFFFFFFFFFFEF level=5"
    }
    "Verbose"
    {
        # Lobby WPP
        $lobbyWppProvider  = "provider={12F0DBB7-BB3F-48DB-BB36-BBE50B15DBC5} keywords=0xFFFFFFFFFFFFFF7F level=5"
        # PubSub WPP
        $pubSubWppProvider = "provider={8A3540B9-E562-4C93-8A8F-F4204993AFEB} keywords=0xFFFFFFFFFFFFFF7F level=5"
        # XNUP WPP
        $xnupWppProvider = "provider={48EA4DB0-8D7E-419B-B465-E5B572F30305} keywords=0xFFFFFFFFFFFFFFDF level=5"
        # MU WPP
        $muWppProvider   = "provider={7F3BF311-D4F4-47D4-B5A0-575C0AFA01DD} keywords=0xFFFFFFFFFFFFFFF7 level=5"
        # XPN WPP
        $xpnWppProvider  = "provider={EE5FF703-7DEE-4E68-BD10-54F1BC71B349} keywords=0xFFFFFFFFFFFFFFFF level=5"
    }
    "VerboseWithAllocations"
    {
        # Lobby WPP
        $lobbyWppProvider  = "provider={12F0DBB7-BB3F-48DB-BB36-BBE50B15DBC5} keywords=0xFFFFFFFFFFFFFFFF level=5"
        # PubSub WPP
        $pubSubWppProvider = "provider={8A3540B9-E562-4C93-8A8F-F4204993AFEB} keywords=0xFFFFFFFFFFFFFFFF level=5"
        # XNUP WPP
        $xnupWppProvider = "provider={48EA4DB0-8D7E-419B-B465-E5B572F30305} keywords=0xFFFFFFFFFFFFFFFF level=5"
        # MU WPP
        $muWppProvider   = "provider={7F3BF311-D4F4-47D4-B5A0-575C0AFA01DD} keywords=0xFFFFFFFFFFFFFFFF level=5"
        # XPN WPP
        $xpnWppProvider  = "provider={EE5FF703-7DEE-4E68-BD10-54F1BC71B349} keywords=0xFFFFFFFFFFFFFFFF level=5"
    }
}

if ($IncludePackets)
{
    Write-Warning "A packet capture was requested with this trace. The resulting output file may therefore record Internet/networking activity on this device beyond just PlayFab Party communication, such as potentially sensitive web browser or private local network connections."
    Write-Host ""
    Write-Host "Please close all unneeded background applications, and never store the resulting output file in an insecure location."
    Write-Host ""
    Write-Host "Be aware that providing the output file to Microsoft support agents may allow them visibility of such networking activities. However only the minimum information required for PlayFab Party support will be used, and no parts will ever be shared with anyone for any reason. All records will be deleted once the support issue has been resolved."
    Write-Host ""
    Read-Host "To abort, press Control-C. Otherwise, press 'Enter'"
    $captureString = "capture=yes"
    # TCP/IP
    $osNetworkingProviders = "provider={2F07E2EE-15DB-40F1-90EF-9D7BA282188A} keywords=0xFFFFFFFFFFFFFFFF level=5"
    # AFD
    $osNetworkingProviders += " provider={E53C6823-7BB8-44BB-90DC-3F86090D48A6} keywords=0xFFFFFFFFFFFFFFFF level=5"
    # BFE
    $osNetworkingProviders += " provider={106B464A-8043-46B1-8CB8-E92A0CD7A560} keywords=0xFFFFFFFFFFFFFFFF level=5"
    # fwpkclnt
    $osNetworkingProviders += " provider={AD33fA19-F2D2-46D1-8F4C-E3C3087E45AD} keywords=0xFFFFFFFFFFFFFFFF level=5"
    # fwpuclnt
    $osNetworkingProviders += " provider={5A1600D2-68E5-4DE7-BCF4-1C2D215FE0FE} keywords=0xFFFFFFFFFFFFFFFF level=5"
    # WFP
    $osNetworkingProviders += " provider={0C478C5B-0351-41B1-8C58-4A6737DA32E3} keywords=0xFFFFFFFFFFFFFFFF level=5"
    # DNS
    $osNetworkingProviders += " provider={1C95126E-7EEA-49A9-A3FE-A378B03DDB4D} keywords=0xFFFFFFFFFFFFFFFF level=5"
    # WS NR
    $osNetworkingProviders += " provider={B923F87A-B069-42B5-BD32-35623ABA1C48} keywords=0xFFFFFFFFFFFFFFFF level=5"
    # WebIO
    $osNetworkingProviders += " provider={50B3E73C-9370-461D-BB9F-26F32D68887D8} keywords=0xFFFFFFFFFFFFFFFF level=5"
    # WebIO WPP
    $osNetworkingProviders += " provider={08F93B14-1608-4a72-9CFA-457EECEDBBA7} keywords=0xFFFFFFFFFFFFFFFF level=5"
    # WinHttp
    $osNetworkingProviders += " provider={7d44233d-3055-4b9c-ba64-0d47ca40a232} keywords=0xFFFFFFFFFFFFFFFF level=5"
    # WinHttp WPP
    $osNetworkingProviders += " provider={B3A7698A-0C45-44DA-B73D-E181C9B5C8E6} keywords=0xFFFFFFFFFFFFFFFF level=5"
}
else
{
    $captureString = "capture=no"
    $osNetworkingProviders = ""
}

$providersString = @($lobbyWppProvider, $pubSubWppProvider, $xnupWppProvider, $muWppProvider, $xpnWppProvider, $osNetworkingProviders) -Join " "

# Attempt to determine if the netsh trace start command supports the
# 'bufferSize' parameter on this system by looking for the "bufferSize=" string
# in the command's help output text.
$netshTraceHelpOutput = [string](netsh trace start help)
if ($netshTraceHelpOutput.Contains("bufferSize="))
{
    $bufferSizeString = "buffersize=512"
}
else
{
    $bufferSizeString = ""
}

# Configure the appropriate output file size limit and mode.
if (($MaxSizeInMB -ne $null) -and ($MaxSizeInMB -gt 0))
{
    $maxSizeString = "maxSize=$MaxSizeInMB fileMode=circular"
}
else
{
    $maxSizeString = "maxSize=0 fileMode=single"
}

$netshStartCmd = "netsh trace start $bufferSizeString overwrite=no tracefile=`"$traceFileName`" $captureString report=disable $maxSizeString $providersString"

Write-Host $netshStartCmd
cmd /c $netshStartCmd
if ($LASTEXITCODE -eq 0)
{
    Write-Host "Successfully started recording trace log."
    Write-Host ""
    Write-Host "Now please run your scenario."
    Read-Host "When complete, press 'Enter' to stop recording"

    cmd /c "netsh trace stop"
    if ($LASTEXITCODE -eq 0)
    {
        $outputFileProperties = Get-ItemProperty $traceFileName
        if ($outputFileProperties)
        {
            $outputFileSize = $outputFileProperties.Length
            $outputFilePath = $outputFileProperties.FullName
            Write-Host "Successfully wrote $outputFileSize byte trace file $outputFilePath"
        }
        else
        {
            Write-Error "Trace file $traceFileName was not successfully written!"
        }            
    }
    else
    {
        Write-Error "An error occurred attempting to stop the trace!"
    }
}
else
{
    Write-Error "An error occurred attempting to start the trace!"
}
