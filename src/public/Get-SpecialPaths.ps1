Function Get-SpecialPaths {
    <#
    .SYNOPSIS
        TBD
    .DESCRIPTION
        TBD
    .EXAMPLE
        TBD
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "",Scope="function",Justification="")]
    Param (

    )
    $SpecialFolders = @{}

    $names = [Environment+SpecialFolder]::GetNames([Environment+SpecialFolder])

    foreach ($name in $names) {
        $SpecialFolders[$name] = [Environment]::GetFolderPath($name)
    }

    $SpecialFolders
}