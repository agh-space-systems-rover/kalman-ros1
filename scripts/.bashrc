# This Bash source script configures Kalman workspace on login.
# It should work both in Distrobox and in a standalone system.

# Source the real .bashrc. This way this script ca be used directly when launching Bash.
source $HOME/.bashrc

# Check if started inside of Distrobox and find workspace root accordingly.
if [ ! -z "$DISTROBOX_WS_ROOT_TEMP_VAR_LATER_REMOVED_BY_BASHRC" ]; then
    # Ensure that host-spawn is properly installed.
    distrobox-host-exec --yes cat /dev/null

    # Fix file descriptor limits in Docker.
    # This fixes rosout memory leaks.
    ulimit -Sn 524288
    ulimit -Hn 524288

    # Fix-up SHELL variable passed from the host.
    export SHELL=/usr/bin/bash

    # Extract the workspace root from the marker variable.
    _KALMAN_WS_ROOT=$DISTROBOX_WS_ROOT_TEMP_VAR_LATER_REMOVED_BY_BASHRC
    unset DISTROBOX_WS_ROOT_TEMP_VAR_LATER_REMOVED_BY_BASHRC

    # Run npm install if kalman_groundstation/web/node_modules does not exist.
    # (This should be handled by the package itself.)
    if [ ! -d "$_KALMAN_WS_ROOT/src/kalman_groundstation/web/node_modules" ]; then
        prev_dir=$(pwd)
        cd "$_KALMAN_WS_ROOT/src/kalman_groundstation/web/"
        npm install
        cd $prev_dir
        unset prev_dir
    fi
else
    _KALMAN_WS_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fi

# Source the ROS setup script on each activation.
source /opt/ros/noetic/setup.bash

# Source the development workspace setup script if available.
if [ -f "$_KALMAN_WS_ROOT/devel/setup.bash" ]; then
    source $_KALMAN_WS_ROOT/devel/setup.bash
fi

# Include Kalman macros.
source $_KALMAN_WS_ROOT/scripts/macros.bash
source $_KALMAN_WS_ROOT/scripts/kalm.bash
