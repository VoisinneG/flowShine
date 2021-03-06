% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/flowR.R
\name{plot_gh}
\alias{plot_gh}
\title{Plot all gates for a given sample of a GatingSet}
\usage{
plot_gh(
  gs,
  df = NULL,
  sample = NULL,
  Ncells = NULL,
  selected_subsets = NULL,
  spill = gs@compensation,
  plot_type = "hexagonal",
  plot_args = list(),
  options = list()
)
}
\arguments{
\item{gs}{a GatingSet}

\item{df}{data.frame with columns \code{name} and \code{subset} 
containing sample and subset names respectively and
columns with plot variables. Ignored if \code{NULL}. 
Otherwise supersedes parameters 'gs', 'sample', 'spill', 'metadata'.}

\item{sample}{sample names}

\item{Ncells}{number of cells to sample from the GatingSet}

\item{selected_subsets}{subset names. if NULL, all gates are drawn.}

\item{spill}{spillover matrix. If NULL, uncompensated data is used both for gating and plotting.}

\item{plot_type}{name of the plot type}

\item{plot_args}{list of plot parameters passed to \code{plot_gs()}}

\item{options}{list of plot format options passed to \code{format_plot()}}
}
\value{
a list of ggplot objects
}
\description{
Plot all gates for a given sample of a gating set
}
