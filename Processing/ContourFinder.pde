public ArrayList<Point2D> FindContour(PVector[][] cloud)
{ 
  Point2D curP = new Point2D();                          //current point 
  ArrayList<Point2D> contour = new ArrayList<Point2D>(); //X, Y indexes of contours points
  
  //find first not nan point
  println("Searching for first non-nan point...");
  
  boolean isFound=false;
  for(curP.y = 0; curP.y<cloud.length && !isFound; curP.y++)
    {
      for(curP.x=0; curP.x<cloud[curP.y].length; curP.x++)
      {
        PVector p = cloud[curP.y][curP.x];
        if(p!=null)
        {
          isFound=true;
          break;
        }
      }
    }
  
  //Fix y coordinate
  curP.y--;
  //println("X =",curP.x, "Y =",curP.y);
  
  //setup graphics
  stroke(255,255,0);
  strokeWeight(2);
  
  //Save the first point
  Point2D start = curP.Copy();
    
  //We at the top of the contour
  //maybe we should go left
  Direction direction = new Direction(2);
  
  //first move (without this cycle will stop on first iteration)
  contour.add(curP.Copy());
  curP.Move(direction);
  
  println("Moving along the contour...");
  
  while((curP.x!=start.x)||(curP.y!=start.y))
  {
    //drawPoint(curP);
    PVector v1 = cloud[curP.y][curP.x];
    if(v1!=null)
      contour.add(curP.Copy());
    
    curP.Move(direction);
    direction=findClosestPoint(curP, cloud, direction);
  }
  
  return contour;
}

//find the direction which is looking
//"outside" of the contour - left hand by current direction
/*
current direction ->
x - point
* - current point
       |xxx
    --*xxxx
    xxxxxxx
    we choose direction UP
*/
Direction findClosestPoint(Point2D curP, PVector[][] cloud, Direction direction)
{
  //It's possible to do loop there, but ...
  if(isPoint(curP, cloud, direction.RotLeft()))    //-45
  {
    if(isPoint(curP, cloud, direction.RotLeft().RotLeft())) //-90
      return direction.RotLeft().RotLeft();
    else
      return direction.RotLeft();
  }
  else
  {
    if(isPoint(curP, cloud, direction))  //0
      return direction;
    else if(isPoint(curP,cloud,direction.RotRight()))  //+45
      return direction.RotRight();
    else
      return direction.RotRight().RotRight();
  }
}

//is point there by direction
boolean isPoint(Point2D curP, PVector[][] cloud, Direction direction)
{
  Point2D p = curP.CopyMove(direction);
  PVector f = cloud[p.x][p.y];
  //println("Direction = ",direction.direction, "X = ", p.x, "Y = ",p.y, f!=null);
  return cloud[p.y][p.x]!=null;
}