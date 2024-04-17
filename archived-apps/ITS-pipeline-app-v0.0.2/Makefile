BINDS = /bin/srun,/bin/sinfo,/bin/squeue,/bin/sbatch,/etc/slurm,/etc/slurm/plugins,/mnt/config/etc/slurm/plugins/,/usr/lib64/slurm/,/usr/lib64/libmunge.so.2,/var/run/munge

all:
	singularity -d run --writable --userns --pwd /envworkspace --bind $(shell pwd)/container:/envworkspace,/vol_b/wongy/tmp:/tmp,/vol_b/wongy/cache:.singularity/cache --env-file envfile docker://jeffycwong/cmaiki-image:latest /bin/bash


test:
	singularity run --writable --bind $(shell pwd)/container:/envworkspace,/vol_b/wongy/tmp:/tmp,/vol_b/wongy/cache:.singularity/cache --env clustering_threshold='100\\,97' docker://jeffycwong/cmaiki-image:latest /bin/bash 

local:
	singularity run --writable --userns --bind output:/output --env-file envfile docker://jeffycwong/cmaiki-image:local /bin/bash
