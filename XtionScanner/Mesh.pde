/**************************************************************************************************
 *                                 МЕШ (ПОЛИГОНАЛЬНАЯ СЕТКА)                                      *
 **************************************************************************************************

ОПИСАНИЕ:
  Это меш - полигональная сетка.
  Этот класс хранит организованный меш (см. облако).

  Вершины хранятся в матрице, где соседние вершины хранятся в соседних элементах матрицы.
  Поддерживаются 3х- и 4х-вершинные полигоны.

ДЕТАЛИ:
  Все  точки, хранящиеся в меше, хранятся в списке PointCloud'ов
  Точки, находящиеся на разных "слоях" (на разной глубине), хранятся
  в разных PointCloud. Используется PointCloud вместо простого массива
  [][][], чтобы иметь возможность работы с контурами.

  ИНДЕКСАЦИЯ:
  Точки индексуются тремя координатами: (z, x, y)
  z - глубина, номер PointCloud

  ПОЛИГОНЫ:
  Полигоны просто хранят индексы 3х или 4х точек в 
  в меше (см. Индексация)

  ОГРАНИЧЕНИЯ:
  При добавлении облака, оно добавляется назад меша, т.е
  нельзя вставить в середину, удалить итп
 */

class Mesh
{
  ArrayList<PointCloud> clouds;    //Список облаков точек
  ArrayList<Polygon> polygons;     //Список полигонов

  int w, h;                        //Размер меша

  //Создает меш с заданным размером
  public Mesh(int w, int h)
  {
    clouds = new ArrayList<PointCloud>();
    polygons=new ArrayList<Polygon>();

    this.w=w; 
    this.h=h;
  }

  ///////////////////////////////////////////////////////////////////////////////////////
  ///    РАБОТА СО СЛОЯМИ
  ///////////////////////////////////////////////////////////////////////////////////////

  //Добавляет слой 
  public void AddLayer(PointCloud cloud) 
  {
    clouds.add(cloud);
    make_mesh(cloud, clouds.size()-1);
    //Содаем полигоны на основе этого облака
  }

  //Принимает облако и осуществляет собственно построение  меша
  // cloud - облако
  // cloud_index-индекс облака в меше
  private void make_mesh(PointCloud cloud, int cloud_index)
  {
    PVector v1, v2, v3, v4, v5;
    
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

          if (x>0)
            v5 = cloud.GetPoint(x-1, y+1);
          else
            v5=null;

          if ((v2!=null) && (v3!=null) && (v4!=null))
          {
            //Все 4 соседнх точки существуют, 4х-вершинный полигон
            //Создаем его
            AddPolygon(new Point3D(x, y,cloud_index), new Point3D(x+1, y,cloud_index), new Point3D(x+1, y+1,cloud_index), new Point3D(x, y+1,cloud_index));
          } else if ((v2!=null) && (v3==null) && (v4!=null))
            AddPolygon(new Point3D(x, y,cloud_index), new Point3D(x+1, y,cloud_index), new Point3D(x, y+1,cloud_index));
          else if ((v2!=null) && (v3!=null) && (v4==null))
            AddPolygon(new Point3D(x, y,cloud_index), new Point3D(x+1, y,cloud_index), new Point3D(x+1, y+1,cloud_index));
          else if ((v2==null) && (v3!=null) && (v4!=null))
            AddPolygon(new Point3D(x, y,cloud_index), new Point3D(x+1, y+1,cloud_index), new Point3D(x, y+1,cloud_index));
          else if ((v2==null) && (v3==null) && (v4!=null) && (v5!=null))
            AddPolygon(new Point3D(x, y,cloud_index), new Point3D(x, y+1,cloud_index), new Point3D(x-1, y+1,cloud_index));
        }
      }
    }
  } 


  public PointCloud GetLayer(int z)
  {
    return clouds.get(z);
  }

  ///////////////////////////////////////////////////////////////////////////////////////
  ///    ПОЛУЧЕНИЕ РАЗМЕРОВ ОБЛАКА
  ///////////////////////////////////////////////////////////////////////////////////////
  int Height() {
    return h;
  }
  int Width() {
    return w;
  }
  Point2D Size() {
    return new Point2D(w, h);
  }


  ///////////////////////////////////////////////////////////////////////////////////////
  ///    ОПЕРАЦИИ НАД ТОЧКАМИ
  ///////////////////////////////////////////////////////////////////////////////////////
  //Получение точки облака
  PVector GetPoint(int x, int y, int z)
  {
    return clouds.get(z).GetPoint(x, y);
  }

  PVector GetPoint(Point3D p)
  {
    return GetPoint(p.x, p.y, p.z);
  }

  //Задание точки облака пока что запрещено, потому что ломает
  //структуру

  ///////////////////////////////////////////////////////////////////////////////////////
  ///    ОПЕРАЦИИ НАД ПОЛИГОНАМИ
  ///////////////////////////////////////////////////////////////////////////////////////

  //Возвращает полигон
  //Целесообразность операции под сомнением, ведь полигон без облака
  //не имеет смылса
  public Polygon GetPolygon(int index)
  {
    return polygons.get(index);
  }

  //Создает полигон из 3х вершин
  public void AddPolygon(Point3D p1, Point3D p2, Point3D p3)
  {
    polygons.add(new Polygon(p1, p2, p3));
  }

  //Создает полигон из 4х вершин
  public void AddPolygon(Point3D p1, Point3D p2, Point3D p3, Point3D p4)
  {
    polygons.add(new Polygon(p1, p2, p3, p4));
  }


  ///////////////////////////////////////////////////////////////////////////////////////
  ///    ВИЗУАЛИЗАЦИЯ
  ///////////////////////////////////////////////////////////////////////////////////////

  //Рисует меш
  void Draw()
  {

    PVector v1;
    PVector v;

    for (int i=0; i<polygons.size(); i++)
    {
      beginShape(TRIANGLE_FAN);
      Polygon p = polygons.get(i);
      Point3D[] p_arr = p.GetPoints();


      for (int j = 0; j<p_arr.length; j++)
      {
        v=GetPoint(p_arr[j]);
        vertex(v.x, v.y, v.z);
      }

      endShape(CLOSE);
    }
  }
} 


///////////////////////////////////////////////////////////////////////////////////////
///    ПОЛИГОН
///////////////////////////////////////////////////////////////////////////////////////

//Класс полигона
class Polygon
{
  //Индексы точек в облаке
  Point3D[] points;

  public Polygon(Point3D p1, Point3D p2, Point3D p3)
  {
    points = new Point3D[]{p1, p2, p3};
  }

  public Polygon(Point3D p1, Point3D p2, Point3D p3, Point3D p4)
  {
    points = new Point3D[]{p1, p2, p3, p4};
  }

  Point3D[] GetPoints()
  {
    return points;
  }
}