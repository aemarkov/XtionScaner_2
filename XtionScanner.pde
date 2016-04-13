import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;
import peasy.test.*;
import controlP5.*;
import processing.opengl.*;

PointCloud cloud;  //point cloud

PointCloud sCloud; //smooth point cloud
Mesh m;            //mesh
Mesh sM;           //smooth mesh

ControlP5 cp5;
PeasyCam cam;

boolean defaultCloud = true;
boolean smoothCloud = false;

boolean defaultContour = false;
boolean smoothContour = false;

boolean defaultMesh = false;
boolean smoothMesh = false;


HoleFiller hf;

void setup()
{
  //General setup
  size(1024, 768, P3D);
  background(0);

  //Настройки камеры
  cam = new PeasyCam(this, 800);
  cam.setMinimumDistance(0.000);
  cam.setMaximumDistance(5000);

  //Получем облака
  cloud=new PointCloud("cloud.OCF");
  FindContour(cloud);

  hf = new HoleFiller();
  cloud = hf.Fill(cloud);

  sCloud = cloud.Smooth(20); 
  FindContour(sCloud);


  //testHoleFiller();

  //Построение меша
  m = new Mesh(cloud.Width(), cloud.Height());
  m.AddLayer(cloud);
  
  sM = new Mesh(sCloud.Width(), sCloud.Height());
  sM.AddLayer(sCloud);
  
  
  //Создание кнопок
  cp5 = new ControlP5(this);
  cp5.addToggle("DefaultCloud")
     .setPosition(10,10)
     .setSize(50,20)
     .setValue(true)
     .setMode(ControlP5.SWITCH);
     
   cp5.addToggle("SmoothCloud")
     .setPosition(10,50)
     .setSize(50,20)
     .setValue(false)
     .setMode(ControlP5.SWITCH);
   
   cp5.addToggle("DefaultContour")
     .setPosition(10,90)
     .setSize(50,20)
     .setValue(false)
     .setMode(ControlP5.SWITCH);
     
   cp5.addToggle("SmoothContour")
     .setPosition(10,130)
     .setSize(50,20)
     .setValue(false)
     .setMode(ControlP5.SWITCH);
     
   cp5.addToggle("DefaultMesh")
     .setPosition(10,170)
     .setSize(50,20)
     .setValue(false)
     .setMode(ControlP5.SWITCH);
     
   cp5.addToggle("SmoothMesh")
     .setPosition(10,210)
     .setSize(50,20)
     .setValue(false)
     .setMode(ControlP5.SWITCH);
     
     
  cp5.setAutoDraw(false);
  
  make_model(sM, 3);
  experiments(cloud);
}

void experiments(PointCloud cloud)
{
  //// Print cloud and indexes to file
  //PrintWriter writer;
  //try 
  //{
  //  writer = new PrintWriter("/home/aleksey/Documents/XtionScanner/points.txt");
  //  for (int row = 0; row < cloud.Height(); row++)
  //    for (int col = 0; col < cloud.Width(); col++)
  //    {
  //      PVector point = cloud.GetPoint(col, row);
  //      if (point != null)
  //        writer.println("r:" + row + " c:" + col + " coordinates: " + point.x + " " + point.y + " " + point.z);
  //    }

  //  writer.close();
  //} catch (FileNotFoundException fnfe){
  //  System.out.println(fnfe);
  //}
  
  // Smooth cloud
  for (int i = 0; i < 50; i++)
  smoothContour(cloud, 8, 0.3);
}

// Step - какая разница в индексах будет между усредняемыми точками
// Суть алгоритма: берутся две точки, координаты второй из них приравниваются среднему этих 2-ух,
// если они далеко друг от друга
void smoothContour(PointCloud cloud, int step, float eps)
{
  PVector a, b; // current and next points
  Point2D a_coord, b_coord; // indexes of a and b
  for (int i = 0; i <= cloud.ContourSize(); i++)
  {
    a_coord = cloud.GetContourPointCycle(i);
    b_coord = cloud.GetContourPointCycle(i + step);
    a = cloud.GetPoint(a_coord);
    b = cloud.GetPoint(b_coord);
    if (PVector.dist(a, b) > eps)
    {
      b = new PVector((a.x+b.x)/2, (a.y+b.y)/2, (a.z+b.z)/2);
      Point2D new_b_coord = cloud.GetContourPointCycle(i);
      cloud.SetPoint(new_b_coord, b);
    }
  }
}

