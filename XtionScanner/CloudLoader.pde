public PVector[][] Load(String filename)
{
   //reading cloud from file
  PVector[][] cloud = new PVector[480][640];
  BufferedReader r = createReader(filename);
  String line;
  
  int y=0;  
  try
  {
    while((line=r.readLine())!=null)
    {
      String[] points = split(line, ';');
      for(int x = 0; x<points.length; x++)
      {
        String[] coords = split(points[x], ' ');
        if(!isNan(coords))
        {
          //Get point coords
          float xc = Float.parseFloat(coords[0])*1000;
          float yc = Float.parseFloat(coords[1])*1000;
          float zc = Float.parseFloat(coords[2])*1000-500;
          
          //need to fix coords
          cloud[479-y][639-x]=new PVector(xc, yc, zc);
        }
      }
      y++;
    }
  }
  catch(IOException exp)
  {
  }
  
  return cloud;
}