## Pre-Loaded Module code ##

<#
 Put all code that must be run prior to function dot sourcing here.

 This is a good place for module variables as well. The only rule is that no 
 variable should rely upon any of the functions in your module as they 
 will not have been loaded yet. Also, this file cannot be completely
 empty. Even leaving this comment is good enough.
#>

## PRIVATE MODULE FUNCTIONS AND DATA ##

function Get-CallerPreference {
    <#
    .Synopsis
       Fetches "Preference" variable values from the caller's scope.
    .DESCRIPTION
       Script module functions do not automatically inherit their caller's variables, but they can be
       obtained through the $PSCmdlet variable in Advanced Functions.  This function is a helper function
       for any script module Advanced Function; by passing in the values of $ExecutionContext.SessionState
       and $PSCmdlet, Get-CallerPreference will set the caller's preference variables locally.
    .PARAMETER Cmdlet
       The $PSCmdlet object from a script module Advanced Function.
    .PARAMETER SessionState
       The $ExecutionContext.SessionState object from a script module Advanced Function.  This is how the
       Get-CallerPreference function sets variables in its callers' scope, even if that caller is in a different
       script module.
    .PARAMETER Name
       Optional array of parameter names to retrieve from the caller's scope.  Default is to retrieve all
       Preference variables as defined in the about_Preference_Variables help file (as of PowerShell 4.0)
       This parameter may also specify names of variables that are not in the about_Preference_Variables
       help file, and the function will retrieve and set those as well.
    .EXAMPLE
       Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

       Imports the default PowerShell preference variables from the caller into the local scope.
    .EXAMPLE
       Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -Name 'ErrorActionPreference','SomeOtherVariable'

       Imports only the ErrorActionPreference and SomeOtherVariable variables into the local scope.
    .EXAMPLE
       'ErrorActionPreference','SomeOtherVariable' | Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

       Same as Example 2, but sends variable names to the Name parameter via pipeline input.
    .INPUTS
       String
    .OUTPUTS
       None.  This function does not produce pipeline output.
    .LINK
       about_Preference_Variables
    #>

    [CmdletBinding(DefaultParameterSetName = 'AllVariables')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_.GetType().FullName -eq 'System.Management.Automation.PSScriptCmdlet' })]
        $Cmdlet,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SessionState]$SessionState,

        [Parameter(ParameterSetName = 'Filtered', ValueFromPipeline = $true)]
        [string[]]$Name
    )

    begin {
        $filterHash = @{}
    }
    
    process {
        if ($null -ne $Name)
        {
            foreach ($string in $Name)
            {
                $filterHash[$string] = $true
            }
        }
    }

    end {
        # List of preference variables taken from the about_Preference_Variables help file in PowerShell version 4.0

        $vars = @{
            'ErrorView' = $null
            'FormatEnumerationLimit' = $null
            'LogCommandHealthEvent' = $null
            'LogCommandLifecycleEvent' = $null
            'LogEngineHealthEvent' = $null
            'LogEngineLifecycleEvent' = $null
            'LogProviderHealthEvent' = $null
            'LogProviderLifecycleEvent' = $null
            'MaximumAliasCount' = $null
            'MaximumDriveCount' = $null
            'MaximumErrorCount' = $null
            'MaximumFunctionCount' = $null
            'MaximumHistoryCount' = $null
            'MaximumVariableCount' = $null
            'OFS' = $null
            'OutputEncoding' = $null
            'ProgressPreference' = $null
            'PSDefaultParameterValues' = $null
            'PSEmailServer' = $null
            'PSModuleAutoLoadingPreference' = $null
            'PSSessionApplicationName' = $null
            'PSSessionConfigurationName' = $null
            'PSSessionOption' = $null

            'ErrorActionPreference' = 'ErrorAction'
            'DebugPreference' = 'Debug'
            'ConfirmPreference' = 'Confirm'
            'WhatIfPreference' = 'WhatIf'
            'VerbosePreference' = 'Verbose'
            'WarningPreference' = 'WarningAction'
        }

        foreach ($entry in $vars.GetEnumerator()) {
            if (([string]::IsNullOrEmpty($entry.Value) -or -not $Cmdlet.MyInvocation.BoundParameters.ContainsKey($entry.Value)) -and
                ($PSCmdlet.ParameterSetName -eq 'AllVariables' -or $filterHash.ContainsKey($entry.Name))) {
                
                $variable = $Cmdlet.SessionState.PSVariable.Get($entry.Key)
                
                if ($null -ne $variable) {
                    if ($SessionState -eq $ExecutionContext.SessionState) {
                        Set-Variable -Scope 1 -Name $variable.Name -Value $variable.Value -Force -Confirm:$false -WhatIf:$false
                    }
                    else {
                        $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                    }
                }
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'Filtered') {
            foreach ($varName in $filterHash.Keys) {
                if (-not $vars.ContainsKey($varName)) {
                    $variable = $Cmdlet.SessionState.PSVariable.Get($varName)
                
                    if ($null -ne $variable)
                    {
                        if ($SessionState -eq $ExecutionContext.SessionState)
                        {
                            Set-Variable -Scope 1 -Name $variable.Name -Value $variable.Value -Force -Confirm:$false -WhatIf:$false
                        }
                        else
                        {
                            $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                        }
                    }
                }
            }
        }
    }
}

