# Vdbench Curve Runs
Identify X_IOPS at Y_Latency
First run idenfies max io
Subsequent runs, run at the % listed in the curve=() param
e.g. curve=(25,50,75)
will tell Vdbench to first establish the maximum iops for the workload
then run the same workload at 25%, 50%, and 75% of that max
* use 512 threads and Vdbench will only consume what it needs
iorate=curve,curve=(1,10,20,30,40,50,60,70,80,85,90,92,94,96,98),interval=1,elapsed=60,warmup=15,threads=512

