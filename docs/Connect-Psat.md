---
external help file: PSPsat-help.xml
Module Name: PSPSat
online version:
schema: 2.0.0
---

# Connect-Psat

## SYNOPSIS

Saves the Api token from Psat into an environment variable.

## SYNTAX

```
Connect-Psat [[-ApiToken] <String>]
```

## DESCRIPTION

Saves the Api token from Psat into an environment variable. Can optionnaly save the token to a file in the user profile folder.

## EXAMPLES

### Example 1

```powershell
PS C:\> Connect-Psat -ApiToken "ertergdfdgdfgrtyrty"
```

You can directly specify the Api Token value with the `ApiToken` parameter.

### Example 2

```powershell
PS C:\> Connect-Psat
```

Or just call it empty and be prompted to enter the token.

## PARAMETERS

### -ApiToken

This is the Api token you copied from your PSAT dashboard.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

Your Psat Api token is stored in an environment variable. It can also optionnaly be stored into your profile folder. Just remember that, either way, it is stored in cleartext.

## RELATED LINKS
