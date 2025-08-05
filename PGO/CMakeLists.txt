cmake_minimum_required(VERSION 3.0.2)
project(fastlivo2_pgo)

# 设置C++标准
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 查找必要的包
find_package(PkgConfig REQUIRED)
find_package(Eigen3 REQUIRED)
find_package(OpenCV REQUIRED)
find_package(PCL REQUIRED)

# 手动设置ROS相关的包含目录和库
set(ROS_INCLUDE_DIRS
    /opt/ros/melodic/include
    /opt/ros/melodic/include/nav_msgs
    /opt/ros/melodic/include/geometry_msgs
    /opt/ros/melodic/include/sensor_msgs
    /opt/ros/melodic/include/visualization_msgs
    /opt/ros/melodic/include/tf
    /opt/ros/melodic/include/std_msgs
    /opt/ros/melodic/include/pcl_ros
    /opt/ros/melodic/include/pcl_conversions
)

# 使用pkg-config查找ROS库
execute_process(
    COMMAND pkg-config --libs roscpp nav_msgs geometry_msgs sensor_msgs visualization_msgs tf std_msgs pcl_ros pcl_conversions
    OUTPUT_VARIABLE ROS_LIBRARIES
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# 查找GTSAM
find_package(GTSAM REQUIRED)

# 包含目录
include_directories(
    include
    ${EIGEN3_INCLUDE_DIR}
    ${OpenCV_INCLUDE_DIRS}
    ${PCL_INCLUDE_DIRS}
    ${ROS_INCLUDE_DIRS}
    ${GTSAM_INCLUDE_DIRS}
)

# 编译PGO文件，包含ScanContext
add_executable(alaserPGO
    src/laserPosegraphOptimization.cpp
    include/scancontext/Scancontext.cpp
)

# 链接库 - 修正GTSAM链接
target_link_libraries(alaserPGO
    ${OpenCV_LIBS}
    ${PCL_LIBRARIES}
    ${ROS_LIBRARIES}
    gtsam
    tbb
    pthread
)

# 编译选项
target_compile_options(alaserPGO PRIVATE -O3 -march=native)