## PUBLIC MODULE FUNCTIONS AND DATA ##

function Remove-MBTSignature
{
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.5/docs/Functions/Remove-MBTSignature.md
    #>

    [CmdletBinding( SupportsShouldProcess = $true )]
    Param (
        [Parameter(ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True)]
        [Alias('FilePath')]
        [string]$Path = $(Get-Location).Path,
        [Parameter()]
        [switch]$Recurse
    )
    Begin {
        $RecurseParam = @{}
        if ($Recurse) {
            $RecurseParam.Recurse = $true
        }
    }

    Process {
        $FilesToProcess = Get-ChildItem -Path $Path -File -Include '*.psm1','*.ps1','*.psd1','*.ps1xml' @RecurseParam

        $FilesToProcess | ForEach-Object -Process {
            $SignatureStatus = (Get-AuthenticodeSignature $_).Status
            $ScriptFileFullName = $_.FullName
            if ($SignatureStatus -ne 'NotSigned') {
                try {
                    $Content = Get-Content $ScriptFileFullName -ErrorAction Stop
                    $StringBuilder = New-Object -TypeName System.Text.StringBuilder -ErrorAction Stop

                    Foreach ($Line in $Content) {
                        if ($Line -match '^# SIG # Begin signature block|^<!-- SIG # Begin signature block -->') {
                            Break
                        }
                        else {
                            $null = $StringBuilder.AppendLine($Line)
                        }
                    }
                    if ($pscmdlet.ShouldProcess( "$ScriptFileFullName")) {
                        Set-Content -Path  $ScriptFileFullName -Value $StringBuilder.ToString()
                        Write-Output "$ScriptFileFullName -> Removed Signature!"
                    }
                }
                catch {
                    Write-Output "$ScriptFileFullName -> Unable to process signed file!"
                    Write-Error -Message $_.Exception.Message
                }
            }
            else {
                Write-Verbose "$ScriptFileFullName -> No signature, nothing done."
            }
        }
    }
}


function Publish-MBTProjectToPSGallery {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.5/docs/Functions/Upload-MBTProjectToPSGallery.md
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "",Scope="function",Justification="")]
    param(
        [parameter(Mandatory=$true, HelpMessage='Name of the module to upload.')]
        [string]$Name,
        [parameter(HelpMessage='Destination gallery (default is PSGallery)')]
        [string]$Repository = 'PSGallery',
        [parameter(HelpMessage='API key for the powershellgallery.com site.')]
        [string]$NuGetApiKey
    )
    # if no API key is defined then look for psgalleryapi.txt in the local profile directory and try to use it instead.
    if ([string]::IsNullOrEmpty($NuGetApiKey)) {
        $psgalleryapipath = "$(Split-Path $Profile)\psgalleryapi.txt"
        Write-Verbose "No PSGallery API key specified. Attempting to load one from the following location: $($psgalleryapipath)"
        if (-not (test-path $psgalleryapipath)) {
            Write-Error "$psgalleryapipath wasn't found and there was no defined API key, please rerun script with a defined APIKey parameter."
            return
        }
        else {
            $NuGetApiKey = get-content -raw $psgalleryapipath
        }
    }

    Publish-Module -Name $Name -NuGetApiKey $NuGetApiKey -Repository $Repository
}


