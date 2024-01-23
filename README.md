# roadmap-automation

<!-- badges: start -->

<!-- badges: end -->

This repo 

## Files

`setup.R` - install the latest version of the `{{gdrive-automation}}` package from GitHub
`sync.R` - run through the synchronization loop
`.Renviron` - file with API keys (should NOT be present in the git repo or the docker image and will be distributed by Hao when the docker image is to be run)

## Instructions

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
