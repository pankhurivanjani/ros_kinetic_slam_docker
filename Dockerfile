FROM roblabfhge/ros:kinetic

ENV ROS_DISTRO kinetic

RUN mkdir workspace
WORKDIR /workspace

# install bootstrap tools 
RUN apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-rosinstall-generator \
    python-wstool build-essential \
    && rm -rf /vr/lib/apt/lists/*

# install dependencies

RUN apt-get update && apt-get install gcc g++

RUN sudo apt-get install -y \
    libglew-dev \
    libopencv-dev \
    libboost-dev libboost-thread-dev libboost-filesystem-dev \
    cmake   \
    libeigen3-dev \
    libblas-dev \
    liblapack-dev \


# build + install pangolin
RUN git clone https://github.com/stevenlovegrove/Pangolin.git  
    && cd Pangolin \
    && git checkout v0.5 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && cmake --build . \
    && make && \
    make install \
    && cd ../.. \
    && rm -rf Pangolin \


# build ORB_SLAM2
RUN cd /home/container \
    && git clone https://github.com/ayushgaud/ORB_SLAM2 \
    && cd ORB_SLAM2 \
    && chmod +x build.sh \
    && ./build.sh 

# build rpg-SVO and REMODE

#Install dependencies

# build + install Sophus
RUN git clone https://github.com/strasdat/Sophus.git \
    && cd Sophus \
    && git checkout a621ff \
    && mkdir build \
    && cd build \
    && cmake .. \
    && cmake --build . \
    && make \
    && sudo make install 

# build + install FAST
RUN git clone https://github.com/uzh-rpg/fast.git \
    && cd fast \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make \
    && sudo make install 

# build + install g20
RUN wget https://github.com/RainerKuemmerle/g2o/archive/20160424_git.tar.gz -O g2o-20160424_git.tar.gz \
    && tar  xvzf g2o-20160424_git.tar.gz \
    && cd g2o-20160424_git \
    && mkdir build \
    && cd build \
    && cmake .. \
    && cmake --build . \
    && make \
    && sudo make install 

#vikit, SVO
RUN mkdir catkin_ws \
    && cd catkin_ws \
    && mkdir src \
    && cd src \
    && git clone https://github.com/uzh-rpg/rpg_vikit.git \
    && git clone git clone https://github.com/uzh-rpg/rpg_svo.git \
    && cd ..  && catkin_make 

# build REMODE
RUN git clone https://github.com/google/googletest.git \
    && cd googletest \
    && git checkout release-1.7.0 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make \
    && cd .. && mkdir install \
    && cp -r include install \
    && cp build/*.a install 

RUN cd catkin_ws \
    && git clone https://github.com/uzh-rpg/rpg_open_remode.git \
    && cd rpg_open_remode \
    && mkdir build && cd build \
    && cmake -DGTEST_ROOT=$catkin_ws/googletest/install -DBUILD_ROS_NODE=OFF .. \
    && make

# build ORB_SLAM2 ros package
RUN /bin/bash -c "cd /home/container/ORB_SLAM2 && source /opt/ros/kinetic/setup.bash && export ROS_PACKAGE_PATH=/opt/ros/kinetic/share:/home/container/ORB_SLAM2/Examples/ROS && env && rosdep update && ./build_ros.sh"

# add entrypoint
#COPY files/entrypoint.sh /usr/local/bin/entrypoint.sh

#ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

#CMD ["/bin/bash"]

##################################################################
 




