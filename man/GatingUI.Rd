% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Gating_module.R
\name{GatingUI}
\alias{GatingUI}
\alias{Gating}
\title{Edit, visualize and show statistics from a gating hierarchy}
\usage{
GatingUI(id)

Gating(input, output, session, rval)
}
\arguments{
\item{id}{shiny id}

\item{input}{shiny input}

\item{output}{shiny output}

\item{session}{shiny session}

\item{rval}{A reactive values object}
}
\value{
The updated reactiveValues object \code{rval}
}
\description{
Edit, visualize and show statistics from a gating hierarchy

Gating module server function
}
\examples{
\dontrun{
library(shiny)
library(shinydashboard)
library(flowWorkspace)
library(flowCore)
library(viridis)
library(scales)
library(ggplot2)
library(ggrepel)
library(plotly)
library(ggridges)

if (interactive()){

  ui <- dashboardPage(
    dashboardHeader(title = "Gating"),
    sidebar = dashboardSidebar(disable = TRUE),
    body = dashboardBody(
      GatingUI("module")
    )
  )

  server <- function(input, output, session) {

    rval <- reactiveValues()
    observe({
      utils::data("GvHD", package = "flowCore")
      rval$gating_set <- GatingSet(GvHD)
    })
    res <- callModule(Gating, "module", rval = rval)
  }

  shinyApp(ui, server)

}
}
}
