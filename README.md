**# Soil-Metagenome-reanalysis**

# Overview

We gathered pre-existed 16S paddy soil metagenome amplicon sequences and 16S rice metagenome amplicon sequences. Our purpose for the reanalysis is to find out a new trend between soil metagenome conducted in the different location, ampling conditions, and the analysis protocol. Our result suggests a new viewpoint to avoid ambiguity which serves as a bottle neck for agricultural microbiome research.



# Technical Overview

We carried out the metagenome analysis using QIIME2 (v. 2018.06) on Ubuntu 16.04 LTS. Our pipe are written by QIIME2 2018.06 version so it could make an error if you use another version of QIIME2. 


# Before running the pipe

Assume you want to follow or refer our pipe. Please be aware of the instructions below to flow your work smoothly.


1. Chekc the version of QIIME2; Most of the command remain unchanged after periodic version update but some are changed. To use our pipe perfectly, please change the command following the new command. 
2. Some pathes on the pipe are not standardized, but specific since this is the pipe we used in our work. So please double check the absolute path to avoid overwritting your analysis result; We commented in the pipe file which path must be written.
3. Be aware of cores used for each process. We used 25 cores for each process and it is still written in the pipe. Please change it depending on your computer.
4. The pipe uses pretrained classifier offered by SILVA database (our reference for metagenome is SILVA v.132). We uploaded "train.sh"file for training your own classifier. The primer sequences written in the file are 515F, 806F primer sequence so please edit it if your primer sequence is different.
    4-1. If you train your own classifier and plan to use it, please edit the classifier name and path in the pipe command file.


# Directory structure

The OTU files are made from analysis from Kingdom level to Species level (Level 1 ~ Level 7). All OTU data from one project are gathered in the directory named after its project name. Below are the project list we used for our reanlaysis and having the OTU files. Description for each project are presented on Table S12.

- PRJNA255789
- PRJNA386367
- PRJNA362531
- PRJNA362529
- PRJNA260992
- PRJNA259434
- PRJNA248059
- PRJNA435634
- PRJNA169177
- PRJNA360379
- PRJDA61421
- PRJEB27398

# Copyright & License


Refer to the LICENSE and authors

# Authors
Myeonghyun Yoou (pple2202@gmail.com)
