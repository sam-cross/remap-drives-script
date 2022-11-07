#
# Drive Remapping Script
#
# github.com/sam-cross
#

####

param (
    [string]$RemapFile = ".\RemapPaths.txt",
    [string]$RemapLogDir = "C:\Temp"
)

# Create RemapLogDir if it doesn't exist, then start logging
mkdir $RemapLogDir -ErrorAction SilentlyContinue
Start-Transcript -Append -Path $(Join-Path $RemapLogDir "Remap.log") -UseMinimalHeader

# Get current shares
$ExistingDrivesRaw = Get-PSDrive -PSProvider "FileSystem" | Select-Object *

# Remove mappings which do not contain "DisplayRoot" values as these aren't network shares
$ExistingDrives = @()
Foreach ($ExistingDriveRaw in $ExistingDrivesRaw) {
    If ($null -ne $ExistingDriveRaw.DisplayRoot) {
        $ExistingDrives += $ExistingDriveRaw
    }
}

# Export existing drives for posterity
$ExistingDrives | Export-Csv -NoTypeInformation -Path $(Join-Path $RemapLogDir "Remap.list.csv")

# Iterate over RemapFile
Foreach ($Mapping in Get-Content $RemapFile) {
    # For each Mapping, split by old/new locations
    $MappingObject = $Mapping.Split(' > ')

    # Iterate over current network drives for any matches
    Foreach ($ExistingDrive in $ExistingDrives) {
        # 0, 1 are blank. 2 is server. 3 is share name. >=4 is directory
        $ExistingDriveObject = $ExistingDrive.DisplayRoot.Split('\')

        $ExistingShareName = "\\$($ExistingDriveObject[2])\$($ExistingDriveObject[3])"
        $ExistingDriveLetter = $ExistingDrive.Name
        $ExistingDirectory = ""
        For ($i = 4; $i -lt $ExistingDriveObject.Count; $i++) {
            $ExistingDirectory += ("\" + $ExistingDriveObject[$i])
        }

        If ($ExistingShareName -eq $MappingObject[0]) {
            $NewDrivePath = "$($MappingObject[1])$($ExistingDirectory)"

            Write-Output "Deleting $ExistingDriveLetter ($($ExistingShareName)$($ExistingDirectory)) ..."
            net use "$($ExistingDriveLetter):" /delete

            Write-Output "Mapping $NewDrivePath to $($ExistingDriveLetter):\ ..."

            # Sleep for a couple seconds, otherwise it won't add the new drive before the old one's deleted
            Start-Sleep 3s

            net use "$($ExistingDriveLetter):" "$NewDrivePath"
        }
    }
}

Stop-Transcript
Exit 