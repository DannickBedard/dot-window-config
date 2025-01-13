
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# this may be long to load... see what i am gettings from this... not much a gues
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

HISTSIZE=500  
HISTFILESIZE=100000

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"

# Declare an associative array to store project names and their paths
declare -A projects

# Populate the projects array with names and locations
projects=(
    ["viridem"]="/c/viridem"
    ["viridem api"]="/c/viridem/api"
    ["viridem worktree"]="/c/viridem-worktree"
    ["export api"]="/c/project/viridem-api-export-test"
    ["aiCommService"]="/c/project/aicommservice"
    ["aiService"]="/c/project/aiservice"
    ["viridemConnect"]="/c/ViridemConnect"
    ["nvimConfig"]="/c/Users/dannick.bedard/AppData/Local/nvim"
    ["userConfig"]="/c/Users/dannick.bedard"
    ["notes"]="/c/Users/dannick.bedard/Documents/Notes"
    ["devTemp"]="/c/Users/dannick.bedard/Documents/Temp/test/dev"
    ["local project"]="/c/project/"
    ["junitJava"]="/c/project/viridem-junit"
)



# Function to list all projects
list_projects() {
    for name in "${!projects[@]}"; do
        echo "$name -> ${projects[$name]}"
    done
}

# Function to navigate to a project directory by name
go_to_project() {
    local project_name="$1"
    if [[ -n "${projects[$project_name]}" ]]; then
        cd "${projects[$project_name]}" || echo "Failed to navigate to ${projects[$project_name]}"
        echo "Now in $(pwd)"
    else
        echo "Project '$project_name' not found!"
    fi
}

# Function to use fzf for project selection
op() {
    local selected_project=$(for name in "${!projects[@]}"; do echo "$name"; done | fzf --height=20% --info=inline --reverse)
    if [[ -n "$selected_project" ]]; then
        go_to_project "$selected_project"
    else
        echo "No project selected."
    fi
}

opv() {

    local selected_project=$(for name in "${!projects[@]}"; do echo "$name"; done | fzf --height=20% --info=inline --reverse)
    if [[ -n "$selected_project" ]]; then
        go_to_project "$selected_project" && nvim .
    else
        echo "No project selected."
    fi
}

pr() {
  # Get the list of all Git branches and pass them to fzf for selection
  selected_branch=$( git branch --all | sed 's/^[* ]*//' | sed 's#^remotes/origin/##' | fzf --height=20% --info=inline --reverse)

  # Check if a branch was selected
  if [ -n "$selected_branch" ]; then
    # Concatenate the selected branch into a string
    result="You selected branch: $selected_branch"
    echo "$result"

    # Base Bitbucket URL
    BITBUCKET_URL="https://bitbucket.org"

    # Get the repository owner and name from Git remote
    REMOTE_URL=$(git remote get-url origin)
    REPO_INFO=$(echo "$REMOTE_URL" | sed -E 's#.*/([^/]+)/([^/]+)(\.git)?$#\1 \2#')
    REPO_OWNER=$(echo "$REPO_INFO" | awk '{print $1}')
    REPO_NAME=$(echo "$REPO_INFO" | awk '{print $2}' | sed 's/\.git$//') # Remove .git if present

    # Current branch name
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    # Destination branch (customize as needed)
    DESTINATION_BRANCH="release/v2024.3"

    # Construct the Pull Request URL
    PR_URL="$BITBUCKET_URL/$REPO_OWNER/$REPO_NAME/pull-requests/new?source=$CURRENT_BRANCH&dest=$selected_branch"

    # Open the URL in the default browser
    echo "Opening: $PR_URL"
    if command -v start &>/dev/null; then
        start "$PR_URL"
    else
        echo "Could not detect a browser open command. Please open this URL manually: $PR_URL"
    fi
  else
    echo "No branch selected."
  fi
}

gcheckout() {
  echo "Fetching... "
  git fetch

  selected_branch=$( git branch --all | sed 's/^[* ]*//' | sed 's#^remotes/origin/##' | fzf --height=20% --info=inline --reverse)
  # Check if a branch was selected
  if [ -n "$selected_branch" ]; then
    # Concatenate the selected branch into a string
    result="You selected branch: $selected_branch"
    echo "$result"
    git checkout $selected_branch
  else
    echo "No branch selected."
  fi
}

gc () { # shurtcut
  gcheckout
}

gclean() {
  # https://stackoverflow.com/a/33548037
  git fetch -p && for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do git branch -D $branch; done
}

sf() {
  echo "Sourcing .bashrc"
  source ~/.bashrc
}
