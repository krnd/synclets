################################## Modules #####################################

################### Oh My Posh #############################
#Requires -Modules oh-my-posh
#   https://ohmyposh.dev/docs

# Apply custom prompt theme.
Set-PoshPrompt -Theme (Resolve-Path -Path (Join-Path $env:USERPROFILE (Join-Path ".config" "oh-my-posh.json"))).ProviderPath

# Enable transient prompt feature.
Enable-PoshTransientPrompt

#################### PSReadLine ############################
#Requires -Modules PSReadLine
#   https://docs.microsoft.com/en-us/powershell/module/psreadline

# No error and anbiguous conditions feedback.
Set-PSReadLineOption -BellStyle None
# Command line editing mode emulate Bash or Emacs.
Set-PSReadLineOption -EditMode Emacs

################### Terminal-Icons #########################
#Requires -Modules Terminal-Icons
#   https://github.com/devblackops/Terminal-Icons

Import-Module -Name Terminal-Icons

################### zoxide #################################
#   https://github.com/ajeetdsouza/zoxide

Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --hook $hook powershell | Out-String)
})


################################## Shortcuts ###################################

# Set-PSReadlineKeyHandler -Chord <key> -ScriptBlock {
#   <script-block>
# }


################################## Aliases #####################################

#Requires -Modules InvokeBuild
#   https://github.com/nightroman/Invoke-Build
New-Alias -Name ib -Value Invoke-Build


################################## Variables ###################################

# Any virtualenv created when this is set to a non-empty value will not have
# it's activate script modify the shell prompt.
$env:VIRTUAL_ENV_DISABLE_PROMPT = 1

