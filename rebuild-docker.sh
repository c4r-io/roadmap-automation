dir="/home/haoye/projects/roadmap-automation/"

# navigate to correct directory
cd $dir

# check for new commits
origin="origin"
branch="main"
commit=$(git log -n 1 --pretty=format:%H "$origin/$branch")
url=$(git remote get-url "$origin")
has_updates=false

for line in "$(git ls-remote -h $url)"; do
    fields=($(echo $line | tr -s ' ' ))
    test "${fields[1]}" == "refs/heads/$branch" || continue
    if [ "${fields[0]}" != "$commit" ] ; then
        has_updates=true
        break
    fi
done

# update and rebuild
if $has_updates ; then
    git pull
    /usr/bin/podman -t roadmap-automation .
fi
