$serviceName = "ds_agent"
$ACTIVATIONURL = "dsm://agents.deepsecurity.trendmicro.com:443/"
$Proxy_Addr_Port = "YOUR VALUES HERE"
$Proxy_User = "YOUR VALUES HERE"
$Proxy_Password = "YOUR VALUES HERE"
$Relay_Proxy_Addr_Port = "YOUR VALUES HERE"
$Relay_Proxy_UserPass = "YOUR VALUES HERE"
$LogFilePath = "C:\Path\to\log\file.log" #update this with the path to your desired log file

# Start transcript logging
Start-Transcript -Path $LogFilePath -Force

try {
    # Check if the service is running, if it is then deactivate and re-activate using proxy
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($service -ne $null) {
        if ($service.Status -eq "Running") {
            Write-Host "The service $serviceName is running. Running activation command..."
            try {
                & $Env:ProgramFiles"\Trend Micro\Deep Security Agent\dsa_control" -r
                Start-Sleep -Seconds 50
                & $Env:ProgramFiles"\Trend Micro\Deep Security Agent\dsa_control" -x ([string]::Format("dsm_proxy://{0}/", $Proxy_Addr_Port))
                & $Env:ProgramFiles"\Trend Micro\Deep Security Agent\dsa_control" -u ([string]::Format("{0}:{1}", $Proxy_User, $Proxy_Password))
                & $Env:ProgramFiles"\Trend Micro\Deep Security Agent\dsa_control" -y ([string]::Format("relay_proxy://{0}/", $Relay_Proxy_Addr_Port))
                & $Env:ProgramFiles"\Trend Micro\Deep Security Agent\dsa_control" -w $Relay_Proxy_UserPass
                & $Env:ProgramFiles"\Trend Micro\Deep Security Agent\dsa_control" -a $ACTIVATIONURL "tenantID:<YOUR-VALUES-HERE>" "token:<YOUR-VALUES-HERE>"

            } catch {
                Write-Host "An error occurred while running the command: $_"
            }
        } else {
            Write-Host "The service $serviceName is not running."
        }
    } else {
        Write-Host "The service $serviceName was not found."
    }
} catch {
    Write-Host "An error occurred while running the script: $_"
}

# Stop transcript logging
Stop-Transcript
