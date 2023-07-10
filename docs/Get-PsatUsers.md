---
external help file: PSPsat-help.xml
Module Name: PSPSat
online version:
schema: 2.0.0
---

# Get-PsatUsers

## SYNOPSIS

Get the list of all users in Psat.

## SYNTAX

```
Get-PsatUsers [[-PageNumber] <Int32>] [[-PageSize] <Int32>] [[-UserEmailAddress] <String[]>]
 [-IncludeDeletedUsers] [-FormatJson]
```

## DESCRIPTION

Get the list of all users in Psat. You can also filter the query and select only a couple of users at a time.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-PsatUsers
```

Get a list of all the users in Psat.

### Example 2

```powershell
PS C:\> Get-PsatUsers -UserEmailAddress test@test.com
```

Returns a specific user informations.

### Example 3

```powershell
PS C:\> Get-PsatUsers -PageSize 10 -PageNumber 3
```

Get 10 users from the third page of the dataset.

### Example 4

```powershell
PS C:\> Get-PsatUsers -FormatJson
```

Returns the data as a JSON string.

## PARAMETERS

### -FormatJson

{{ Fill FormatJson Description }}

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

### -IncludeDeletedUsers

{{ Fill IncludeDeletedUsers Description }}

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

### -PageNumber

{{ Fill PageNumber Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageSize

{{ Fill PageSize Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserEmailAddress

{{ Fill UserEmailAddress Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

All responses are paginated. You can set `PageNumber` and `PageSize` to pinpoint a specific section of the dataset.

## RELATED LINKS
