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

function Convert-ArrayToString {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.1/docs/Functions/Convert-ArrayToString.md
    #>
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true,Position=0)]
        [AllowEmptyCollection()]
        [Array]$Array,

        [Parameter(Mandatory=$False)]
        [switch]$Flatten
    )

    Begin{
        If ($Flatten) {
            $Mode = 'Append'
        }
        Else {
            $Mode = 'AppendLine'
        }

        If($Flatten -or $Array.Count -eq 0){
            $Indenting = ''
            $RecursiveIndenting = ''
        }
        Else {
            $Indenting = '    '
            $RecursiveIndenting = '    ' * (Get-PSCallStack).Where({$_.Command -match 'Convert-ArrayToString|Convert-HashToSTring' -and $_.InvocationInfo.CommandOrigin -eq 'Internal' -and $_.InvocationInfo.Line -notmatch '\$This'}).Count
        }
    }

    Process{
        $StringBuilder = [System.Text.StringBuilder]::new()

        If ($Array.Count -ge 1){
            [void]$StringBuilder.$Mode("@(")
        }
        Else {
            [void]$StringBuilder.Append("@(")
        }

        For($i = 0; $i -lt $Array.Count; $i++) {
            $Item = $Array[$i]

            If($Item -is [String]){
                [void]$StringBuilder.Append($Indenting + $RecursiveIndenting + "'$Item'")
            }
            ElseIf($Item -is [int] -or $Value -is [double]){
                [void]$StringBuilder.Append($Indenting + $RecursiveIndenting + "$($Item.ToString())")
            }
            ElseIf($Item -is [bool]){
                [void]$StringBuilder.Append($Indenting + $RecursiveIndenting + "`$$Item")
            }
            ElseIf($Item -is [array]){
                $Value = Convert-ArrayToString -Array $Item -Flatten:$Flatten

                [void]$StringBuilder.Append($Indenting + $RecursiveIndenting + $Value)
            }
            ElseIf($Item -is [hashtable]){
                $Value = Convert-HashToSTring -Hashtable $Item -Flatten:$Flatten

                [void]$StringBuilder.Append($Indenting + $RecursiveIndenting + $Value)
            }
            Else {
                Throw "Array element is not of known type."
            }

            If ($i -lt ($Array.Count - 1)){
                [void]$StringBuilder.$Mode(', ')
            }
            ElseIf(-not $Flatten){
                [void]$StringBuilder.AppendLine('')
            }
        }

        [void]$StringBuilder.Append($RecursiveIndenting + ')')
        $StringBuilder.ToString()
    }
}


function Convert-HashToString
{
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.1/docs/Functions/Convert-HashToString.md
    #>
    [cmdletbinding()]
    Param  (
        [Parameter(Mandatory=$true,Position=0)]
        [Hashtable]$Hashtable,

        [Parameter(Mandatory=$False)]
        [switch]$Flatten
    )

    Begin{
        If($Flatten -or $Hashtable.Keys.Count -eq 0)
        {
            $Mode = 'Append'
            $Indenting = ''
            $RecursiveIndenting = ''
        }
        Else{
            $Mode = 'Appendline'
            $Indenting = '    '
            $RecursiveIndenting = '    ' * (Get-PSCallStack).Where({$_.Command -match 'Convert-ArrayToString|Convert-HashToSTring' -and $_.InvocationInfo.CommandOrigin -eq 'Internal' -and $_.InvocationInfo.Line -notmatch '\$This'}).Count
        }
    }

    Process{
        $StringBuilder = [System.Text.StringBuilder]::new()

        If($Hashtable.Keys.Count -ge 1)
        {
            [void]$StringBuilder.$Mode("@{")
        }
        Else
        {
            [void]$StringBuilder.Append("@{")
        }

        Foreach($Key in $Hashtable.Keys)
        {
            $Value = $Hashtable[$Key]

            If($Key -match '\s')
            {
                $Key = "'$Key'"
            }

            If($Value -is [String])
            {
                [void]$StringBuilder.$Mode($Indenting + $RecursiveIndenting + "$Key = '$Value'")
            }
            ElseIf($Value -is [int] -or $Value -is [double])
            {
                [void]$StringBuilder.$Mode($Indenting + $RecursiveIndenting + "$Key = $($Value.ToString())")
            }
            ElseIf($Value -is [bool])
            {
                [void]$StringBuilder.$Mode($Indenting + $RecursiveIndenting + "$Key = `$$Value")
            }
            ElseIf($Value -is [array])
            {
                $Value = Convert-ArrayToString -Array $Value -Flatten:$Flatten

                [void]$StringBuilder.$Mode($Indenting + $RecursiveIndenting + "$Key = $Value")
            }
            ElseIf($Value -is [hashtable])
            {
                $Value = Convert-HashToSTring -Hashtable $Value -Flatten:$Flatten
                [void]$StringBuilder.$Mode($Indenting + $RecursiveIndenting + "$Key = $Value")
            }
            Else
            {
                Throw "Key value is not of known type."
            }

            If($Flatten){[void]$StringBuilder.Append("; ")}
        }

        [void]$StringBuilder.Append($RecursiveIndenting + "}")

        $StringBuilder.ToString().Replace("; }",'}')
    }

    End{}
}

