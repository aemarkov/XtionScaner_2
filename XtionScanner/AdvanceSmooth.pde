//Advancive contour smoothing
void AdvanceSmooth(PVector[][] cloud, ArrayList<Point2D> contour)
{
  strokeWeight(1);
  
  int n=6;                     //Number of points need to calculate average direction vector  
  
  ArrayList<Float> avList = new ArrayList<Float>();
  
  PVector prevPoint;
  float angle=0;
  int m=0;
  
  //calculate first direction
  for(int i = -n/2; i<n/2; i++)
  {
    Point2D p1 = getPoint(contour, i);
    Point2D p2 = getPoint(contour, i+1);
    PVector v1 = cloud[p1.y][p1.x];
    PVector v2 = cloud[p2.y][p2.x];
    float ang =calcVector(v1, v2);
    angle+=ang;
    m++;
  }
  angle/=m;
  println("Angle = ",degrees(angle));

  //Get first point
  Point2D p = contour.get(0);
  PVector v= cloud[p.y][p.x];
  prevPoint = new PVector(v.x, v.y, v.z);

  //smoothing
  for(int i = 0; i<100; i++)
  {
    //get current and next points
    Point2D p1 = getPoint(contour, i);
    Point2D p2 = getPoint(contour, i+1);
    PVector v1 = cloud[p1.y][p1.x];
    PVector v2 = cloud[p2.y][p2.x];
    
    float dx = v2.x - v1.x;
    float dy = v2.y - v1.y;
    
    //average current angle
    float curAngle = calcVector(v1, v2);
    float diff = angle - curAngle;        
            
    float k = 0.05;//diff;
    angle = (1-k)*angle + k*curAngle;        
    
    /*if(abs(cos(angle))>0.1)
    {
      prevPoint.y-=(v1.x-prevPoint.x)*tan(angle);
      prevPoint.x=v1.x;
    }
    else
    {
      prevPoint.y=v1.y;
    }*/
    
    
    strokeWeight(1);
    drawVector(v1, curAngle, color(0,0,255));
    
    //println(abs(dx)>abs(dy),"dx: ", dx, " dy:", dy);
    println(degrees(curAngle));
    if(abs(curAngle-PI/2)>PI/8)
    {
      //println("horizontal");
      prevPoint.y-=(v1.x-prevPoint.x)*tan(angle);
      prevPoint.x=v1.x;
      drawVector(prevPoint, angle, color(0,255,0));
    }
    else
    {
      drawVector(prevPoint, angle, color(255,255,0));
      //println("vertical");
      prevPoint.x+=(prevPoint.y-v1.y)*tan(PI/2-angle);
      prevPoint.y=v1.y;
    }
    
    
    /*float r = -0.5;
    prevPoint.x+=r*cos(angle);
    prevPoint.y-=r*sin(angle);*/
    
    strokeWeight(2);
    stroke(255,0,255);
    point(v1.x, v1.y, v1.z);
    stroke(255,255,0);
    point(prevPoint.x, prevPoint.y, v1.z);
  }
}

void drawVector(PVector[][] cloud, Point2D p, float angle, color c)
{
   PVector v1 = cloud[p.y][p.x];
   drawVector(v1, angle, c);
}

void drawVector(PVector v, float angle, color c)
{
  float len = 3; //<>//
  PVector v2 = new PVector(v.x-len*cos(angle), v.y+len*sin(angle), v.z);
  stroke(c);
  line(v.x, v.y, v.z, v2.x, v2.y, v2.z);
}

/*
Calculate average vector(angle) of list of points
Ideally, I think, we should use linear regression to 
calculate linear  aproxymation of this points list, and 
take it's angle (with Ox). 
But now it's to difficult, so I tried to just connect 
first and the last points*/
double calcAverageVector(PVector[][] cloud, ArrayList<Point2D> points)
{
  Point2D p1 = points.get(0);
  Point2D p2 = points.get(points.size()-1);
  PVector v1 = cloud[p1.y][p1.x];
  PVector v2 = cloud[p2.y][p2.x];
  
  return calcVector(v1, v2);
}

float calcVector(PVector v1, PVector v2)
{   
  //float angle =  (float)atan2(v2.y-v1.y, v2.x-v1.x);
  float angle = PI-atan2(v2.y-v1.y,v2.x-v1.x);
  if(angle>PI)angle = -(2*PI-angle);
  return angle;
}

float averageFloat(ArrayList<Float> l)
{
  float val = 0;
  for(int i = 0; i<l.size(); i++)
    val+=l.get(i);
    
  return val/l.size();
}