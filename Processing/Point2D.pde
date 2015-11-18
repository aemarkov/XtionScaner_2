//Simple point storing pair of INTEGER values
class Point2D
{
  public int x, y;
  public Point2D()
  {
    x=0; y=0;
  }
  
  public Point2D(int x, int y)
  {
    this.x=x;
    this.y=y;
  }
  
  public Point2D Copy()
  {
    return new Point2D(x,y);
  }
  
  //Moves the point
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
  
  public Point2D CopyMove(Direction direction)
  {
    Point2D newP = this.Copy();
    newP.Move(direction);
    return newP;
  }
}