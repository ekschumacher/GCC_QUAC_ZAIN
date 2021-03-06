##This script is used to determine if there are differences between 
#scoring based on who scored them in Zamia integrifolia 

#####################
#     Libraries     #
#####################

library(adegenet)
library(diveRsity)

#######################
#     Load Files      #
#######################
setwd("../../Data_Files")

#convert arp2gen - comment in if needed
#arp2gen("ZAIN_adegenet_files/ZAIN_garden_wild_rebinned.arp")

#load in data frame with 2 pops - scored by us vs. scored by the Griffith lab
ZAIN_og_genind <- read.genepop("Adegenet_Files/Garden_Wild/ZAIN_og_garden_wild.gen", ncode = 3)

#convert to genpop
ZAIN_og_genpop <- genind2genpop(ZAIN_og_genind)

#load rebinned genepop file as a genind object
ZAIN_rebinned_genind <- read.genepop("Adegenet_Files/Garden_Wild/ZAIN_rebinned_garden_wild.gen", ncode = 3)

#convert to genepop
ZAIN_rebinned_genpop <- genind2genpop(ZAIN_rebinned_genind)

#create a list of loci 
loci <- colnames(ZAIN_og_df)

#clean list 
loci <- unique(gsub("\\..*","",loci)[4:25])

###############################
#     Scoring Comparison      #
###############################

##loop to compare scoring between the Hoban Lab Scoring and the Griffith Lab
setwd("../Analyses/Results/Scoring_Comparison")
pdf("ZAIN_scoring_comparison_barplots.pdf",width=20,height=9)

for(a in loci){
  
  ZAIN_scoring <- ZAIN_og_genpop[,which(grepl(a,colnames(ZAIN_og_genpop@tab)))]@tab
  
  for(p in 1:2) ZAIN_scoring[p,] <- ZAIN_scoring[p,]/sum(ZAIN_scoring[p,])
  #reorder data frame
  ZAIN_scoring <- ZAIN_scoring[,sort(colnames(ZAIN_scoring))]
  
  #now plot 
  ZAIN_barplot <- barplot(ZAIN_scoring, las = 2, beside = TRUE, col = c("darkgreen", "darkseagreen1"),
                           legend.text =  c("Hoban_Lab","Griffith_Lab"), ylim = c(0,1), main = paste0(a),
                          names = gsub("^.*\\.","",colnames(ZAIN_scoring)))
  
}

dev.off()


############################################################
#     Scoring Comparison Following Rebinning Analysis      #
############################################################
##loop to compare scoring between the Hoban Lab Scoring and the Griffith Lab

pdf("ZAIN_scoring_comparison_barplots_post_rebinning.pdf",width=20,height=9)
for(a in loci){
  
  ZAIN_scoring <- ZAIN_rebinned_genpop[,which(grepl(a,colnames(ZAIN_rebinned_genpop@tab)))]@tab
  
  for(p in 1:2) ZAIN_scoring[p,] <- ZAIN_scoring[p,]/sum(ZAIN_scoring[p,])
  #reorder data frame
  ZAIN_scoring <- ZAIN_scoring[,sort(colnames(ZAIN_scoring))]
  
  #now plot 
  ZAIN_barplot <- barplot(ZAIN_scoring, las = 2, beside = TRUE, col = c("darkgreen", "darkseagreen1"),
                          legend.text =  c("Hoban_Lab","Griffith_Lab"), ylim = c(0,1), main = paste0(a),
                          names = gsub("^.*\\.","",colnames(ZAIN_scoring)))
  
}

dev.off()


sessionInfo()
