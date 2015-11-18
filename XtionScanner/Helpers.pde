/*-------------------------------------------------------
 *               ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
 *-----------------------------------------------------*/

//Проверяет, что координаты в стркоовом представлении являются NaN
boolean isNan(String[] coords)
{
  if(coords.length!=3)return true;
  return coords[0].equals("nan") && coords[1].equals("nan") && coords[2].equals("nan");    
}

//Отображает облако точек
void drawCloud(PVector[][] cloud)
{
  for(int y = 0; y<cloud.length; y++)
  {
    for(int x=0; x<cloud[y].length; x++)
    {
      PVector p = cloud[y][x];
      if(p!=null)
        point(p.x, p.y, p.z);
    }
  }
}

//Рисует точку ПО ИНДЕКСУ
//т.е рисует точку массива
//ВНИМАНЕ. ВРЕМЕННЫЙ МЕТОД - ЧИСЛА ПОДОБРАНЫ
void drawPoint(int x, int y)
{
  //point(x*5-1300, y*5-400);
  //point(x*3-600, y*3-300);
  point(x*3-600, y*3-300, 0);
}

//Рисует точку ПО ИНДЕКСУ
//(все аналогично)
void drawPoint(Point2D p)
{
  drawPoint(p.x, p.y);
}

//РИСУЕТ КОНТУР
void drawContour(PVector[][] cloud, ArrayList<Point2D> contour)
{
  stroke(255,0,0);
  PVector v1;
  PVector v2;
  Point2D p;
    
  for(int i = 0 ;i<contour.size()-1; i++)
  {
    p=contour.get(i);
    v1=cloud[p.y][p.x];
    p=contour.get(i+1);
    v2=cloud[p.y][p.x];
    
    //if(v1!=null && v2!=null)
      line(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
  }
}

//Возвращает точку из контура, словно контур является
//кольцевым буфером
//[-1] = N-1  (последняя)
//[0] =  0
//...
//[N-1] = N-1 (перввая)
//[N] =   0   (последняя)
Point2D getPoint(ArrayList<Point2D> contour, int index)
{
  if(index<0) 
    index=contour.size()+index;
  else if(index>=contour.size())
    index=index-contour.size();
  return contour.get(index);
}