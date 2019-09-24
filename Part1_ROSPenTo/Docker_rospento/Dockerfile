FROM ubuntu:bionic

MAINTAINER Sebastian Taurer <sebastian.taurer@joanneum.at>

WORKDIR /root/

# Pre-install tools
RUN apt-get update && apt-get install -y \
    && apt-get install -y git

# Install mono
RUN apt install -y gnupg ca-certificates
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list
RUN apt-get update && apt-get -y install mono-devel

# Install nuget
RUN apt-get install -y nuget

# Setup ROSPenTo
RUN git clone https://github.com/jr-robotics/ROSPenTo.git
RUN cd ROSPenTo && nuget restore && msbuild

# Create an alias for ROSPenTo and rospento
RUN echo 'alias ROSPenTo="mono /root/ROSPenTo/RosPenToConsole/bin/Debug/RosPenToConsole.exe"' >> /root/.bashrc
RUN echo 'alias rospento="mono /root/ROSPenTo/RosPenToConsole/bin/Debug/RosPenToConsole.exe"' >> /root/.bashrc

CMD ["bash"]
