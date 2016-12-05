

1.Retrieve/Download Vdbench and PreRequisites Software
(or copy testing package from /se/temp/
2.Install Vdbench and PreRequisite softare
(or unzip testing package)
install java
3.Configure Testing Environment

4.Execute Tests
5.Report Results


1.Retrieve/Download Vdbench and PreRequisites Software
Java
Vdbench
Workload definitions and scripts

2.Install Vdbench and PreRequisites
Java
Vdbench
Validation package
- Vdbench Workload definitions
- Scripts

3.Configure Testing Environment
Set-VDBenchSD.ps1

4.Execute Tests
Start-TestRun.ps1

5.Report Results
(Collect/Query/Transform/View/Report Results)

5.1 Create-VdbenchExcel.ps1
5.1.1 ./convert-VdbenchFlatfiletoCsv.ps1
5.1.1 ./convert_all_vdbench_flatfiles_to_csv.ps1
5.1.1. ./merge_vdbench_csv_to_excel.ps1




For each workload, Convert Flatfile.html to Flatfile.csv
Run Convert_all_vdbench_flatfiles_to_csv.ps1
Merge all flatfile.csv into single excel spreadsheet
Merge all CSV to XLS





Requirements:
	1. Powershell v.X
	2. Import-Excel module required for output to Excel
	3. Vdbench 12-01 package required on test machine

To use:
	1. Provision storage to Test VM
	2. Copy Vdbench package to Test VM
	3. Simply drop any workloads from ./Workload/Templates/ into ./Workload/Run/ 
	./Workloads/Run directory will be ran
	./Workloads/Templates houses Vdbench workload templates
	
	4. Set-VdbenchSD.ps1	# Sets the storage device to be used in the Vdbench workloads in ./Workloads/Run
	5. Start-TestRun.ps1	# Starts tests configured in ./Workloads/Run
	6. Convert_all_vdbench_flatfiles_to_csv.ps1 < 6b. Convert-Vdbenchflatfiletocsv.ps1
	7. csvmerge.ps1/merge-VdbenchCSV
	merges CSVs into a single excel document
	provides a filter point for data
    Applies conditional formatting, pivot tables, and charts to Excel worksheet

	Example: 
	Identify Max Bandwidth while under 20ms latency
    Worksheet containing Rollup of all max data from all runs



    

