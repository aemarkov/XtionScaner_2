/*--------------------------------------------------------
 *                  АХОЖДЕНИЕ КОНТУРА
 *------------------------------------------------------*/

/*
Нахождение контура работает следующим образом:
 1. Двигаемся разверткой по матрице точек, до тех пор, пока не найдем
 первую существующую точку
 2. Эта точка будет самой верхней точкой контура - поэтому стартовое направление
 движения будет ВПРАВО
 3. Пытаемся найти точку В_НАПРАВЛЕНИИ_ДВИЖЕНИЯ от текущей. Если ее там нет - ищем
 как можно менее откланяющиеся от этого направления точки, при этом сначала
 стараемся найти точки, находящиеся как бы "вовне" контура, а затем, если не удалось
 - внутри
 4. Продолжаем так двигаться, пока не обойдем весь контур*/

public void FindContour(PointCloud cloud)
{ 
  Point2D curP = new Point2D();                          //Текущая точка 

  //Ищем первую существующую точку
  println("Finding contour...");
  println("Searching for first non-nan point...");

  boolean isFound=false;
  for (curP.y = 0; curP.y<cloud.Height() && !isFound; curP.y++)
  {
    for (curP.x=0; curP.x<cloud.Width(); curP.x++)
    {
      PVector p = cloud.GetPoint(curP.x, curP.y);
      if (p!=null)
      {
        isFound=true;
        break;
      }
    }
  }

  //Исправление координаты (ВТФ???)
  curP.y--;

  //--------------------------------------------
  //Настройки графики для отображения контура //
  stroke(255, 255, 0);                          //
  strokeWeight(2);                            //
  //--------------------------------------------

  //Созраняем найденную точку
  Point2D start = new Point2D(curP);

  //Мы на самой верхней точке контура, поэтому 
  //в качестве направление выбираем ВПРАВО
  Direction direction = new Direction(2);

  //Первый сдвиг (без него цикл завершиться на первой итерации)
  cloud.AddContourPoint(new Point2D(curP));
  curP.Move(direction);

  //Движемся вдоль контура
  println("Moving along the contour...");
  while ((curP.x!=start.x)||(curP.y!=start.y))
  {
    //Выбираем очередную точку и добавляем ее в контур
    PVector v1 = cloud.GetPoint(curP.x, curP.y);
    if (v1!=null)
      cloud.AddContourPoint(new Point2D(curP));

    //Перехордим к следующей точке
    curP.Move(direction);
    direction=findClosestPoint(curP, cloud, direction);
  }

  println("Contour found");
}

//Ищем направление, которое направлено
//"вовне" от контура - по левую руку от текущего направления
/*
Текущее направление ->
 x - точка
 * - текущая точка
 |xxx
 --*xxxx
 xxxxxxx
 Выбираем направление ВВЕРХ
 */
Direction findClosestPoint(Point2D curP, PointCloud cloud, Direction direction)
{

  //Поочередно проверяем разные углы
  if (isPoint(curP, cloud, direction.RotLeft()))    //-45
  {
    if (isPoint(curP, cloud, direction.RotLeft().RotLeft())) //-90
      return direction.RotLeft().RotLeft();
    else
      return direction.RotLeft();
  } else
  {
    if (isPoint(curP, cloud, direction))  //0
      return direction;
    else if (isPoint(curP, cloud, direction.RotRight()))  //+45
      return direction.RotRight();
    else
      return direction.RotRight().RotRight();
  }
}

//Проверяем, существует ли точка в нужном направлении движения
boolean isPoint(Point2D curP, PointCloud cloud, Direction direction)
{
  Point2D p = curP.CopyMove(direction);
  PVector f = cloud.GetPoint(p.x, p.y);
  return cloud.GetPoint(p.x, p.y)!=null;
}