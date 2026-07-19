# CFD-Project

# Right so I have changed to a versioned approach since I lost the progress twice when it crashed. So now the complete solver will save in checkpoint.mat every 2.5 simulated seconds
# If you want to run it again, running grenade06.m is enough
# If you want to run from the beginning again, you gotta delete the old checkpoint.mat
# If you want to keep the old results, you gotta make a new file and whatnot, which you do in the following way:
mkdir run_xKN065
movefile checkpoint.mat run_xKN065\   % or delete it
copyfile snapshots.mat run_xKN065\
copyfile grenade_history.txt run_xKN065\
# where run_xKN065 is the name of the run
