# library(flowWorkspaceData)
library(flowWorkspace)
library(ncdfFlow)
library(premessa)
library(flowCore)
library(ggcyto)
# fs <- read.ncdfFlowSet(files = c("../flowR_utils/norm/20120222_cells_found.fcs", 
#                                  "../flowR_utils/norm/20120229_cells_found.fcs"))

fs <- read.ncdfFlowSet(files = c("/mnt/NAS7/Workspace/hammamiy/data_premasse/20120222_cells_found.fcs"))
                                 # "/mnt/NAS7/Workspace/hammamiy/data_premasse/20120229_cells_found.fcs"))

gs <- GatingSet(fs)


colnames(gs)

#using functions from flowR

#define gates
rg <- flowCore::rectangleGate(filterId = "beads1", list("Bead1(La139)Di" = c(10, 200), "(Ir193)Di" = c(-50, 50)))
rg2 <- rectangleGate(filterId = "beads2", list("Bead2(Pr141)Di" = c(10, 200), "(Ir193)Di" = c(-50, 50)))
rg3 <- rectangleGate(filterId = "beads3", list("CD11c(Tb159)Di" = c(10, 200), "(Ir193)Di" = c(-50, 50)))
rg4 <- rectangleGate(filterId = "beads4", list("Bead3(Tm169)Di" = c(10, 200), "(Ir193)Di" = c(-50, 50)))
rg5 <- rectangleGate(filterId = "beads5", list("Bead4(Lu175)Di" = c(10, 200), "(Ir193)Di" = c(-50, 50)))

rg_new <- rectangleGate(filterId = "new_beads", list("Bead4(Lu175)Di" = c(10, 200)))

flowWorkspace::gs_pop_add(gs, rg)
flowWorkspace::gs_pop_add(gs, rg2, parent = "/beads1")
flowWorkspace::gs_pop_add(gs, rg3, parent = "/beads1/beads2")
flowWorkspace::gs_pop_add(gs, rg4, parent = "/beads1/beads2/beads3")
flowWorkspace::gs_pop_add(gs, rg5, parent = "/beads1/beads2/beads3/beads4")

flowWorkspace::gs_pop_add(gs, rg_new)

recompute(gs)

plot_gs_ggcyto(gs,sample = sampleNames(gs), gate_name = "beads1",
               plot_type = "dots",
               plot_args = list(xvar = "Bead1(La139)Di", yvar = "(Ir193)Di" ),
               options = list(default_trans = asinh_trans())) + facet_wrap(~name)


# compute baseline
df <- get_data_gs(gs = gs, sample = sampleNames(gs), subset = c("beads5", "new_beads"))
beads.cols.names <- c("Bead1(La139)Di", "Bead2(Pr141)Di", "CD11c(Tb159)Di", "Bead3(Tm169)Di", "Bead4(Lu175)Di")
df$id <- 1
df_stat <- flowR:::compute_stats(df = df, 
                                 y_trans = asinh_trans(scale = 5), 
                                 apply_inverse = TRUE,
                                 yvar = beads.cols.names, 
                                 stat_function = "median", 
                                 id.vars = c("id"))
baseline.data <- unlist(df_stat[, -1])

#normalize data for each sample
df_list <- list()
for(sample in sampleNames(gs)){
  df <- get_data_gs(gs, sample = sample, subset = "root")
  m <- as.matrix(df[-which(names(df) %in% c("name", "subset"))])
  beads.data <- get_data_gs(gs, sample = sample, subset = c("beads5", "new_beads"))
  beads.data <- as.matrix(beads.data[-which(names(beads.data) %in% c("name", "subset"))])
  norm.res <- premessa:::correct_data_channels(m = m,
                                               beads.data = beads.data,
                                               baseline = baseline.data,
                                               beads.col.names = beads.cols.names,
                                               time.col.name = "Time")
  m.normed <- norm.res$m.normed
  
  
  vect <- c("beads5", "new_beads")
  
  
  vect_indic <- sapply(vect, function(x){
    list(gh_pop_get_indices(gs[[sample]], x))
  }) 
  
  # use intersect   
  maxlen <- max(sapply(vect_indic, length))

  intersec <- unique(lapply(seq(maxlen),function(i) Reduce(union,lapply(vect_indic,"[[", i))))
  beads.events <- unlist(intersec)
  # beads.events <- gh_pop_get_indices(gs[[sample]], "beads5")
  # print(beads.events)
  

  m.normed <- cbind(m.normed,
                    beadDist = premessa:::get_mahalanobis_distance_from_beads(m.normed, 
                                                                              beads.events, 
                                                                              beads.cols.names))
  
  print("tets")
  colnames(m.normed) <- paste(colnames(m.normed), "norm")
  colnames(m.normed)[colnames(m.normed)=="beadDist norm"] <- "beadDist"
  
  df_list[[sample]] <- cbind(df, as.data.frame(m.normed))
}

