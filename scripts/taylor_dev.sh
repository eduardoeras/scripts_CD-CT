#!/bin/bash

exec > >(tee MONAN_taylor_dev_output.txt) 2>&1

################################################################################
# Script: taylor_dev.sh
# Description: Compile and run the MONAN model with Taylor PBL scheme for
# development and testing.
# Author: Eduardo Rohde Eras
# Date: April 28, 2026
################################################################################

# Record the start time for runtime calculation
START_TIME=$(date +%s)

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

echo "_/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\_"
echo -e "\n\nCompilation completed. Proceeding to run the model...\n\n"
echo "_/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\_"
sleep 4

#Run MONAN model with Taylor PBL scheme
./2.pre_processing.bash GFS 655362 2025120800 48 2>&1 | tee pre_processing_output.txt
./3.run_model.bash GFS 655362 2025120800 48 2>&1| tee model_run_output.txt

# Record the end time and calculate elapsed time
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

# Print total runtime in HH:MM:SS format
printf "Total runtime: %02d:%02d:%02d\n" \
       $((ELAPSED/3600)) \
       $((ELAPSED%3600/60)) \
       $((ELAPSED%60))

echo -e "\n#########################"
echo "# Simulation completed. #"
echo -e "#########################\n"

################################################################################