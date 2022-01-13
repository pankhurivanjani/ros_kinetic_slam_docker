#FROM roblabfhge/ros:kinetic
FROM tiryoh/ros-kinetic-desktop
#FROM taehogang/ros-kinetic
ENV ROS_DISTRO kinetic

USER root
RUN sudo apt-get update
RUN sudo apt-key del 421C365BD9FF1F717815A3895523BAEEB01FA116
RUN sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# install bootstrap tools 
RUN sudo apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-rosinstall-generator \
    python-wstool build-essential \
    && sudo rm -rf /vr/lib/apt/lists/*

RUN sudo apt-get install -y ros-kinetic-catkin 
# install dependencies

RUN apt-get update && apt-get install gcc g++

#Opencv 3 
#RUN sudo apt-get install  python3-dev python3-pip python3-venv
RUN wget https://github.com/opencv/opencv/archive/3.2.0.zip -O OpenCV320.zip \
    && unzip OpenCV320.zip -d OpenCV320 \
    && rm OpenCV320.zip \
    && cd OpenCV320/opencv-3.2.0 \
    #RUN git clone https://github.com/opencv/opencv.git \
    #&& cd opencv \
    #&& git checkout 3.4 \ 
    #&& git checkout v3.2.0 \
    #&& cd .. \
    #&& git clone https://github.com/opencv/opencv_contrib.git \
    #&& cd opencv_contrib \
    #&& git checkout v3.2.0 \
    #&& cd .. \
    #cd opencv \
    && mkdir build \
    && cd build \
    && cmake .. \
    #&& cmake -D CMAKE_BUILD_TYPE=RELEASE \
    #    -D CMAKE_INSTALL_PREFIX=/usr/local \
    #    -D INSTALL_C_EXAMPLES=ON \
    #    -D INSTALL_PYTHON_EXAMPLES=ON \
    #    -D WITH_TBB=ON \
    #    -D WITH_V4L=ON \
    #    -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules \
    #    -D BUILD_EXAMPLES=ON .. \

    && make -j4 \
    && sudo make install 


    
RUN sudo apt-get install -y \
    libglew-dev \
    libopencv-dev \
    libboost-dev libboost-thread-dev libboost-filesystem-dev \
    cmake   \
    libeigen3-dev \
    libblas-dev \
    liblapack-dev 
RUN sudo apt-get install libopencv-dev 
RUN sudo apt-get install ros-kinetic-opencv3
# build + install pangolin
RUN git clone https://github.com/stevenlovegrove/Pangolin.git \
    && cd Pangolin \
    && git checkout v0.5 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && cmake --build . \
    && make && \
    make install \
    && cd ../.. \
    && rm -rf Pangolin 


# build ORB_SLAM2
RUN git clone https://github.com/ayushgaud/ORB_SLAM2 \
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
#RUN mkdir catkin_ws \
RUN /bin/bash -c '. /opt/ros/kinetic/setup.bash'
RUN cd catkin_ws \
    #&& mkdir src \
    && cd src \
    && git clone https://github.com/uzh-rpg/rpg_vikit.git \
    && git clone https://github.com/uzh-rpg/rpg_svo.git \
    #&& ./opt/ros/kinetic/setup.bash \
    && sudo apt-get install  ros-kinetic-catkin python-catkin-tools  \
    && cd .. \
    #&&  /bin/bash -c  /opt/ros/kinetic/setup.sh \
    CMD catkin_make

# build REMODE
RUN git clone https://github.com/google/googletest.git \
    && cd googletest \
    && git checkout release-1.7.0 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && sudo make \
    && sudo cp *.a /usr/lib \
    && cd .. && mkdir install \
    && cp -r include install \
    && cp build/*.a install 

#ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq nvidia-cuda-toolkit
#RUN whereis cuda
RUN sudo find / -name cuda
#RUN sudo apt install -yq 
RUN sudo apt install cmake libgtest-dev
RUN cd catkin_ws \
    && sudo ln -s /usr/cuda-5.5 /usr/cuda \
    && git clone https://github.com/pankhurivanjani/rpg_open_remode.git \
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
 




