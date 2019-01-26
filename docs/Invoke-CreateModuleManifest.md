---
external help file: PSBuilder-help.xml
Module Name: PSBuilder
online version:
schema: 2.0.0
---

# Invoke-CreateModuleManifest

## SYNOPSIS
{{Fill in the Synopsis}}

## SYNTAX

```
Invoke-CreateModuleManifest [-Name] <String> [-Guid] <String> [-Author] <String> [-Description] <String>
 [-Path] <String> [-ModuleFilePath] <String> [-Version] <String> [[-CompanyName] <String>]
 [[-Dependencies] <Object[]>] [[-LicenseUri] <String>] [[-IconUri] <String>] [[-ProjectUri] <String>]
 [[-ReleaseNotes] <String>] [[-HelpInfoUri] <String>] [[-CompatiblePSEditions] <String[]>]
 [[-PowerShellVersion] <String>] [[-PowerShellHostName] <String>] [[-PowerShellHostVersion] <String>]
 [[-DotNetFrameworkVersion] <String>] [[-CLRVersion] <String>] [[-ProcessorArchitecture] <String>]
 [[-RequiredAssemblies] <String[]>] [[-ScriptsToProcess] <String[]>] [[-TypesToProcess] <String[]>]
 [[-FormatsToProcess] <String[]>] [[-NestedModules] <String[]>] [[-DefaultCommandPrefix] <String>]
 [[-Tags] <String[]>] [[-Prerelease] <String>] [-PSData <OrderedDictionary>]
 [[-RequireLicenseAcceptance] <Boolean>] [<CommonParameters>]
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

### -Author
{{Fill Author Description}}

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

### -CLRVersion
{{Fill CLRVersion Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 19
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CompanyName
{{Fill CompanyName Description}}

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

### -CompatiblePSEditions
{{Fill CompatiblePSEditions Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 14
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DefaultCommandPrefix
{{Fill DefaultCommandPrefix Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 26
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Dependencies
{{Fill Dependencies Description}}

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
{{Fill Description Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DotNetFrameworkVersion
{{Fill DotNetFrameworkVersion Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 18
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FormatsToProcess
{{Fill FormatsToProcess Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 24
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Guid
{{Fill Guid Description}}

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

### -HelpInfoUri
{{Fill HelpInfoUri Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IconUri
{{Fill IconUri Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LicenseUri
{{Fill LicenseUri Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleFilePath
{{Fill ModuleFilePath Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
{{Fill Name Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NestedModules
{{Fill NestedModules Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 25
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
{{Fill Path Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PowerShellHostName
{{Fill PowerShellHostName Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 16
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PowerShellHostVersion
{{Fill PowerShellHostVersion Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 17
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PowerShellVersion
{{Fill PowerShellVersion Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 15
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Prerelease
{{Fill Prerelease Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 28
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProcessorArchitecture
{{Fill ProcessorArchitecture Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 20
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProjectUri
{{Fill ProjectUri Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReleaseNotes
{{Fill ReleaseNotes Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RequireLicenseAcceptance
{{Fill RequireLicenseAcceptance Description}}

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 29
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RequiredAssemblies
{{Fill RequiredAssemblies Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 21
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScriptsToProcess
{{Fill ScriptsToProcess Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 22
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tags
{{Fill Tags Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 27
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TypesToProcess
{{Fill TypesToProcess Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 23
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Version
{{Fill Version Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PSData
{{Fill PSData Description}}

```yaml
Type: OrderedDictionary
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

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