void repairContour(PointCloud cloud)
{
  // Find min and max x and y points with coordinates
  // TODO
  // Find dx and dy
  // TODO
  
  ArrayList<Point2D> new_contour;
  // Т.к. все точки в контуре облака уже сглажены, просто проходимся по его контуру
  Point2D new_indexes = new Point2D();
  for (int i = 0; i < cloud.ContourSize(); i++)
  {
    Point2D current_indexes = cloud.GetContourPoint(i);
    PVector point = cloud.GetPoint(current_indexes);
    cloud.SetPoint(current_indexes, null);

    new_indexes.x = 111; // TODO
    new_indexes.y = 111; // TODO
    cloud.SetPoint(new_indexes, point);
    new_contour.add(point);
  }
}


void make_model(Mesh m, float width)
{
  PointCloud c = m.GetLayer(0);
  PointCloud c2 = new PointCloud(m.Width(), m.Height());

  //Создаем сдинутый дубликат облака
  for(int y = 0; y<c2.Height(); y++)
  {
    for(int x = 0; x<c2.Width(); x++)
    { //<>//
      PVector p1 = c.GetPoint(x,y); //<>//
      PVector p2;
      if(p1!=null) //<>//
      { //<>// //<>//
        p2 = new PVector(p1.x, p1.y, p1.z-width); //<>// //<>// //<>//
        c2.SetPoint(x,y,p2); //<>// //<>//
      } //<>//
    } //<>//
  } //<>//
 //<>// //<>//
  //Добавляем его //<>// //<>//
  m.AddLayer(c2); //<>// //<>// //<>//
 //<>// //<>//
  //Делаем грань
  for(int i = 0; i<c.ContourSize(); i++)
  { //<>//
    Point2D p1 = c.GetContourPointCycle(i); //<>//
    Point2D p2 = c.GetContourPointCycle(i+1);

    Point3D p_1 = new Point3D(p1.x, p1.y, 0);
    Point3D p_2 = new Point3D(p2.x, p2.y, 0);

    Point3D p_3 = new Point3D(p2.x, p2.y, 1);
    Point3D p_4 = new Point3D(p1.x, p1.y, 1);

    m.AddPolygon(p_1, p_2, p_3, p_4); //<>//
  } //<>//

}

void draw()
{
  //canea and light setup //<>//
  background(0); //<>//
  pushMatrix();
  
  scale(3, 3, 3);
  pointLight(255, 255, 255, width/2, height/2, 400);
  pointLight(255, 255, 255, width/2, height/2, -400);

  //Отображение облака
  if(defaultCloud)
  {
    stroke(255, 100, 100);
    strokeWeight(1);
    drawCloud(cloud);
    //hf.Fill(cloud);
  }
  
  if(smoothCloud)
  {
    stroke(100, 255, 100);
    strokeWeight(1);
    drawCloud(sCloud);
  }
  

  //Отображение контура
  if(defaultContour)
  {
    stroke(255,0,0);
    //strokeWeight(5);
    drawContour(cloud);
  }
  
  if(smoothContour)
  {
    stroke(0,255,0);
//strokeWeight(5);
    drawContour(sCloud);
  }
  
  if(defaultMesh)
  {
     //Отображение меша
      noStroke();
      m.Draw();
  }
  
  if(smoothMesh)
  {
     //Отображение меша
      noStroke();
      sM.Draw();
  }
  
  popMatrix();
  gui();
}

void gui() {
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  cp5.draw();
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

void DefaultCloud(boolean theFlag)
{
  defaultCloud=theFlag;
}

void SmoothCloud(boolean theFlag)
{
  smoothCloud=theFlag;
}

void DefaultContour(boolean theFlag)
{
  defaultContour=theFlag;
}

void SmoothContour(boolean theFlag)
{
  smoothContour=theFlag;
}

void DefaultMesh(boolean theFlag)
{
  defaultMesh=theFlag;
}

void SmoothMesh(boolean theFlag)
{
  smoothMesh=theFlag;
}