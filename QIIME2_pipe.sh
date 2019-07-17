# Quality trimming using CUTADAPT
# DIRECTORYNAME = absolute path of your raw sequences
# RESULTDIR = absolute path for the result files

# CAUTION #
# Before running the pipe, a manifest file and metadata file must be prepared in the RESULTDIR!!!


DIRECTORYNAME="/home/seokwon/test_amplicon/rawdata_furtherstudy/susu2"
RESULTDIR="/home/seokwon/test_amplicon/susu2"


#Import sequences to demux file
qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path $RESULTDIR/*manifest* --output-path $RESULTDIR/paired-end-demux.qza --source-format PairedEndFastqManifestPhred33
qiime demux summarize --i-data $RESULTDIR/*.qza --o-visualization $RESULTDIR/demux.qzv


echo -n "Which tool would you use for denoise? [dada2(a)/deblur(b)]"
read answer
while :
do
if [ $answer = "a" ]
then
        tool_denoise=1
	break
elif [ $answer = "b" ]
then
        tool_denoise=2
	break
else
        echo "answer again! dada2(a)? or deblur(b)?"
        continue
fi


done


#-----------------------------------------------------------------------------------------using dada2-----------------------------------------------------------------------------------------------------------------------

#Check the quality and input length for trunc if you decide to use dada2 for denoise
if [ $tool_denoise = 1 ]
then
        while :
        do

                echo -n Input length for truncate forward sequence:
                read input
                if [ ${input} -lt 50 -o ${input} -gt 999 ]
                then
                        continue
                fi
                echo -n Input length for truncate reverse sequence:
                read input2
                if [ ${input2} -lt 50 -o ${input2} -gt 999 ]
                then
                        continue
                fi

                echo -n "Are you sure?[y/n]"
                read input3
                if [ $input3 = "y" ] || [ $input3 = "Y" ]
                then
                        break
                else
                        continue
                fi
        done


#Denoise using dada2-paired
mkdir $RESULTDIR/denoise
qiime dada2 denoise-paired --i-demultiplexed-seqs `find /home/seokwon/test_amplicon/ -name "*demux.qza" -mmin -60` --p-trunc-len-f $input --p-trunc-len-r $input2 --o-table $RESULTDIR/denoise/table-dada2.qza --o-representative-sequences $RESULTDIR/denoise/rep-seqs-dada2.qza --o-denoising-stats $RESULTDIR/denoise/stats-dada2.qza --verbose --p-n-threads 25

#Denoised table visualization
qiime feature-table summarize --i-table `find $RESULTDIR/denoise -name "*table*" | grep .qza` --o-visualization $RESULTDIR/denoise/table.qzv

#Unzip denoised table ONLY WHEN YOU USE DADA2
unzip -d $RESULTDIR/denoise/unzipped_table $RESULTDIR/denoise/table.qzv
#Extract sample read frequency
MinRead_Freq=cut -f 2 -d ',' `find $RESULTDIR/ -name "sample-frequency-detail.csv"` | tail -1 | cut -f 1 -d '.'

fi

#---------------------------------------------------------------------------------------------using deblur--------------------------------------------------------------------------------------------------------

#Denoise using deblur
if [ $tool_denoise = 2 ]
then
mkdir $RESULTDIR/denoise
qiime quality-filter q-score --i-demux `find /home/seokwon/test_amplicon/ -name "*demux.qza" -mmin -60` --p-min-quality 30 --o-filtered-sequences $RESULTDIR/denoise/filtered-demux.qza --o-filter-stats $RESULTDIR/denoise/filter_stats.qza --verbose
qiime demux summarize --i-data $RESULTDIR/denoise/filtered-demux.qza --o-visualization $RESULTDIR/denoise/filtered-demux.qzv

 while :
        do
                echo -n Input length to trim before deblur:
                read input4
                if [ ${input4} -lt 50 -o ${input4} -gt 999 ]
                then
                        continue
                else
                        echo -n "Are you sure?[y/n]"
                        read input5
                        if [ $input5 = "y" ] || [ $input5 = "Y" ]
                        then
                                break
                        else
                                continue
                        fi
                fi
        done


qiime deblur denoise-16S --i-demultiplexed-seqs $RESULTDIR/denoise/filtered-demux.qza --p-trim-length $input4 --o-representative-sequences $RESULTDIR/denoise/rep-seqs-deblur.qza --o-table $RESULTDIR/denoise/table-deblur.qza --p-sample-stats --o-stats $RESULTDIR/denoise/stats-deblur.qza --verbose --p-jobs-to-start 25



fi
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


#OTU closed-reference clustering
mkdir $RESULTDIR/clustering
qiime vsearch cluster-features-closed-reference --i-table $RESULTDIR/denoise/table*.qza --i-sequences $RESULTDIR/denoise/rep-*.qza --i-reference-sequences `find /home/seokwon/test_amplicon/ -name "silva*" | grep 97_16S.qza` --p-perc-identity 0.97 --o-clustered-table $RESULTDIR/clustering/table-cr-97.qza --o-clustered-sequences $RESULTDIR/clustering/rep-seqs-cr-97.qza --o-unmatched-sequences $RESULTDIR/clustering/unmatched-cr-97.qza --verbose --p-threads 25 


#Making Tree
mkdir $RESULTDIR/phylogeny
qiime alignment mafft --i-sequences $RESULTDIR/denoise/rep-*.qza --o-alignment $RESULTDIR/phylogeny/aligned-rep-seqs.qza
qiime alignment mask --i-alignment $RESULTDIR/phylogeny/aligned-rep-seqs.qza --o-masked-alignment $RESULTDIR/phylogeny/masked-aligned-rep-seqs.qza
qiime phylogeny fasttree --i-alignment $RESULTDIR/phylogeny/masked-aligned-rep-seqs.qza --o-tree $RESULTDIR/phylogeny/unrooted-tree.qza
qiime phylogeny midpoint-root --i-tree $RESULTDIR/phylogeny/unrooted-tree.qza --o-rooted-tree $RESULTDIR/phylogeny/rooted-tree.qza

#Taxonomy analysis using pre-trained silva classifier
mkdir $RESULTDIR/taxonomy
qiime feature-classifier classify-sklearn --i-classifier `find /home/seokwon/test_amplicon/ -name "silva-132*classifier.qza"` --i-reads $RESULTDIR/clustering/rep-*.qza --o-classification $RESULTDIR/taxonomy/taxonomy.qza --verbose --p-n-jobs -3

#Make barplot using taxonomy and metadata
#qiime taxa barplot --i-table $RESULTDIR/clustering/table*.qza --i-taxonomy $RESULTDIR/taxonomy/taxonomy.qza --m-metadata-file $RESULTDIR/*metadata* --o-visualization $RESULTDIR/taxonomy/taxa-barplot.qzv



:<<END
#Diversity and PCoA analysis
if [ $tool_denoise = 1 ]
then
qiime diversity core-metrics-phylogenetic --i-phylogeny $RESULTDIR/phylogeny/rooted-tree.qza --i-table $RESULTDIR/denoise/table-dada2.qza --p-sampling-depth $MinRead_Freq --m-metadata-file $RESULTDIR/*metadata* --output-dir $RESULTDIR/PCoA --p-n-jobs -1 --verbose
fi
 END
