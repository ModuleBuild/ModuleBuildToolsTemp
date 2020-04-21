---
external help file: ModuleBuildToolsTemp-help.xml
Module Name: ModuleBuildToolsTemp
online version: https://github.com/zloeber/ModuleBuild
schema: 2.0.0
---

# New-PSGalleryProjectProfile

## SYNOPSIS
Create a powershell Gallery module upload profile

## SYNTAX

```
New-PSGalleryProjectProfile [-Path] <String> [[-ProjectUri] <String>] [[-Tags] <String>]
 [[-Repository] <String>] [[-ReleaseNotes] <String>] [[-LicenseUri] <String>] [[-IconUri] <String>]
 [[-NuGetApiKey] <String>] [[-OutputFile] <String>] [<CommonParameters>]
```

## DESCRIPTION
Create a powershell Gallery module upload profile.
Some items (like Name) are inferred from the module manifest and are left out.

## EXAMPLES

### EXAMPLE 1
```

```

## PARAMETERS

### -Path
Path of module project files to upload.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProjectUri
Module project website.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tags
Tags used to search for the module (separated by commas)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Repository
Destination gallery (default is PSGallery)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: PSGallery
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReleaseNotes
Release notes.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LicenseUri
License website.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IconUri
Icon web path.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NuGetApiKey
API key for the powershellgallery.com site.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputFile
OutputFile (default is .psgallery)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: .psgallery
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Zachary Loeber
Site: http://www.the-little-things.net/
Version History
1.0.0 - Initial release

## RELATED LINKS
