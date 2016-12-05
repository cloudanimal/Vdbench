[CmdletBinding()]
    param (        
    [parameter(Mandatory=$false,HelpMessage="Enter the name of this Testrun")]
    [ValidateNotNullOrEmpty()]
    [string]$Run
    )
<#
    # This function converts flatfile.html into a Powershell CSV Object
    # .Example1
    # $CsvObj = (convert-VdbenchFlatfiletoCsv -File \path\to\flatfile.html)
    #
    # .Example2
    # Using Pipeline
    # $CSVObj = (get-content \path\to\flatfile.html).pspath | convert-VdbenchFlatfiletoCsv
    #
    # .Example3
    # Query CSVObj
    # $CSVObj | Where-Object {($_.resp -gt "19") -and ($_.resp -lt "20")} | export-csv -path .\flatfile.csv
    #
    # Next Steps: 
    # Query CSV Object
    # Export CSV Object to a file
    # Convert all Vdbench flat.html's to CSV
    # Merge all CSV files into a single Excel Workbook .xlsx
    # Query data in Excel using Excel GUI, Macros, or Powershell
    #> 
    #
##
# Load module to convert flatfile.html > flatfile.csv
#. .\convert-VdbenchFlatfiletoCsv.ps1
#
#
function convert-VdbenchFlatfiletoCsv {
	[CmdletBinding()]
	param(
		#[Parameter(Mandatory=$True,Position=1,ValueFromPipelineByPropertyName =$True)][string[]]$HTMLFlatFile
        [Parameter(Mandatory=$True)][string[]]$File
	)
<#
    # This function converts flatfile.html into a Powershell CSV Object
    # .Example1
    # $CsvObj = (convert-VdbenchFlatfiletoCsv -File \path\to\flatfile.html)
    #
    # .Example2
    # Using Pipeline
    # $CSVObj = (get-content \path\to\flatfile.html).pspath | convert-VdbenchFlatfiletoCsv
    #
    # .Example3
    # Query CSVObj
    # $CSVObj | Where-Object {($_.resp -gt "19") -and ($_.resp -lt "20")} | export-csv -path .\flatfile.csv
    #
    # Next Steps: 
    # Query CSV Object
    # Export CSV Object to a file
    # Convert all Vdbench flat.html's to CSV
    # Merge all CSV files into a single Excel Workbook .xlsx
    # Query data in Excel using Excel GUI, Macros, or Powershell
    #> 
    #
    # Logic expecting a single flatfile.html
    $FlatFile = (Get-Item $File)
    $NewFlatFile = ".\newflatfile.txt"
    $Content = $Null
    $NewContent = $Null
    $NewCsv = ".\new.csv"

    #Fetch the contents
    $Content = (get-content $flatfile) -match '^[0-9]'

    #Replace at least two spaces by a single tab:
    $NewContent = $Content -replace ' {1,}', "`t"

    #Write back to a file
    $NewContent | Set-Content $NewFlatFile

    #notepad $NewFlatFile
    $CsvHeader = "date","Run","Interval","reqrate","rate","MB/sec","bytes/io","read%","resp","read_resp","write_resp","resp_max","resp_std","xfersize","threads","rdpct","rhpct","whpct","seekpct","lunsize","version","compratio","dedupratio","queue_depth","cpu_used","cpu_user","cpu_kernel","cpu_wait","cpu_idle"
    $CsvObj = (Import-Csv -Delimiter "`t" -Path $Newflatfile -Header $CsvHeader)

    #$CsvObj | Export-Csv -Path $NewCsv -NoTypeInformation
    return $CsvObj

}
#
#
#
Write-Verbose ""
Write-Verbose "Setting Variables"
#
$BaseDir = "."
$Output = "$BaseDir\output"
#$TestRun = (Get-ChildItem $Results)
$File = "flatfile.html"
$Flatfiles = (Get-ChildItem $File -Recurse)
#
Write-Verbose "BaseDir = $BaseDir"
Write-Verbose "OutputDir = $Output"
Write-Verbose "OutputCSVDir = $OutputCSV"

## Get Flatfiles, convert flatfile to csv
$Flatfiles | foreach{Write-Verbose $_.FullName}

## Process
Write-Verbose ""
write-verbose "Beginning Conversion"
# Find all flatfile.html files recursively from $basedir
# Convert each flatfile.html to flatfile.csv
# Save flatfile.csv in same directory as originating flatfile.html
#
foreach($ffile in $flatfiles){
    $OutFile = $ffile.fullname -replace ".html",".csv"
    Write-Verbose $OutFile
    # $CsvObj = (convert-VdbenchFlatfiletoCsv -File .\flatfile.html)    
    $CSVObj = convert-VdbenchFlatfiletoCsv -File $ffile
    ## Filter results (If desired or later in excel)
    # (e.g. Less than 20 ms latency)   
    # Query CSV Object and output to csv $OutFile
    # $CSVObj | Where-Object {($_.resp -gt "19") -and ($_.resp -lt "20")} | export-csv -path $OutFile
    $CSVObj | export-csv -NoTypeInformation -Path $Outfile
}

# Next Step:
# Merge all CSVs into a single Excel workbook
# $get-content $csv | Export-Excel .\test.xlsx -WorkSheetname csv2 -AutoSize -Show





