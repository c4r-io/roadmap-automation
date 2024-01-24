# Base R image
FROM rocker/r2u:22.04

# Install libcurl
RUN apt-get update && apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev libfontconfig1-dev libharfbuzz-dev libfribidi-dev

# Make a directory in the container
RUN mkdir /home/c4r-automation

# Install Renv
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

WORKDIR /home/c4r-automation/

# renv package dependencies
COPY renv.lock renv.lock
RUN mkdir -p renv
COPY .Rprofile  .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

# Restore the R environment
RUN R -e "renv::restore()"

# authentication files
RUN mkdir -p .secrets
COPY .secrets/gdrive-token.rds .secrets/gdrive-token.rds
COPY .secrets/github-PAT.rds .secrets/github-PAT.rds

# scripts
COPY setup.R setup.R
COPY sync.R sync.R

# Run the R script
CMD Rscript /home/c4r-automation/setup.R
CMD Rscript /home/c4r-automation/sync.R
