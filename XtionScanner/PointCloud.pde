/**************************************************************************************************
 *                                     ОБЛАКО ТОЧЕК
 **************************************************************************************************

ОПИСАНИЕ:
  Этот класс хранит организованное облако точек.
  Облако хранится в матрице таким образом, что
  в соседних элементах хранятся соседние точки.
  Это упрощает работу

  Помимо этого, этот класс содержит информацию
  о контуре облака - точках на границе облака

ФОРМАТ ФАЙЛА
  OCF (Organized Cloud File) - Формат файла для хранения организованного облкака точек
  Понятие организованного облака точек см. в PointCloud

  Формат файла:
  [METADATA]
  VERSION=v
  WIDTH=w
  HEIGHT=h
  [DATA]
  x y z;x y z;x y z; ... x y z;
  x y z;x y z;x y z; ... x y z;
  x y z;x y z;x y z; ... x y z;

  В начале файла идет служебная информация, которая начинается с [METADATA]
  Здес содержиться
   - номер версии (для распознования разных версий формата в дальнейшем)
   - ширина и высота облкак точек

  Затем, начиная с [DATA] идут точки облака, разделенные точкой с запятой.
  1 строка файла - 1 стррока организованного облака*/

class PointCloud implements Cloneable
{
  //Матрица точек облака
  private PVector[][] point_cloud;

  //Размеры матрицы
  private int w, h;

  //Контур
  //Контур не выносится в отдельный класс, т.к он прост (просто список)
  //и не имеет смысла без облака
  //Используется, когда нужен обход вокруг контура
  public ArrayList<Point2D> contour;

  //Второй вариант контура, используется рядом алгоритмов для
  //упрощения и оптимизации. Хранит значение - есть ли контур в этой точке.
  public boolean[][] is_contour;


  ///////////////////////////////////////////////////////////////////////////////////////
  ///     КОНСТРУКТОРЫ
  ///////////////////////////////////////////////////////////////////////////////////////

  //Создает облако точек заданного размера
  public PointCloud(int w, int h)
  {
    this.w = w; //<>//
    this.h = h;
    point_cloud = new PVector[h][w];
    contour = new ArrayList<Point2D>();
    is_contour = new boolean[h][w];
  }


  //Копирование
  public PointCloud clone()
  {
    PointCloud copy = new PointCloud(w,h);
    for(int y = 0; y<h; y++)
      copy.point_cloud[y]=point_cloud[y].clone();

    this.copy_contour(copy);
    
    return copy;
  }

  //Копирует контур
  private void copy_contour(PointCloud target)
  {
    target.contour = new ArrayList<Point2D>();
    target.is_contour = new boolean[h][w];

    for(Point2D point: contour)
      target.contour.add(point.clone());

    for(int y =0; y<h; y++)
      target.is_contour[y]=is_contour[y].clone();
  }

  //Копирование только облака
  public PointCloud clone_cloud()
  {
    PointCloud copy = new PointCloud(w,h);
    for(int y = 0; y<h; y++)
      copy.point_cloud[y]=point_cloud[y].clone();

    copy.contour = new ArrayList<Point2D>();
    copy.is_contour = new boolean[h][w];

    return copy;
  }


  ///////////////////////////////////////////////////////////////////////////////////////
  ///     ПОЛУЧЕНИЕ РАЗМЕРОВ
  ///////////////////////////////////////////////////////////////////////////////////////
  public int Height() {
    return h;
  }
  public int Width() {
    return w;
  }
  public Point2D Size() {
    return new Point2D(w, h);
  }


  ///////////////////////////////////////////////////////////////////////////////////////
  ///    ОПЕРАЦИИ НАД ТОЧКАМИ
  ///////////////////////////////////////////////////////////////////////////////////////

  //Получение точки облака
  public PVector GetPoint(int x, int y)
  {
    return point_cloud[y][x];
  }

  public PVector GetPoint(Point2D p)
  {
    return point_cloud[p.y][p.x];
  }

  //Задание точки облака
  public void SetPoint(int x, int y, PVector value)
  {
    point_cloud[y][x]=value;
  }

  public void SetPoint(Point2D p, PVector value)
  {
    point_cloud[p.y][p.x]=value;
  }

  //Сглаживание
  public PointCloud Smooth(int size)
  {
    PointCloud sCloud = new PointCloud(w, h);

    for (int y = 0; y<h; y++)
    {
      for (int x = 0; x<w; x++)
      {
        PVector v, v2;

        v=GetPoint(x, y);
        if (v!=null)
        {

          int n = 0;
          float z_sum=0;

          for (int x1=max(0, x-size/2); x1<min(w, x+size/2); x1++)
          {
            for (int y1 = max(0, y-size/2); y1<min(h, y+size/2); y1++)
            {
              v2 = GetPoint(x1, y1);
              if (v2!=null)
              {
                z_sum+=v2.z;
                n++;
              }
            }
          }


          //if (z_sum!=Double.NaN)
          //{
            z_sum/=n;
            sCloud.SetPoint(x, y, new PVector(v.x,v.y,z_sum));
          //}
        }
      }
    }

    cloud.copy_contour(sCloud);

    return sCloud;
  }

  ///////////////////////////////////////////////////////////////////////////////////////
  ///    ОПЕРАЦИИ НАД КОНТУРОМ
  ///////////////////////////////////////////////////////////////////////////////////////

  public void ClearContour()
  {
    contour.clear();

    for(int y = 0; y<h; y++)
      for(int x = 0; x<w; x++)
        is_contour[y][x]=false;
  }

  //Добавляет точку в контур
  public void AddContourPoint(int x, int y)
  {
    contour.add(new Point2D(x, y));
    is_contour[y][x]=true;
  }

  public void AddContourPoint(Point2D p)
  {
    //contour.add(p);
    AddContourPoint(p.x, p.y);
  }

  //Возвращает размер контура
  public int ContourSize()
  {
    return contour.size();
  }

  //Возвращает ИНДЕКСЫ точки из контура
  public Point2D GetContourPoint(int index)
  {
    return contour.get(index);
  }

  //Возвращает 3D КООРДИНАТЫ точки из контура
  public PVector GetPointFromContour(int index)
  {
    Point2D p = contour.get(index);
    return point_cloud[p.y][p.x];
  }

  //Возвращает точку из контура, словно контур является
  //кольцевым буфером
  //[-1] = N-1  (последняя)
  //[0] =  0
  //...
  //[N-1] = N-1 (перввая)
  //[N] =   0   (последняя)
  public Point2D GetContourPointCycle(int index)
  {
    if (index<0)
      index=contour.size()+index;
    else if (index>=contour.size())
      index=index-contour.size();
    return contour.get(index);
  }


  //Возвращает, является ли точка контуром или нет
  public boolean IsContour(int x, int y)
  {
    return is_contour[y][x];
  }

  public boolean IsContour(Point2D p)
  {
    return IsContour(p.x, p.y);
  }

  //[ГОВНОКОД] Возвращает весь контур, нахуй, используется в каком-то методе
  //УБРАТЬ НАХУЙ
  public ArrayList<Point2D> GetContour()
  {
    return new ArrayList<Point2D>(contour);
  }
}