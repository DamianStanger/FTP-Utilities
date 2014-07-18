param(
[string]$ftpRoot,    # "ftp://ftpsite.net/site/wwwroot",
[string]$folderRoot, # "c:/foldertoupload",
[string]$username,
[string]$password
)

Write-Host ** Starting FTPRecursiveUpload

Write-host ** Arguments **
Write-Host "ftpRoot    : " $ftpRoot
Write-Host "folderRoot : " $folderRoot
Write-Host "username   : " $username
Write-Host "password   : " $password


function UploadFilesInFolder([string]$folder)
{
    $files = Get-ChildItem -Path $folder -File
    foreach($file in $files)
    {
        Write-Host "Uploading file $file.FullName"
        UploadByFtp $file.FullName
    } 
}

function UploadWebsiteFiles([string]$folder)
{ 
    $ftpfolder = $ftproot + $folder.Substring($folderRoot.Length).Replace("\", "/")
    CreateFTPFolder $ftpfolder
    Write-Host "starting upload of folder: $folder"
    UploadFilesInFolder $folder

    $paths = get-childitem -Path $folder -Directory 
    foreach($path in $paths) 
    {
        Write-Host "FoundItem: $path"
        if ($path.Attributes -eq "Directory") 
        {
            if ($path.Name -notin ".", "..")
            { 
                 Write-Host "uploading file: " $path.FullName
                 UploadWebsiteFiles $path.FullName
            }
        }
    }
}

function UploadByFtp([string]$fullfileName)
{
    $file = $ftpRoot + $fullfileName.Substring($folderRoot.Length).Replace("\", "/")
    $ftp = [System.Net.FtpWebRequest]::Create($file)
    $ftp = [System.Net.FtpWebRequest]$ftp
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $ftp.Credentials = new-object System.Net.NetworkCredential($username, $password)
    $ftp.UseBinary = $true
    $ftp.UsePassive = $true

    Write-Host "Uploading $file"
    # read in the file to upload as a byte array
    $content = [System.IO.File]::ReadAllBytes($fullfileName)
    $ftp.ContentLength = $content.Length
    # get the request stream, and write the bytes into it
    $rs = $ftp.GetRequestStream()
    $rs.Write($content, 0, $content.Length)
    $rs.Close()
    $rs.Dispose()
}

function CreateFTPFolder($newFolder)
{
    try
     {
        Write-Host "creating folder " $newFolder
        $makeDirectory = [System.Net.WebRequest]::Create($newFolder);
        $makeDirectory.Credentials = New-Object System.Net.NetworkCredential($username,$password);
        $makeDirectory.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory;
        $makeDirectory.GetResponse();          
    }
    catch [Net.WebException] 
    {
        try {
            Write-Host "Error creating folder " $newFolder
            
            #if there was an error returned, check if folder already existed on server
            $checkDirectory = [System.Net.WebRequest]::Create($newFolder);
            $checkDirectory.Credentials = New-Object System.Net.NetworkCredential($username,$password);
            $checkDirectory.Method = [System.Net.WebRequestMethods+FTP]::PrintWorkingDirectory;
            $response = $checkDirectory.GetResponse();
     
            #folder already exists!
            Write-Host "Folder already exists " $newFolder
        }
        catch [Net.WebException] {                
            #if the folder didn't exist, then it's probably a file perms issue, incorrect credentials, dodgy server name etc
            Write-Host "Failed creating folder " $newFolder
        }    
    }
}


UploadWebsiteFiles $folderRoot 
