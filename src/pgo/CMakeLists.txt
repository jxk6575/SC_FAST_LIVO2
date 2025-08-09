cmake_minimum_required(VERSION 3.0.2)
project(pgo CXX)

# 调试期推荐 Debug + ASan（更容易定位内存越界/双重释放）
set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 依赖
find_package(catkin REQUIRED COMPONENTS
  roscpp
  sensor_msgs
  nav_msgs
  geometry_msgs
  visualization_msgs
  tf
  pcl_ros
  pcl_conversions
)
find_package(Eigen3 REQUIRED)
find_package(OpenCV REQUIRED)
find_package(PCL REQUIRED)
find_package(GTSAM REQUIRED)  # 可能只导出 gtsam 或 GTSAM::gtsam，下面会做兼容

# 导出给其他包（本包没有消息可留空）
catkin_package(
  CATKIN_DEPENDS roscpp std_msgs sensor_msgs nav_msgs geometry_msgs visualization_msgs tf pcl_ros pcl_conversions
)

# 头文件目录（只用各包提供的变量，避免手写路径导致 ABI 混淆）
include_directories(
  include
  ${catkin_INCLUDE_DIRS}
  ${OpenCV_INCLUDE_DIRS}
  ${PCL_INCLUDE_DIRS}
  ${EIGEN3_INCLUDE_DIRS}
  ${GTSAM_INCLUDE_DIRS}
  ${GTSAM_INCLUDE_DIR}      # 某些旧版本只提供这个变量
)

# 可执行文件
add_executable(alaserPGO
  src/laserPosegraphOptimization.cpp
  include/scancontext/Scancontext.cpp
)

# 确保生成顺序（即使没消息也安全）
add_dependencies(alaserPGO ${${PROJECT_NAME}_EXPORTED_TARGETS} ${catkin_EXPORTED_TARGETS})

# 调试期开启 AddressSanitizer（注意不要再叠加 -O3/-march，定位问题更稳）
target_compile_options(alaserPGO PRIVATE -fsanitize=address -fno-omit-frame-pointer -O1 -g)
target_link_options(alaserPGO PRIVATE -fsanitize=address)

# ---- GTSAM 目标兼容处理：优先用 GTSAM::gtsam，没有就回退 ----
if (TARGET GTSAM::gtsam)
  set(GTSAM_TARGET GTSAM::gtsam)
elseif (TARGET gtsam)
  set(GTSAM_TARGET gtsam)
elseif (GTSAM_LIBRARIES)
  set(GTSAM_TARGET ${GTSAM_LIBRARIES})
else()
  message(FATAL_ERROR "Found GTSAM but no usable CMake target or library variable")
endif()

# 链接库（不要手动再加 tbb/pthread，交给 GTSAM/包本身处理）
target_link_libraries(alaserPGO
  ${GTSAM_TARGET}
  ${catkin_LIBRARIES}
  ${OpenCV_LIBS}
  ${PCL_LIBRARIES}
)

# ---- 若定位完问题，改为发布构建，可用下列配置替换上面的 ASan 选项 ----
# set(CMAKE_BUILD_TYPE Release)
# target_compile_options(alaserPGO PRIVATE -O3 -march=native)
