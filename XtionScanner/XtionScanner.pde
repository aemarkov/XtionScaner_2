import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;
import peasy.test.*;

PointCloud cloud;  //point cloud
MeshLayer m;

void setup()
{
  //General setup
  size(800, 800, P3D);

  cloud=Load("..\\Data\\cloud.proc");

  //Draw
  /*ortho(-width/20, width/20, -height/20, height/20);
  camera(width/2.0+50, height/2.0-100,200, 
   width/2.0+50, height/2.0-100, 0, 
   0, 1, 0);*/

  //Setup PeasyCam (for rotation)
  PeasyCam cam = new PeasyCam(this, 200);
  cam.setMinimumDistance(0.000);
  cam.setMaximumDistance(5000);

  //translate(width/2, height/2, 0);
  ///rotateZ(PI);
  //drawCloud(cloud);
  FindContour(cloud);
  m = new MeshLayer(cloud); 
  m.Draw();
  //stroke(100,100,100);
  noStroke();
}

void draw()
{
  background(0);
  //noStroke();
  scale(3,3,3);
  box(50);
 
  pointLight(255, 255, 255, width/2, height/2, 400);
  pointLight(255, 255, 255, width/2, height/2, -400);
  m.Draw();
}