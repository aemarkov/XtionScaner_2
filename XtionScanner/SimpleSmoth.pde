/* ПРОСТОЕ СГЛАЖИВАНИЕ
 * Просто усредняет несколько точек.
 * Не лучший результат
 */
void SimpleSmooth(PVector[][] cloud,ArrayList<Point2D> contour)
{
  stroke(0,255,0);
  
  //Averaging list
  ArrayList<PVector> list=new ArrayList<PVector>();
  int n=50;  //number of averaging points
  
  for(int i=-n; i<contour.size(); i++)
  {
    //Add point to the list
    //Keep number of points is N
    Point2D p = getPoint(contour,i);
    list.add(cloud[p.y][p.x]);
    if(list.size()>n)
      list.remove(0);
    
    //Drawing points
    if(i>0)
    {
      PVector av = average(list);
      point(av.x, av.y, av.z);
    }
  }
}

//Average list of coordinates
PVector average(ArrayList<PVector> list)
{
  PVector av = new PVector();
  for(int i=0; i<list.size(); i++)
    av.add(list.get(i));
  
  av.div(list.size());
  return av;
}