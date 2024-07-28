# invoke-build




## Core


### Boostrapper [_(invokebuild.bootstrap.bat)_](invokebuild.bootstrap.bat)
>*To be documented.*


### Entry Script [_(.build.ps1)_](.build.ps1)
>*To be documented.*

#### Commands
- `INVOKEBUILD:SETUP [-Late] <Script>`


### Tasks [_(common.build.ps1)_](common.build.ps1)
>*To be documented.*

TASK `.` <br/>
TASK `..` <br/>
TASK `...` <br/>
TASK `/` <br/>
`__InvokeBuild::IsTaskDefined <Name>` <br/>
`__InvokeBuild::IsTaskMissing <Name>` <br/>


### Helpers [_(common.helpers.ps1)_](common.helpers.ps1)
>*To be documented.*

#### Functions
- `Join-Paths <Paths...>`
- `... | Out-FileUTF8NoBOM <Path> [-Append]`




## Plugins


### [argument](argument.plugin.ps1)
>*To be documented.*

#### Commands
- `ARGUMENT:GET <Name> [<Default>]` <br/>
  `ARGUMENT:GET -Boolean <Name> [<Default>]` <br/>
  `ARGUMENT:GET -Number <Name> [<Default>]` <br/>
  `ARGUMENT:GET -String <Name> [<Default>]` <br/>
  `ARGUMENT:GET -Switch <Name>` <br/>
  `ARGUMENT:GET -Test <Name>` <br/>
  `ARG` (alias for `ARGUMENT:GET`) <br/>


### [bundle](bundle.plugin.ps1)
>*To be documented.*

#### Commands
- `BUNDLE:TAG <Name> [<Value>]`
- `BUNDLE:TAG <NameValueHashtable>`
- `BUNDLE:CONFIGURE [<Tag>] [-SourceDir <Path>] [-WorkDir <Path>] [-OutputDir <Path>] [-Clean]`
- `BUNDLE:COLLECT [-Tag <Tag>] <Path> [-To <Path>] [-Rename <Name>]`
- `BUNDLE:COLLECT [-Tag <Tag>] <Paths[]> [-To <Path>]`
- `BUNDLE` (alias for `BUNDLE:COLLECT`)
- `BUNDLE:OUTPUT [-Tag <Tag>] <Artifact> -As <Bundler> [@Passthrough]`
- `BUNDLE:CLEAN [-Purge]`
#### Functions
`__InvokeBuild::Plugin::Bundle::MakeBundler <Name> [-Extension <Extension>] <Script>` <br/>

#### Extensions
- [zip](bundle.zip.extension.ps1)
  &ndash; *To be documented.*


### [config](config.plugin.ps1)
>*To be documented.*

- `CONFIG:LOAD [-Immediate] <ValuesHashtable>` <br/>
  `CONFIG:LOAD [-Immediate] <File>`
- `CONFIG:VALUE <Name> -Default <Value>` (`<Value>` can be `$null` - which means it needs to be specified) <br/>
  `CONFIGURE` (alias for `CONFIG:VALUE`)
- `CONFIG:GET <Name>` <br/>
  `CONF` (alias for `CONFIG:GET`)




## Scripts


### [cxx:docs](cxx.docs.build.ps1)
>*To be documented.*

#### Dependencies
- (plugin) [config](config.plugin.ps1)

#### Configuration
- `.directory` &ndash; ... (defaults to `"docs"`)
- `.generator` &ndash; ... (defaults to `"html"`)

#### Tasks
- `build` &ndash; ...
- `show` &ndash; ...
- `clean` &ndash; ...


### [flutter](flutter.build.ps1)
>*To be documented.*

#### Dependencies
- (plugin) [config](config.plugin.ps1)

#### Configuration
- `.platform` &ndash; ... (defaults to `"windows"`)

#### Tasks
- `setup` &ndash; ...
- `build` &ndash; ...
- `run` &ndash; ...
- `clean` &ndash; ...
- `purge` &ndash; ...


### [python:cog](python.cog.build.ps1)
>*To be documented.*

#### Dependencies
- (plugin) [config](config.plugin.ps1)
- (script) [python:venv](python.venv.build.ps1)

#### Configuration
- `.quiet` &ndash; ... (defaults to `$false`)
- `.verbose` &ndash; ... (defaults to `$false`)
- `.markers` &ndash; ... (defaults to `"[[[cog ]]] [[[end]]]"`)
- `.include` &ndash; ... (defaults to `@()`)
- `.prologue` &ndash; ... (defaults to `""`)
- `.replace` &ndash; ... (defaults to `$true`)
- `.paths` &ndash; ... (defaults to `@()`)
- `.filter` &ndash; ... (defaults to `@()`)
- `.presetmode` &ndash; ... (defaults to `$false`)

#### Tasks
- `run` &ndash; ...


### [python:hatch](python.hatch.ps1)

#### Dependencies
- (plugin) [config](config.plugin.ps1)
- (script) [python:venv](python.venv.build.ps1)

#### Configuration
- `.output` &ndash; Specifies the output directory. (defaults to `"dist"`)

#### Tasks
- `build` &ndash; Builds the package.
  <br/>*<small>@( affected by `.output` )</small>*
- `install` &ndash; Installs the built wheel into the virtual environment.
- `uninstall` &ndash; Uninstalls the built wheel from the virtual environment.
- `clean` &ndash; Removes the source distribution from the output directory.
- `purge` &ndash; Removes all targets from the output directory.


### [python:venv](python.venv.build.ps1)

#### Dependencies
- (plugin) [config](config.plugin.ps1)

#### Configuration
- `.shorthands` &ndash; Specifies whether to define the `..` task. (default to `$true`)
- `.version` &ndash; The version to use for creating the virtual environment. (default to `"default"`)
- `.path` &ndash; The path where the virtual environment should be created. (default to `".venv"`)
- `.requirements` &ndash; The requirements file specifying the requirements to automatically install. (default to `"requirements.txt"`)
- `.compilants` &ndash; Additional requirements files to compile. (default to `@()`)

#### Tasks
- `..` &ndash; Alias for `activate`. (Only if not explicitly defined otherwise.)
- `activate` &ndash; Activates the virtual environment.
- `deactivate` &ndash; Deactivates the virtual environment.
- `setup` &ndash; Creates the virtual environment and installs the requirements. (This is basically a shorthand for running `create` and `install`.)
- `create` &ndash; Creates the virtual environment.
  <br/>*<small>@( affected by `.version`, `.path` )</small>*
- `compile` &ndash; Compiles all requirements files.
  <br/>*<small>@( affected by `.requirements`, `.compilants` )</small>*
- `install` &ndash; Installs the specified requirements.
  <br/>*<small>@( affected by `.requirements` )</small>*
- `reinstall` &ndash; Reinstalls the virtual environment and the specified requirements.
  <br/>*<small>@( affected by `.requirements` )</small>*
- `purge` &ndash; Destroys the virtual environment.
  <br/>*<small>@( affected by `.path` )</small>*
