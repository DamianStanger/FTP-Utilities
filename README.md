# FTP-Utilities

A collection of powershell utilities to work with ftp sites


## FTPRecursiveDelete.ps1

Powershell to recursively delete everything from a FTP directory.

Originally developed to run against an Azure website FTP target but no reason why this cant be changed to work against any FTP target.

When running against an Azure website run with the following:
```
.\FTPRecursiveDelete.ps1 -ftpRoot <publishUrl> -Username <userName> -Password <UserPwd>
```
Example:
``` 
.\FTPRecursiveDelete.ps1 -ftpRoot ftp://waws-prod-db1-123.ftp.azurewebsites.windows.net/site/wwwroot/ -Username 'MyWebsite\$MyWebsite' -Password AzurePa55w0rdX3St0aagu9pn1viHyLdJGGG8vidgorXnKharMgggk1KlMxx
```


## FTPRecursiveUpload.ps1

Powershell to recursively upload everything from a local directory to a FTP site.

Originally developed to run against an Azure website FTP target but no reason why this cant be changed to work against any FTP target.

When running against an Azure website run with the following:
```
.\FTPRecursiveUpload.ps1 -ftpRoot <publishUrl> -folderRoot <fullPathOfTargetDir> -Username <userName> -Password <UserPwd>
```
Example:
``` 
.\FTPRecursiveUpload.ps1 -ftpRoot ftp://waws-prod-db1-123.ftp.azurewebsites.windows.net/site/wwwroot/ -folderRoot 'c:\my folder\' -Username 'MyWebsite\$MyWebsite' -Password AzurePa55w0rdX3St0aagu9pn1viHyLdJGGG8vidgorXnKharMgggk1KlMxx
```
