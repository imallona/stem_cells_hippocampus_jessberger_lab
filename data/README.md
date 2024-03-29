## File naming

Data delivieries follow FGCZ naming:

- Gli1_20180503BJ : HiSeq4000_20180607_RUN458_o4458
- 20190308.A-20190219_Gli1_5d_A01 : HiSeq2500_20190308_RUN510_o5375
- 20181004.A-Gli1_12wk_20180822BJ_A01 : HiSeq2500_20181004_RUN491_rerun_o4766
- 20180813.A-Ascl1_d4_plate1_A01 : HiSeq2500_20180813_RUN479_o4611
- 20190524.A-Ascl1_5d_II_20190403BJ_A01 : HiSeq2500_20190524_RUN518_o5566
- 20181112.A-Ascl1_12wk_A01 : HiSeq2500_20181112_RUN494_o4944
- 20190708.A-Ascl1_12wk_2_20190514BJ_A01 : HiSeq2500_20190708_RUN521_o5702

Prediction :

- batch_genes.xlsx : batch affected genes between Gli and Ascl
- diff_expression_dNSC.rds : DEG Gli vs Ascl in dNSC cluster
- diff_expression_ndNSC.rds : DEG Gli vs Ascl in ndNSC cluster
- matrix_allcells_allgenes.rds : count matrix with genes as rows and cells as columns (from Seurat object)
