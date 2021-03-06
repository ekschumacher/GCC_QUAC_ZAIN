##Here we calculate summary statistics 
#First, we tested linkage disequilibrium, null alleles, and Hardy Weinberg 
#equilibrium. Next, a data frame including expected heterozygosity, 
#allelic richness, number of alleles, mean longtitude and latitude 
#for wild populations, and individual numbers. 
#This table is included in full in the supplemental text of this manuscript.
#When files are referred to as "clean" that means individuals 
#that are clones and indviduals with too much missing data have been removed. 
#When files and objects are titled "red" that means they have been reduced
#for relatedness (25% or more related individuals are reduced to one individual
#per phenotype)

#########################
#        Libraries      #
#########################

library(adegenet)
library(poppr)
library(hierfstat)
library(PopGenReport)
library(pegas)
library(diveRsity)

#########################
#   Load Data Files     #
#########################
##set working directory to load in data files
setwd("../../Data_Files")

##comment in if files need to be converted 
#sp_arp_list <- list.files(path = "Adegenet_Files", pattern = "_allpop.arp$")

#for(sp in 1:length(sp_arp_list)){

# arp2gen(paste0("Adegenet_Files/", sp_arp_list[[sp]]))

#}

#list data files 
#genind objects 
sp_genind_list <- list.files(path = "Adegenet_Files/", pattern = "_clean.gen")

#df files 
sp_df_list <- list.files(path = "Data_Frames/", pattern = "_clean_df.csv")

#create scenario list 
scenario_list <- c("QUAC_wK", "QUAC_woK", "ZAIN_og", "ZAIN_rebinned")

############################################################
#  Null Alleles, HWE Deviation, Linkage Disequilibrium     #
############################################################

#loop to assess scores for null alleles, HWE deviations, and linkage disequilibrium
for(sp in 1:length(sp_genind_list)){
  
  #load genepop files as genind objects 
  sp_genind_temp <- read.genepop(paste0("Adegenet_Files/", sp_genind_list[[sp]]), ncode = 3)
  
  #load data frames 
  sp_df_temp <- read.csv(paste0("Data_Frames/", sp_df_list[[sp]]))
  
  #organize genind object
  rownames(sp_genind_temp@tab) <- sp_df_temp[,1]
  levels(sp_genind_temp) <- unique(sp_df_temp[,2])
  
  ##run prelim genetic diversity assessments  
  #calculate % of null alleles/locus
  sp_null_all <- null.all(sp_genind_temp)
  
  #create data frame
  sp_null_all_df <- signif(data.frame(sp_null_all$null.allele.freq$summary2),3)
  
  #write out data frame
  write.csv(sp_null_all_df, paste0("../Analyses/Results/Sum_Stats/", scenario_list[[sp]] , "_null_all_df.csv"))
  
  #run HWE deviations by pop 
  sp_HWE_pop <- seppop(sp_genind_temp) %>% lapply(hw.test, B = 1000)
  
  #create df by pop 
  sp_HWE_pop_df <- sapply(sp_HWE_pop, "[", i = TRUE, j = 3)
  
  #name columns with populations
  colnames(sp_HWE_pop_df) <- unique(sp_df_temp[,2])
  
  #round to the 3rd digit
  sp_HWE_allpop_df <- signif(sp_HWE_pop_df, 3)
  
  #write out 
  write.csv(sp_HWE_allpop_df, paste0("../Analyses/Results/Sum_Stats/", scenario_list[[sp]], "_HWE_dev_pop.csv"))
  
  #calculate linkage disequilibrium 
  sp_ld <- pair.ia(sp_genind_temp, sample = 1000)
  
  #convert to a data frame
  sp_ld_df <- data.frame(round(sp_ld,digits = 2))
  
  #write out 
  write.csv(sp_ld_df, paste0("../Analyses/Results/Sum_Stats/", scenario_list[[sp]], "_LD.csv"))
  
}

###########################################
#          Genetic Stats by Pop           #
###########################################
#create a list of pop types 
pop_type_list <- c("Garden", "Wild")

###loops to generate summary statistics for populations 
##outer loop is by species
#inner loop is by wild or botanic garden
for(sp in 1:length(sp_genind_list)){
  ##write loop to calculate all summary stats 
  for(pop_type in 1:length(pop_type_list)){
  
    #load genepop files as genind objects 
    sp_genind_temp <- read.genepop(paste0("Adegenet_Files/",sp_genind_list[[sp]]), ncode = 3)
    
    #load data frames 
    sp_df_temp <- read.csv(paste0("Data_Frames/", sp_df_list[[sp]]))
  
    #organize genind 
    rownames(sp_genind_temp@tab) <- sp_df_temp[,1]
    levels(sp_genind_temp@pop) <- unique(sp_df_temp[,2])
    
    #limit by pop_type 
    sp_poptype_df_temp <- sp_df_temp[sp_df_temp[,3] == paste0(pop_type_list[[pop_type]]),]
    sp_poptype_genind_temp <- sp_genind_temp[rownames(sp_genind_temp@tab) %in% sp_poptype_df_temp[,1],]
    
    ##start genetic analyses
    #create genetic summary of the genind file 
    sp_sum <- summary(sp_poptype_genind_temp)
    #create poppr file 
    sp_poppr <- poppr(sp_poptype_genind_temp)
    #save mean for final output table 
    sp_hexp_mean <- sp_poppr[1:length(levels(sp_poptype_genind_temp@pop)),10]
    #allele numbers by pop 
    sp_nall <- sp_sum$pop.n.all
    #individual numbers
    sp_ind <- sp_poppr[1:length(levels(sp_poptype_genind_temp@pop)), 2:3]
    #save allelic richness for comparison
    sp_allrich_list <- allelic.richness(sp_poptype_genind_temp)$Ar
    sp_allrich_mean <- colMeans(allelic.richness(sp_poptype_genind_temp)$Ar)	
  
    #create data frame 
    sp_allpop_gendiv_sumstat_df <- signif(cbind(sp_ind, sp_nall, sp_allrich_mean, sp_hexp_mean),3)
    
    #name rows 
    rownames(sp_allpop_gendiv_sumstat_df) <- unique(sp_poptype_df_temp$Pop)
    colnames(sp_allpop_gendiv_sumstat_df) <- c("Ind","MLG", "NAll", "All_Rich", "Hexp")
    
    #write out data frame
    write.csv(sp_allpop_gendiv_sumstat_df, paste0("../Analyses/Results/Sum_Stats/", pop_type_list[[pop_type]], "_", gsub("\\..*","",sp_genind_list[[sp]]), 
                                                  "_gendiv_sumstats.csv"))
  
  }
}
