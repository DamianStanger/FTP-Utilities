Write-Host ** Starting FTPRecursiveDelete

$WebsiteName = "<websitename>"
$Username = '<username>'
$Password = "<password>"
$ftpRoot= "ftp://myserver.com/site/wwwroot/"

Add-Type -Language CSharp @"
public class DirectoryItem{
    public string name;
    public bool isDirectory;
}
"@;

function ListDirectoryDetails($dirName)
{
  Write-Host "** ListDirectoryDetails(" $dirName ")"

  $FTPRequest = [System.Net.FtpWebRequest]::Create("$dirName")
  $FTPRequest = [System.Net.FtpWebRequest]$FTPRequest
  $FTPRequest.Credentials = New-Object System.Net.NetworkCredential($Username.Normalize(), $Password.Normalize(), $WebsiteName.Normalize())
  $FTPRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectoryDetails
  $FTPRequest.EnableSSL = $False
  $FTPRequest.UseBinary = $True
  $FTPRequest.UsePassive = $True
  $FTPRequest.KeepAlive = $False 	

  $FTPResponse = $FTPRequest.GetResponse()
  $ResponseStream = $FTPResponse.GetResponseStream()
	$FTPReader = New-Object System.IO.Streamreader -ArgumentList $ResponseStream
  $data = $FTPReader.ReadToEnd()    
	$FTPReader.Close()	

  $stringArray = $data.Split("`n")

  $arrayOfItems = @()

  foreach($item in $stringArray)
  {   
    $item = $item.Replace("`n", "").Replace("`r","").Trim()
    if($item.Length -gt 0){
      $a = New-Object DirectoryItem
      $name = GetNameFromDirectoryStringItem $item
      $isDir = GetIsDirectoryFromDirectyStringItem $item
      $a.name = $name
      $a.isDirectory = $isDir

      $arrayOfItems += $a
    }
  }

  return $arrayOfItems
}

function GetNameFromDirectoryStringItem($directoryItemAsString)
{
  $regex = [regex]"\S+$"
  $match = $regex.Match($directoryItemAsString)    
  return $match.Captures[0]
}

function GetIsDirectoryFromDirectyStringItem($directoryItemAsString)
{
  $match = $directoryItemAsString -match " <DIR> "
  return $match   
}

function RecursiveDirDelete($arrayOfItemsToDelete, $currentPath)
{
  Write-Host "** RecursiveDirDelete(" $currentPath ")"

  #DeleteAllFiles
  foreach($item in $arrayOfItemsToDelete)
  {
    if($item.isDirectory -eq $false){
      $fileNameToDelete = $currentPath + $item.name
      Write-Host "    Delete file" $fileNameToDelete
      DeleteFile $fileNameToDelete
      }
  }

  #RecurseAndDeleteAllDirectories
  foreach($item in $arrayOfItemsToDelete)
  {
    if($item.isDirectory){
      $nextPath = $currentPath + $item.name + "/"
      Write-Host "    Recursive delete on" $nextPath            
      $dirArray = ListDirectoryDetails $nextPath
      RecursiveDirDelete $dirArray $nextPath
      RemoveDirectory $nextPath
      }
  }
}

function DeleteFile($fileNameWithPath)
{
  write-host "**  -- Deleting" $fileNameWithPath 

  $FTPRequest = [System.Net.FtpWebRequest]::Create("$fileNameWithPath")
  $FTPRequest = [System.Net.FtpWebRequest]$FTPRequest
  $FTPrequest.Method = [System.Net.WebRequestMethods+Ftp]::DeleteFile
  $FTPRequest.Credentials = New-Object System.Net.NetworkCredential($Username.Normalize(), $Password.Normalize(), $WebsiteName.Normalize())
  $FTPRequest.EnableSSL = $False
  $FTPRequest.UseBinary = $True
  $FTPRequest.UsePassive = $True
  $FTPRequest.KeepAlive = $False    

  # Delete
  $FTPrequest.GetResponse()

  # Cleanup
  $Run.Close()
  $Run.Dispose()
}

function RemoveDirectory($dirNameWithPath)
{
  write-host "**  -- Removing" $dirNameWithPath 
    
  $FTPRequest = [System.Net.FtpWebRequest]::Create("$dirNameWithPath")
  $FTPRequest = [System.Net.FtpWebRequest]$FTPRequest
  $FTPrequest.Method = [System.Net.WebRequestMethods+Ftp]::RemoveDirectory
  $FTPRequest.Credentials = New-Object System.Net.NetworkCredential($Username.Normalize(), $Password.Normalize(), $WebsiteName.Normalize())
  $FTPRequest.EnableSSL = $False
  $FTPRequest.UseBinary = $True
  $FTPRequest.UsePassive = $True
  $FTPRequest.KeepAlive = $False

  # Remove Dir
  $FTPrequest.GetResponse()

  # Cleanup
  $Run.Close()
  $Run.Dispose()
}


$rootDirArray = ListDirectoryDetails $ftpRoot
RecursiveDirDelete $rootDirArray $ftpRoot
Write-Host ** Finished FTPRecursiveDelete
