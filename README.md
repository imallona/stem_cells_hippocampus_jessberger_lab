Note: 
This github repository contains the main parts of the analysis described below. Nevertheless, as this was a collaborative effort, additional methods or steps that could be potentially missing here, can be viewed at https://github.com/vkorobeynyk/scRNA-seq_analysis_jessberger_lab 

## Aim

Transcriptional comparison between Gli1- and Ascl1- targeted neuronal stem cells (NSCs) isolated from the adult mouse hippocampus.

## Repository structure

Tasks (`01`, `02`, etc) subfolders contain both source code in R (`Rmd` files) and the rendered HTML reports.

- `data`, processed data / annotations.
- `01_jaeger_descriptive`, scater's QC; Seurat's integration, dimensionality reduction and clustering.
- `02_mapping`, STAR + featurecounts + velocyto workflow to retrieve count matrices and velocyto's loom files.
- `03_diff_expression`, differential expression analysis (Seurat-based).
- `04_velocyto`, `velocyto.R`-based run.
- `05_prediction`, Machine Learning approach to predict Gli vs Ascl cells 

## Requirements

Mapping and other computer intensive tasks were run on a multicore 64-bits linux machine. Data analysis was carried out in R v3.6.1. A shortlist of the package versions include:

```
cutadapt v1.16
sickle v1.33
STAR v2.6.0c
subread v1.6.2 (featurecounts)
velocyto.py v0.17.17
caret v6.0.84
```

R packages

```
 package              * version   date       lib source        
 biomaRt              * 2.40.0    2019-05-02 [1] Bioconductor  
 edgeR                  3.26.5    2019-06-21 [1] Bioconductor  
 ggplot2              * 3.2.0     2019-06-16 [1] CRAN (R 3.6.0)
 igraph                 1.2.4.1   2019-04-22 [1] CRAN (R 3.6.0)
 irlba                  2.3.3     2019-02-05 [1] CRAN (R 3.6.0)
 limma                  3.40.2    2019-05-17 [1] Bioconductor  
 Rtsne                  0.15      2018-11-10 [1] CRAN (R 3.6.0)
 scater               * 1.12.2    2019-05-24 [1] Bioconductor  
 scran                * 1.12.1    2019-05-27 [1] Bioconductor  
 sctransform            0.2.0     2019-04-12 [1] CRAN (R 3.6.0)
 Seurat               * 3.0.0     2019-04-15 [1] CRAN (R 3.6.0)
 SingleCellExperiment * 1.6.0     2019-05-02 [1] Bioconductor  
 tsne                   0.1-3     2016-07-15 [1] CRAN (R 3.6.0)
 purrr                  0.3.2	  2019-03-15 [1] CRAN (R 3.6.1)
 dplyr			0.8.3	  2019-07-04 [1] cran (R 3.6.1)
```

# Data availability

- [GSE138941](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE138941) includes raw data and count tables.

# Publication link

- [Bottes, S., Jaeger, B.N., Pilz, GA. et al. Long-term self-renewing stem cells in the adult mouse hippocampus identified by intravital imaging. Nat Neurosci 24, 225–233 (2021). https://doi.org/10.1038/s41593-020-00759-4](https://www.nature.com/articles/s41593-020-00759-4)
  
## To do list

- document