function Get-MBTBuildEnvironment {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.5/docs/Functions/Get-MBTBuildEnvironment.md
    #>
    [CmdletBinding()]
    param(
        [parameter(Position = 0, ValueFromPipeline = $TRUE)]
        [String]$Path
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
    }
    process {
        # If no path was specified take a few guesses
        if ([string]::IsNullOrEmpty($Path)) {
            $Path = (Get-ChildItem -File -Filter "*.buildenvironment.json" -Path '.\','..\','.\build\' | Select-Object -First 1).FullName

            if ([string]::IsNullOrEmpty($Path)) {
                throw 'Unable to locate a *.buildenvironment.json file to parse!'
            }
        }
        if (-not (Test-Path $Path)) {
            throw "Unable to find the file: $Path"
        }

        try {
            $LoadedEnv = Get-Content $Path | ConvertFrom-Json
            $LoadedEnv | Add-Member -Name 'Path' -Value ((Resolve-Path $Path).ToString()) -MemberType 'NoteProperty'
            $LoadedEnv
        }
        catch {
            throw "Unable to load the build file in $Path"
        }
    }
}


function Get-MBTFunctionParameter {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.5/docs/Functions/Get-MBTFunctionParameter.md
    #>
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline=$true, HelpMessage='Lines of code to process.')]
        [string[]]$Code,
        [parameter(Position=1, HelpMessage='Name of function to process.')]
        [string]$Name,
        [parameter(Position=2, HelpMessage='Try to parse for script parameters as well.')]
        [switch]$ScriptParameters
    )
    begin {
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
        $Codeblock = @()
        $ParseError = $null
        $Tokens = $null
        # These are essentially our AST filters
        $functionpredicate = { ($args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]) }
        $parampredicate = { ($args[0] -is [System.Management.Automation.Language.ParameterAst]) }
        $typepredicate = { ($args[0] -is [System.Management.Automation.Language.TypeConstraintAst]) }
        $paramattributes = { ($args[0] -is [System.Management.Automation.Language.NamedAttributeArgumentAst]) }
        $output = @()
    }
    process {
        $Codeblock += $Code
    }
    end {
        $ScriptText = ($Codeblock | Out-String).trim("`r`n")
        Write-Verbose "$($FunctionName): Attempting to parse AST."
        $AST = [System.Management.Automation.Language.Parser]::ParseInput($ScriptText, [ref]$Tokens, [ref]$ParseError)
        if($ParseError) {
            $ParseError | Write-Error
            throw "$($FunctionName): Will not work properly with errors in the script, please modify based on the above errors and retry."
        }
        if (-not $ScriptParameters) {
            $functions = $ast.FindAll($functionpredicate, $true)
            if (-not [string]::IsNullOrEmpty($Name)) {
                $functions = $functions | Where-Object {$_.Name -eq $Name}
            }
            # get the begin and end positions of every for loop
            foreach ($function in $functions) {
                Write-Verbose "$($FunctionName): Processing function - $($function.Name.ToString())"
                $Parameters = $function.FindAll($parampredicate, $true)
                foreach ($p in $Parameters) {
                    $ParamType = $p.FindAll($typepredicate, $true)
                    Write-Verbose "$($FunctionName): Processing Parameter of type [$($ParamType.typeName.FullName)] - $($p.Name.VariablePath.ToString())"
                    $OutProps = @{
                        'FunctionName' = $function.Name.ToString()
                        'ParameterName' = $p.Name.VariablePath.ToString()
                        'ParameterType' = $ParamType[0].typeName.FullName
                    }
                    # This will add in any other parameter attributes if they are specified (default attributes are thus not included and output may not be normalized)
                    $p.FindAll($paramattributes, $true) | ForEach-Object {
                        $OutProps.($_.ArgumentName) = $_.Argument.Value
                    }
                    $Output += New-Object -TypeName PSObject -Property $OutProps
                }
            }
        }
        else {
            Write-Verbose "$($FunctionName): Processing Script parameters"
            if ($ast.ParamBlock -ne $null) {
                $scriptparams = $ast.ParamBlock
                $Parameters = $scriptparams.FindAll($parampredicate, $true)
                foreach ($p in $Parameters) {
                    $ParamType = $p.FindAll($typepredicate, $true)
                    Write-Verbose "$($FunctionName): Processing Parameter of type [$($ParamType.typeName.FullName)] - $($p.Name.VariablePath.ToString())"
                    $OutProps = @{
                        'FunctionName' = 'Script'
                        'ParameterName' = $p.Name.VariablePath.ToString()
                        'ParameterType' = $ParamType[0].typeName.FullName
                    }
                    # This will add in any other parameter attributes if they are specified (default attributes are thus not included and output may not be normalized)
                    $p.FindAll($paramattributes, $true) | ForEach-Object {
                        $OutProps.($_.ArgumentName) = $_.Argument.Value
                    }
                    $Output += New-Object -TypeName PSObject -Property $OutProps
                }
            }
            else {
                Write-Verbose "$($FunctionName): There were no script parameters found"
            }
        }
        $Output
        Write-Verbose "$($FunctionName): End."
    }
}


