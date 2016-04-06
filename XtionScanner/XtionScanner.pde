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


HoleFiller hf;
ContourSmoother sm;

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

  hf = new HoleFiller();          //Заполнятель дырок
  sm = new ContourSmoother();     //Сглаживатель контура

  cloud = hf.Fill(cloud);         //Заполняем
  SmoothContour(cloud, 50, 8, 0.3);
 //cloud = hf.Fill(cloud);

  //cloud = cloud.Smooth(20);  


  //Построение меша
  /*m = new Mesh(cloud.Width(), cloud.Height());
  m.AddLayer(cloud);
  
  sM = new Mesh(sCloud.Width(), sCloud.Height());
  sM.AddLayer(sCloud);*/
  
  
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

//Сглаживает контур
void SmoothContour(PointCloud cloud, int count, int step, float eps)
{

  /*
    Алгоритм:
    1. Сглаживаем контур
    2. Фиксим индексы, чтобы форма контура в координатах и в "форма в индексах"
       совпадали

    Вычисление координат по индексам
    x = x0 + i*dx
    y = y0 + j*dx

    Вычисление индексов новых точек
    i' = (x' - x0)/dx
    j' = (y' - y0)/dy 

    Видим, что нужны (X0, y0) (dx,dy). Их надо найти ДО(!!!)
    сглаживания контура

    Берем строку и две точки (x1, y-) (x2, y-) в начале и конце
      Y-нас не интересует, потому что в строке он изменяется мало

      Решаем систему:
      x1 = x0 + i1*dx
      x2 = x0 + i2*dx

      Решение:
      dx = (x2-x1)/(i2-i1)
      x0 = x1 - i1*dx
      

      Аналогично поступаем с Y: берем две точки по вертикали
      y1 = y0 + j1*dy
      y2 = y0 + j2*dy

      dy = (y2-y1)/(j2-j1)
      y0 = y1 - j1*dy

  */

  //Находим значения
  float x0, y0, dx, dy;
  PVector sp = cloud.GetPointFromContour(0);
  float x_min=sp.x, x_max=sp.x, y_min=sp.y, y_max=sp.y;
  //x_min=sp.x; x_max=sp.x; y_min=sp.y; y_max=sp.y;

  int i_min=0, i_max=0, j_min = 0, j_max=0;

  //Просто ищем минимальное и максимальное значение
  for(int i = 0; i<cloud.ContourSize(); i++)
  {
    PVector p = cloud.GetPointFromContour(i);
    Point2D pc = cloud.GetContourPoint(i);

    //X
    if(p.x<x_min)
    {
      x_min=p.x;
      i_min=pc.x;
    }
    else if(p.x>x_max)
    {
      x_max=p.x;
      i_max=pc.x;
    }

    //Y
    if(p.y<y_min)
    {
      y_min=p.y;
      j_min=pc.y;
    }
    else if(p.y>y_max)
    {
      y_max=p.y;
      j_max=pc.y;
    }

  }


  //Расчет


  dx=(x_max-x_min)/(i_max-i_min);
  x0=x_min - dx*i_min;

  dy=(y_max-y_min)/(j_max-j_min);
  y0=y_min - dy*j_min;

  println(x0, ' ', y0, "; ", dx, ' ',dy);

  //Сглаживаем контур
  //Копия контура
  ArrayList<PVector> copy_contour = new ArrayList<PVector>();
  for(int i = 0; i<cloud.ContourSize(); i++)
    copy_contour.add(cloud.GetPointFromContour(i).copy());


  println(count);
  for(int i = 0; i<count; i++)
   smooth_contour(copy_contour, step, eps);

  //Фиксим индексы контура
  //repairContour(cloud, copy_contour, new PVector(x0,y0), new PVector(dx, dy));
}


// Step - какая разница в индексах будет между усредняемыми точками
// Суть алгоритма: берутся две точки, координаты второй из них приравниваются среднему этих 2-ух,
// если они далеко друг от друга
void smooth_contour(List<PVector> contour, int step, float eps)
{
  PVector a, b;             // Текущая и следующая точка
  for (int i = 0; i <= contour.size(); i++)
  {
    a = get_point_cycle(contour, i);
    b = get_point_cycle(contour, i+step);

    if (PVector.dist(a, b) > eps)
    {
      b = new PVector((a.x+b.x)/2, (a.y+b.y)/2, (a.z+b.z)/2);

      //Point2D new_b_coord = cloud.GetContourPointCycle(i);
      //cloud.SetPoint(new_b_coord, b);
      set_point_cycle(contour, i, b);
    }
  }
}

//Возвращет точку, словно контур замкнут
PVector get_point_cycle(List<PVector> contour, int index)
{
  
  return contour.get(get_cycle_index(contour, index));
}

void set_point_cycle(List<PVector> contour, int index, PVector value)
{
  contour.set(get_cycle_index(contour, index),value);
}

int get_cycle_index(List<PVector> contour, int index)
{
  if (index<0)
   index=contour.size()+index;
  else if (index>=contour.size())
    index=index-contour.size();
  return index;
}

//Меняет индексы у точек контура
void repairContour(PointCloud cloud, List<PVector> contour, PVector center, PVector step)
{

  //ArrayList<Point2D> new_contour=new ArrayList<Point2D>();
  cloud.ClearContour();

  //Проходим по сглаженному контуру и генерим индексы
  for(int i=0; i<contour.size(); i++)
  { 
    /*
        Вычисление индексов новых точек
      i' = (x' - x0)/dx
      j' = (y' - y0)/dy 
    */

    PVector point = contour.get(i);
    int _i = (int)((point.x - center.x)/step.x);
    int _j = (int)((point.y - center.y)/step.y);

    cloud.SetPoint(_i, _j, point);
    cloud.AddContourPoint(_i, _j);
  }


  /*for (int i = 0; i < cloud.ContourSize(); i++)
  {
    Point2D current_indexes = cloud.GetContourPoint(i);
    PVector point = cloud.GetPoint(current_indexes);
    cloud.SetPoint(current_indexes, null);

    

    Point2D new_indexes = new Point2D();

    new_indexes.x = (int)((point.x - center.x)/step.x);
    new_indexes.y = (int)((point.y - center.y)/step.y);

    cloud.SetPoint(new_indexes, point);
    new_contour.add(new_indexes);
  }

  cloud.ClearContour();
  for(Point2D p: new_contour)
    cloud.AddContourPoint(p);*/
}

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