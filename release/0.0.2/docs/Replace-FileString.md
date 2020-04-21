---
external help file: ModuleBuildToolsTemp-help.xml
Module Name: ModuleBuildToolsTemp
online version:
schema: 2.0.0
---

# Replace-FileString

## SYNOPSIS
Replaces strings in files using a regular expression.

## SYNTAX

### Path (Default)
```
Replace-FileString [-Pattern] <String> [-Replacement] <String> [-Path] <String[]> [-CaseSensitive] [-Multiline]
 [-UnixText] [-Overwrite] [-Force] [-Encoding <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### LiteralPath
```
Replace-FileString [-Pattern] <String> [-Replacement] <String> [-LiteralPath] <String[]> [-CaseSensitive]
 [-Multiline] [-UnixText] [-Overwrite] [-Force] [-Encoding <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Replaces strings in files using a regular expression.
Supports
multi-line searching and replacing.

## EXAMPLES

### EXAMPLE 1
```
Replace-FileString.ps1 '(Ferb) and (Phineas)' '$2 and $1' Story.txt
```

This command replaces the string 'Ferb and Phineas' with the string
'Phineas and Ferb' in the file Story.txt and outputs the file.
Note
that the pattern and replacement strings are enclosed in single quotes
to prevent variable expansion.

### EXAMPLE 2
```
Replace-FileString.ps1 'Perry' 'Agent P' Ferb.txt -Overwrite
```

This command replaces the string 'Perry' with the string 'Agent P' in
the file Ferb.txt and overwrites the file.

## PARAMETERS

### -Pattern
Specifies the regular expression pattern.

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

### -Replacement
Specifies the regular expression replacement pattern.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Specifies the path to one or more files.
Wildcards are permitted.
Each
file is read entirely into memory to support multi-line searching and
replacing, so performance may be slow for large files.

```yaml
Type: String[]
Parameter Sets: Path
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -LiteralPath
Specifies the path to one or more files.
The value of the this
parameter is used exactly as it is typed.
No characters are interpreted
as wildcards.
Each file is read entirely into memory to support
multi-line searching and replacing, so performance may be slow for
large files.

```yaml
Type: String[]
Parameter Sets: LiteralPath
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CaseSensitive
Specifies case-sensitive matching.
The default is to ignore case.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Multiline
Changes the meaning of ^ and $ so they match at the beginning and end,
respectively, of any line, and not just the beginning and end of the
entire file.
The default is that ^ and $, respectively, match the
beginning and end of the entire file.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UnixText
Causes $ to match only linefeed (\n) characters.
By default, $ matches
carriage return+linefeed (\r\n).
(Windows-based text files usually use
\r\n as line terminators, while Unix-based text files usually use only
\n.)

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Overwrite
Overwrites a file by creating a temporary file containing all
replacements and then replacing the original file with the temporary
file.
The default is to output but not overwrite.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Allows overwriting of read-only files.
Note that this parameter cannot
override security restrictions.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Encoding
Specifies the encoding for the file when -Overwrite is used.
Possible
values are: ASCII, BigEndianUnicode, Unicode, UTF32, UTF7, or UTF8.
The
default value is ASCII.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: ASCII
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.IO.FileInfo.
## OUTPUTS

### System.String without the -Overwrite parameter, or nothing with the
### -Overwrite parameter.
## NOTES

## RELATED LINKS

[about_Regular_Expressions]()

