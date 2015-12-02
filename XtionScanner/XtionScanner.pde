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
  println(cloud.Width(), cloud.Height());  


  sCloud = new PointCloud(cloud.Width(), cloud.Height());

  //Сглаживание
  int size = 20;
  for (int y = 0; y<cloud.Height(); y++)
  {
    for (int x = 0; x<cloud.Width(); x++)
    {
      PVector v;
      v=cloud.GetPoint(x, y);
      if (v!=null)
      {

        int n = 0;
        PVector sum = new PVector();

        for (int x1=max(0, x-size/2); x1<min(cloud.Width(), x+size/2); x1++)
        {
          for (int y1 = max(0, y-size/2); y1<min(cloud.Height(), y+size/2); y1++)
          {
            v = cloud.GetPoint(x1, y1);
            if (v!=null)
            {
              sum.add(v);
              n++;
            }
          }
        }


        if ((sum.x!=Double.NaN)&&(sum.y!=Double.NaN)&&(sum.z!=Double.NaN))
        {
          sum.div(n);
          sCloud.SetPoint(x, y, sum);
        }
      }
    }
  }

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