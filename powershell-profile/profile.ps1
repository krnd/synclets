################################## Preface #####################################

$script:ISWORKWISE = ("IEB-BR" -eq $env:USERDOMAIN)


################################## Settings ####################################

######################## Oh My Posh ########################
#   https://ohmyposh.dev

# Apply custom prompt theme.
oh-my-posh init pwsh --config (Resolve-Path -Path (Join-Path $env:USERPROFILE (Join-Path ".config" "oh-my-posh.json"))).Path | Invoke-Expression

# Enable transient prompt feature.
Enable-PoshTransientPrompt


######################## pipenv ############################
#   https://pipenv.pypa.io

# If set, use `.venv` in your project directory instead of the global virtualenv
# manager `pew`.
$env:PIPENV_VENV_IN_PROJECT = 1


######################### PSReadLine #######################
#Requires -Modules PSReadLine
#   https://learn.microsoft.com/en-us/powershell/module/psreadline

# No error and anbiguous conditions feedback.
Set-PSReadLineOption -BellStyle None
# Command line editing mode emulate Bash or Emacs.
Set-PSReadLineOption -EditMode Emacs


######################## Terminal-Icons ####################
#Requires -Modules Terminal-Icons
#   https://github.com/devblackops/Terminal-Icons

Import-Module -Name Terminal-Icons


######################## virtualenv ########################
#   https://virtualenv.pypa.io

# Activator scripts also modify your shell prompt to indicate which environment
# is currently active, by prepending the environment name (or the name specified
# by `--prompt` when initially creating the environment) in brackets, like
# `(venv)`. You can disable this behavior by setting the environment variable
# `VIRTUAL_ENV_DISABLE_PROMPT` to any value. You can also get the environment
# name via the environment variable `VIRTUAL_ENV_PROMPT` if you want to
# customize your prompt, for example.
$env:VIRTUAL_ENV_DISABLE_PROMPT = 1


######################## zoxide ############################
#   https://github.com/ajeetdsouza/zoxide

Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --hook $hook powershell | Out-String)
})


################################## Aliases #####################################

######################## InvokeBuild #######################
#Requires -Modules InvokeBuild
#   https://github.com/nightroman/Invoke-Build

New-Alias -Name ib -Value Invoke-Build


################################## Shortcuts ###################################

# Set-PSReadlineKeyHandler -Chord <key> -ScriptBlock {
#   <script-block>
# }


################################## Variables ###################################

# ...
