<img src="./docs/psat.jpg" height="200">

# PowerShell-PSAT

A PowerShell module to interact with [the Proofpoint Security Awareness Training reporting API](https://proofpoint.securityeducation.com/api/reporting/documentation/#api-Introduction).

## Installing this module

This module is available in [PowerShell Gallery](https://www.powershellgallery.com/packages/NinjaRmmApi):

```powershell
PS C:\> Install-Module PSPsat
```

Or, download it from here and save all of the files somewhere in your `$PSModulePath`.

## Before you start

To get started with this module, you will need to log into your PSAT dashboard and create a new API token. It's under _Company Settings_ > _API Tokens_.
Take note of that token. You will not see it again in the dashboard.

Then, in your PowerShell session, teach it your secrets with `Connect-Psat`.

```powershell
PS C:\> Connect-Psat -ApiToken "TF4STGMDR4H7AEXAMPLE"
```

You will be prompted to save the token into your user profile for later use.

## Using the module

Now that that's been done, start using their API!

### Users

You can look up users information with the `Get-PsatUsers` cmdlet. With no arguments, it returns a list of all customers. You can also use the -UserEmailAddress parameter to fetch a specific users. By default, the API will return only the first 20 users and the response is paginated. You can specify the `PageSize` and `PageNumber` to pinpoint your searches.

By default, the response will be a `PSCustomObject`.

```powershell
PS C:\> Get-PsatUsers

useremailaddress : ex-amohsni@test.com
userfirstname    : Abdel
userlastname     : Mohsni
userlocale       : default
usertimezone     : America/New_York
useractiveflag   : True
userdeleteddate  :
datalastupdated  : 2023-07-08 8:32:17 PM
usertags         :
sso_id           : Unknown
id               : 1
type             : fn_user_v1
```

You can get the raw response by adding the `-FormatJson` parameter.

```powershell
PS C:\> Get-PsatUsers -FormatJson

{
  "data": [
    {
      "type": "fn_user_v1",
      "id": 1,
      "attributes": {
        "useremailaddress": "ex-amohsni@test.com",
        "userfirstname": "Abdel",
        "userlastname": "Mohsni",
        "userlocale": "default",
        "usertimezone": "America/New_York",
        "useractiveflag": true,
        "userdeleteddate": null,
        "datalastupdated": "2023-07-08T20:32:17.840352-04:00",
        "usertags": null,
        "sso_id": "Unknown"
      }
    }]
}
```

## What else can I do?

There is plenty of help to read. Get started with this:

```powershell
PS C:\> Get-Help about_****
```