function Out-MBTZip {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.5/docs/Functions/Out-MBTZip.md
    #>
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $Directory,
        [Parameter(Position=1, Mandatory=$true)]
        [string] $FileName,
        [Parameter(Position=2)]
        [switch] $overwrite
    )
    Add-Type -Assembly System.IO.Compression.FileSystem
    $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
    if (-not $FileName.EndsWith('.zip')) {$FileName += '.zip'}
    if ($overwrite) {
        if (Test-Path $FileName) {
            Remove-Item $FileName
        }
    }
    [System.IO.Compression.ZipFile]::CreateFromDirectory($Directory, $FileName, $compressionLevel, $false)
}


Function Get-MBTSpecialPath {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.5/docs/Functions/Get-MBTSpecialPath.md
    #>
    Param (

    )
    $SpecialFolders = @{}
    $names = [Environment+SpecialFolder]::GetNames([Environment+SpecialFolder])
    ForEach ($name in $names) {
        $SpecialFolders[$name] = [Environment]::GetFolderPath($name)
    }
    $SpecialFolders
}


Function Set-MBTBuildEnvironment {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.5/docs/Functions/Set-MBTBuildEnvironment.md
    #>

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "",Scope="function",Justification="")]
    param(
        [parameter(Position = 0, ValueFromPipeline = $TRUE)]
        [String]$Path
    )
    DynamicParam {
        # Create dictionary
        $DynamicParameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        if ([String]::isnullorempty($Path)) {
            $BuildPath = (Get-ChildItem -File -Filter "*.buildenvironment.json" -Path '.\','..\','.\build\' | Select-Object -First 1).FullName
        }
        else {
            $BuildPath = $Path
        }

        if ((Test-Path $BuildPath) -and ($BuildPath -like "*.buildenvironment.json")) {
            try {
                $LoadedBuildEnv = Get-Content $BuildPath | ConvertFrom-Json
                $NewParams = (Get-Member -Type 'NoteProperty' -InputObject $LoadedBuildEnv).Name
                $NewParams | ForEach-Object {

                    $NewParamSettings = @{
                        Name = $_
                        Type = $LoadedBuildEnv.$_.gettype().Name.toString()
                        ValueFromPipeline = $TRUE
                        HelpMessage = "Update the setting for $($_)"
                    }

                    # Add new dynamic parameter to dictionary
                    New-MBTDynamicParameter @NewParamSettings -Dictionary $DynamicParameters
                }
            }
            catch {
                throw "Unable to load the build file in $BuildPath"
            }
        }

        # Return dictionary with dynamic parameters
        $DynamicParameters
    }

    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        if ([String]::isnullorempty($Path)) {
            $BuildPath = (Get-ChildItem -File -Filter "*.buildenvironment.json" -Path '.\','..\','.\build\' | Select-Object -First 1).FullName
        }
        else {
            $BuildPath = $Path
        }

        Write-Verbose "Using build file: $BuildPath"
    }
    process {
        New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

        if ((Test-Path $BuildPath) -and ($BuildPath -like "*.buildenvironment.json")) {
            try {
                $LoadedBuildEnv = Get-BuildEnvironment -Path $BuildPath
                Foreach ($ParamKey in ($PSBoundParameters.Keys | Where-Object {$_ -ne 'Path'})) {
                    $LoadedBuildEnv.$ParamKey = $PSBoundParameters[$ParamKey]
                    Write-Output "Updating $ParamKey to be $($PSBoundParameters[$ParamKey])"
                }
                $LoadedBuildEnv.PSObject.Properties.remove('Path')
                $LoadedBuildEnv | ConvertTo-Json | Out-File -FilePath $BuildPath -Encoding:utf8 -Force
                Write-Output "Saved configuration file - $BuildPath"
            }
            catch {
                throw "Unable to load the build file in $BuildPath"
            }
        }
        else {
            Write-Error "Unable to find or process a buildenvironment.json file!"
        }
    }
}


