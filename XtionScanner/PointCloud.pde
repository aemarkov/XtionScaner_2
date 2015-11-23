/* Этот класс представляет организованное облако точек */
class PointCloud
{
  //Матрица точек облака
  private PVector[][] point_cloud;

  //Размеры матрицы
  private int w, h;

  //Контур
  //Контур не выносится в отдельный класс, т.к он прост (просто список)
  //и не имеет смысла без облака
  private ArrayList<Point2D> contour; 

  //Создает облако точек заданного размера
  PointCloud(int w, int h)
  {
    this.w = w;
    this.h = h;
    point_cloud = new PVector[h][w];
    contour = new ArrayList<Point2D>();
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
    return point_cloud[y][x];
  }

  PVector GetPoint(Point2D p)
  {
    return point_cloud[p.y][p.x];
  }

  //Задание точки облака
  void SetPoint(int x, int y, PVector value)
  {
    point_cloud[y][x]=value;
  }

  void SetPoint(Point2D p, PVector value)
  {
    point_cloud[p.y][p.x]=value;
  }

  //--------------- Операции над контуром ----------------------------
  //Добавляет точку в контур
  void AddContourPoint(int x, int y)
  {
    contour.add(new Point2D(x, y));
  }

  void AddContourPoint(Point2D p)
  {
    contour.add(p);
  }

  //Возвращает размер контура
  int ContourSize() {
    return contour.size();
  }

  //Возвращает ИНДЕКСЫ точки из контура 
  Point2D GetContourPoint(int index)
  {
    return contour.get(index);
  }

  //Возвращает 3D КООРДИНАТЫ точки из контура
  PVector GetPointFromContour(int index)
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
  Point2D GetContourPointCycle(int index)
  {
    if (index<0) 
      index=contour.size()+index;
    else if (index>=contour.size())
      index=index-contour.size();
    return contour.get(index);
  }
}