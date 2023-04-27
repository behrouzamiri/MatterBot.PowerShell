function Get-MMChannel {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$MMUrl,
        [Parameter(Mandatory = $true)]
        [string]$ChannelName,
        [Parameter(Mandatory = $true)]
        [string]$TeamID,
        [Parameter(Mandatory = $true)]
        [string]$AccessToken
    )
    
    $url = "$MMUrl/api/v4/teams/$TeamID/channels/name/$ChannelName"
    # your API token here
    $headers = @{'Authorization' = 'Bearer ' + $AccessToken}

    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
        return $response.id
    } catch {
        Write-Error "Error: $($_.Exception.Message)"
    }
}

function Get-MMTeams {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$MMUrl,
        [Parameter(Mandatory = $true)]
        [string]$AccessToken
    )
    
    $url = "$MMUrl/api/v4/teams"
    $headers = @{'Authorization' = 'Bearer ' + $AccessToken}
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
        return $response
    } catch {
        Write-Error "Error: $($_.Exception.Message)"
    }
}

function Find-MMChannel {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SearchString,
        [Parameter(Mandatory = $true)]
        [string]$TeamID,
        [Parameter(Mandatory = $true)]
        [string]$MMUrl,
        [Parameter(Mandatory = $true)]
        [string]$AccessToken
    )

    $url = "$MMUrl/api/v4/teams/$TeamID/channels"
    $headers = @{'Authorization' = 'Bearer ' + $AccessToken}
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
        return $response | Where-Object { $_.display_name -match $SearchString }
    } catch {
        Write-Error "Error: $($_.Exception.Message)"
    }
}
function Add-MMPost {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$MMUrl,
        [Parameter(Mandatory = $true)]
        [string]$ChannelId,
        [Parameter(Mandatory = $true)]
        [string]$AccessToken,
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter()]
        [string]$ThreadId
    )

    $url = "$MMUrl/api/v4/posts"
    $headers = @{'Authorization' = 'Bearer ' + $AccessToken}
    $body = @{
        channel_id = $ChannelId
        message = $Message
        root_id = $ThreadId
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body ($body | ConvertTo-Json)
        return $response
    } catch {
        Write-Error "Error: $($_.Exception.Message)"
    }
}

function Remove-MMPost {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$MMUrl,
        [Parameter(Mandatory = $true)]
        [string]$PostId,
        [Parameter(Mandatory = $true)]
        [string]$AccessToken
    )

    $url = "$MMUrl/api/v4/posts/$PostId"
    $headers = @{'Authorization' = 'Bearer ' + $AccessToken}

    try {
        $response = Invoke-RestMethod -Uri $url -Method DELETE -Headers $headers
        return $response
    } catch {
        Write-Error "Error: $($_.Exception.Message)"
    }
}

Export-ModuleMember Get-MMChannel, Get-MMTeams, Find-MMChannel, Add-MMPost, Remove-MMPost