function New-MBTDynamicParameter {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.5/docs/Functions/New-MBTDynamicParameter.md
    #>
    [CmdletBinding(PositionalBinding = $false, DefaultParameterSetName = 'DynamicParameter')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "",Scope="function",Justification="")]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [System.Type]$Type = [int],

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [string[]]$Alias,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$Mandatory,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [int]$Position,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [string]$HelpMessage,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$DontShow,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$ValueFromPipeline,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$ValueFromPipelineByPropertyName,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$ValueFromRemainingArguments,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [string]$ParameterSetName = '__AllParameterSets',

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$AllowNull,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$AllowEmptyString,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$AllowEmptyCollection,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$ValidateNotNull,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [switch]$ValidateNotNullOrEmpty,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [ValidateCount(2, 2)]
        [int[]]$ValidateCount,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [ValidateCount(2, 2)]
        [int[]]$ValidateRange,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [ValidateCount(2, 2)]
        [int[]]$ValidateLength,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [ValidateNotNullOrEmpty()]
        [string]$ValidatePattern,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [ValidateNotNullOrEmpty()]
        [scriptblock]$ValidateScript,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [ValidateNotNullOrEmpty()]
        [string[]]$ValidateSet,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'DynamicParameter')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                if (!($_ -is [System.Management.Automation.RuntimeDefinedParameterDictionary])) {
                    Throw 'Dictionary must be a System.Management.Automation.RuntimeDefinedParameterDictionary object'
                }
                $true
            })]
        $Dictionary = $false,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'CreateVariables')]
        [switch]$CreateVariables,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'CreateVariables')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                # System.Management.Automation.PSBoundParametersDictionary is an internal sealed class,
                # so one can't use PowerShell's '-is' operator to validate type.
                if ($_.GetType().Name -ne 'PSBoundParametersDictionary') {
                    Throw 'BoundParameters must be a System.Management.Automation.PSBoundParametersDictionary object'
                }
                $true
            })]
        $BoundParameters
    )

    Begin {
        Write-Verbose 'Creating new dynamic parameters dictionary'
        $InternalDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary

        Write-Verbose 'Getting common parameters'
        function _temp { [CmdletBinding()] Param() }
        $CommonParameters = (Get-Command _temp).Parameters.Keys
    }

    Process {
        if ($CreateVariables) {
            Write-Verbose 'Creating variables from bound parameters'
            Write-Debug 'Picking out bound parameters that are not in common parameters set'
            $BoundKeys = $BoundParameters.Keys | Where-Object { $CommonParameters -notcontains $_ }

            foreach ($Parameter in $BoundKeys) {
                Write-Debug "Setting existing variable for dynamic parameter '$Parameter' with value '$($BoundParameters.$Parameter)'"
                Set-Variable -Name $Parameter -Value $BoundParameters.$Parameter -Scope 1 -Force
            }
        }
        else {
            Write-Verbose 'Looking for cached bound parameters'
            Write-Debug 'More info: https://beatcracker.wordpress.com/2014/12/18/psboundparameters-pipeline-and-the-valuefrompipelinebypropertyname-parameter-attribute'
            $StaleKeys = @()
            $StaleKeys = $PSBoundParameters.GetEnumerator() |
                ForEach-Object {
                if ($_.Value.PSobject.Methods.Name -match '^Equals$') {
                    # If object has Equals, compare bound key and variable using it
                    if (!$_.Value.Equals((Get-Variable -Name $_.Key -ValueOnly -Scope 0))) {
                        $_.Key
                    }
                }
                else {
                    # If object doesn't has Equals (e.g. $null), fallback to the PowerShell's -ne operator
                    if ($_.Value -ne (Get-Variable -Name $_.Key -ValueOnly -Scope 0)) {
                        $_.Key
                    }
                }
            }
            if ($StaleKeys) {
                [string[]]"Found $($StaleKeys.Count) cached bound parameters:" + $StaleKeys | Write-Debug
                Write-Verbose 'Removing cached bound parameters'
                $StaleKeys | ForEach-Object {[void]$PSBoundParameters.Remove($_)}
            }

            # Since we rely solely on $PSBoundParameters, we don't have access to default values for unbound parameters
            Write-Verbose 'Looking for unbound parameters with default values'

            Write-Debug 'Getting unbound parameters list'
            $UnboundParameters = (Get-Command -Name ($PSCmdlet.MyInvocation.InvocationName)).Parameters.GetEnumerator()  |
                # Find parameters that are belong to the current parameter set
            Where-Object { $_.Value.ParameterSets.Keys -contains $PsCmdlet.ParameterSetName } |
                Select-Object -ExpandProperty Key |
                # Find unbound parameters in the current parameter set
                                                Where-Object { $PSBoundParameters.Keys -notcontains $_ }

            # Even if parameter is not bound, corresponding variable is created with parameter's default value (if specified)
            Write-Debug 'Trying to get variables with default parameter value and create a new bound parameter''s'
            $tmp = $null
            foreach ($Parameter in $UnboundParameters) {
                $DefaultValue = Get-Variable -Name $Parameter -ValueOnly -Scope 0
                if (!$PSBoundParameters.TryGetValue($Parameter, [ref]$tmp) -and $DefaultValue) {
                    $PSBoundParameters.$Parameter = $DefaultValue
                    Write-Debug "Added new parameter '$Parameter' with value '$DefaultValue'"
                }
            }

            if ($Dictionary) {
                Write-Verbose 'Using external dynamic parameter dictionary'
                $DPDictionary = $Dictionary
            }
            else {
                Write-Verbose 'Using internal dynamic parameter dictionary'
                $DPDictionary = $InternalDictionary
            }

            Write-Verbose "Creating new dynamic parameter: $Name"

            # Shortcut for getting local variables
            $GetVar = {Get-Variable -Name $_ -ValueOnly -Scope 0}

            # Strings to match attributes and validation arguments
            $AttributeRegex = '^(Mandatory|Position|ParameterSetName|DontShow|HelpMessage|ValueFromPipeline|ValueFromPipelineByPropertyName|ValueFromRemainingArguments)$'
            $ValidationRegex = '^(AllowNull|AllowEmptyString|AllowEmptyCollection|ValidateCount|ValidateLength|ValidatePattern|ValidateRange|ValidateScript|ValidateSet|ValidateNotNull|ValidateNotNullOrEmpty)$'
            $AliasRegex = '^Alias$'

            Write-Debug 'Creating new parameter''s attirubutes object'
            $ParameterAttribute = New-Object -TypeName System.Management.Automation.ParameterAttribute

            Write-Debug 'Looping through the bound parameters, setting attirubutes...'
            switch -regex ($PSBoundParameters.Keys) {
                $AttributeRegex {
                    Try {
                        $ParameterAttribute.$_ = . $GetVar
                        Write-Debug "Added new parameter attribute: $_"
                    }
                    Catch {
                        $_
                    }
                    continue
                }
            }

            if ($DPDictionary.Keys -contains $Name) {
                Write-Verbose "Dynamic parameter '$Name' already exist, adding another parameter set to it"
                $DPDictionary.$Name.Attributes.Add($ParameterAttribute)
            }
            else {
                Write-Verbose "Dynamic parameter '$Name' doesn't exist, creating"

                Write-Debug 'Creating new attribute collection object'
                $AttributeCollection = New-Object -TypeName Collections.ObjectModel.Collection[System.Attribute]

                Write-Debug 'Looping through bound parameters, adding attributes'
                switch -regex ($PSBoundParameters.Keys) {
                    $ValidationRegex {
                        Try {
                            $ParameterOptions = New-Object -TypeName "System.Management.Automation.${_}Attribute" -ArgumentList (. $GetVar) -ErrorAction Stop
                            $AttributeCollection.Add($ParameterOptions)
                            Write-Debug "Added attribute: $_"
                        }
                        Catch {
                            $_
                        }
                        continue
                    }

                    $AliasRegex {
                        Try {
                            $ParameterAlias = New-Object -TypeName System.Management.Automation.AliasAttribute -ArgumentList (. $GetVar) -ErrorAction Stop
                            $AttributeCollection.Add($ParameterAlias)
                            Write-Debug "Added alias: $_"
                            continue
                        }
                        Catch {
                            $_
                        }
                    }
                }

                Write-Debug 'Adding attributes to the attribute collection'
                $AttributeCollection.Add($ParameterAttribute)

                Write-Debug 'Finishing creation of the new dynamic parameter'
                $Parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList @($Name, $Type, $AttributeCollection)

                Write-Debug 'Adding dynamic parameter to the dynamic parameter dictionary'
                $DPDictionary.Add($Name, $Parameter)
            }
        }
    }

    End {
        if (!$CreateVariables -and !$Dictionary) {
            Write-Verbose 'Writing dynamic parameter dictionary to the pipeline'
            $DPDictionary
        }
    }
}


