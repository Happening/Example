# You may be required to enable script execution: Set-ExecutionPolicy Unrestricted -Scope CurrentUser
# Requires at least Powershell 3.0 (included since Windows 7)

$Src = (Split-Path $MyInvocation.MyCommand.Path) + "\"
$Dest = [System.IO.Path]::GetTempFileName()

# Read key from first argument
if ($Args.length -eq 0) {
    echo "Usage: .\$($MyInvocation.MyCommand.Name) <upload key>"
    Exit
}

# Create a ZIP file, remove old one first
If (Test-Path $Dest){
    Remove-Item $Dest
}

try {
    [Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
    [System.IO.Compression.ZipFile]::CreateFromDirectory($Src, $Dest, [System.IO.Compression.CompressionLevel]::Optimal, $false)
} catch {
    echo "Unable to create a ZIP file. Aborting."
    Exit
}

# Upload the file
try {
    Invoke-RestMethod -Uri "https://happening.im/plugin/$($Args[0])" -InFile $Dest -Method POST
} catch {
    echo "Unable to post ZIP file. Is your key correct? Aborting."
    Exit
}