#Remove-TypeData -TypeName System.Collections.HashTable -ErrorAction SilentlyContinue
#Update-TypeData -TypeName System.Collections.HashTable -MemberType ScriptMethod -MemberName ToString -Value {Convert-HashToString $This}


function Get-BuildEnvironment {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.1/docs/Functions/Get-BuildEnvironment.md
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
            $Path = (Get-ChildItem -File -Filter "*.buildenvironment.json" -Path '.\','..\','.\build\' | select -First 1).FullName

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


function Get-ErrorDetail
{
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.1/docs/Functions/Get-ErrorDetail.md
    #>
    Param (
        [Parameter(Mandatory,ValueFromPipeline)]
        $e
    )
    process
    {
        if ($e -is [Management.Automation.ErrorRecord]) {
            [PSCustomObject]@{
                Reason    = $e.CategoryInfo.Reason
                Exception = $e.Exception.Message
                Target    = $e.CategoryInfo.TargetName
                Script    = $e.InvocationInfo.ScriptName
                Line      = $e.InvocationInfo.ScriptLineNumber
                Column    = $e.InvocationInfo.OffsetInLine
                Datum     = Get-Date
                User      = $env:USERNAME
            }
        }
    }
}


function Get-ErrorInfo {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.1/docs/Functions/Get-ErrorInfo.md
    #>
    param (
        [Parameter(ValueFrompipeline)]
        [Management.Automation.ErrorRecord]$errorRecord
    )

    process {
        $info = [PSCustomObject]@{
            Exception = $errorRecord.Exception.Message
            Reason    = $errorRecord.CategoryInfo.Reason
            Target    = $errorRecord.CategoryInfo.TargetName
            Script    = $errorRecord.InvocationInfo.ScriptName
            Line      = $errorRecord.InvocationInfo.ScriptLineNumber
            Column    = $errorRecord.InvocationInfo.OffsetInLine
            Date      = Get-Date
            User      = $env:username
        }

        $info
    }
}



Function Get-SpecialPaths {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.1/docs/Functions/Get-SpecialPaths.md
    #>
    Param (

    )
    $SpecialFolders = @{}

    $names = [Environment+SpecialFolder]::GetNames([Environment+SpecialFolder])

    foreach ($name in $names) {
        $SpecialFolders[$name] = [Environment]::GetFolderPath($name)
    }

    $SpecialFolders
}


function New-CommentBasedHelp {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.1/docs/Functions/New-CommentBasedHelp.md
    #>
'@

        $Codeblock = @()
    }
    process {
        $Codeblock += $Code
    }
    end {
        $ScriptText = ($Codeblock | Out-String).trim("`r`n")
        Write-Verbose "$($FunctionName): Attempting to parse parameters."
        $FuncParams = @{}
        if ($ScriptParameters) {
            $FuncParams.ScriptParameters = $true
        }
        $AllParams = Get-FunctionParameter @FuncParams -Code $Codeblock | Sort-Object -Property FunctionName
        $AllFunctions = @($AllParams.FunctionName | Select -unique)

        foreach ($f in $AllFunctions) {
            $OutCBH = @{}
            $OutCBH.FunctionName = $f
            [string]$OutParams = ''
            $fparams = @($AllParams | Where {$_.FunctionName -eq $f} | Sort-Object -Property Position)
            $fparams | foreach {
                $ParamHelpMessage = if ([string]::IsNullOrEmpty($_.HelpMessage)) {$_.ParameterName + " explanation`n`r"} else { $_.HelpMessage + "`n`r"}
                $OutParams += $CBH_PARAM -replace '%%PARAM%%',$_.ParameterName -replace '%%PARAMHELP%%',$ParamHelpMessage
            }

            $OutCBH.CBH = $CBHTemplate -replace '%%PARAMETER%%',$OutParams

            New-Object PSObject -Property $OutCBH
        }

        Write-Verbose "$($FunctionName): End."
    }
}


function New-DynamicParameter {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.1/docs/Functions/New-DynamicParameter.md
    #>
    [CmdletBinding(PositionalBinding = $false, DefaultParameterSetName = 'DynamicParameter')]
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


function New-PSGalleryProjectProfile {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.1/docs/Functions/New-PSGalleryProjectProfile.md
    #>
    [CmdletBinding()]
    param(
        [parameter(Position=0, Mandatory=$true, HelpMessage='Path of module project files to upload.')]
        [string]$Path,
        [parameter(Position=1, HelpMessage='Module project website.')]
        [string]$ProjectUri = '',
        [parameter(Position=2, HelpMessage='Tags used to search for the module (separated by commas)')]
        [string]$Tags = '',
        [parameter(Position=3, HelpMessage='Destination gallery (default is PSGallery)')]
        [string]$Repository = 'PSGallery',
        [parameter(Position=4, HelpMessage='Release notes.')]
        [string]$ReleaseNotes = '',
        [parameter(Position=5, HelpMessage=' License website.')]
        [string]$LicenseUri = '',
        [parameter(Position=6, HelpMessage='Icon web path.')]
        [string]$IconUri = '',
        [parameter(Position=7, HelpMessage='NugetAPI key for the powershellgallery.com site.')]
        [string]$NuGetApiKey = '',
        [parameter(Position=8, HelpMessage='OutputFile (default is .psgallery)')]
        [string]$OutputFile = '.psgallery'
    )

    $PublishParams = @{
        Path = $Path
        NuGetApiKey = $NuGetApiKey
        ProjectUri = $ProjectUri
        Tags = $Tags
        Repository = $Repository
        ReleaseNotes = $ReleaseNotes
        LicenseUri = $LicenseUri
        IconUri = $IconUri
    }

    if (Test-Path $OutputFile) {
        $PublishParams | Export-Clixml -Path $OutputFile -confirm
    }
    else {
        $PublishParams | Export-Clixml -Path $OutputFile
    }
}


function Out-Zip {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.1/docs/Functions/Out-Zip.md
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


function Out-ZipFromFile {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.1/docs/Functions/Out-ZipFromFile.md
    #>
    [cmdletbinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]$Files,
        [Parameter(Position=1, Mandatory=$true)]
        [string]$ZipFile,
        [Parameter(Position=2)]
        [switch]$overwrite
    )
    begin {
        #Prepare zip file
        if (($Overwrite) -and (test-path($ZipFile)) ) {
            try {
                Remove-Item -Path $ZipFile -Force
            }
            catch {
                throw
            }
        }
        if (-not (test-path($ZipFile))) {
            try {
                set-content $ZipFile ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
                $ThisZipFile = Get-ChildItem $ZipFile
                $ThisZipFile.IsReadOnly = $false
            }
            catch {
                throw
            }
        }

        $shellApplication = new-object -com shell.application
        $zipPackage = $shellApplication.NameSpace($ThisZipFile.FullName)
        $AllFiles = @()
    }
    process {
        $AllFiles += $Files
    }
    end {
        foreach($file in $AllFiles) {
            $ThisFile = Get-ChildItem -Path $File -File
            $zipPackage.CopyHere($ThisFile.FullName)
            while($zipPackage.Items().Item($ThisFile.name) -eq $null){
                Start-sleep -seconds 1
            }
        }
    }
}


Function Script:Prompt-ForBuildBreak {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.1/docs/Functions/Prompt-ForBuildBreak.md
    #>
    param (
        [Parameter(Position=0)]
        [System.Object]$LastError,
        [Parameter(Position=1)]
        $CustomError = $null
    )
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "End the build."
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Stop the build."
    $ContinueBuildPrompt = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    if (($host.ui.PromptForChoice('Stop the build?', 'Should the build stop here?', $ContinueBuildPrompt, 0)) -eq 0) {
        if ($CustomError -ne $null) {
            throw $CustomError
        }
        else {
            throw $LastError
        }
    }
    else {
        Write-Output "Contining the build process despite the following error:"
        if ($CustomError -ne $null) {
            Write-Output $CustomError
        }
        else {
            Write-Output $LastError.Exception
        }
    }
}


function Remove-Signature
{
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.1/docs/Functions/Remove-Signature.md
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


function Replace-FileString {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.1/docs/Functions/Replace-FileString.md
    #>

    [CmdletBinding(DefaultParameterSetName="Path",
                SupportsShouldProcess=$TRUE)]
    param(
    [parameter(Mandatory=$TRUE,Position=0)]
        [String] $Pattern,
    [parameter(Mandatory=$TRUE,Position=1)]
        [String] [AllowEmptyString()] $Replacement,
    [parameter(Mandatory=$TRUE,ParameterSetName="Path",
        Position=2,ValueFromPipeline=$TRUE)]
        [String[]] $Path,
    [parameter(Mandatory=$TRUE,ParameterSetName="LiteralPath",
        Position=2)]
        [String[]] $LiteralPath,
        [Switch] $CaseSensitive,
        [Switch] $Multiline,
        [Switch] $UnixText,
        [Switch] $Overwrite,
        [Switch] $Force,
        [String] $Encoding="ASCII"
    )

    begin {
    # Throw an error if $Encoding is not valid.
    $encodings = @("ASCII","BigEndianUnicode","Unicode","UTF32","UTF7",
                    "UTF8")
    if ($encodings -notcontains $Encoding) {
        throw "Encoding must be one of the following: $encodings"
    }

    # Extended test-path: Check the parameter set name to see if we
    # should use -literalpath or not.
    function test-pathEx($path) {
        switch ($PSCmdlet.ParameterSetName) {
        "Path" {
            test-path $path
        }
        "LiteralPath" {
            test-path -literalpath $path
        }
        }
    }

    # Extended get-childitem: Check the parameter set name to see if we
    # should use -literalpath or not.
    function get-childitemEx($path) {
        switch ($PSCmdlet.ParameterSetName) {
        "Path" {
            get-childitem $path -force
        }
        "LiteralPath" {
            get-childitem -literalpath $path -force
        }
        }
    }

    # Outputs the full name of a temporary file in the specified path.
    function get-tempname($path) {
        do {
        $tempname = join-path $path ([IO.Path]::GetRandomFilename())
        }
        while (test-path $tempname)
        $tempname
    }

    # Use '\r$' instead of '$' unless -UnixText specified because
    # '$' alone matches '\n', not '\r\n'. Ignore '\$' (literal '$').
    if (-not $UnixText) {
        $Pattern = $Pattern -replace '(?<!\\)\$', '\r$'
    }

    # Build an array of Regex options and create the Regex object.
    $opts = @()
    if (-not $CaseSensitive) { $opts += "IgnoreCase" }
    if ($MultiLine) { $opts += "Multiline" }
    if ($opts.Length -eq 0) { $opts += "None" }
    $regex = new-object Text.RegularExpressions.Regex $Pattern, $opts
    }

    process {
    # The list of items to iterate depends on the parameter set name.
    switch ($PSCmdlet.ParameterSetName) {
        "Path" { $list = $Path }
        "LiteralPath" { $list = $LiteralPath }
    }

    # Iterate the items in the list of paths. If an item does not exist,
    # continue to the next item in the list.
    foreach ($item in $list) {
        if (-not (test-pathEx $item)) {
        write-error "Unable to find '$item'."
        continue
        }

        # Iterate each item in the path. If an item is not a file,
        # skip all remaining items.
        foreach ($file in get-childitemEx $item) {
        if ($file -isnot [IO.FileInfo]) {
            write-error "'$file' is not in the file system."
            break
        }

        # Get a temporary file name in the file's directory and create
        # it as a empty file. If set-content fails, continue to the next
        # file. Better to fail before than after reading the file for
        # performance reasons.
        if ($Overwrite) {
            $tempname = get-tempname $file.DirectoryName
            set-content $tempname $NULL -confirm:$FALSE
            if (-not $?) { continue }
            write-verbose "Created file '$tempname'."
        }

        # Read all the text from the file into a single string. We have
        # to do it this way to be able to search across line breaks.
        try {
            write-verbose "Reading '$file'."
            $text = [IO.File]::ReadAllText($file.FullName)
            write-verbose "Finished reading '$file'."
        }
        catch [Management.Automation.MethodInvocationException] {
            write-error $ERROR[0]
            continue
        }

        # If -Overwrite not specified, output the result of the Replace
        # method and continue to the next file.
        if (-not $Overwrite) {
            $regex.Replace($text, $Replacement)
            continue
        }

        # Do nothing further if we're in 'what if' mode.
        if ($WHATIFPREFERENCE) { continue }

        try {
            write-verbose "Writing '$tempname'."
            [IO.File]::WriteAllText("$tempname", $regex.Replace($text,
            $Replacement), [Text.Encoding]::$Encoding)
            write-verbose "Finished writing '$tempname'."
            write-verbose "Copying '$tempname' to '$file'."
            copy-item $tempname $file -force:$Force -erroraction Continue
            if ($?) {
            write-verbose "Finished copying '$tempname' to '$file'."
            }
            remove-item $tempname
            if ($?) {
            write-verbose "Removed file '$tempname'."
            }
        }
        catch [Management.Automation.MethodInvocationException] {
            write-error $ERROR[0]
        }
        } # foreach $file
    } # foreach $item
    } # process

    end { }
}


Function Set-BuildEnvironment {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.1/docs/Functions/Set-BuildEnvironment.md
    #>

    [CmdletBinding()]
    param(
        [parameter(Position = 0, ValueFromPipeline = $TRUE)]
        [String]$Path
    )
    DynamicParam {
        # Create dictionary
        $DynamicParameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        if ([String]::isnullorempty($Path)) {
            $BuildPath = (Get-ChildItem -File -Filter "*.buildenvironment.json" -Path '.\','..\','.\build\' | select -First 1).FullName
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
                    New-DynamicParameter @NewParamSettings -Dictionary $DynamicParameters
                }
            }
            catch {
                #throw "Unable to load the build file in $BuildPath"
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
            $BuildPath = (Get-ChildItem -File -Filter "*.buildenvironment.json" -Path '.\','..\','.\build\' | select -First 1).FullName
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


function Upload-ProjectToPSGallery {
    <#
    .EXTERNALHELP ModuleBuildToolsTemp-help.xml
    .LINK
        https://github.com/justin-p/ModuleBuildToolsTemp/tree/master/release/0.0.1/docs/Functions/Upload-ProjectToPSGallery.md
    #>
    [CmdletBinding()]
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


