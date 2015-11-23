/* Описывает направление движения*/
class Direction
{
  /* Движения в указанные стороны указаны цифами
   7 0 1
   6 * 2
   5 4 3
   ВНИМАНЕ. ВРЕМЕННЫЙ КОД.
   ДЕЛАТЬ ПЕРЕМЕННУЮ НАПРАВЛЕНИЯ ПУБЛИЧНОЙ - ПЛОХО*/
  public int direction; 

  //Создает направление по-умолчанию - вверх
  public Direction()
  {
    direction=0;
  }

  //Создает направление из его целочисленного кода
  public Direction(int direction)
  {
    this.direction=direction;
  }

  //Копирует
  public Direction(Direction other)
  {
    this.direction = other.direction;
  }

  //Поворачивает направление влево на одно деление
  //Возвращает копию объекта и не модифицирует сам объект
  public Direction RotLeft()
  {
    Direction dNew = new Direction(this);
    dNew.direction--;
    if (dNew.direction<0)
      dNew.direction=7;
    return dNew;
  }

  //Поворачивает направление вправо на одно деление
  //Возвращает копию объекта и не модифицирует сам объект
  public Direction RotRight()
  {
    Direction dNew = new Direction(this);
    dNew.direction++;
    if (dNew.direction>7)
      dNew.direction=0;
    return dNew;
  }
}