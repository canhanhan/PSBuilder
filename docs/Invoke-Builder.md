---
external help file: PSBuilder-help.xml
Module Name: PSBuilder
online version:
schema: 2.0.0
---

# Invoke-Builder

## SYNOPSIS
Executes build tasks

## SYNTAX

### Default (Default)
```
Invoke-Builder [[-Tasks] <String[]>] [-TestTags <String[]>] [-ThrowOnError] [-ExitWithCode]
 [<CommonParameters>]
```

### UseFile
```
Invoke-Builder [[-Tasks] <String[]>] -ConfigurationFile <String> [-TestTags <String[]>] [-ThrowOnError]
 [-ExitWithCode] [<CommonParameters>]
```

### UseHashtable
```
Invoke-Builder [[-Tasks] <String[]>] -Configuration <Hashtable> [-TestTags <String[]>] [-ThrowOnError]
 [-ExitWithCode] [<CommonParameters>]
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Configuration
{{Fill Configuration Description}}

```yaml
Type: Hashtable
Parameter Sets: UseHashtable
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigurationFile
{{Fill ConfigurationFile Description}}

```yaml
Type: String
Parameter Sets: UseFile
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExitWithCode
{{Fill ExitWithCode Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tasks
{{Fill Tasks Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TestTags
{{Fill TestTags Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ThrowOnError
{{Fill ThrowOnError Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
