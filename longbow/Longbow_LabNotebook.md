Tuesday, October 8th, 2024, 11:00 PM
1) Checked Longbow github. https://github.com/broadinstitute/longbow/

2) Got too excited and tried installing via pip, to no avail b/c of Python version compatibility issues, it seems.

3) Continued with original plan of installing via Docker image.

4) Went to docker site to view MacOS installation instructions. I opted to install via CLI.
https://docs.docker.com/desktop/install/mac-install/

5) Looking at Apple Silicon installation instructions, it is recommended that I first install Rosetta 2.
$ softwareupdate --install-rosetta

6) After successfully installing Rosetta2, I scrolled down to command line installation instructions. Downloaded the Apple Silicon Docker.dmg file to my Desktop.

7) Installed Docker from downloaded image on Desktop with appropriate flags included for install command
$ sudo hdiutil attach /Users/evan/Desktop/Docker.dmg
$ sudo /Volumes/Docker/Docker.app/Contents/MacOS/install --accept-license --user=evan
$ sudo hdiutil detach /Volumes/Docker

8) Launched Docker Desktop app. Skipped account login and surveys. Immediately hit with a file integrity issue. Chose to repair. All is well.

9) Returned to commandline and Longbow github to install Longbow Docker image
$ docker pull us.gcr.io/broad-dsp-lrma/lr-longbow:0.6.14

10) Getting started with Longbow:
#Downloaded small test dataset
$ cd /Users/evan/bioinfo/Hacking_MAS_Seq/testdata
$ curl https://github.com/broadinstitute/longbow/raw/main/tests/test_data/mas15_test_input.bam -L -o mas15_test_input.bam
$ curl https://github.com/broadinstitute/longbow/raw/main/tests/test_data/mas15_test_input.bam.pbi -L -o mas15_test_input.bam.pbi
$ curl https://github.com/broadinstitute/longbow/raw/main/tests/test_data/resources/SIRV_Library.fasta -L -o SIRV_Library.fasta

11) Followed Docker instructions on how to run a container.
# Cloned welcome repo
$ cd /Users/evan/bioinfo/Hacking_MAS_Seq/
$ mkdir Docker
$ cd Docker
$ git clone https://github.com/docker/welcome-to-docker
$ cd welcome-to-docker

# Checked Dockerfile
# Built first image
$ docker build -t welcome-to-docker .

# Welcome image appeared in Docker Desktop app. Ran it in a container named "welcomedocker" with the port assignment 8089.
# Viewed frontend. Woooooo!
# Stopped container.

12) Tried running Longbow v0.6.14 from Docker Desktop - to no avail. Checked Longbow documentation page for alternative.
#Found code to install and run a Docker image of Longbow v0.3.0
$ docker run -v $PWD:/data -it "us.gcr.io/broad-dsp-lrma/lr-longbow:0.3.0"

#This worked! The image and container are present in Docker Desktop and the container is running. Docker is not happy that I'm running this on an Apple Silicon machine, though. It was written for Linux/Intel.
WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested

#New command prompt to signal docker image:
(venv) root@3d3b800e48ca:/#

#Verified version
(venv) root@3d3b800e48ca:/# longbow version
    0.3.0

#Exited to attempt new version run with this method
(venv) root@d82f20093f05:/# exit
exit

#Trying to run Longbow version 0.6.14
$ docker run -v $PWD:/data -it "us.gcr.io/broad-dsp-lrma/lr-longbow:0.6.14"
    WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested
(venv) root@46facdab54a7:/#

#Success!! Finally can run test data

#Set up our container and ensured it worked properly
$ docker run --name longbow -v /Users/evan/bioinfo/Hacking_MAS_Seq/Docker/longbowdata:/longbowdata -it us.gcr.io/broad-dsp-lrma/lr-longbow:0.6.14
$ exit
$ docker start longbow -i

13) Ran test data 
# Basic processing workflow
  longbow annotate -m mas_15+sc_10x5p mas15_test_input.bam | \  # Annotate reads according to the mas_15+sc_10x5p model
  tee ann.bam | \                                             # Save annotated BAM for later
  longbow filter | \                                          # Filter out improperly-constructed arrays
  longbow segment | \                                         # Segment reads according to the model
  longbow extract -o filter_passed.bam                        # Extract adapter-free cDNA sequences


(venv) root@7b713325e5ed:/# cd longbowdata/testdata/

(venv) root@7b713325e5ed:/longbowdata/testdata# ls
    SIRV_Library.fasta  mas15_test_input.bam  mas15_test_input.bam.pbi

(venv) root@7b713325e5ed:/longbowdata/testdata# longbow annotate -m mas_15+sc_10x5p mas15_test_input.bam | tee ann.bam | longbow filter | longbow segment | longbow extract -o filter_passed.bam

