#$file = "C:\Users\joscook\Documents\Projects\AUTOMATION\SLIPSTREAM_MEDIA\UCP2000_VMware_HyperV_Configuration_Spreadsheet_v3.0.xlsx"
# Create Excel File
rm $file -ErrorAction Ignore

$xlPkg = $(
    New-PSItem north 10
    New-PSItem east  20
    New-PSItem west  30
    New-PSItem south 40
) | Export-Excel $file -PassThru

$ws=$xlPkg.Workbook.Worksheets[1]

$ws.Cells["A3"].Value = "Hello World"
$ws.Cells["B3"].Value = "Updating cells"
$ws.Cells["D1:D5"].Value = "Data"

$ws.Cells.AutoFitColumns()

$xlPkg.Save()
$xlPkg.Dispose()

Invoke-Item $file