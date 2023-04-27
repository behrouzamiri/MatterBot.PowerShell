# Load Configurations
$global:BotConfig = Import-PowerShellDataFile .\config.psd1
# Load Modules
Import-Module ./modules/mattermost/MatterPosh.psm1

# Import Phases
# Load moderation phase function
. ./phases/moderation.ps1
. ./phases/functionality.ps1
. ./phases/answer.ps1

# Initialize Variables
$global:MMUrl = "$($BotConfig.Mattermost.Scheme)://$($Botconfig.Mattermost.Server)"
$global:AccessToken = $($BotConfig.Mattermost.AccessToken)
$WSURL = "ws://$($BotConfig.Mattermost.Server)/api/v4/websocket"
Try {
    Do {

        #Create a WebSocket Client object
        $WS = New-Object System.Net.WebSockets.ClientWebSocket
        $CT = New-Object System.Threading.CancellationToken
        #Connect to the mattermost WebSocket endpoint
        $Conn = $WS.ConnectAsync($WSURL, $CT)                                                  
        While (!$Conn.IsCompleted) { Start-Sleep -Milliseconds 100 }
        #we now must be connected
        Write-Host "Connected to $($WSURL)"

        #Now let's authenticate. I'm going to use the Websocket challenge method.
        $challenge = '{"seq": 1,"action": "authentication_challenge","data": {"token": "' + $AccessToken + '"}}'
        $chararray = $challenge.ToCharArray()
        # define a byte array as buffer that could be used for send/receive operations.
        $Size = 1024
        $Array = [byte[]] @(, 0) * $Size
        #now the REceiver and Sender streams as follow
        $Recv = New-Object System.ArraySegment[byte] -ArgumentList @(, $Array)
        $send = New-Object System.ArraySegment[byte] -ArgumentList @(, $chararray)
            
        #now lets send the authentication challenge 
        $Conn = $WS.SendAsync($send, [System.Net.WebSockets.WebSocketMessageType]::Text, [bool]$EOM, $CT)

        # Get the response over the WebSocket connection
        While ($WS.State -eq 'Open') {
            try {
                    
                Do {
                    $Conn = $WS.ReceiveAsync($Recv, $CT)
                    While (!$Conn.IsCompleted) { Start-Sleep -Milliseconds 100 }

                    $UTFresponse = [System.Text.Encoding]::UTF8.GetString($Recv.Array[0..($Conn.Result.Count - 1)]);
                } Until ($Conn.Result.Count -lt $Size)

                #output the response / you can log it if you want
                   ($UTFresponse | convertfrom-json)
                If ($UTFresponse) {
                    $MMEvent = ($UTFresponse | convertfrom-json)
                    

                    # Evaluate the message in each phase
                    if ($MMevent.event -eq "posted") {
                        if ($MMevent.data.channel_type -eq "O") {
                            # Invoke moderation rules on the post
                            ProcessMessageInModerationPhase $MMevent
                        }
                    }
                }
            }
            catch {
                $UTFresponse
                $Error[0]
            }
        }
    } until(!$Conn)
}
Catch {
    $Conn
    $Script:Error[0].Exception
    $Script:Error[0].ScriptStackTrace
}