function New-MBTCommentBasedHelp {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.5/docs/Functions/New-MBTCommentBasedHelp.md
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "",Scope="function",Justification="")]
    param(
        [parameter(Position=0, ValueFromPipeline=$true, HelpMessage='Lines of code to process.')]
        [string[]]$Code,
        [parameter(Position=1, HelpMessage='Process the script parameters as the source of the comment based help.')]
        [switch]$ScriptParameters
    )
    begin {
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
        $CBH_PARAM = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("LlBBUkFNRVRFUiAlJVBBUkFNJSUNCiUlUEFSQU1IRUxQJSUNCg=="))
        $CBHTemplate = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("PCMNCi5TWU5PUFNJUw0KVEJEDQouREVTQ1JJUFRJT04NClRCRA0KJSVQQVJBTUVURVIlJQ0KLkVYQU1QTEUNClRCRA0KIz4="))
        $Codeblock = @()
    }
    process {
        $Codeblock += $Code
    }
    end {
        #$ScriptText = ($Codeblock | Out-String).trim("`r`n")
        Write-Verbose "$($FunctionName): Attempting to parse parameters."
        $FuncParams = @{}
        if ($ScriptParameters) {
            $FuncParams.ScriptParameters = $true
        }
        $AllParams = Get-MBTFunctionParameter @FuncParams -Code $Codeblock | Sort-Object -Property FunctionName
        $AllFunctions = @($AllParams.FunctionName | Select-Object -unique)

        foreach ($f in $AllFunctions) {
            $OutCBH = @{}
            $OutCBH.FunctionName = $f
            [string]$OutParams = ''
            $fparams = @($AllParams | Where-Object {$_.FunctionName -eq $f} | Sort-Object -Property Position)
            $fparams | ForEach-Object {
                $ParamHelpMessage = if ([string]::IsNullOrEmpty($_.HelpMessage)) {$_.ParameterName + " explanation`n`r"} else { $_.HelpMessage + "`n`r"}
                $OutParams += $CBH_PARAM -replace '%%PARAM%%',$_.ParameterName -replace '%%PARAMHELP%%',$ParamHelpMessage
            }

            $OutCBH.CBH = $CBHTemplate -replace '%%PARAMETER%%',$OutParams

            New-Object PSObject -Property $OutCBH
        }

        Write-Verbose "$($FunctionName): End."
    }
}


