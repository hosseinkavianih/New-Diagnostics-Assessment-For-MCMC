library(ggplot2)
library(gridExtra)
library(viridis)  # load package
library(patchwork)
library(ggpubr)


setwd("C:/Users/Julianne Quinn/Box Sync/HosseinJulieShare/MCMC/New Diagnostics Paper/Data/100D/Marginals")
#setwd("D:/MCMC/Posteriors/MH/100d")

#setwd("D:/MCMC/Posteriors/MH/")


indices <- rep(1,5)#rep(1, 25)

# These of all file names for 100d - for five algorithms
file_names <- c(#"25 Percernt  Max NFE - 25 Percernt Max Chains (MH_Opt).Rdata","25 Percernt  Max NFE - 75 Percernt Max Chains (MH_Opt).Rdata", "50 Percernt  Max NFE - 50 Percernt Max Chains (MH_Opt).Rdata", "75 Percernt  Max NFE - 25 Percernt Max Chains (MH_Opt).Rdata","75 Percernt  Max NFE - 75 Percernt Max Chains (MH_Opt).Rdata",
                #"25 Percernt  Max NFE - 25 Percernt Max Chains (MH_NoOpt).Rdata","25 Percernt  Max NFE - 75 Percernt Max Chains (MH_NoOpt).Rdata", "50 Percernt  Max NFE - 50 Percernt Max Chains (MH_NoOpt).Rdata", "75 Percernt  Max NFE - 25 Percernt Max Chains (MH_NoOpt).Rdata","75 Percernt  Max NFE - 75 Percernt Max Chains (MH_NoOpt).Rdata",
                "25 Percernt  Max NFE - 25 Percernt Max Chains (AM_Opt).Rdata","25 Percernt  Max NFE - 75 Percernt Max Chains (AM_Opt).Rdata", "50 Percernt  Max NFE - 50 Percernt Max Chains (AM_Opt).Rdata", "75 Percernt  Max NFE - 25 Percernt Max Chains (AM_Opt).Rdata","75 Percernt  Max NFE - 75 Percernt Max Chains (AM_Opt).Rdata")#,
                #"25 Percernt  Max NFE - 25 Percernt Max Chains (AM_NoOpt).Rdata","25 Percernt  Max NFE - 75 Percernt Max Chains (AM_NoOpt).Rdata", "50 Percernt  Max NFE - 50 Percernt Max Chains (AM_NoOpt).Rdata", "75 Percernt  Max NFE - 25 Percernt Max Chains (AM_NoOpt).Rdata","75 Percernt  Max NFE - 75 Percernt Max Chains (AM_NoOpt).Rdata",
                #"25 Percernt  Max NFE - 25 Percernt Max Chains (DREAM).Rdata","25 Percernt  Max NFE - 75 Percernt Max Chains (DREAM).Rdata", "50 Percernt  Max NFE - 50 Percernt Max Chains (DREAM).Rdata", "75 Percernt  Max NFE - 25 Percernt Max Chains (DREAM).Rdata","75 Percernt  Max NFE - 75 Percernt Max Chains (DREAM).Rdata")
titles <- c(#"MH Opt 25% NFE/25% Chains", "MH Opt 25% NFE/75% Chains", "MH Opt 50% NFE/50% Chains", "MH Opt 75% NFE/25% Chains", "MH Opt 75% NFE/75% Chains",
            #"MH No_Opt 25% NFE/25% Chains", "MH No_Opt 25% NFE/75% Chains", "MH No_Opt 50% NFE/50% Chains", "MH No_Opt 75% NFE/25% Chains", "MH No_Opt 75% NFE/75% Chains",
            "AM Opt 25% NFE/25% Chains", "AM Opt 25% NFE/75% Chains", "AM Opt 50% NFE/50% Chains", "AM Opt 75% NFE/25% Chains", "AM Opt 75% NFE/75% Chains")#,
            #"AM No_Opt 25% NFE/25% Chains", "AM No_Opt 25% NFE/75% Chains", "AM No_Opt 50% NFE/50% Chains", "AM No_Opt 75% NFE/25% Chains", "AM No_Opt 75% NFE/75% Chains",
            #"DREAM 25% NFE/25% Chains", "DREAM 25% NFE/75% Chains", "DREAM 50% NFE/50% Chains", "DREAM 75% NFE/25% Chains", "DREAM 75% NFE/75% Chains")
# create an empty list to store the dataframes

