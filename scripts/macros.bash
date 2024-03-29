# Included by ./.bashrc

# Executes colcon build in workspace.
build() {
    prev_dir=$(pwd)
    cd $_KALMAN_WS_ROOT

    # Verify if rosdep cache exists.
    if [ ! -d "$HOME/.ros/rosdep" ]; then
        # Update rosdep index.
        echo "Updating rosdep index..."
        rosdep update --rosdistro $ROS_DISTRO --default-yes
    fi

    # Install rosdep dependencies.
    echo "Installing dependencies..."
    rosdep install --rosdistro $ROS_DISTRO --default-yes --ignore-packages-from-source --from-path src

    # Build the workspace.
    echo "Building packages..."
    catkin build
    if [ $? -ne 0 ]; then
        echo "Failed to build some packages."
        cd $prev_dir
        unset prev_dir
        return
    fi

    # Source the setup script.
    source devel/setup.bash

    # Load .vscode/settings.json.
    echo "Updating Visual Studio Code settings..."
    python3 $_KALMAN_WS_ROOT/scripts/configure_vscode.py

    echo "Done building packages."

    cd $prev_dir
    unset prev_dir
}

# Removes build artifacts in workspace.
clean() {
    # Remove directories.
    rm -rf $_KALMAN_WS_ROOT/build
    rm -rf $_KALMAN_WS_ROOT/devel
    rm -rf $_KALMAN_WS_ROOT/logs

    # Remove paths from $AMENT_PREFIX_PATH and $CMAKE_PREFIX_PATH.
    # AMENT_PREFIX_PATH=/opt/ros/$ROS_DISTRO
    # unset CMAKE_PREFIX_PATH
}

# Downloads non-existing repositories using VCS.
# Then pulls all repositories using Git.
pull() {
    prev_dir=$(pwd)
    cd $_KALMAN_WS_ROOT

     # Find all repositories.
    REPOS=$(find . -type d -name .git -execdir pwd \;)

    # Pull all repositories.
    for REPO in $REPOS; do
        cd $REPO
        git pull
        if [ $? -ne 0 ]; then
            echo "Failed to pull $REPO."
            cd $prev_dir
            unset prev_dir
            return
        fi
    done

    cd $prev_dir
    unset prev_dir
}

# Pushes changes in each repository.
# Will automatically commit if needed.
# Will ask for the commit message.
push() {
    prev_dir=$(pwd)
    cd $_KALMAN_WS_ROOT

    # Find all repositories.
    REPOS=$(find . -type d -name .git -execdir pwd \;)

    # Push all repositories.
    for REPO in $REPOS; do
        # Check if there are changes.
        cd $REPO
        git diff-index --quiet HEAD --
        if [ $? -ne 0 ]; then
            # Changes exist.
            echo "There are uncommitted changes in $REPO."

            # Ask for the commit message.
            echo "Commit message:"
            read COMMIT_MESSAGE

            # Ask for optional branch name (default to current branch).
            CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
            echo "Create new branch? Name (leave empty for current branch):"
            read BRANCH_NAME
            if [ ! -z "$BRANCH_NAME" ]; then
                # Try to create the branch.
                git checkout -b $BRANCH_NAME
                if [ $? -ne 0 ]; then
                    echo "Failed to create branch $BRANCH_NAME."
                    cd $prev_dir
                    unset prev_dir
                    return
                fi
            fi

            # Commit changes.
            git add .
            git commit -m "$COMMIT_MESSAGE"
            if [ $? -ne 0 ]; then
                echo "Failed to commit changes."
                cd $prev_dir
                unset prev_dir
                return
            fi
            git push --set-upstream origin $BRANCH_NAME

        fi
    done

    cd $prev_dir
    unset prev_dir
}
