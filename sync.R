library(gert)
library(gdrive.automation)

process_roadmaps <- function()
{
    # start of processing loop
    gdrv_auth()
    set_loop_num_var()
    log_action("Starting Processing Loop")

    # access roadmap docs from db
    tryCatch({
        db_units <- read_db_units()
        roadmap_urls <- db_units$`roadmap URL`
        tracker_urls <- db_units$`unit tasks URL`
        tracker_sheets <- db_units$`Sheet Name`
    }, error = function(e) {
        log_action(e$message,
                   url = getOption("gdrv_auto_env.URL_db_units"),
                   type = "ERROR")
    })

    for (idx in seq(NROW(db_units)))
    {
        roadmap_url <- roadmap_urls[idx]
        tracker_url <- tracker_urls[idx]
        tracker_sheet <- tracker_sheets[idx]
        sync_statuses(roadmap_url, tracker_url, tracker_sheet)
        merge_todo()
    }

    log_action("Ending Processing Loop")
}

set_github_pat <- function(force_new = FALSE,
                           token_file = ".secrets/github-PAT.rds",
                           decrypt_env_var = "GH_PAT_KEY")
{
    token <- Sys.getenv("GITHUB_PAT")
    if (token != "" && !force_new)
    {
        return(invisible(token))
    }

    if (gargle::secret_has_key(decrypt_env_var))
    {
        token <- gargle::secret_read_rds(token_file,
                                         key = decrypt_env_var)
    }

    Sys.setenv(GITHUB_PAT = token)
    invisible(token)
}

update_data <- function(path = tempdir())
{

    # set up git config
    git_config_global_set("user.name", "Raven Bot")
    git_config_global_set("user.email", "raven_bot@c4r.io")
    set_github_pat(force_new = TRUE)

    # clone dashboard repo
    repo_path <- file.path(path, "unit-dashboard")
    repo <- git_clone("https://github.com/c4r-io/unit-dashboard",
                      path = repo_path)

    # update data file
    data_file <- "unit_data.RDS"
    data_path <- file.path(repo_path, data_file)
    download_unit_data(data_path)

    # add, commit, push new data file
    git_add(files = data_file, repo = repo)
    commit_msg <- paste("auto-update data;",
                        format(Sys.time(), "%F %T %Z", tz = "America/New_York"))
    git_commit(message = commit_msg, repo = repo)
    git_push(repo = repo)

    return()
}

process_roadmaps()
set_github_pat()
update_data()
