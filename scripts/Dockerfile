# Installs ROS: Noetic (Desktop, Full) in an Ubuntu 20.04 container.
# http://wiki.ros.org/noetic/Installation/Ubuntu

# ROS: Noetic requires Ubuntu Focal.
FROM ubuntu:focal

# Update repositories.
RUN apt-get update

# Set locale to UTF-8 compatible.
RUN apt-get install -y locales
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
RUN export LANG=en_US.UTF-8

# Enable universe repository.
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y universe
RUN apt-get update

# Install the ROS 2 GPG key.
RUN apt-get install -y curl
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

# Add the ROS repository.
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-get update

# Install ROS.
RUN apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata keyboard-configuration
RUN apt-get install -y ros-noetic-desktop-full

# Install development tools and ROS tools (as shown on ROS Wiki).
RUN apt-get install -y python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential

# Install additional dependencies.
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y python3-catkin-tools libignition-gazebo5-dev libignition-math4-dev ros-noetic-moveit ros-noetic-moveit-servo spacenavd python3-pip nodejs npm ros-noetic-rtabmap-ros

# Python deps
RUN pip install transitions==0.8.10 utm==0.7.0 shyaml==0.6.2 graphviz==0.19.1 uvicorn==0.15.0 fastapi>=0.70.0 websockets>=11.0.3

# Initialize rosdep.
RUN rosdep init --rosdistro noetic --as-root "apt:no pip:no"

# Clean up caches.
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /tmp/*
