//Direction of moving
class Direction
{
  //This is direction
   // 7 0 1
   // 6 * 2
   // 5 4 3
  //It's very bad to do it public, but I am to lazy
  //and don't know anything about JAVA's operator's overload
  public int direction; 
  
  public Direction()
  {
    direction=0;
  }
  
  public Direction(int direction)
  {
    this.direction=direction;
  }
  
  public Direction Copy()
  {
    return new Direction(direction);
  }
  
  public Direction RotLeft()
  {
    Direction dNew = this.Copy();
    dNew.direction--;
    if(dNew.direction<0)
      dNew.direction=7;
    return dNew;
  }
  
  public Direction RotRight()
  {
    Direction dNew = this.Copy();
    dNew.direction++;
    if(dNew.direction>7)
      dNew.direction=0;
    return dNew;
  }
  
}