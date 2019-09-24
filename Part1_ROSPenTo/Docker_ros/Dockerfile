FROM ros:melodic

MAINTAINER Sebastian Taurer <sebastian.taurer@joanneum.at>

WORKDIR /root/catkin_ws

# Setup ROS examples
RUN git clone -b melodic-devel https://github.com/ros/ros_tutorials.git src/ros_tutorials
RUN rm -r src/ros_tutorials/turtlesim/
RUN /bin/bash -c "source /opt/ros/melodic/setup.bash && catkin_make"

# Source environment
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc \
    && echo "source /root/catkin_ws/devel/setup.bash" >> ~/.bashrc

CMD ["bash"]
