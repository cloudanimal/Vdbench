[CmdletBinding()]
    param (
        
    [parameter(Mandatory=$True,HelpMessage="Enter the name of this testrun")]
    [ValidateNotNullOrEmpty()]
    [string]$Run
    )

clear-host

function start-testrun {
	[CmdletBinding()]
	param (
        
        [parameter(Mandatory=$True,HelpMessage="Enter the name of this testrun")]
        [ValidateNotNullOrEmpty()]
		[string]$Run

	)
    Begin {
        function Get-Timestamp {
            $timestamp=Get-Date -Format 'yyyyMMdd-HHmmss'   #20161008-101629
        return $timestamp
        }

        function Set-PowerPlan {
	    [CmdletBinding(SupportsShouldProcess = $True)]
	    param (
		    [ValidateSet("High performance", "Balanced", "Power saver")]
		    [ValidateNotNullOrEmpty()]
		    [string] $PreferredPlan = "High Performance"
	    )

	    Write-Verbose "Setting power plan to `"$PreferredPlan`""
	    $guid = (Get-WmiObject -Class Win32_PowerPlan -Namespace root\cimv2\power -Filter "ElementName='$PreferredPlan'").InstanceID.ToString()
	    $regex = [regex]"{(.*?)}$"
	    $plan = $regex.Match($guid).groups[1].value

	    powercfg -S $plan
	    $Output = "Power plan set to "
	    $Output += "`"" + ((Get-WmiObject -Class Win32_PowerPlan -Namespace root\cimv2\power -Filter "IsActive='$True'").ElementName) + "`""
	    Write-Verbose $Output
    }

    Set-PowerPlan "High Performance"
    
    <#
    Runs whatever workloads (*.cfg) are in the workloads directory
    #>
    ###########################################################################
    # Notes:
    <# $DiskDrives = Get-WmiObject WIn32_DiskDrive | Select Index, DeviceID, Size | Sort Index
    # foreach ($Disk in $DiskDrives) {"sd=Disk$($Disk.Index),lun=$($Disk.DeviceID),openflags=directio,size=$([Math]::Floor($Disk.Size / 1GB))g"}
    # get-item *.cfg | ForEach {(get-content -path $_.FullName).Replace("6143g","2147g") | Set-Content -Path $_.FullName}
    # 2147g
    # Curve adjustment for HDD testing
    # get-item *.cfg | ForEach {(get-content -path $_.FullName).Replace("(1,10,20,30,40,50,60,70,80,85,90,92,94,96,98)","(1,5,10,15,20,25,30,35,40,45,50,75)") | Set-Content -Path $_.FullName}
    # ^(?=.*?\b<text_to_replace>\b)(?!#.)*$.
    # (1,5,10,15,20,25,30,35,40,45,50,75)
    # get-item *.cfg | ForEach {(get-content -path $_.FullName | Select-String "curve=")}
    #>
    <#
    #rd=lblkseqiorun,wd=lblkseqio,iorate=curve,curve=(1,5,10,15,20,25,30,35,40,45,50,75),interval=1,elapsed=60,warmup=15,threads=512
    #rd=lblkseqiorun,wd=lblkseqio,iorate=curve,curve=(1,5,10,15,20,25,30,35,40,45,50,75),interval=1,elapsed=60,warmup=15,threads=512
    #rd=exchcurverun,wd=exchcurve,iorate=curve,curve=(1,5,10,15,20,25,30,35,40,45,50,75),interval=1,elapsed=60,warmup=15,threads=512
    #rd=smallrun1,wd=small,iorate=curve,curve=(1,5,10,15,20,25,30,35,40,45,50,75),interval=1,elapsed=60,warmup=15
    #rd=max4kcurverun,wd=max4kcurve,iorate=curve,curve=(1,5,10,15,20,25,30,35,40,45,50,75),interval=1,elapsed=60,warmup=15,threads=512
    #rd=max4kcurverun,wd=max4kcurve,iorate=curve,curve=(1,5,10,15,20,25,30,35,40,45,50,75),interval=1,elapsed=60,warmup=15,threads=512
    #rd=oltpcurverun,wd=oltpcurve,iorate=curve,curve=(1,5,10,15,20,25,30,35,40,45,50,75),interval=1,elapsed=60,warmup=15,threads=512
    #*rd=myrd,wd=wd1,iorate=curve,curve=(1,5,10,15,20,25,30,35,40,45,50,75),interval=1,elapsed=60,warmup=15,threads=512
    #rd=sqlrun,wd=sqlcurve,iorate=curve,curve=(1,5,10,15,20,25,30,35,40,45,50,75),interval=1,elapsed=60,warmup=15,threads=512
    #*rd=myrd,wd=wd1,iorate=curve,curve=(1,5,10,15,20,25,30,35,40,45,50,75),interval=1,elapsed=60,warmup=15,threads=512
    #rd=webcurverun,wd=webcurve,iorate=curve,curve=(1,5,10,15,20,25,30,35,40,45,50,75),interval=1,elapsed=60,warmup=15,threads=512
    #>
    ###########################################################################
    # Setting up environment variables for test run
    ###########################################################################
    #$basedir = Split-Path -parent $MyInvocation.MyCommand.Definition 
    $basedir = '.'
    $workload_profiles = $(Get-Childitem $basedir\workloads\curves\*.cfg)
    $outputdir = $basedir + "\output"
    $vdbench = $basedir + "\vdbench50403\vdbench.bat"
    #$timestamp=Get-Date -Format 'yyyyMMdd-HHmmss'   #20161008-101629
    $timestamp = Get-Timestamp
    $rundir = ($outputdir + "\" + $timestamp + '-'+$run)
    Write-Verbose ""
    Write-Verbose "Variables Used"
    Write-Verbose "BaseDir = $basedir"
    Write-Verbose "Outputdir = $outputdir"
    Write-Verbose "Vdbench = $vdbench"
    Write-Verbose "Timestamp = $timestamp"
    Write-Verbose "Rundir = $rundir"
    #
    # Create Output Directory $rundir
    if(!(test-path $rundir)){
        try {
            New-Item -Path $rundir -ItemType directory -Force | out-null
        } catch [Exception] {
            $_.Exception.GetType().FullName, $_.Exception.Message | Write-Warning
            break
        } finally {

        }
    } else {
    Write-Warning $Rundr already exists
    break
    }
    Write-Verbose ""
    Write-Verbose "Calling .\Set-VdbenchSD.ps1"
    .\Set-VdbenchSD.ps1

    }

    Process {

        Foreach ($workload in Get-Childitem $workload_profiles){
        $workload_name = [System.IO.Path]::GetFileNameWithoutExtension($workload)
        $workloaddir = ($rundir + "\" + $workload_name)

        $arguments = "-f $workload -o $workloaddir"
        Write-Verbose ""
        Write-Verbose "Starting Vdbench"
        Write-Verbose "$vdbench $arguments -NoNewWindow -Wait"
        Start-Process $vdbench $arguments -NoNewWindow -Wait
    
    <#
    TODO: format disk, wipe disk between runs
    clear-disk
    Reset-PhysicalDisk (if unhealthy)
    Write-VolumeCache #enables you to forcibly empty, or flush, the write cache by writing it to disk
    Update-HostStorageCache or VDS Rescan when PG groups change
    #>
    Write-Verbose "Sleeping for 60 seconds between workloads"
    Start-Sleep 60
    }

    }

    End {
    Write-Verbose "Test Run Complete"
    }
}
Write-Verbose "Starting Test Run"
start-testrun -Run $Run