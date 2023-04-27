function ProcessMessageInModerationPhase($MMEvent) {
    $moderationRules = (Get-Content .\rules\moderation.yaml | ConvertFrom-Yaml)
    $PostContent = $MMEvent.data.post | ConvertFrom-Json

    foreach ($restrictedChannel in $moderationRules.restricted_channels.pattern) {
        if ($MMEvent.data.channel_name -match $restrictedChannel) {
            $UserWhitelistRules = $moderationRules.restricted_channels.channels.allowed_users
            if ($UserWhitelistRules -notcontains $PostContent.user_id) {
                Remove-MMPost -PostId ($MMEvent.data.post | ConvertFrom-Json).id -MMUrl $MMUrl -AccessToken $AccessToken
                # Log the event if you want
                # Todo: add each event into a database, so we can refer to it or have actions, like moderation review or stuff
                # $MMEvent | Export-Clixml -Depth 20 -Path .\moderatedevent.xml -Encoding utf8
                return
            }
        }
    }
    
    $badWordRules = $moderationRules.bad_words
    if ($badWordRules) {
        foreach ($badWord in $badWordRules.pattern ) {
            if ($PostContent.message -match $badWord) {
                Remove-MMPost -PostId ($MMEvent.data.post | ConvertFrom-Json).id -MMUrl $MMUrl -AccessToken $AccessToken
                # Log the event if you want
                # Todo: add each event into a database, so we can refer to it or have actions, like moderation review or stuff
                # $MMEvent | Export-Clixml -Depth 20 -Path .\badwordevent.xml -Encoding utf8
                return
            }
        }
    }
}
