# PowerShell Network Drive Remap Script

This is a quick script which you can use to replace the paths of network drives on the local machine.

Two great examples of use cases are:

* Moving from on-premises fileservers to Azure File Sync (this is what it was written for!)
* Moving files between fileservers

It's a simple script which takes an input file with a list of drive mappings, and migrates any matching existing network drive mappings to the new locations.

## Usage

Simply open up a PowerShell session and run:

```powershell
> .\Remap.ps1
```

There are a couple parameters you can use as well:

```
-RemapFile : The file in which the old/new path mappings reside (default is ".\RemapPaths.txt")
-RemapLogDir : The directory in which to store logs the script creates (default is "C:\Temp")
```

So, as a full example, run:

`.\Remap.ps1 -RemapFile "C:\Temp\MyRemaps.txt" -RemapLogDir "C:\Temp\RemapLogs"`

## RemapFile

In the file, please do not use trailing slashes, and do not use full directory paths as these will automatically be recreated to match the shares. An example of a file would be the below:

```
\\localfs01\Example-Share > \\afs01\Example-Share
\\localfs02\Example Share 2 > \\afs03\Example Share 2
\\localfs01\OldSharePath > \\afs03\NewFS01SharePath
```

You can use spaces and you don't need to put anything in quotes. You MUST add spaces either side of the `>` as the script splits based on this convention (and it looks neater).

Note that entries such as `\\localfs01` and `\\lfs-01` will need to be added individually. This script takes the exact share paths and will not detect variations in naming.

### Group Policy

If you're using GPOs for drive mapping, please bear in mind that some of these changes might be overwritten by your Group Policy. Check these before running.

## Issues and Contributions

If you notice an issue, please log an Issue on GitHub. Even if it's an uncommon use case, I'd like to know about it (as I'm sure others would too).

If you'd like to contribute, please do so. It's only a small script. I'll check any PRs as they come through.

## Licence

This script was written as generically as possible and is licenced under the MIT licence.