#!/bin/bash

################################################################################
# Script: taylor_dev.sh
# Description: Compile and run the MONAN model with Taylor PBL scheme for
# development and testing.
# Author: Eduardo Rohde Eras
# Date: 2025-02-03
################################################################################

#Compile MONAN model
cd ../sources/MONAN-Model_1.4.3-rc/
./make-all.sh | tee MONAN_Compilation_output.txt
cd ../../scripts/

#Erase previous data output
cd ../dataout/
ls
echo "Removing previous data output..."
rm -rf *
ls
echo "Previous data output removed. Back to scripts directory."
cd ../scripts/

#Run MONAN model with Taylor PBL scheme
./2.pre_processing.bash GFS 655362 2025112600 12 2>&1 | tee pre_processing_output.txt
./3.run_model.bash GFS 655362 2025112600 12 2>&1| tee model_run_output.txt

################################################################################