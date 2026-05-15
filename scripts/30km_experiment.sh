#!/bin/bash

exec > >(tee MONAN_30km_experiment_ysu_output.txt) 2>&1

################################################################################
# Script: 30km_experiment.sh
# Description: Run a series of MONAN model simulations with 30km resolution for
# a range of dates. 
################################################################################

#Functions
print_status() {
    echo -e "\n################################################################"
    echo "$1"
    echo -e "################################################################\n"
}

#Erase previous data output
if cd ../dataout/; then
    ls
    echo "Removing previous data output..."
    rm -rf *
    ls
    echo "Previous data output removed. Back to scripts directory."
    cd ../scripts/
else
    echo "ERROR: dataout directory not found. Aborting to prevent accidental deletion." >&2
    exit 1
fi

sleep 4

#Compile MONAN model
cd ../sources/MONAN-Model_1.4.3-rc/
./make-all.sh | tee MONAN_Compilation_output.txt
cd ../../scripts/

##################################################################################
#                        Date range for the simulations                          #
##################################################################################

#Full range simulation
#start_date="2025-11-26" 
#end_date="2025-12-30"  

#Short range simulation
start_date="2025-12-05" 
end_date="2025-12-20"

##################################################################################

#Simulation span in hours (e.g., 120 for 5 days)
simulation_span=120

#Convert dates to Unix timestamps for looping
start_ts=$(date -d "$start_date" +%s)
end_ts=$(date -d "$end_date" +%s)

#Looping over dates (the sane way)
#Strategy: Convert dates to Unix timestamps (seconds since 1970-01-01),
#loop numerically, them convert back to human dates.
#This avoids calendar madness.
for (( ts = start_ts; ts <= end_ts; ts += 86400 )); do
    simulation_date=$(date -d "@$ts" +%Y%m%d00)
    message="* * * Simulation for date: $simulation_date with span: $simulation_span hours * * *"
    print_status "$message"
    #Creating the execution strings
    pre="2.pre_processing.bash GFS 655362 $simulation_date $simulation_span"
    model="3.run_model.bash GFS 655362 $simulation_date $simulation_span"
    post="4.run_post.bash GFS 655362 $simulation_date $simulation_span"
    #Running the simulation steps
    print_status "Running pre-processing..."
    sleep 2
    ./${pre}
    print_status "Running model..."
    sleep 2
    ./${model}
    print_status "Running post-processing..."
    sleep 2
    ./${post}
done

echo -e "\n##############################"
echo "# All simulations completed. #"
echo -e "##############################\n"