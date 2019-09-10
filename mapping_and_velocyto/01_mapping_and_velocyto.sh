#!/bin/bash
##
## Baptiste Jaeger chez Jessberger stuff
##
## from unaligned bamfiles to velocyto looms
##
## 09 august 2019
##
## Izaskun Mallona

export TASK="02_velocyto_mapping"
export WD=/home/Shared_s3it/imallona/baptiste_jaeger/"$TASK"
# export WD="$HOME"/"$TASK"

export SOFT="$HOME"/soft
export VIRTENVS="$HOME"/virtenvs

export NTHREADS=32

## guess this one
export MM10=/home/Shared/data/annotation/Mouse/Ensembl_GRCm38.90/STARIndex/Ensembl_GRCm38.90.dna.primary_assembly_126/
export MM10_GTF=/home/Shared/data/annotation/Mouse/Ensembl_GRCm38.90/gtf/Mus_musculus.GRCm38.90.gtf

# export STAR=/usr/local/software/STAR-STAR_2.4.2a/STAR
export STAR=/home/imallona/soft/star/STAR-2.6.0c/source/STAR
export FASTQC=/usr/local/software/FastQC/fastqc
export SICKLE="$HOME"/soft/sickle/sickle-1.33/sickle
export CUTADAPT="$VIRTENVS"/cutadapt/bin/cutadapt
export QUALIMAP="$SOFT"/qualimap/qualimap_v2.2.1/qualimap
export FEATURECOUNTS="$SOFT"/subread/subread-1.6.2-source/bin/featureCounts

export NEXTERA=CTGTCTCTTATA

export BAMTOOLS="/usr/bin/bamtools"


mkdir -p $WD/unmapped_bam
cd $WD/unmapped_bam

cat > velocyto_urls.conf <<EOL
https://fgcz-gstore.uzh.ch/projects/p2488/HiSeq4000_20180607_RUN458_o4458/Gli1_20180503BJ_unmapped.bam
https://fgcz-gstore.uzh.ch/projects/p2488/HiSeq2500_20190308_RUN510_o5375/20190308.A-20190219_Gli1_5d_A01_unmapped.bam
https://fgcz-gstore.uzh.ch/projects/p2488/HiSeq2500_20181004_RUN491_rerun_o4766/20181004.A-Gli1_12wk_20180822BJ_A01_unmapped.bam
https://fgcz-gstore.uzh.ch/projects/p2488/HiSeq2500_20180813_RUN479_o4611/20180813.A-Ascl1_d4_plate1_A01_unmapped.bam
https://fgcz-gstore.uzh.ch/projects/p2488/HiSeq2500_20190524_RUN518_o5566/20190524.A-Ascl1_5d_II_20190403BJ_A01_unmapped.bam
https://fgcz-gstore.uzh.ch/projects/p2488/HiSeq2500_20181112_RUN494_o4944/20181112.A-Ascl1_12wk_A01_unmapped.bam
https://fgcz-gstore.uzh.ch/projects/p2488/HiSeq2500_20190708_RUN521_o5702/20190708.A-Ascl1_12wk_2_20190514BJ_A01_unmapped.bam
EOL

wget -i velocyto_urls.conf \
     --user imallona -e robots=off --ask-password \
     --reject='index.html*'

cd $WD/unmapped_bam

## Standardizing delivery names

ln -s Gli1_20180503BJ_unmapped.bam HiSeq4000_20180607_RUN458_o4458.bam
ln -s 20190308.A-20190219_Gli1_5d_A01_unmapped.bam HiSeq2500_20190308_RUN510_o5375.bam
ln -s 20181004.A-Gli1_12wk_20180822BJ_A01_unmapped.bam HiSeq2500_20181004_RUN491_rerun_o4766.bam
ln -s 20180813.A-Ascl1_d4_plate1_A01_unmapped.bam HiSeq2500_20180813_RUN479_o4611.bam
ln -s 20190524.A-Ascl1_5d_II_20190403BJ_A01_unmapped.bam HiSeq2500_20190524_RUN518_o5566.bam
ln -s 20181112.A-Ascl1_12wk_A01_unmapped.bam HiSeq2500_20181112_RUN494_o4944.bam
ln -s 20190708.A-Ascl1_12wk_2_20190514BJ_A01_unmapped.bam HiSeq2500_20190708_RUN521_o5702.bam

## cutadapt and sickle

mkdir -p $WD/trimming
cd $WD/trimming

for dataset in $(find $WD/unmapped_bam -name "HiSeq*bam")
do
    folder=$(basename $dataset .bam)
    mkdir -p $WD/trimming/$folder

    cd $WD/trimming
done


echo 'Get fasta'

cd $WD/trimming

for dataset in $(find $WD/unmapped_bam -name "HiSeq*bam" | sort)
do
    folder=$(basename $dataset .bam)
    
    cd $WD/trimming/$folder
    
    echo $dataset

    echo 'split'
    
    samtools split $dataset \
         --threads "$NTHREADS" \
         -f '%!.bam'

    for fn in $(find . -name "*bam")
    do
        
        bn=$(basename $fn .bam)
        "$BAMTOOLS" convert -in "$fn" \
                    -format fastq > "$bn".fastq
        gzip "$bn".fastq
        rm -f "$fn"
        # rename 's/_unmapped//g' "$bn".fq.gz
    done


    source $VIRTENVS/cutadapt/bin/activate

    for fn in $(find . -name "*fastq.gz")
    do
        echo $curr
        curr=$(basename "$fn" .fastq.gz)
        cutadapt \
            -j $NTHREADS \
            -a $NEXTERA \
            -o "$curr"_cutadapt.fastq.gz \
            "$fn" &> "$curr"_cutadapt.log
    done
    
    deactivate
    
    N=$NTHREADS
    (
        for fn in $(find . -name "*_cutadapt.fastq.gz"| xargs -n$NTHREADS)
        do 
            ((i=i%N)); ((i++==0)) && wait
            curr=$(basename "$fn" _cutadapt.fastq.gz)
            echo $curr $i
            
            "$SICKLE" se \
                      -f "$fn" \
                      -o "$curr"_cutadapt_sickle.fastq.gz \
                      -t sanger \
                      -g &> "$curr"_cutadapt_sickle.log &

        done
    )
