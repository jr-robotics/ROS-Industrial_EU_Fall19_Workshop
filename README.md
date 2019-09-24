# ROS-Industrial EU Fall’19 Workshop

### Tech Workshop on MoveIt, security & skill oriented programming with ROS
Fall edition of [ROS-Industrial EU Tech Workshop](https://rosin-project.eu/event/ros-industrial-eu-fall19-workshop) took place at Fraunhofer IPA on October 09th and 10th, 2019. The first session on the second day was hold by [JOANNEUM RESEARCH](https://www.joanneum.at/robotics/).

This repository contains all information, explanations, demo packages and docker files needed for the workshop. The first part demonstrates some insufficiencies of ROS(1) using the penetration testing tool [ROSPenTo](https://github.com/jr-robotics/ROSPenTo). The second part shows how to use the [SROS2](https://github.com/ros2/sros2) tools to setup and configure a security infrastructure for a ROS2 workspace.

To get started, check out this repository and perform the installation of the prerequisites (see below).

## Prerequisites
The following tools are used during the workshop.

### GIT
[Git](https://git-scm.com/) is a distributed version control system. In the workshop Git is used to clone already existing Git repositories from centralized repos shared by other users. Git can be downloaded [here](https://git-scm.com/downloads).

### Docker
[Docker](https://docs.docker.com/) is a platform for building, sharing and running container-based applications. In the workshop docker is used to easily setup the environment (installing ROS, building packages, executing demos).

##### Docker installation
 - [Docker for Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
 - [Docker for Windows](https://docs.docker.com/docker-for-windows/install/)

### Wireshark
[Wireshark](https://www.wireshark.org/) is a widely-used network protocol analyzer. It lets you see what’s happening on your network at a microscopic level.

## Part 1: [ROSPenTo](Part1_ROSPenTo/)
In this part of the workshop the penetration testing tool [ROSPenTo](Part1_ROSPenTo/) is introduced and its capabilities are demonstrated in an example ROS network.

## Part 2: [SROS2](Part2_SROS2/)
In this part of the workshop a ROS2 network is set up and secured with the help of the [SROS2](Part2_SROS2/) tools.

