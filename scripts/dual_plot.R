library(tidyverse)
library(aplot)
source("/data/research/jravilab/molevol_scripts/R/cleanup.R")
source("/data/research/jravilab/molevol_scripts/R/summarize.R")
source("/data/research/jravilab/molevol_scripts/R/plotting.R")
source("/data/research/jravilab/molevol_scripts/R/networks_domarch.R")
source("/data/research/jravilab/molevol_scripts/R/networks_gencontext.R")
source("/data/research/jravilab/molevol_scripts/R/pre-msa-tree.R")
source("/data/research/jravilab/molevol_scripts/R/ipr2viz.R")
source("/data/research/jravilab/molevol_scripts/R/lineage.R")
source("/data/research/jravilab/molevol_scripts/R/msa.R")
source("/data/research/jravilab/molevol_scripts/scripts/tree.R")
source("/data/research/jravilab/molevol_scripts/R/colnames_molevol.R")
source("/data/research/jravilab/molevolvr_app/pins/PinGeneration.R")
source("/data/research/jravilab/molevolvr_app/scripts/ui/components.R")
source("/data/research/jravilab/molevolvr_app/scripts/ui/UIOutputComponents.R")
source("/data/research/jravilab/molevolvr_app/scripts/ui/splashPageComponent.R")
source("/data/research/jravilab/molevolvr_app/scripts/MolEvolData_class.R")
source("/data/research/jravilab/molevolvr_app/scripts/ui/tabText.R")
source("/data/research/jravilab/molevolvr_app/scripts/utility.R")

df <- read_tsv("/data/scratch/janani/molevolvr_out/Sr4eyi_full/cln_combined_by_domarch.tsv")
in_ipr <- read_tsv("/data/scratch/janani/molevolvr_out/Sr4eyi_full/ipr_combined.tsv")

rep_fasta_path = tempfile()
#top_acc <- find_top_acc(infile_full="/data/scratch/janani/molevolvr_out/GZKL61_full/cln_combined.tsv",
#                         DA_col = "DomArch.Pfam",
#                        ## @SAM, you could pick by the Analysis w/ max rows!
#                         lin_col = "Lineage",
#                         n = 22)  
top_acc <- df$AccNum
acc2fa(top_acc, outpath = rep_fasta_path, "sequential")
rename_fasta(rep_fasta_path, rep_fasta_path, replacement_function=map_acc2name,
                 acc2name = select(df,"AccNum","Name"))
rep_msa_path = tempfile()
alignFasta(rep_fasta_path, "ClustalO", rep_msa_path)

tree <- seq_tree(rep_msa_path)
# insert this code into ipr2viz_web to make labels compatible
#ipr_out_sub <- ipr_out_sub %>% distinct(Name, .keep_all = TRUE)
#  ipr_out_sub <- subset(ipr_out_sub, select = -c(Label))
#ipr_out_sub$label <- paste0(" ", ipr_out_sub$Name)
ipr_plot <- ipr2viz_web("/data/scratch/janani/molevolvr_out/Sr4eyi_full/ipr_combined.tsv","/data/scratch/janani/molevolvr_out/Sr4eyi_full/cln_combined_by_domarch.tsv",
analysis = c("Pfam"), text_size = 12)

last_plot <- ipr_plot %>% insert_right(tree)

ggsave("plot.png", last_plot, dpi = 400, device = "png", height = 11, width = 14)