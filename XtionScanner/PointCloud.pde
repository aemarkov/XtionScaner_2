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
    this.w = w; //<>//
    this.h = h;
    point_cloud = new PVector[h][w];
    contour = new ArrayList<Point2D>();
  }


  //Создает облако точек из файла
  public PointCloud(String filename)
  {
    BufferedReader r = createReader(filename); //<>//
    String line;

    int v=-1, w=-1, h=-1;
    
    try
    {
      //Читаем метаданные
      line = r.readLine();
      if(!line.equals("[METADATA]"))
        throw new Error("Invalid file format: no METADATA");

      //Читаем метаданные до конца файла или до начала данных
      while(((line=r.readLine())!=null) && (!line.equals("[DATA]")))
      {
        //Парсим строку
        KeyValuePair  pair = parse_line(line);

        //Заполняем соотвествующие значения. в зависимости от этой строки
        if(pair.key.equals("VERSION"))
          v=pair.value;
        else if(pair.key.equals("WIDTH"))
          w=pair.value;
        if(pair.key.equals("HEIGHT"))
          h=pair.value;
      }

      //Проверка на то, что все необходимые значения ввеедены
      if((v==-1)||(w==-1)||(h==-1))
        throw new Error("Invalid file format: expected parameters not set");

      //Создаем структуры для облака
      this.w=w;
      this.h=h;
      point_cloud=new PVector[h][w];

      //Читаем облако точек
      int y = 0;
      while ((line=r.readLine())!=null)
      {
        String[] points = split(line, ';');
        for (int x = 0; x<points.length; x++)
        {
          String[] coords = split(points[x], ' ');
          if (!isNan(coords))
          {
            //Get point coords
            float xc = Float.parseFloat(coords[0])*1000;
            float yc = Float.parseFloat(coords[1])*1000;
            float zc = Float.parseFloat(coords[2])*1000-500;

            //need to fix coords (????)
            //SetPoint(x, y, new PVector(xc, yc, zc));
            SetPoint(639-x, 479-y, new PVector(xc, yc, zc));
          }
        }
        y++;
      }
    
    }catch (IOException exp)
    {
    }
  }

  KeyValuePair parse_line(String line)
  {
    String[] strings = line.split("=");
    return new KeyValuePair(strings[0], Integer.parseInt(strings[1]));
  }

  ///////////////////////////////////////////////////////////////////////////////////////
  ///     ПОЛУЧЕНИЕ РАЗМЕРОВ
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

  ///////////////////////////////////////////////////////////////////////////////////////
  ///    ОПЕРАЦИИ НАД КОНТУРОМ
  ///////////////////////////////////////////////////////////////////////////////////////

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