df <- do.call(rbind, df_list)

#build GatingSet
fs_norm <- build_flowset_from_df(df = df, origin = fs)
gs_norm <- build_gatingset_from_df(df = df, gs_origin = gs)
gs_norm <- GatingSet(fs_norm)


plot_gs(gs_norm,sample = sampleNames(gs_norm),
        plot_type = "dots",
        plot_args = list(xvar = "Bead1(La139)Di", yvar = "(Ir193)Di" ),
        options = list(default_trans = asinh_trans())) + facet_wrap(~name)

#using only functions from premessa

# wd <- "../flowR_utils/norm"
# wd <- "/mnt/NAS7/Workspace/hammamiy/data_premasse"
# beads.cols.names <- c("Bead1(La139)Di", "Bead2(Pr141)Di", "CD11c(Tb159)Di", "Bead3(Tm169)Di", "Bead4(Lu175)Di")
# beads.gate <- list()
# beads.gate[["20120222_cells_found.fcs"]] <- list("Bead1(La139)Di" = list(x=asinh(c(10, 200)/5), y=asinh(c(-50, 50)/5)), 
#                                                  "Bead2(Pr141)Di" = list(x=asinh(c(10, 200)/5), y=asinh(c(-50, 50)/5)), 
#                                                  "CD11c(Tb159)Di" = list(x=asinh(c(10, 200)/5), y=asinh(c(-50, 50)/5)), 
#                                                  "Bead3(Tm169)Di" = list(x=asinh(c(10, 200)/5), y=asinh(c(-50, 50)/5)), 
#                                                  "Bead4(Lu175)Di" = list(x=asinh(c(10, 200)/5), y=asinh(c(-50, 50)/5))) 
# beads.gate[["20120229_cells_found.fcs"]] <-list("Bead1(La139)Di" = list(x=asinh(c(10, 200)/5), y=asinh(c(-50, 50)/5)), 
#                                                 "Bead2(Pr141)Di" = list(x=asinh(c(10, 200)/5), y=asinh(c(-50, 50)/5)), 
#                                                 "CD11c(Tb159)Di" = list(x=asinh(c(10, 200)/5), y=asinh(c(-50, 50)/5)), 
#                                                 "Bead3(Tm169)Di" = list(x=asinh(c(10, 200)/5), y=asinh(c(-50, 50)/5)), 
#                                                 "Bead4(Lu175)Di" = list(x=asinh(c(10, 200)/5), y=asinh(c(-50, 50)/5))) 
# 
# normalize_folder(wd  = wd, 
#                  beads.gates = beads.gate, 
#                  output.dir.name = "../flowR_utils/norm/normed/", 
#                  beads.type = "Beta", 
#                  baseline = NULL)

# 
# premessa::normalize_folder(wd  = wd, 
#                            beads.gates = beads.gate, 
#                            output.dir.name = "/normed/", 
#                            beads.type = "Beta", 
#                            baseline = NULL)
# 
# bdata <- premessa:::calculate_baseline(wd, beads.type = "Beta", files.type = "data", beads.gates = beads.gate)
# 
# fs
# sample <- sampleNames(fs)[1]
# m <- flowCore::exprs(fs[[sample]])
# beads.events <- premessa:::identify_beads(m, beads.gate[[sample]], beads.cols.names, dna.col = "(Ir193)Di")
# beads.data <- m[beads.events,]
# 
# fs
# beads.data
# table(beads.events)
# 
# norm.res <- premessa:::correct_data_channels(m, beads.data, baseline = bdata, beads.cols.names)
# 
# 
# m.normed <- norm.res$m.normed
# m.normed <- cbind(m.normed,
#                   beadDist = premessa:::get_mahalanobis_distance_from_beads(m.normed, 
#                                                                             beads.events, 
#                                                                             beads.cols.names))
# 
# # premessa:::plot_distance_from_beads(m.normed, x.var = "(Ir193)Di", y.var = "(Ir191)Di")
# 
# 
# # premessa:::plot_beads_over_time(beads.data = m, beads.normed = norm.res$beads.normed, beads.cols = beads.cols.names)
# 
# 
# 
# test <- get_gates_from_gs(gs)
# test$`/beads1/beads2/beads3/beads4/beads5`