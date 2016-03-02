/**************************************************************************************************
 *                         Точка с целочисленными координатами                                    *
 **************************************************************************************************
 
ОПИСАНИЕ:
  Двумерная точка с целочисленными координатами с 
  возможностью сдвигать ее на 1 клетку в заданном 
  направлении

 */
class Point2D implements Cloneable
{
  //Координаты
  public int x, y;

  //Создание нулевой точки
  public Point2D()
  {
    x=0; 
    y=0;
  }

  //Создание точки с указанными координатами
  public Point2D(int x, int y)
  {
    this.x=x;
    this.y=y;
  }

  //Копирование
  public Point2D(Point2D other)
  {
    this.x = other.x;
    this.y = other.y;
  }

  //Сдвиг точки в заданном направлении
  public void Move(Direction direction)
  {
    switch(direction.direction)
    {
    case 0:
      y--;
      break;
    case 1:
      x++;
      y--;
      break;  
    case 2:
      x++;
      break;
    case 3:
      x++;
      y++;
      break;
    case 4:
      y++;
      break;
    case 5:
      x--;
      y++;
      break;
    case 6:
      x--;
      break;
    case 7:
      x--;
      y--;
      break;
    }
  }

  //Возвращает сдвинутую точку, но не трогает оригинал
  public Point2D CopyMove(Direction direction)
  {
    Point2D newP = new Point2D(this);
    newP.Move(direction);
    return newP;
  }

  // Преобразование к строке
  @Override
  public String toString()
  {
    return "("+Integer.toString(x)+" "+Integer.toString(y)+")";
  }

  //Сравнение
  @Override
  public boolean equals(Object obj)
  {
    if(obj == this)
      return true;

    /* obj ссылается на null */

    if(obj == null)
      return false;

     /* Удостоверимся, что ссылки имеют тот же самый тип */

    if(!(getClass() == obj.getClass()))
      return false;
    else
    {
      Point2D tmp = (Point2D)obj;
      return (tmp.x==this.x)&&(tmp.y==this.y);

    }
  }


  //Копирование
  public Point2D clone()
  {
    return new Point2D(x,y);  
  }
}