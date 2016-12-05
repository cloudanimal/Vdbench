$file = "C:\Temp\ps.xlsx"
rm $file -ErrorAction Ignore

ps |
    where company |
    select Company,PagedMemorySize,PeakPagedMemorySize |
    Export-Excel $file -Show -AutoSize `
        -IncludePivotTable `
        -IncludePivotChart `
        -ChartType ColumnClustered `
        -PivotRows Company `
        -PivotData @{PagedMemorySize='sum';PeakPagedMemorySize='sum'} `
        -PivotDataToColumn