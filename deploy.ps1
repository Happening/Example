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
	echo "Unable to create ZIP."
	echo $_.Exception.GetType().FullName, $_.Exception.Message
	Exit
}

# Upload the file
try {
	$OldEAP = $ErrorActionPreference
	$ErrorActionPreference = 'SilentlyContinue'
	$result = Invoke-RestMethod -Uri "https://happening.im/plugin/$($Args[0])" -InFile $Dest -Method POST
	$ErrorActionPreference = $OldEAP
	# Print success result
	echo $result
} catch [Exception] {
	echo ">>> Failed to deploy your plugin to Happening:"
	# Print the exception message (includes the HTTP status code)
	echo $_.Exception.Message
	# Print the body of the server response (includes the error message from Happening)
	$result = $_.Exception.Response.GetResponseStream()
	$reader = New-Object System.IO.StreamReader($result)
	$reader.BaseStream.Position = 0
	$reader.DiscardBufferedData()
	$responseBody = $reader.ReadToEnd();
	echo $responseBody
	Exit
}

