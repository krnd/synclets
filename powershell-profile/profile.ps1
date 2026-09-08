# ################################ PREFACE #####################################

$global:ISWORKWISE = $null

. (Join-Path $PSScriptRoot "profile.local.ps1")

if ($null -eq $global:ISWORKWISE) {
    throw "Local profile does not set 'ISWORKWISE'."
}


# ################################ SETTINGS ####################################

# ###################### Oh My Posh ########################
# https://ohmyposh.dev

Invoke-Expression (& {
        $Theme = (Join-Path `
            (Join-Path $env:USERPROFILE ".config") `
            (Join-Path "oh-my-posh" "theme.json"))
        (oh-my-posh init pwsh --config $Theme | Out-String)
    })


# ###################### pipenv ############################
# https://pipenv.pypa.io

# If set, use `.venv` in your project directory instead of the global virtualenv
# manager `pew`.
$env:PIPENV_VENV_IN_PROJECT = 1


# ###################### PSReadLine ########################
# https://learn.microsoft.com/powershell/module/psreadline

#Requires -Modules PSReadLine

# Specifies how PSReadLine responds to various error and ambiguous conditions.
Set-PSReadLineOption -BellStyle None
# Specifies the command line editing mode.
Set-PSReadLineOption -EditMode Windows
# Specifies the maximum number of commands to save in PSReadLine history.
Set-PSReadLineOption -MaximumHistoryCount 16384
# This option controls the recall behavior.
Set-PSReadLineOption -HistoryNoDuplicates
# Indicates that the cursor moves to the end of commands that you load from
# history by using a search.
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

# Specifies the source for PSReadLine to get predictive suggestions.
Set-PSReadLineOption -PredictionSource History
# Sets the style for the display of the predictive text.
Set-PSReadLineOption -PredictionViewStyle InlineView


# ###################### Terminal-Icons ####################
# https://github.com/devblackops/Terminal-Icons

#Requires -Modules Terminal-Icons
# Import-Module -Name Terminal-Icons


# ###################### virtualenv ########################
# https://virtualenv.pypa.io

# Activator scripts also modify your shell prompt to indicate which environment
# is currently active, by prepending the environment name (or the name specified
# by `--prompt` when initially creating the environment) in brackets, like
# `(venv)`. You can disable this behavior by setting the environment variable
# `VIRTUAL_ENV_DISABLE_PROMPT` to any value. You can also get the environment
# name via the environment variable `VIRTUAL_ENV_PROMPT` if you want to
# customize your prompt, for example.
$env:VIRTUAL_ENV_DISABLE_PROMPT = 1


# ###################### zoxide ############################
# https://github.com/ajeetdsouza/zoxide

Invoke-Expression (& {
        (zoxide init powershell | Out-String)
    })


# ################################ ALIASES #####################################

# ###################### InvokeBuild #######################
# https://github.com/nightroman/Invoke-Build

#Requires -Modules InvokeBuild

New-Alias -Name ib -Value Invoke-Build


# ################################ KEYBINDINGS #################################

Set-PSReadLineKeyHandler -Chord "Ctrl+Spacebar" -Function SwitchPredictionView

Set-PSReadLineKeyHandler -Chord "UpArrow" -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Chord "DownArrow" -Function HistorySearchForward


# ################################ FUNCTIONS ###################################

# ###################### Claude ############################
# https://claude.ai

function Set-ClaudeProfile {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Name
    )
    $Path = (Join-Path $HOME ".claude-$Name")
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "Claude profile '$Name' does not exist."
    }
    # Switch the profile for every session started from now on.
    [Environment]::SetEnvironmentVariable("CLAUDE_CONFIG_DIR", $Path, "User")
    # Switch the profile for the current session.
    $env:CLAUDE_CONFIG_DIR = $Path
}
