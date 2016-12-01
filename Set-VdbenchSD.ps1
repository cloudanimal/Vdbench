###########################################################################
$basedir = Split-Path -parent $MyInvocation.MyCommand.Definition 
$workload_profiles = $(Get-Childitem $basedir\workloads\curves\*.cfg)
$outputdir = $basedir + "\output"
$vdbench = $basedir + "\vdbench50403\vdbench.bat"
$timestamp=Get-Date -Format 'yyyyMMdd-HHmmss'   #20161008-101629
#$rundir = ($outputdir + "\" + $run + "\")
#md $rundir -ErrorAction SilentlyContinue
###########################################################################
$regex = "^(?=.*?\b'sd'\b)(?!'*'.)*$."
Function Get-VdbenchSD () {
	#TODO: Use Get-PSDrive provider property and select non-os drive to avoid wiping out OS
	$DiskDrives = Get-WmiObject WIn32_DiskDrive | Select Index, DeviceID, Size | Sort Index
	$SD = $(foreach ($Disk in $DiskDrives) {"sd=Disk$($Disk.Index),lun=$($Disk.DeviceID),openflags=directio,size=$([Math]::Floor($Disk.Size / 1GB))g"})
	return $SD[1]
}

Function Set-VdbenchSD ($PathToFile, $StringToFind, $StringToReplace) {
	(Get-Content $PathToFile) |
	Foreach-Object {$_ -replace $StringToFind, $StringToReplace } |
	Set-Content $PathToFile
}

$SD = Get-VdbenchSD

Write-Verbose ""
Write-Verbose "Setting Vdbench Workload Storage Device parameter"
ForEach ($w in $workload_profiles){
	$regex = "^sd.*?$"
    write-verbose "$w.name"    
	Set-VdbenchSD $w $regex $sd
    gc $w | sls ",size=" | Write-Verbose
    Write-Verbose "----------------------"
	}



#gc .\workloads\curves\*.cfg | sls ",size="