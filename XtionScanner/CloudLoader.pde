public PointCloud Load(String filename)
{
   //reading cloud from file
  PointCloud cloud = new PointCloud(640,480);
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
          
          //need to fix coords (????)
          cloud.SetPoint(639-x, 479-y,new PVector(xc, yc, zc));
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