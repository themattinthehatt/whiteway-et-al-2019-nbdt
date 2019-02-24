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

max_screens=4
sleep_time=1s

#datasets1=`seq 25 1 34`
datasets2=`seq 402 1 402`

#model_nums1=(0)
#model_nums1=(1 2 3 4 5 11 12 13 14 15)
#model_nums2=(111 112 113 114 115 121 122 123 124 125 131 132 133 134 135)
#model_nums3=(141 142 143 144 145 151 152 153 154 155)

#model_nums1=(1)
#model_nums1=(1 2 3 11 12 13)
#model_nums2=(111 112 113 121 122 123 131 132 133)
#model_nums3=(141 142 143 151 152 153)

#model_nums1=(6 7 8 9 16 17 18 19)
model_nums2=(116 117 118 119 126 127 128 129 136 137 138 139 146 147 148 149 156 157 158 159 166 167 168 169 176 177 178 179 186 187 188 189 196 197 198 199)
#model_nums3=(161 162 163 164 165 171 172 173 174 175 181 182 183 184 185 191 192 193 194 195)

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
            "add_dir('gam'); scriptFitGams($dataset,$model_num); exit"
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
            "add_dir('gam'); scriptFitGams($dataset,$model_num); exit"
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
            "add_dir('gam'); scriptFitGams($dataset,$model_num); exit"
    done
done

# test
#for dataset in $datasets1 $datasets2; do
#    for model_num in ${model_nums1[@]}; do
#        echo $dataset-$model_num
#    done
#done

exit
