#!/bin/bash 

#SBATCH --account=bgmp                    #REQUIRED: which account to use
#SBATCH --partition=bgmp                  #REQUIRED: which partition to use
#SBATCH --cpus-per-task=4                 #optional: number of cpus, default is 1
#SBATCH --mem=16GB                        #optional: amount of memory, default is 4GB per cpu
#SBATCH --mail-user=tizzard@uoregon.edu     #optional: if you'd like email
#SBATCH --mail-type=ALL                   #optional: must set email first, what type of email you want
#SBATCH --job-name=velveth_k31            #optional: job name
#SBATCH --output=velveth_k31_%j.out       #optional: file to store stdout from job, %j adds the assigned jobID
#SBATCH --error=velveth_k31_%j.err        #optional: file to store stderr from job, %j adds the assigned jobID

set -e

conda activate bgmp-velvet

#set variables
cvg=auto
kmer_length=49
outdir=/projects/bgmp/tizzard/bioinfo/Bi621/PS/ps6-ettizzard/velvet_output_results_$kmer_length
mkdir -p $outdir

#velvet command
/usr/bin/time -v velveth $outdir $kmer_length -fastq -shortPaired -separate 800_3_PE5_interleaved.fq_1 800_3_PE5_interleaved.fq_2 -short 800_3_PE5_interleaved.fq.unmatched
"/projects/bgmp/tizzard/bioinfo/Bi621/PS/ps6-ettizzard/velvetscript.sh" [noeol] 24L, 1179C                                                                               