#Tail of output:
Progress:  75%|███████████████████████████████████████████████████████████████████████████████████████████████████████████████                                     | 6/8 [00:01<00:00,  4.50 read/s]
Process Process-13:
Traceback (most recent call last):
  File "/usr/local/lib/python3.7/multiprocessing/process.py", line 297, in _bootstrap
    self.run()
  File "/usr/local/lib/python3.7/multiprocessing/process.py", line 99, in run
    self._target(*self._args, **self._kwargs)
  File "/longbow/src/longbow/commands/annotate.py", line 271, in _write_thread_fn
    bam_utils.write_annotated_read(read, ppath, is_rc, logp, lb_model, out_bam_file)
  File "/longbow/src/longbow/utils/bam_utils.py", line 376, in write_annotated_read
    out_bam_file.write(read)
  File "pysam/libcalignmentfile.pyx", line 1709, in pysam.libcalignmentfile.AlignmentFile.write
  File "pysam/libcalignmentfile.pyx", line 1741, in pysam.libcalignmentfile.AlignmentFile.write
OSError: sam_write1 failed with error code -1
[INFO 2024-10-09 08:41:25 annotate] Annotated 6 reads with 657 total sections.
[INFO 2024-10-09 08:41:25 annotate] Done. Elapsed time: 1.76s. Overall processing rate: 3.41 reads/s.

# I don't know what exactly went wrong early, but the functionality seems to be there?
# Looked at github page for getting started tips (github seems to be more updated than standalone documentation page)

(venv) root@7b713325e5ed:/longbowdata/testdata# longbow annotate mas15_test_input.bam | longbow segment | longbow extract -o extracted.bam
#Didn't work.

# Current time is Wednesday, October 9th, 2024 1:52 AM. Goodnight moon.

Sunday, October 13th, 3:52PM
14) Trying longbow again with Varsheni's suggested code. Hopefully this results in all reads being processed, not just 75%.
#Due to Docker being weird, I now have to start Docker Desktop and wait for it to notify of files being changed, then repair those files to allow for commandline use of the docker commands. Very annoying,
and seems to be an ongoing issue on Docker for Mac: 
https://github.com/docker/for-mac/issues/6898
https://github.com/docker/for-mac/issues/7109

#Still workable, just annoying.

15) Back to commandline.
$ docker start longbow -i
# cd longbowdata/testdata/
# longbow annotate -m mas_15+sc_10x5p mas15_test_input.bam | longbow filter -m mas_15+sc_10x5p | longbow segment -m mas_15+sc_10x5p | longbow extract -m mas_15+sc_10x5p -o filter_passed.bam

#WORKED!!! THANK YOU VARHSENI <3

16) Ok. Now that we confirmed working condition of longbow image and commands, we need to port all of this to talapas. First things first: getting the docker image to singularity foe HPC purposes.
# VPN'd into talapas. Started an interactive session.
$ srun -A bgmp -p bgmp -c4 --mem=16G --pty bash
$ cd /projects/bgmp/shared/groups/2024/mas-hack/shared/
$ mkdir longbow
$ cd longbow
$ singularity pull docker://us.gcr.io/broad-dsp-lrma/lr-longbow:0.6.14
$ module load singularity
$ singularity version
3.7.2

#Documentation for this version of singularity: https://apptainer.org/user-docs/3.7/
#According to documentation, it's probably a better idea to build the image rather than pull (to promote reproducibility).
#Moved pulled image to "pull_image_old" folder.
$ singularity build longbow_0.6.14.sif docker://us.gcr.io/broad-dsp-lrma/lr-longbow:0.6.14
$ singularity shell longbow_0.6.14.sif

#Downloaded test data to longbow singularity image on talapas
$ wget https://github.com/broadinstitute/longbow/raw/main/tests/test_data/mas15_test_input.bam
$ wget https://github.com/broadinstitute/longbow/raw/main/tests/test_data/mas15_test_input.bam.pbi
$ wget https://github.com/broadinstitute/longbow/raw/main/tests/test_data/resources/SIRV_Library.fasta

$ Tested longbow on data again
> longbow annotate -m mas_15+sc_10x5p mas15_test_input.bam | longbow filter -m mas_15+sc_10x5p | longbow segment -m mas_15+sc_10x5p | longbow extract -m mas_15+sc_10x5p -o filter_passed.bam

#All reads successfully filtered, but the speed is really slow at 1.81 reads/s. :(
#Hopefully using a different node will be better.

#Trying an interactive GPU session
$ srun -A bgmp -p interactivegpu -c4 --mem=16G --pty bash
# 1.78 reads/s ....

#Trying with more resources...
$ srun -A bgmp -p interactivegpu -c16 --mem=64G --pty bash
# 4.81 reads/s!! Progress!

#Maxing resources here
$ srun -A bgmp -p interactivegpu -c24 --mem=256G --pty bash
# 5.90 reads/s. I have a hunch that the memory is the limiting factor here. No clue if that's accurate though.

$ srun -A bgmp -p interactivegpu -c24 --mem=400G --pty bash
# 6.06 reads/s. Cores definiely matter to a significant degree.

$ srun -A bgmp -p interactivegpu -c28 --mem=400G --pty bash
# 5.48 reads/s. Weird.....

#Trying GPU long partition
$ srun -A bgmp -p gpulong -c32 --mem=400G --pty bash
# 5.91 reads/s. At this point, we might just be hitting a wall due to the small size of the dataset. We should probably try testing with larger data to better gauge performance of various nodes.
