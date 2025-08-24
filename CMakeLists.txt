cmake_minimum_required(VERSION 3.0.2)
project(fast_livo)

set(CMAKE_BUILD_TYPE Release)
set(CMAKE_CXX_STANDARD 17)

# Define ROOT_DIR
add_definitions(-DROOT_DIR="${CMAKE_CURRENT_SOURCE_DIR}/")

# ----------------------- catkin & deps -----------------------
find_package(catkin REQUIRED COMPONENTS
  roscpp
  sensor_msgs
  std_msgs
  tf
  tf2
  tf2_ros
  image_transport
  cv_bridge
  pcl_ros
  vikit_common 
  vikit_ros
)

find_package(Eigen3 REQUIRED)
find_package(PCL REQUIRED)
find_package(OpenCV REQUIRED)
find_package(Boost REQUIRED COMPONENTS thread)

# OpenMP
find_package(OpenMP)
if(OpenMP_CXX_FOUND)
  add_compile_options(${OpenMP_CXX_FLAGS})
  add_definitions(-DOMP_EN)
endif()

# 导出给下游（本包也用得到）
catkin_package(
  CATKIN_DEPENDS roscpp sensor_msgs std_msgs tf tf2 tf2_ros image_transport cv_bridge pcl_ros
  vikit_common vikit_ros
  DEPENDS PCL OpenCV Boost
  INCLUDE_DIRS include
)

# 包含路径（关键：${catkin_INCLUDE_DIRS}）
include_directories(
  include
  ${catkin_INCLUDE_DIRS}
  ${EIGEN3_INCLUDE_DIRS}
  ${PCL_INCLUDE_DIRS}
  ${OpenCV_INCLUDE_DIRS}
  /usr/local/include
)

# ----------------------- 库与可执行文件 -----------------------
add_library(vio          src/vio.cpp src/frame.cpp src/visual_point.cpp)
add_library(lio          src/voxel_map.cpp)
add_library(pre          src/preprocess.cpp)
add_library(imu_proc     src/IMU_Processing.cpp)
add_library(laser_mapping src/LIVMapper.cpp)

# 让消息/生成目标的依赖顺序正确
add_dependencies(vio           ${catkin_EXPORTED_TARGETS})
add_dependencies(lio           ${catkin_EXPORTED_TARGETS})
add_dependencies(pre           ${catkin_EXPORTED_TARGETS})
add_dependencies(imu_proc      ${catkin_EXPORTED_TARGETS})
add_dependencies(laser_mapping ${catkin_EXPORTED_TARGETS})

add_executable(fastlivo_mapping src/main.cpp)

# 链接（关键：用 ${catkin_LIBRARIES}，别硬编码 ROS 路径）
target_link_libraries(fastlivo_mapping
  laser_mapping
  vio
  lio
  pre
  imu_proc
  ${catkin_LIBRARIES}
  ${PCL_LIBRARIES}
  ${OpenCV_LIBRARIES}
  ${Boost_LIBRARIES}
)

# OpenMP 链接
if(OpenMP_CXX_FOUND)
  target_link_libraries(fastlivo_mapping OpenMP::OpenMP_CXX)
endif()
