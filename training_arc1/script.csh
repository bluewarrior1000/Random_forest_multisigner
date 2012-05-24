# Run in current working directory and export all variables
#$ -wd /home/ufaserv1_i/scsjc/training/ -V -e /nobackup/scsjc/joboutput/ -o /nobackup/scsjc/joboutput/
# Set a 6 hour limit
#$ -l h_rt=7:00:00
# Setup the task array
#$ -t 1:20
# Stack setting?
#$ -l h_stack=10M
#$ -l h_vmem=3500M
unset DISPLAY
#export MCR_CACHE_ROOT=$TMPDIR
./deployment/mcc_wrapper ${SGE_TASK_ID}