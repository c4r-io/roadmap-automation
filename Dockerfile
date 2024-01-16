# Base R image
FROM rocker/r-base

# Make a directory in the container
RUN mkdir /home/c4r-automation

# Install Renv
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

# Copy Renv files
WORKDIR /home/c4r-automation/

COPY renv.lock renv.lock
RUN mkdir -p renv
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

RUN mkdir -p .secrets
COPY sync.R sync.R
COPY .secrets/gdrive-token.rds .secrets/gdrive-token.rds
COPY .Rprofile  .Rprofile

# Restore the R environment
RUN R -e "renv::restore()"

# Run the R script
CMD Rscript /home/c4r-automation/sync.R