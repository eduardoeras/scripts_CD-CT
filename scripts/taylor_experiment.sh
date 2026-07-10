#!/bin/bash

clear

exec > >(tee MONAN_taylor_experiment_output.txt) 2>&1

################################################################################
# Script: taylor_experiment.sh
# Description: Compile and run the MONAN model for a set of scenarios.
# Author: Eduardo Rohde Eras
# Date: June 12, 2026
################################################################################

# Record the start time for runtime calculation
START_TIME=$(date +%s)

#experiment_name="MONAN_Taylor"
#experiment_name="MONAN_MYNN"
experiment_name="MONAN_YSU"

# Scenario info
declare -A outback=(
    [name]="outback"
    [year]="2025"
    [month]="12"
    [day]="05"
)

declare -A great_plains=(
    [name]="great_plains"
    [year]="2025"
    [month]="12"
    [day]="25"
)

declare -A oceanic=(
    [name]="oceanic"
    [year]="2025"
    [month]="12"
    [day]="15"
)

declare -A winter_storm=(
    [name]="winter_storm"
    [year]="2025"
    [month]="12"
    [day]="10"
)

declare -A inland=(
    [name]="inland"
    [year]="2025"
    [month]="12"
    [day]="26"
)

declare -A amazon=(
    [name]="amazon"
    [year]="2025"
    [month]="12"
    [day]="22"
)

declare -A pampas=(
    [name]="pampas"
    [year]="2025"
    [month]="12"
    [day]="15"
)

declare -A mega_city=(
    [name]="mega_city"
    [year]="2025"
    [month]="12"
    [day]="25"
)

declare -A flores_da_cunha=(
    [name]="flores_da_cunha"
    [year]="2025"
    [month]="12"
    [day]="08"
)

declare -A rio_bonito=(
    [name]="rio_bonito"
    [year]="2025"
    [month]="11"
    [day]="07"
)

# List of scenario variable names to execute
scenarios=(
    outback
    great_plains
    oceanic
    winter_storm
    inland
    amazon
    pampas
    mega_city
    flores_da_cunha
    rio_bonito
)

#Compile MONAN model
cd ../sources/MONAN-Model_1.4.3-rc/
./make-all.sh | tee MONAN_Compilation_output.txt
cd ../../scripts/
echo "_/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\_"
echo -e "\n\nCompilation completed. Proceeding to run the model...\n\n"
echo "_/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\__/\_"
sleep 4

# Number of days to begin the simulation before the event date
offset=-2

for scenario_name in "${scenarios[@]}"; do

    # Create a reference to the associative array named in scenario_name
    declare -n scenario="$scenario_name"

    # Construct the init date string in the format YYYYMMDDHH
    init_date="${scenario[year]}${scenario[month]}${scenario[day]}00"

    # Offset the initial simulation date so the simulation starts before the event
    init_date=$(date -d "${init_date:0:8} ${init_date:8:2} ${offset} days" +%Y%m%d%H)

    # Print scenario information
    echo -e "\n********************************"
    echo "Scenario: ${scenario[name]}"
    echo "Event date: ${scenario[year]}${scenario[month]}${scenario[day]}00"
    echo "Initial condition: ${init_date}"
    echo -e "********************************\n"

    #Erase previous data output
    echo -e "\n~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^"
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
    echo "Previous data output cleared. Starting scenario: ${scenario_name}"
    echo -e "~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^\n"

    #Run MONAN model with Taylor PBL scheme
    ./2.pre_processing.bash GFS 655362 "${init_date}" 96 2>&1 | tee pre_processing_output.txt
    ./3.run_model.bash GFS 655362 "${init_date}" 96 2>&1| tee model_run_output.txt

    # Define output directory for the current scenario and copy model output there
    monan_output_dir="/p/projetos/monan_atm/eduardo.eras/SandBox/scripts_CD-CT/dataout/${init_date}/Model"
    experiment_data_dir="/p/projetos/monan_atm/eduardo.eras/SandBox/PBL_dev/data/experiment/${experiment_name}/${scenario[name]}"

    # Print paths for verification
    echo -e "\n~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^"
    echo "Output directory: ${monan_output_dir}"
    echo "Model output will be copied to: ${experiment_data_dir}"
    
    # Copying model output to experiment data directory
    echo "Start copying model output to experiment data directory..."
    mkdir -p "${experiment_data_dir}"
    cp -r "${monan_output_dir}" "${experiment_data_dir}/"
    echo "Model output copied to experiment data directory."
    echo -e "~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^\n"

done

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