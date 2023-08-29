# Configure auto-complete, code analysis and terminal for VS Code.

import os, shutil, json, glob

ws_dir = os.path.normpath(os.path.dirname(__file__) + "/..")
config_path = os.path.join(ws_dir, ".vscode/settings.json")
dist_dir = os.path.expanduser("~/.vscode-ros2-dist-packages")

# If needed, copy ROS dist-packages to ~ for auto-complete on the host.
shutil.copytree(glob.glob("/opt/ros/*/lib/python*/dist-packages")[0], dist_dir, dirs_exist_ok=True)

# Load the configuration file.
if os.path.isfile(config_path):
    with open(config_path) as f:
        config = json.load(f)
else:
    config = {}

# Add terminal profile.
running_distrobox = "DISTROBOX_HOST_HOME" in os.environ
if running_distrobox:
    config["terminal.integrated.profiles.linux"] = {
        "kalman-ros1": {
            "path": f"{ws_dir}/scripts/distrobox"
        }
    }
else:
    config["terminal.integrated.profiles.linux"] = {
        "kalman-ros1": {
            "path": f"/usr/bin/bash --rcfile {ws_dir}/scripts/.bashrc"
        }
    }
config["terminal.integrated.defaultProfile.linux"] = "kalman-ros1"

# Reset paths.
config["python.autoComplete.extraPaths"] = [dist_dir]

# Find the install directory.
devel_dir = os.path.join(ws_dir, "devel")
if os.path.isdir(devel_dir):
    # Add package path to the configuration.
    for site_packages_dir in glob.glob(os.path.join(devel_dir, "lib", "python*", "dist-packages")):
        config["python.autoComplete.extraPaths"].append(site_packages_dir)

# Sort the paths.
config["python.autoComplete.extraPaths"].sort()

# Replicate auto-complete paths for analysis.
config["python.analysis.extraPaths"] = config["python.autoComplete.extraPaths"]

# Save the configuration file.
os.makedirs(os.path.dirname(config_path), exist_ok=True)
with open(config_path, "w") as f:
    json.dump(config, f, indent=4)
