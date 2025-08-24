#include "LIVMapper.h"

int main(int argc, char **argv)
{
  ros::init(argc, argv, "laserMapping");
  ros::NodeHandle nh;
  ros::Publisher pub_map;  // 添加这行声明
  pub_map = nh.advertise<sensor_msgs::PointCloud2>("global_map", 1);
  float mapviz_filter_size;  // 添加这行声明
  nh.param("mapviz_filter_size", mapviz_filter_size, 0.1f);
  image_transport::ImageTransport it(nh);
  LIVMapper mapper(nh); 
  mapper.initializeSubscribersAndPublishers(nh, it);
  mapper.run();
  return 0;
}