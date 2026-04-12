# function definitions

function update_ssh_keys() {
    cd ~/.ssh/
    rm id_rsa
    ssh-add -D
    mv ~/Downloads/id_rsa.openssh ./id_rsa
    chmod 0600 id_rsa
    ssh-add id_rsa
    ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub
    pbcopy < ~/.ssh/id_rsa.pub
}

function pygrep() {
    grep -n $1 **/*.py
}

function gogrep() {
    grep -n $1 **/*.go
}

function cppgrep() {
    grep -n $1 **/*.cpp **/*.h
}

function default_arg() {
    if [ -n "$2" ]; then
        local arg="$2"
    else
        local arg="$1"
    fi
    echo "$arg"
}

function root() {
    cd `git rev-parse --show-toplevel`
}

function todo() {
    grep -n "TODO" **/*.*
}

function push() {
    branch=`git branch | grep \* | cut -d ' ' -f2`
    echo $branch
    message="$1"
    git commit -am $message
    if test -z $2; then
        git push origin $branch
    else
        remote=$2
        git push $remote $branch
    fi
    echo "Commited and pushed"
}

function get-functions() {
    print -l ${(ok)functions} | grep -v "_"
}

function master() {
    git checkout master
    git pull upstream master
    git push origin master
}

function ghead() {
    git rev-list main..HEAD | tail -1
}

function fixup() {
    if test -z $1; then
        commit=$(ghead)
    fi
    git commit -a --fixup $commit
}

function auto-rebase() {
    local source_branch=`default_arg "master" $1 `
    git rebase -i --autosquash $source_branch
}

function fvim() {
    vim `find . -name $1`
}

function clean-docker() {
    docker rm $(docker ps -q -f "status=exited")
    docker rmi $(docker images -q -f "dangling=true")
    docker volume rm $(docker volume ls -qf dangling=true)
}

function pydir() {
    mkdir -p $1
    touch "$1/__init__.py"
}

function gitmain() {
    git branch -m master main
    git push -u origin main
    git push origin :master
}

function ciw() {
    local current_branch=`git branch --show-current`
    local branch=`default_arg $current_branch $1`
    while :; do clear; cowsay -f tux $branch ; ci -v $branch --color=always | sed -e 's/http.*//'; sleep 15; done
}

function _ciw() {
    compadd `git --no-pager branch`
}

compdef _ciw ciw

function delete_old_branches() {
    for branch in $(git branch -a | sed 's/^\s*//' | sed 's/^remotes\///' | grep -v 'main$\|develop$'); do
      if ! ( [[ -f "$branch" ]] || [[ -d "$branch" ]] ) && [[ "$(git log $branch --since "1 month ago" | wc -l)" -eq 0 ]]; then
        if [[ "$DRY_RUN" = "false" ]]; then
          ECHO=""
        fi
        local_branch_name=$(echo "$branch" | sed 's/remotes\/origin\///')
        $ECHO git branch -d "${local_branch_name}"
        $ECHO git push origin --delete "${local_branch_name}"
      fi
    done
}

function readme() {
    (test -e README.md && echo "Readme already exists") || echo "${1}" >> README.md
}
