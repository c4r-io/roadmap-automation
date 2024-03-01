library(gert)
library(gdrive.automation)

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
