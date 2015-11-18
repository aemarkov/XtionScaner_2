PointCloud cloud;  //point cloud

void setup()
{
  //General setup
  size(800,800, P3D);
  
  
  stroke(255);
  noFill();
 
  cloud=Load("..\\Data\\cloud.proc");
 
  //Draw
  ortho(-width/20, width/20, -height/20, height/20);
  camera(width/2.0+50, height/2.0-100,120, 
         width/2.0+50, height/2.0-100, 0, 
         0, 1, 0);
  
  beginShape();
  background(0);
  
  translate(width/2, height/2, 0);
  rotateZ(PI);
  drawCloud(cloud);
  FindContour(cloud);
  drawContour(cloud);
  //AdvanceSmooth(cloud, contour);
  endShape();
}