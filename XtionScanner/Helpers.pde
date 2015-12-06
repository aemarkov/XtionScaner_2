/*-------------------------------------------------------
 *               ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
 *-----------------------------------------------------*/

//Проверяет, что координаты в стркоовом представлении являются NaN
boolean isNan(String[] coords)
{
  if (coords.length!=3)return true;
  return coords[0].equals("nan") && coords[1].equals("nan") && coords[2].equals("nan");
}

//Отображает облако точек
void drawCloud(PointCloud cloud)
{
  for (int y = 0; y<cloud.Height(); y++)
  {
    for (int x=0; x<cloud.Width(); x++)
    {
      PVector p = cloud.GetPoint(x, y);
      if (p!=null)
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
  point(x, y);
}

//Рисует точку ПО ИНДЕКСУ
//(все аналогично)
void drawPoint(Point2D p)
{
  drawPoint(p.x, p.y);
}

//РИСУЕТ КОНТУР
void drawContour(PointCloud cloud)
{
  PVector v1;
  PVector v2;

  for (int i = 0; i<cloud.ContourSize()-1; i++)
  {
    v1=cloud.GetPointFromContour(i);
    v2=cloud.GetPointFromContour(i+1);
    line(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
  }
}