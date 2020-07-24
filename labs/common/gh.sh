
if [[ ${GH_TOKEN} == "" ]]; then
    echo "GH_TOKEN variable not set. Please rerun the env script"
    exit -1
fi
if [[ ${GITHUB_USERNAME} == "" ]]; then
    echo "GITHUB_USERNAME variable not set. Please rerun the env script"
    exit -1
fi
if [[ $2 == "" || $1 == "" ]]; then
    echo "Usage: gh <create|delete> <repo> "
    exit -1
fi
action=$1
repo=$2
user=$GITHUB_USERNAME
token=${GH_TOKEN}
base=https://api.github.com

export GIT_ASKPASS=$BASE_DIR/labs/common/ghp.sh


if [[ $action == 'create' ]]; then
    # Create
    curl -H "Authorization: token $token" ${base}/user/repos -d '{"name": "'"${repo}"'"}' > /dev/null
    echo "Created ${repo}"

    #TODO: Check if repo exists first
fi

if [[ $action == 'delete' ]]; then
    # Delete
    curl -H "Authorization: token $token" -X "DELETE" ${base}/repos/${user}/${repo}
    echo "Deleted ${repo}"
fi


