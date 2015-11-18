/* ПРОСТОЕ СГЛАЖИВАНИЕ
 * Просто усредняет несколько точек.
 * Не лучший результат
 */
void SimpleSmooth(PointCloud cloud)
{
  stroke(0,255,0);
  
  //Averaging list
  ArrayList<PVector> list=new ArrayList<PVector>();
  int n=50;  //number of averaging points
  
  for(int i=-n; i<cloud.ContourSize(); i++)
  {
    //Add point to the list
    //Keep number of points is N
    Point2D p = cloud.GetContourPointCycle(i);
    list.add(cloud.GetPoint(p));
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