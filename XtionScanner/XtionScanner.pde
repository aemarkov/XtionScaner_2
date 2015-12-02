import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;
import peasy.test.*;

PointCloud cloud;  //point cloud
PointCloud sCloud;
Mesh m;

void setup()
{
  //General setup
  size(800, 800, P3D);

  cloud=new PointCloud("..\\Data\\cloud.OCF"); //<>//
  sCloud = cloud.Smooth(20);

  //Setup PeasyCam (for rotation)
  PeasyCam cam = new PeasyCam(this, 200);
  cam.setMinimumDistance(0.000);
  cam.setMaximumDistance(5000);

  println(cloud.Width()*cloud.Height());
  println(sCloud.Width()*sCloud.Height());

  FindContour(sCloud);
  m = new Mesh(sCloud.Width(), sCloud.Height());
  m.AddLayer(sCloud);
  noStroke();
}

void draw()
{
  background(0); //<>//
  scale(3, 3, 3);
  pointLight(255, 255, 255, width/2, height/2, 400);
  pointLight(255, 255, 255, width/2, height/2, -400);
  noStroke();
  m.Draw();
  stroke(255, 0, 0);
  drawContour(sCloud);
}