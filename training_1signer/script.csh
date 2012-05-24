# Run in current working directory and export all variables
#$ -wd /home/ufaserv1_i/scsjc/training_1signer/ -V -e /nobackup/scsjc/joboutput/ -o /nobackup/scsjc/joboutput/
# Set a 6 hour limit
#$ -l h_rt=12:00:00
# Setup the task array
#$ -t 41:80
# Stack setting?
#$ -l h_stack=10M
#$ -l h_vmem=4000M
unset DISPLAY
#export MCR_CACHE_ROOT=$TMPDIR
./deployment/mcc_wrapper_tomas ${SGE_TASK_ID}