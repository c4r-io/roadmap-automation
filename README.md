# roadmap-automation

This repo contains the files for automation of C4R synchronization scripts.

## Overview

This repo and associated docker image are deployed to the Kording Lab server.

Primary Actions:

* every day, a bash script is run to check for updates to this repo on Github, if found, the Docker image is rebuilt
* hourly, during North America work hours, the Docker iamge is run, which does the synchronization and updating of content related to C4R materials. The bulk of this code is in https://github.com/c4r-io/gdrive-automation 

## Files

### Bash Scripts
`run-sync.sh` - run the docker image (simplifies the command for cron and on-demand running)
`rebuild-docker.sh` - check for updates to the `main` branch of the git repo:
  if found, get updates and rebuild the docker image
  if not, reset the repo (in case there is cruft in the local folder for some reason)

### Docker Files
`Dockerfile` - the spec for the docker image

### R Files
`setup.R` - install the latest version of the `{{gdrive-automation}}` package from GitHub
`sync.R` - run through the synchronization loop

### Authentication
`.secrets/gdrive-token.rds` - token for API access to Google Drive files (from personal app to avoid shared limits for all users of the `{googledrive}` package)
`.secrets/github-PAT.rds` - token for updating the Github Repo for the dashboard
`.Renviron` - file with decryption keys for the above (encrypted) tokens, also includes monday.com API key (this file should be ABSENT from the git repo and docker image, and is distributed for deployment, and mounted during the run by `run-sync.sh`

## Cron

These are the cron schedules for deployment:
```
0 12-23/1 * * * /usr/bin/bash /home/haoye/projects/roadmap-automation/run-sync.sh
0 3 * * * /usr/bin/bash /home/haoye/projects/roadmap-automation/rebuild-docker.sh
```

`0 12-23/1 * * *` runs every hour between 1200 and 2300 (as the server is on UTC time, this is either 0800-1900 ET or 0700-1800 ET, depending on whether daylight savings is in effect)

`0 3 * * *` runs at 0300 every day (either 2300 ET or 2200 ET, depending on whether daylight savings is in effect)

The first command runs the synchronization script.
The second command runs the script to check for and rebuild the docker image.

## Local Building and Testing)

To build 
```
docker build --platform=linux/amd64 -t roadmap-automation .
```

To run
```
docker run --net=host --platform=linux/amd64 -v ./.Renviron:/home/c4r-automation/.Renviron roadmap-automation:latest
```

To run (with interactive shell for debugging)
```
docker run -it --net=host --platform=linux/amd64 -v ./.Renviron:/home/c4r-automation/.Renviron roadmap-automation:latest bash
```

## Past Troubleshooting

Some major challenges:
1. authentication to APIs - I needed both non-interactive authentication (https://gargle.r-lib.org/articles/non-interactive-auth.html) as well as my own API credentials (https://gargle.r-lib.org/articles/get-api-credentials.html) to get around API rate limits

2. debugging various errors and wanting to automate updating the Docker image (is why this repo now has more complex shell scripts to handle the routine commands)

3. using the latest version of `{{gdrive-automation}}` - included as its own setup line in the `setup.R`, so that it is run every time the Docker image is run, and updating the Github Actions script of the Dashboard to use `{{ secrets.GITHUB_TOKEN }}` in order to deal with Github - Github rate limits.

