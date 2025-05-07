#!/bin/sh -l
REPO_NAME="PP_Repository_Template"
REPO_URL="https://github.com/EvertBunschoten/PP_Repository_Template.git"

echo "Docker Container for $REPO_NAME Repository"
usage="$(basename "$0") [-h] [-b branch_name]
where:
    -h  show this help text
    -b  branch name
    -s  script with tests
"

flags=""
branch=""
testscript="run_regression.py"
workdir=$PWD
export CCACHE_DIR=$workdir/ccache

while [ $# -gt 0 ];
do
    case "$1" in
        -b)
                branch=$2
                shift 2
            ;;
        -s)
                testscript=$2
                shift 2
            ;;
        *)
                echo "$usage" >&2
                exit 1
            ;;
esac
done

# Clone source code using git into directory "src".
if [ ! -z "$branch" ]; then
  name="$REPO_NAME_$(echo $branch | sed 's/\//_/g')"
  echo "Branch provided. Cloning to $PWD/src/$name"
  if [ ! -d "src" ]; then
    mkdir "src"
  fi
  cd "src"
  git clone --recursive $REPO_URL $name
  cd $name
  export REPO_DIR=$PWD
  git config --add remote.origin.fetch '+refs/pull/*/merge:refs/remotes/origin/refs/pull/*/merge'
  git config --add remote.origin.fetch '+refs/heads/*:refs/remotes/origin/refs/heads/*'
  git fetch origin
  git checkout $branch
  git submodule update
else
    echo "Branch not specified, use -b to provide a branch."
    exit 1
fi

# Optional: update python environment variables if applicable

# Activate python virtual environment and install required modules
python3 -m venv /home/ubuntu/pyenv 
virtualenv -p /usr/bin/python3 /home/ubuntu/pyenv 
. /home/ubuntu/pyenv/bin/activate 
python3 -m pip install -r $REPO_DIR/requirements.txt 

export REPO_HOME=$PWD
export PYTHONPATH=$PYTHONPATH:$REPO_HOME
export PATH=$PATH:$REPO_HOME/bin/

# Run script for regression tests 
echo "Running regression tests for $name"
cd "regressiontests"

python3 $testscript
