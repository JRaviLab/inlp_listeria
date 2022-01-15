library(tidyverse)
df <- read_tsv("/data/scratch/janani/molevolvr_out/Sr4eyi_full/cln_combined_only_listeria.tsv")
df <- distinct(df)
cp_df <- df
for (row in 1:nrow(df)){
    row <- df[row,]
    dups <- subset(df, df$AccNum == row$AccNum)
    if (nrow(dups) > 1){
        dups <- dups[order(dups$PcPositive, decreasing = TRUE),]
        keeper <- dups[1,]
        dups <- dups[2:nrow(dups),]$Query
        cp_df <- subset(cp_df, !(cp_df$AccNum == keeper$AccNum & cp_df$Query %in% dups))
        print("not passed")
    }
    else{
        print("passed")
    }
}

write_tsv(cp_df, "/data/scratch/janani/molevolvr_out/Sr4eyi_full/cln_combined_no_dupes.tsv")