done

cd $WD
mkdir -p $WD/star

for dataset in $(find $WD/unmapped_bam -name "HiSeq*bam" | sort)
do
    folder=$(basename $dataset .bam)

    mkdir -p $WD/star/$folder
    
    cd $WD/star/$folder

    
    for fn in $(find . -name "*_cutadapt_sickle.fastq.gz")
    do
        curr=$(basename "$fn" _cutadapt_sickle.fastq.gz)
        echo $curr
        mkdir -p "$curr"_star
        
        "$STAR" --runMode alignReads \
                --runThreadN $NTHREADS \
                --outSAMtype BAM SortedByCoordinate \
                --readFilesCommand zcat \
                --genomeDir "$MM10" \
                --outFileNamePrefix "$curr"_star/"$curr" \
                --readFilesIn  $fn

        # duplicates are not ignored but multimappers are (and star reports plenty of them)

        $FEATURECOUNTS \
            -T "$NTHREADS" \
            -t exon \
            -g gene_id \
            -a "$MM10_GTF" \
            -o "$curr"_star/"$curr"_counts.txt \
            "$curr"_star/"$curr"Aligned.sortedByCoord.out.bam

    done

    cd $WD
done



echo 'velocyto processing'
# done at neutral due to file sizing


source ~/virtenvs/velocyto/bin/activate

export TASK="02_velocyto_mapping"
export WD=/home/Shared_s3it/imallona/baptiste_jaeger/"$TASK"

for folder in $(find "$WD"/star -maxdepth 1 -type d -not -path "$WD"/star )
do
    echo "$folder"

    cd "$folder"
    # velocyto run-smartseq2 \
    #          -c  \
    #          --samtools-threads $NTHREADS \
             # -d 1 $(find "$folder" -name "*.bam" -print) "$MM10_GTF"

    velocyto run-smartseq2 \
             -d 1 $(find "$folder" -name "*.bam" -print) "$MM10_GTF" &
    
    cd "$WD"
      
done 

deactivate


# HiSeq2500_20190524_RUN518_o5566 was not run for some reason

for folder in /home/Shared_s3it/imallona/baptiste_jaeger/02_velocyto_mapping/star/HiSeq2500_20190524_RUN518_o5566
do
    echo "$folder"

    cd "$folder"
    # velocyto run-smartseq2 \
    #          -c  \
    #          --samtools-threads $NTHREADS \
             # -d 1 $(find "$folder" -name "*.bam" -print) "$MM10_GTF"

    velocyto run-smartseq2 \
             -d 1 $(find "$folder" -name "*.bam" -print) "$MM10_GTF"
    
    cd "$WD"
      
done 

# crashes again... let's check why

find /home/Shared_s3it/imallona/baptiste_jaeger/02_velocyto_mapping/star/HiSeq2500_20190524_RUN518_o5566 -name "*bam" -exec ls -lh {} \; > /tmp/sizes.log

fgrep -w 28 /tmp/sizes.log

samtools view -H /home/Shared_s3it/imallona/baptiste_jaeger/02_velocyto_mapping/star/HiSeq2500_20190524_RUN518_o5566/Ascl1_5d_II_20190403BJ_D21_star/Ascl1_5d_II_20190403BJ_P02Aligned.sortedByCoord.out.bam


ll -h /home/Shared_s3it/imallona/baptiste_jaeger/02_velocyto_mapping/trimming/HiSeq2500_20190524_RUN518_o5566/Ascl1_5d_II_20190403BJ_P02*

# ok, is empty let's avoid empty bamfiles

for folder in /home/Shared_s3it/imallona/baptiste_jaeger/02_velocyto_mapping/star/HiSeq2500_20190524_RUN518_o5566
do
    echo "$folder"

    cd "$folder"
    # velocyto run-smartseq2 \
    #          -c  \
    #          --samtools-threads $NTHREADS \
             # -d 1 $(find "$folder" -name "*.bam" -print) "$MM10_GTF"

    velocyto run-smartseq2 \
             -d 1 $(find "$folder" -name "*.bam" -size +1k -print) "$MM10_GTF"
    
    cd "$WD"
      
done 



cd /home/Shared_s3it/imallona/baptiste_jaeger/02_velocyto_mapping
mkdir loom_delivery
cd $_


for folder in $(find "$WD"/star -maxdepth 1 -type d -not -path "$WD"/star )
do
    echo $(basename $folder)

    folder=$(basename $folder)
    # mkdir -p $(basename $folder)
    ls -l /home/Shared_s3it/imallona/baptiste_jaeger/02_velocyto_mapping/star/"$folder"/*/velocyto/*loom
    rsync -avt /home/Shared_s3it/imallona/baptiste_jaeger/02_velocyto_mapping/star/"$folder"/*/velocyto/*loom "$folder"/
done 
