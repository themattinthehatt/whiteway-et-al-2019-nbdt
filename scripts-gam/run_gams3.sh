#!/bin/bash
# script to run fitting routines in multiple matlab instances
#
# a matlab startup script named 'startup.m' should be located on MATLAB's 
# default path, e.g. /home/user/Documents/MATLAB/
#
# to run from the command line, cd to the directory containing this script, 
# then run
# bash run_gams.sh
#
# screen command options
# -d -m start screen in detached mode
# -S specify session name
# NOTE: screen command automatically exits detached session once command if
# finished
# screen -S $screen_id -X quit

max_screens=5
sleep_time=5s

datasets1=`seq 1 1 4`
datasets2=`seq 100 10 120`

model_nums1=(1 2 3 4 5)
model_nums2=(11 12 13 14 15)
model_nums3=(21 22 23 24 31 32 33 34)

# fit gams
for dataset in $datasets1 $datasets2; do
    for model_num in ${model_nums1[@]}; do
        # get anything in screen list that is not a directory
        num_screens=$(ls /var/run/screen/S-mattw -1 | grep -v ^d | wc -l)
        # sleep while there are too many screens
        while (($num_screens >= $max_screens)); do
            sleep $sleep_time
            num_screens=$(ls /var/run/screen/S-mattw -1 | grep -v ^d | wc -l)
        done
        # execute next run
        screen_id="screen_"$dataset"-"$model_num
        screen -d -m -S $screen_id matlab -nojvm -r \
            "add_dir('gam'); scriptFitGams2($dataset,$model_num); exit"
    done
done

# fit decoders
for dataset in $datasets1 $datasets2; do
    for model_num in ${model_nums2[@]}; do
        # get anything in screen list that is not a directory
        num_screens=$(ls /var/run/screen/S-mattw -1 | grep -v ^d | wc -l)
        # sleep while there are too many screens
        while (($num_screens >= $max_screens)); do
            sleep $sleep_time
            num_screens=$(ls /var/run/screen/S-mattw -1 | grep -v ^d | wc -l)
        done
        # execute next run
        screen_id="screen_"$dataset"-"$model_num
        screen -d -m -S $screen_id matlab -nojvm -r \
            "add_dir('gam'); scriptFitGams2($dataset,$model_num); exit"
    done
done

# evaluate decoders on gams
for dataset in $datasets1 $datasets2; do
    for model_num in ${model_nums3[@]}; do
        # get anything in screen list that is not a directory
        num_screens=$(ls /var/run/screen/S-mattw -1 | grep -v ^d | wc -l)
        # sleep while there are too many screens
        while (($num_screens >= $max_screens)); do
            sleep $sleep_time
            num_screens=$(ls /var/run/screen/S-mattw -1 | grep -v ^d | wc -l)
        done
        # execute next run
        screen_id="screen_"$dataset"-"$model_num
        screen -d -m -S $screen_id matlab -nojvm -r \
            "add_dir('gam'); scriptFitGams2($dataset,$model_num); exit"
    done
done

# test
#for dataset in $datasets1 $datasets2; do
#    for model_num in ${model_nums1[@]}; do
#        echo $dataset-$model_num
#    done
#done

exit
