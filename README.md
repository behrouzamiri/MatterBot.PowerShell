# MatterBot.PowerShell

PowerShell Bot Framework for Mattermost server.
You can use it to bring Enterprise Edition features into MM server with your PowerShell mojo, however this can be used with Enterprise Edition as well.

The bot has 3 phases, with support of adding more phases into it. the main 3 phases are:
1. Moderation: includes channel restriction and word filtering. usually removes posts with matching criteria
2. Functionality: does action based on the parsed text.
3. Answer: provides virtual agent experience for the MM server, like FAQ answering.

All phases are in exact above oreder, meaning that an event (usually a Post) will go through phases in order, and bot will stop processing the message with more phases, as soon as a phase catches that. this is the intended behaviour.

# Installation

1. clone the repo:
git clone 
2. navigate to the repo directory:
cd 
3. Start the bot by simply running the Bot.ps1 file:

# Configuration

All the configuration for the bot are inside Config.psd1 file. you should specify your own server and token at least.
there are 

# Contribution
Please contribute! give idea and let's make it better.
