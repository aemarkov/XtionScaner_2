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

boolean draw_cloud = true;
boolean draw_contour = false;
boolean draw_mesh = false;


void setup()
{
  //General setup
  size(800, 800, P3D);
  background(0);

  //Настройки камеры
  cam = new PeasyCam(this, 800);
  cam.setMinimumDistance(0.000);
  cam.setMaximumDistance(5000);

  //Получем облака
  OCFReader cloud_reader = new OCFReader();
  cloud=cloud_reader.OpenCloud("..\\Data\\cloud.OCF");
  FindContour(cloud);

  CloudClearer cc = new CloudClearer();           //Обрезатель контура
  HoleFiller hf = new HoleFiller();               //Заполнятель дырок
  ContourSmoother sm = new ContourSmoother();     //Сглаживатель контура

  //cloud = cc.CutCloud(cloud);
  //cloud = hf.Fill(cloud);                     //Заполняем
  //sm.SmoothContour(cloud, 10, 8, 0.3);        //Сглаживаем контур
  //cloud = cc.CutCloud(cloud);
  //cloud = hf.Fill(cloud);                     //Заполняем
  //

  //cloud = hf.Fill(cloud); 

  cloud = cloud.Smooth(20);  


  //Построение меша
  m = new Mesh(cloud.Width(), cloud.Height());
  m.AddLayer(cloud);
  
  
  //Создание кнопок
  cp5 = new ControlP5(this);
  cp5.addToggle("DrawCloud") 
     .setPosition(10,10)
     .setSize(50,20)
     .setValue(true)
     .setMode(ControlP5.SWITCH);
     
   cp5.addToggle("DrawContour")
     .setPosition(10,50)
     .setSize(50,20)
     .setValue(false)
     .setMode(ControlP5.SWITCH);
   
   cp5.addToggle("DrawMesh")
     .setPosition(10,90)
     .setSize(50,20)
     .setValue(false)
     .setMode(ControlP5.SWITCH);
     
     
  cp5.setAutoDraw(false);
  
  //make_model(sM, 3);
}


//////////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////////////////////

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

    m.AddPolygon(p_1, p_2, p_3, p_4); //<>// //<>//
  } //<>// //<>//

}

void draw()
{
  //canea and light setup //<>// //<>//
  background(0); //<>// //<>//
  pushMatrix();
  
  scale(3, 3, 3);
  pointLight(255, 255, 255, width/2, height/2, 400);
  pointLight(255, 255, 255, width/2, height/2, -400);

  //Отображение облака
  if(draw_cloud)
  {
    stroke(255, 100, 100);
    strokeWeight(1);
    drawCloud(cloud);
    stroke(0,255,0);
  }
  
  
  //Отображение контура
  if(draw_contour)
  {
    stroke(0,255,0);
    strokeWeight(0.1);
    drawContour(cloud);
  }
  
  
  if(draw_mesh)
  {
     //Отображение меша
      noStroke();
      m.Draw();
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

void DrawCloud(boolean theFlag)
{
  draw_cloud=theFlag;
}


void DrawContour(boolean theFlag)
{
  draw_contour=theFlag;
}


void DrawMesh(boolean theFlag)
{
  draw_mesh=theFlag;
}