/*
Это меш - полигональная сетка.
 Этот класс хранит организованный меш (см. облако).
 Вершины хранятся в матрице, где соседние вершины
 хранятся в соседних элементах матрицы.
 Вершины, находящиеся по одним координатам на разной
 "глубине" хранятся в разных слоях.
 Поддерживаются 3х- и 4х-вершинные полигоны*/


//Однослойный меш
class MeshLayer
{
  PointCloud cloud;                //Облако точек - организованный набор вершин
  ArrayList<Polygon> polygons;     //Список полигонов

  int w, h;                        //Размер меша

  //Просто создает меш
  public MeshLayer()
  {
    cloud=null;
    polygons=new ArrayList<Polygon>();
    w=0; 
    h=0;
  }

  //Принимает облако и осуществляет собственно построение 
  //меша
  public MeshLayer(PointCloud cloud)
  {
    PVector v1, v2, v3, v4, v5;
    this.cloud = cloud;
    polygons=new ArrayList<Polygon>();
    w = cloud.Width();
    h = cloud.Height();
    stroke(255, 0, 0);
    strokeWeight(1);

   //Построение меша
    //Проходим по всем точкам, смотрим на точки справа, снизу, снизу-справа.
    //Возможно несколько ситуаций:
    //. . . 1--2 . . . .
    //      |  |
    //. . . 4--3 . . . .

    //. . . 1--2 . . . .
    //      | /
    //. . . 4    . . . . . 

    //. . . 1--2 . . . .
    //       \ |
    //. . .    3 . . . . 

    //. . . 1    . . . .
    //      | \ 
    //. . . 4--3 . . . . 

    //.  .  1  . . . . .
    //    / |  
    //.  5--4  . . . . . 

    for (int y = 0; y<h-1; y++)
    {
      for (int x = 0; x<w-1; x++)
      {
        //Берем текущую точку
        v1 = cloud.GetPoint(x, y);
        if (v1!=null)
        {
          //Берем соседние четыре точки
          v2 = cloud.GetPoint(x+1, y);
          v3 = cloud.GetPoint(x+1, y+1);
          v4 = cloud.GetPoint(x, y+1);

          if(x>0)
          	v5 = cloud.GetPoint(x-1,y+1);
          else
           	v5=null;

          if ((v2!=null) && (v3!=null) && (v4!=null))
          {
            //Все 4 соседнх точки существуют, 4х-вершинный полигон
            //Создаем его
            AddPolygon(new Point2D(x, y), new Point2D(x+1, y), new Point2D(x+1, y+1), new Point2D(x, y+1));
          } 
          else if((v2!=null) && (v3==null) && (v4!=null))
          	AddPolygon(new Point2D(x, y), new Point2D(x+1, y), new Point2D(x, y+1));
          else if((v2!=null) && (v3!=null) && (v4==null))
          	AddPolygon(new Point2D(x, y), new Point2D(x+1, y), new Point2D(x+1, y+1));
          else if((v2==null) && (v3!=null) && (v4!=null))
          	AddPolygon(new Point2D(x, y), new Point2D(x+1, y+1), new Point2D(x, y+1));
          else if((v2==null) && (v3==null) && (v4!=null) && (v5!=null))
          	AddPolygon(new Point2D(x, y),  new Point2D(x, y+1), new Point2D(x-1,y+1));
        }
      }
    }
  } 

  //---------------- Получение размеров облака ------------------------
  int Height() {
    return h;
  }
  int Width() {
    return w;
  }
  Point2D Size() {
    return new Point2D(w, h);
  }


  //-------------- Операции над точками в облаке ----------------------
  //Получение точки облака
  PVector GetPoint(int x, int y)
  {
    return cloud.GetPoint(x, y);
  }

  PVector GetPoint(Point2D p)
  {
    return cloud.GetPoint(p);
  }

  //Задание точки облака пока что запрещено, потому что ломает
  //структуру

  //----------------- Операции над полигонами -----------------------
  //Возвращает полигон
  //Целесообразность операции под сомнением, ведь полигон без облака
  //не имеет смылса
  public Polygon GetPolygon(int index)
  {
    return polygons.get(index);
  }

  //Создает полигон
  public void AddPolygon(Point2D p1, Point2D p2, Point2D p3)
  {
    polygons.add(new Polygon(p1, p2, p3));
  }

  public void AddPolygon(Point2D p1, Point2D p2, Point2D p3, Point2D p4)
  {
    polygons.add(new Polygon(p1, p2, p3, p4));
  }
 
  //Рисует меш
  void Draw()
  {

  	PVector v1;
  	PVector v;
	
  	for(int i=0; i<polygons.size(); i++)
  	{
  		beginShape(TRIANGLE_FAN);
  		Polygon p = polygons.get(i);
  		Point2D[] p_arr = p.GetPoints();

  		
  		for(int j = 0 ;j<p_arr.length; j++)
  		{
  			v=cloud.GetPoint(p_arr[j]);
  			vertex(v.x, v.y, v.z);
  		}
  		
		endShape(CLOSE);
  	}
  }

} 


//Класс полигона
class Polygon
{
  //Индексы точек в облаке
  Point2D[] points;

  public Polygon(Point2D p1, Point2D p2, Point2D p3)
  {
    points = new Point2D[]{p1, p2, p3};
  }

  public Polygon(Point2D p1, Point2D p2, Point2D p3, Point2D p4)
  {
    points = new Point2D[]{p1, p2, p3, p4};
  }

  Point2D[] GetPoints()
  {
  	return points;
  }

}