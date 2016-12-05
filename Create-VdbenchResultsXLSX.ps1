function Merge-vdbenchCSV {
   [cmdletbinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory=$false)][String]$Source = ".\output",
            [Parameter(Mandatory=$false)][String]$Destination=".\results.xlsx"
            #[Parameter(Mandatory=$false)][Switch]$Show
    )

    <#

    .SYNOPSIS
    Merge CSV created by Convert-VdbenchFlatfiletoCsv.ps1 into an Excel Workbook

    .DESCRIPTION
    Create a new Excel workbook
    Import each Workload results CSV file as a new worksheet
    Identify the maximum bandwidth while under 20ms 

    Loops through vdbench flatfiles in a single directory that have been converted to csv by the 
    convert-VdbenchFlatfiletoCsv -File
    Merges all CSV files found in $path
    converts to .xlsx in the output directory

    .EXAMPLE
    Merge-vdbenchCSV

    .EXAMPLE
    Merge-vdbenchCSV -whatif

    .EXAMPLE
    Merge-vdbenchCSV -Verbose

    .EXAMPLE
    Merge-vdbenchCSV -Source .\output -Destination .\allresults.xlsx -WhatIf

    .EXAMPLE
    Merge-vdbenchCSV -Source .\output -Destination .\allresults.xlsx -Verbose

    .PARAMETER Source
    The computer name to query. Just one.

    .PARAMETER Destination
    The name and path to the excel file to write to.

    #>

    Begin {
        # Check if module is installed, 
        # if installed, load module
        # if not, install module, then load module
        # Load Modules
        #. .\ConvertCSV-ToExcel.ps1
        # Get-InstalledModule importexcel
        if(!(Get-InstalledModule importexcel)) {
            Try {
            Install-Module importexcel
            Import-Module importexcel
            } catch {
                $_.Exception.GetType().FullName, $_.Exception.Message | Write-Warning
                Write-Warning "Automatic installation of the importexcel module failed"
                Write-Warning "Please install the importexcel module to continue"
                Write-Warning "https://www.powershellgallery.com/packages/ImportExcel/2.2.9"
                Write-Warnning "Install-Module -Name ImportExcel"
                break
            }
        } else {
            Try {
            Import-Module importexcel
            } catch {
                $_.Exception.GetType().FullName, $_.Exception.Message | Write-Warning
                Write-Warning "Automatic installation of the importexcel module failed"
                Write-Warning "Please install the importexcel module to continue"
                Write-Warning "https://www.powershellgallery.com/packages/ImportExcel/2.2.9"
                Write-Warnning "Install-Module -Name ImportExcel"
                break
            }
        }
        #
        $BaseDir = "."
        $Output = "$BaseDir\output"
        $File = "flatfile.csv"
        $Workbook = $Destination
        #
        function Get-VdbenchCSV {
            #$CSVfiles = (Get-ChildItem "$output\$File" -Recurse)
            $CSVFiles = Get-ChildItem "$output\$File" -Recurse | 
            sort @{Expression={($_.fullname -split '\\')[-2]}; Ascending=$false},@{Expression={($_.fullname -split '\\')[-3]}; Ascending=$true} | Select-Object fullname
            $CSVCount=$CSVfiles.Count
            Write-Verbose “Detected ($CSVCount) CSV files”
            return $CSVFiles
        }
        $CSVFiles = Get-VdbenchCSV
    }
    
    Process {

        Write-Verbose "Creating: $Workbook"

        ## PROCESS

        $CSVfiles | foreach{
 
            #$CsvHeader = "date","Run","Interval","reqrate","rate","MB/sec","bytes/io","read%","resp","read_resp","write_resp","resp_max","resp_std","xfersize","threads","rdpct","rhpct","whpct","seekpct","lunsize","version","compratio","dedupratio","queue_depth","cpu_used","cpu_user","cpu_kernel","cpu_wait","cpu_idle"
            $CsvObj = (Import-Csv -Delimiter "," -Path $_.fullname)

            $workload = (($_.fullname -split '\\')[-2])
            $sd = ($_.fullname -split '\\')[-3]
            $worksheetName = (($workload+$sd) -replace "thread_curve|threads_curve","t_")
 
            #Write-Verbose "Adding $Workload to $Workbook"
            
            If ($Pscmdlet.ShouldProcess("$SD-$Workload","Merge")) {
                # Filtering out names longer than 31 characters for Excel worksheet name limit
                If($worksheetName.length -lt "31" ){
                    #Write-Host "adding $worksheetname"
                    #Write-Host "get-content $_.fullname | Export-Excel $Workbook -WorkSheetname $worksheetName -AutoSize"
                    # TODO: Find Max value of CsvObj rate colum where latency -lt 20

                    $MAX = ($CSVObj | Where-Object {$_.resp -lt "20" }  | Sort-Object  -Property "MB/sec" -Descending)[0]

                    $CsvObj | 
                    Export-Excel $Workbook -WorkSheetname $worksheetName -BoldTopRow -AutoFilter -FreezeTopRow -AutoSize -ConditionalText $( New-ConditionalText $max.date blue cyan )
                    #(Col_X = QueueDepth)
                    #(Col_E = Rate)
                    #(Col_F = MB/s)
                    #(Col_I = Latency(resp))
                }else{
                    write-host "skipping $worksheetname"
                }
            }
        }
    }
}

# Example Commands (Uncomment to Test)
#Merge-vdbenchCSV
#Merge-vdbenchCSV -whatif
Merge-vdbenchCSV -Verbose
#Merge-vdbenchCSV -Source .\output -Destination .\allresults.xlsx -WhatIf
#Merge-vdbenchCSV -Source .\output -Destination .\allresults.xlsx -Verbose