# These are the file names for only MH_OPT
#file_names <- c("25 Percernt  Max NFE - 25 Percernt Max Chains (MH_Opt).Rdata","25 Percernt  Max NFE - 75 Percernt Max Chains (MH_Opt).Rdata", "50 Percernt  Max NFE - 50 Percernt Max Chains (MH_Opt).Rdata", "75 Percernt  Max NFE - 25 Percernt Max Chains (MH_Opt).Rdata","75 Percernt  Max NFE - 75 Percernt Max Chains (MH_Opt).Rdata")

# These are the files names for Bimodal example
#file_names <- c("High GR - Low KLD.Rdata", "High GR - Low WD.Rdata", "High KLD - Low GR.Rdata","High KLD - Low WD.Rdata", "High WD - Low GR.Rdata", "High WD - Low KLD.Rdata","LH With KLD Close to 0.Rdata", "LH With KLD Close to 10.Rdata", "LH With KLD Close to 20.Rdata")
#indices <- c(23, 5, 8, 24, 6, 24, 6, 1, 23)

#load("25 Percernt  Max NFE - 25 Percernt Max Chains (DREAM).Rdata")

# create an empty list to store the samples
samples_list <- list()

#load("25 Percernt  Max NFE - 25 Percernt Max Chains (MH_Opt).Rdata")

dim = 1 # dimension to plot marginals for

# loop through each file name
for (i in 1:length(file_names)) {
  
  # load the Rdata file
  load(file_names[i])
  
  # get the number of chains in the Rdata file
  num_chains <- length(listdata[[indices[i]]])
  
  # create an empty list to store the chains
  chain_list <- list()
  
  # loop through each chain and extract the desired column
  for (j in 1:num_chains) {
    chain_list[[j]] <- listdata[[indices[i]]][[j]]$chain[,dim]
  }
  
  # combine the chains into a single vector
  samples_list[[i]] <- unlist(chain_list)
  
  # give the columns descriptive names
  #colnames(df_list[[i]]) <- paste0("Chain_", 1:num_chains)
  
  #df_list[[i]]$file_name <- gsub(".Rdata", "", file_names[i])
}

# define chain colors

#chain_colors <- plasma(20)

# define bimodal function - comment out if you want to do 100d example

#bimodal_func <- function(x) {
#  1/3 * dnorm(x, mean = -5, sd = 1) + 2/3 * dnorm(x, mean = 5, sd = 1)
#}

# This is the 100d function for the first dimension

highdim_func <- function(x) {
  dnorm(x, mean = 0, sd = sqrt(dim))
}

plot_list <- list()

lay <- rbind(c(4,NA,5),
             c(NA,3,NA),
             c(1,NA,2))

# loop through each list in df_list and create a plot
for (i in 1:length(samples_list)) {
  # get the length of the chains in this list
  #chain_lengths <- sapply(df_list[[i]], length)
  
  # create a data frame with all the chains in this list
  #df <- data.frame(
  #  chain = rep(names(df_list[[i]]), chain_lengths),
  #  value = unlist(df_list[[i]])
  #)
  df <- data.frame(value=samples_list[[i]])
  
  # create a plot with the KDE of the 100d function and a dashed red KDE of all chains together
  p <- ggplot(df, aes(x = value)) +
    stat_function(aes(color = "100d"), fun = highdim_func) +
    #geom_density(aes(color = chain)) +
    stat_density(geom = "line", aes(color = "All Chains"), data=df, adjust=3)+
                 #lty = 1, lwd=1, data = df) +
    scale_color_manual(values = c("100d" = "black", 
                                "All Chains" = "red")) +
    #ggtitle(gsub(".Rdata", "", file_names[i]))+
    #ggtitle(titles[[i]]) +
    xlim(-15, 15) +
    #theme(plot.title = element_text(hjust = 0.5)) #+
    theme(legend.position = "none")
  
  # add the plot to the plot_list
  plot_list[[i]] <- p
}

#plot_list[[2]]
# arrange the plots into a 3x3 grid using gridExtra
grid.arrange(grobs = plot_list, layout_matrix=lay)#, ncol = 5)
#ggarrange(plot_list[[1]], plot_list[[2]], plot_list[[3]], plot_list[[4]], plot_list[[5]], plot_list[[6]], plot_list[[7]], plot_list[[8]], plot_list[[9]], ncol=3, nrow = 3, common.legend = TRUE, legend = "bottom")
