FROM ros:dashing

MAINTAINER Sebastian Taurer <sebastian.taurer@joanneum.at>

WORKDIR /root/ros2_example_ws

# Pre-install tools
RUN apt-get update && apt-get install -y \
    && apt-get install -y nano \
    && apt-get install -y openssh-server \
    && apt-get install -y libssl-dev \
    && apt-get install -y ros-dashing-sros2

# Setup ROS2 examples
RUN git clone -b dashing https://github.com/ros2/examples src/examples \
    && rm -r src/examples/rclcpp/ \
    && /bin/bash -c "source /opt/ros/dashing/setup.bash && colcon build --symlink-install"

# Source environment
RUN echo "source /opt/ros/dashing/setup.bash" >> ~/.bashrc \
    && echo "source /root/ros2_example_ws/install/setup.bash" >> ~/.bashrc

# SSH setup
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Set new password 'root' for user 'root'
RUN /bin/bash -c "echo -e 'root\nroot' | passwd root"

# Copy files
COPY ./my_entrypoint.sh /
COPY ./policy.xml /root/
COPY ./request.cnf /root/

# Setup entrypoint
RUN ["chmod", "+x", "/my_entrypoint.sh"]
ENTRYPOINT ["/my_entrypoint.sh"]

CMD ["bash"]
