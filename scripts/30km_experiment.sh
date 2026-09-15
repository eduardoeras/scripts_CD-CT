#!/bin/bash
LOG_FILE="MONAN_experiment_output.txt"
exec > >(tee $LOG_FILE) 2>&1

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

###################
# Experiment name #
###################

EXPERIMENT_NAME="full_simulation_eras_dev"

########################
# Experiment directory #
########################

OUTPUT_PATH="/p/projetos/monan_atm/eduardo.eras/Output"

##############################
# ERASE DATAOUT, BE CAREFUL! #
##############################

ERASE=1

##################################
# Date range for the simulations #
##################################

#Full range simulation
START_DATE="2025-11-26" 
END_DATE="2025-12-30"

#Short range simulation
#START_DATE="2025-12-05" 
#END_DATE="2025-12-20"

#Minimum range simulattion
#START_DATE="2025-12-01" 
#END_DATE="2025-12-02"

###################################################
# Simulation span in hours (e.g., 120 for 5 days) #
###################################################

SIMULATION_SPAN=120

#################################################################################
#                                                                               #
#                           .,,uod8B8bou,,.                                     #
#                  ..,uod8BBBBBBBBBBBBBBBBRPFT?l!i:.                            #
#             ,=m8BBBBBBBBBBBBBBBRPFT?!||||||||||||||                           #
#             !...:!TVBBBRPFT||||||||||!!^^""'   ||||                           #
#             !.......:!?|||||!!^^""'            ||||                           #
#             !.........||||                     ||||                           #
#             !.........||||  ##                 ||||                           #
#             !.........||||                     ||||                           #
#             !.........||||                     ||||                           #
#             !.........||||                     ||||                           #
#             !.........||||                     ||||                           #
#             `.........||||                    ,||||                           #
#              .;.......||||               _.-!!|||||                           #
#       .,uodWBBBBb.....||||       _.-!!|||||||||!:'                            #
#    !YBBBBBBBBBBBBBBb..!|||:..-!!|||||||!iof68BBBBBb....                       #
#    !..YBBBBBBBBBBBBBBb!!||||||||!iof68BBBBBBRPFT?!::   `.                     #
#    !....YBBBBBBBBBBBBBBbaaitf68BBBBBBRPFT?!:::::::::     `.                   #
#    !......YBBBBBBBBBBBBBBBBBBBRPFT?!::::::;:!^"`;:::       `.                 #
#    !........YBBBBBBBBBBRPFT?!::::::::::^''...::::::;         iBBbo.           #
#    `..........YBRPFT?!::::::::::::::::::::::::;iof68bo.      WBBBBbo.         #
#      `..........:::::::::::::::::::::::;iof688888888888b.     `YBBBP^'        #
#        `........::::::::::::::::;iof688888888888888888888b.     `             #
#          `......:::::::::;iof688888888888888888888888888888b.                 #
#            `....:::;iof688888888888888888888888888888888899fT!                #
#              `..::!8888888888888888888888888888888899fT|!^"'                  #
#                `' !!988888888888888888888888899fT|!^"'                        #
#                    `!!8888888888888888899fT|!^"'                              #
#                      `!988888888899fT|!^"'                                    #
#                        `!9899fT|!^"'                                          #
#                          `!^"'                                                #
#                                                                               #
#################################################################################

# Erase /model/dataout directory
if [[ ERASE -eq 1 ]]; then
    echo "Erasing dataout..."
    cd ../dataout/
    rm -r *
    cd ../scripts/
    echo "dataout erased. back to script..."
else
    echo "dataout files not erased."
fi

#Convert dates to Unix timestamps for looping
start_ts=$(date -d "$START_DATE" +%s)
end_ts=$(date -d "$END_DATE" +%s)

# Record the start time for runtime calculation
START_TIME=$(date +%s)

#Looping over dates (the sane way)
#Strategy: Convert dates to Unix timestamps (seconds since 1970-01-01),
#loop numerically, them convert back to human dates.
#This avoids calendar madness.
for (( ts = start_ts; ts <= end_ts; ts += 86400 )); do
    simulation_date=$(date -d "@$ts" +%Y%m%d00)
    message="* * * Simulation for date: $simulation_date with span: $SIMULATION_SPAN hours * * *"
    print_status "$message"
    #Creating the execution strings
    pre="2.pre_processing.bash GFS 655362 $simulation_date $SIMULATION_SPAN"
    model="3.run_model.bash GFS 655362 $simulation_date $SIMULATION_SPAN"
    post="4.run_post.bash GFS 655362 $simulation_date $SIMULATION_SPAN"
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
    # Print parcial runtime in HH:MM:SS format
    printf "Parcial runtime: %02d:%02d:%02d\n" \
       $((ELAPSED/3600)) \
       $((ELAPSED%3600/60)) \
       $((ELAPSED%60))
done

# Move the output data to the experiment directory
mkdir -p "$OUTPUT_PATH/$EXPERIMENT_NAME/"
mv "$LOG_FILE" "$OUTPUT_PATH/$EXPERIMENT_NAME/"
cd ../dataout
mv * "$OUTPUT_PATH/$EXPERIMENT_NAME/"

# Record the end time and calculate elapsed time
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

# Print total runtime in HH:MM:SS format
printf "Total runtime: %02d:%02d:%02d\n" \
       $((ELAPSED/3600)) \
       $((ELAPSED%3600/60)) \
       $((ELAPSED%60))

echo -e "\n##############################"
echo "# All simulations completed. #"
echo -e "##############################\n"