## Post-Load Module code ##

# Use this variable for any path-sepecific actions (like loading dlls and such) to ensure it will work in testing and after being built
$MyModulePath = $(
    Function Get-ScriptPath {
        $Invocation = (Get-Variable MyInvocation -Scope 1).Value
        if($Invocation.PSScriptRoot) {
            $Invocation.PSScriptRoot
        }
        Elseif($Invocation.MyCommand.Path) {
            Split-Path $Invocation.MyCommand.Path
        }
        elseif ($Invocation.InvocationName.Length -eq 0) {
            (Get-Location).Path
        }
        else {
            $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
        }
    }

    Get-ScriptPath
)

# Load any plugins found in the plugins directory
if (Test-Path (Join-Path $MyModulePath 'plugins')) {
    Get-ChildItem (Join-Path $MyModulePath 'plugins') -Directory | ForEach-Object {
        if (Test-Path (Join-Path $_.FullName "Load.ps1")) {
            Invoke-Command -NoNewScope -ScriptBlock ([Scriptblock]::create(".{$(Get-Content -Path (Join-Path $_.FullName "Load.ps1") -Raw)}")) -ErrorVariable errmsg 2>$null
        }
    }
}

$ExecutionContext.SessionState.Module.OnRemove = {
    # Action to take if the module is removed
    # Unload any plugins found in the plugins directory
    if (Test-Path (Join-Path $MyModulePath 'plugins')) {
        Get-ChildItem (Join-Path $MyModulePath 'plugins') -Directory | ForEach-Object {
            if (Test-Path (Join-Path $_.FullName "UnLoad.ps1")) {
                Invoke-Command -NoNewScope -ScriptBlock ([Scriptblock]::create(".{$(Get-Content -Path (Join-Path $_.FullName "UnLoad.ps1") -Raw)}")) -ErrorVariable errmsg 2>$null
            }
        }
    }
}

$null = Register-EngineEvent -SourceIdentifier ( [System.Management.Automation.PsEngineEvent]::Exiting ) -Action {
    # Action to take if the whole pssession is killed
    # Unload any plugins found in the plugins directory
    if (Test-Path (Join-Path $MyModulePath 'plugins')) {
        Get-ChildItem (Join-Path $MyModulePath 'plugins') -Directory | ForEach-Object {
            if (Test-Path (Join-Path $_.FullName "UnLoad.ps1")) {
                Invoke-Command -NoNewScope -ScriptBlock [Scriptblock]::create(".{$(Get-Content -Path (Join-Path $_.FullName "UnLoad.ps1") -Raw)}") -ErrorVariable errmsg 2>$null
            }
        }
    }
}

# Use this in your scripts to check if the function is being called from your module or independantly.
# Call it immediately to avoid PSScriptAnalyzer 'PSUseDeclaredVarsMoreThanAssignments'
$ThisModuleLoaded = $true
$ThisModuleLoaded

# Non-function exported public module members might go here.
#Export-ModuleMember -Variable SomeVariable -Function  *


