library(gt)
library(here)
library(tidyverse)
library(paletteer)
library(stringr)
make_table <- function(){
df <- read_tsv("/data/scratch/janani/molevolvr_out/Sr4eyi_full/cln_combined_by_domarch.tsv")
df <- df %>% subset( select = c(QueryName, Name,
																Species, Lineage,
																AccNum, PcPositive, PcIdentity,
																DomArch.Pfam))
df <- df[order(df$QueryName),]
df <- df %>% mutate(DomArch.Pfam = str_replace_all(DomArch.Pfam, "\\+", "\\+<br>"))
table <- df %>%
  gt() %>%
  fmt_markdown(columns = everything()) %>%
  cols_label(QueryName="Query", Name="Subject"
  					 AccNum = "Accession") %>%
  tab_options(
      # Headings; Titles
      heading.background.color="black",
      heading.border.bottom.color="#989898",
      heading.title.font.size="14px",
      heading.subtitle.font.size="13px",
      # Column labels
      column_labels.background.color="grey50", #B09C85FF
      column_labels.font.size="12px",
      # Stubs
      stub.background.color="#4DBBD5", #B09C85FF
      stub.border.style="dashed",
      stub.border.color="#989898",
      stub.border.width="1px",
      # Row groups
      row_group.background.color="#3C5488", #FFEFDB80
      row_group.border.top.color="#989898",
      row_group.border.bottom.style="none",
      row_group.font.size="12px",
      # Summary rows
      summary_row.border.color="#989898",
      # summary_row.background.color="#FFEBEE",
      # grand_summary_row.background.color="#FFFFFF",
      # Table
      table.font.color="#323232",
      table_body.hlines.color="#989898",
      table_body.border.top.color="#989898",
      table.font.size="10px",
      table.width="90%"
    )

gtsave(table, "table.pdf")
}

filterByGenome <- function(){
  df <- read_tsv("/data/scratch/janani/molevolvr_out/Sr4eyi_full/cln_combined_no_dupes.tsv")
  df <- df %>% add_column(Assembly = "")
  #df <- df %>% arrange(desc(PcPositive)) %>% add_column(Assembly = "") %>% group_by(Species) %>% slice(1)
  for (i in 1:nrow(df)){
    accession <- df[i,]$AccNum
    res <- system(paste("./find_genome.sh", accession), intern = TRUE)
    res <- str_split(res, "\t")
    tryCatch({
          assembly <- res[[1]][11]
      print(assembly)
      df[i,]$Assembly <- assembly
    },
    error = function(e){
      print("passed")
    }
    )
  }
  df_grouped <- df %>% arrange(desc(PcPositive)) %>% group_by(Species) %>% slice(1)
  df <- df %>% subset(Assembly %in% df_grouped$Assembly)
  write_tsv(df, "/data/scratch/janani/molevolvr_out/Sr4eyi_full/cln_combined_by_genome.tsv")
}

filterByDomains <- function(){
  df <- read_tsv("/data/scratch/janani/molevolvr_out/Sr4eyi_full/cln_combined_no_dupes.tsv")
  df <- df[order(desc(df$PcPositive)),]
  df <- df %>% group_by(Species) %>% distinct(DomArch.Pfam, .keep_all = TRUE) %>% ungroup()
  write_tsv(df, "/data/scratch/janani/molevolvr_out/Sr4eyi_full/cln_combined_by_domarch.tsv")
}

filterByGenome()
filterByDomains()
make_table()
