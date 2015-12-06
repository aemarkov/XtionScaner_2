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

  cloud=new PointCloud("..\\Data\\cloud.OCF"); //<>// //<>// //<>//
  sCloud = cloud.Smooth(20);


    //Setup PeasyCam (for rotation)
  PeasyCam cam = new PeasyCam(this, 200);
  cam.setMinimumDistance(0.000);
  cam.setMaximumDistance(5000);

  FindContour(sCloud);
 

  //Построение меша
  /*m = new Mesh(sCloud.Width(), sCloud.Height());
  m.AddLayer(sCloud);
  make_model(m, 3);*/
}


void make_model(Mesh m, float width)
{
  PointCloud c = m.GetLayer(0);
  PointCloud c2 = new PointCloud(m.Width(), m.Height());

  //Создаем сдинутый дубликат облака
  for(int y = 0; y<c2.Height(); y++)
  {
    for(int x = 0; x<c2.Width(); x++)
    {
      PVector p1 = c.GetPoint(x,y);
      PVector p2;
      if(p1!=null)
      {
        p2 = new PVector(p1.x, p1.y, p1.z-width);
        c2.SetPoint(x,y,p2);
      } 
    }
  }

  //Добавляем его
  m.AddLayer(c2);

  //Делаем грань
  for(int i = 0; i<c.ContourSize(); i++)
  {
    Point2D p1 = c.GetContourPointCycle(i);
    Point2D p2 = c.GetContourPointCycle(i+1);

    Point3D p_1 = new Point3D(p1.x, p1.y, 0);
    Point3D p_2 = new Point3D(p2.x, p2.y, 0);

    Point3D p_3 = new Point3D(p2.x, p2.y, 1);
    Point3D p_4 = new Point3D(p1.x, p1.y, 1);

    m.AddPolygon(p_1, p_2, p_3, p_4);
  }

}

void draw()
{
  //canea and light setup //<>//
  background(0); //<>// //<>//
  scale(3, 3, 3);
  pointLight(255, 255, 255, width/2, height/2, 400);
  pointLight(255, 255, 255, width/2, height/2, -400);

  //Отображение меша
  //noStroke();
  //m.Draw();
  
  //Отображение облака
  stroke(255);
  strokeWeight(1);
  drawCloud(sCloud);

  //Отображение контура
  stroke(0,255,0);
  drawContour(sCloud);
  
  stroke(255,0,0); 
  strokeWeight(5);
  SimpleSmooth(sCloud);
}