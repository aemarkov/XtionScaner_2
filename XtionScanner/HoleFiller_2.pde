import java.util.*;

//Засунул это пока все в класс, чтобы не мешалось
public class HoleFiller_1
{

  // in | oldCloud    : отсюда мы берем недостающие точки
  // in/out | newCloud: здесь сглаженный контур и облако состоящее из точек контура
  // Заполняем newCloud точками из oldCloud
  // Далее заделываем дырки
  // Я сознательно разделил код на ступени для понятности и последствие - 3 * О(N^2)
  void HoleFiller(PointCloud oldCloud, PointCloud newCloud)
  {
    if (newCloud.Width() != oldCloud.Width() || newCloud.Height() != oldCloud.Height())
      throw new IndexOutOfBoundsException("[Error] Width or Height of newCloud and oldCloud are not the same");

    FillNewCloudWithOldCloud(oldCloud, newCloud);
    ArrayList<HoleLine> holes = FindHoles(newCloud);
    FillHoles(holes, newCloud);
  }

  void FillNewCloudWithOldCloud(PointCloud oldCloud, PointCloud newCloud)
  {
    ArrayList<Point2D> smoothedContour = oldCloud.GetContour(); // For debug = oldCloud.GetContour(); For release newCloud.GetContour();
    IndexRange yRange = getYRange(smoothedContour);
    for(int y = yRange.low; y <= yRange.high; y++)
    {
      IndexRange xRange = getXRange(smoothedContour, y);
      for(int x = xRange.low; x <= xRange.high; x++)
      {
        PVector pointXY = oldCloud.GetPoint(x,y);
        if (!isNan(pointXY))  newCloud.SetPoint(x, y, pointXY);
      }
    }
  }

  // Поиск дырок-строк и составление списка таковых
  ArrayList<HoleLine> FindHoles(PointCloud cloud)
  {
    ArrayList<HoleLine> holes = new ArrayList<HoleLine>();
    ArrayList<Point2D> contour = cloud.GetContour();
    IndexRange yRange = getYRange(contour);
    for(int y = yRange.low; y <= yRange.high; y++)
    {
      IndexRange xRange = getXRange(contour, y);
      boolean isPreviousPointNan = false;
      boolean isCurrentPointNan  = false;
      boolean previousPointIsLeftBorderOfHole = false; // +Предыдущая+ точка - левая  граница дыры (последняя неNan точка слева от дыры)
      boolean currentPointIsRightBorderOfHole = false; // Текущая точка      - правая граница дыры (первая неNan точка справа от дыры)
      IndexRange hole = new IndexRange(-1, -1);
      boolean holeFound = false;
      for(int x = xRange.low; x <= xRange.high; x++)
      {
        PVector pointXY = cloud.GetPoint(x,y);
        isCurrentPointNan = isNan(pointXY);

        previousPointIsLeftBorderOfHole = isCurrentPointNan  && !isPreviousPointNan;
        if (previousPointIsLeftBorderOfHole)
          hole.low  = x - 1;
        currentPointIsRightBorderOfHole = !isCurrentPointNan && isPreviousPointNan;
        if (currentPointIsRightBorderOfHole)
          hole.high = x;

        holeFound = currentPointIsRightBorderOfHole;
        if (holeFound)
        {
          holes.add(new HoleLine(hole, y));
          hole = new IndexRange(-1, -1); // hole теперь ссылается на другую переменную
        }

        isPreviousPointNan = isCurrentPointNan;
      }
    }

    return holes;
  }

  // Залатываем все дыры
  void FillHoles(ArrayList<HoleLine> holes, PointCloud cloud)
  {
    Iterator<HoleLine> iterator = holes.iterator();
    println(holes);
    while(iterator.hasNext())
    {
      HoleLine hole = iterator.next();
      FillHole(hole, cloud);
    }
  }

  public void FindAndFillHoles(PointCloud cloud)
  {
    ArrayList<HoleLine> holes = FindHoles(cloud);
    FillHoles(holes, cloud);
  }

  // Предполагаем, что расстояние по оси x между точками в дыре одинаковое
  // Предполагаем, что они имеют одинаковую координату y (т.к. рассматриваем дыруСтроку)
  // Насчет Z предполагаем, что все точки в дыре находятся на одинаковой координате
  void FillHole(HoleLine hole, PointCloud cloud)
  {
    PVector leftBorderOfHole  = cloud.GetPoint(hole.xRange.low,  hole.y);
    PVector rightBorderOfHole = cloud.GetPoint(hole.xRange.high, hole.y);
    double realYOfLeftBorderPoint = leftBorderOfHole.y; // or right;

    double lengthOfRealRange = rightBorderOfHole.x - leftBorderOfHole.x;
    int lengthOfIndexRange   = hole.xRange.GetLength();
    double distanceBetwenTwoPoints = lengthOfRealRange / lengthOfIndexRange;

    for (int x = hole.xRange.low, i = 1; x <= hole.xRange.high; x++)
    {
      double newX = leftBorderOfHole.x + i * distanceBetwenTwoPoints;
      double newY = realYOfLeftBorderPoint;
      double newZ = (leftBorderOfHole.z + rightBorderOfHole.z) / 2.0; // Можно добавить градацию по оси Z
      cloud.SetPoint(x, hole.y, new PVector((float)newX, (float)newY, (float)newZ));
    }
  }


  // Формируем список всех 'x' координат точек контура с координатой y == 'y', далее получаем min, max
  // out | Range { x_min, x_max }
  IndexRange getXRange(ArrayList<Point2D> contour, int y)
  {
    // Ищем в контуре точки с y == y и собираем их 'x' координаты
    ArrayList<Integer> xOfPointInYRow = new ArrayList<Integer>();
    Iterator<Point2D> contourIterator = contour.iterator();
    while(contourIterator.hasNext())
    {
       Point2D contourPoint = contourIterator.next();
       if (contourPoint.y == y)
          xOfPointInYRow.add(contourPoint.x);
    }

    return FindMinMaxRange(xOfPointInYRow);
  }

  // Составляем массив из координат, далее получаем min, max
  // out | Range { y_min, y_max }
  IndexRange getYRange(ArrayList<Point2D> contour)
  {
    // Собираем 'y' всех точек в массив
    ArrayList<Integer> listOfAllYInContour = new ArrayList<Integer>();
    Iterator<Point2D> contourIterator = contour.iterator();
    while(contourIterator.hasNext())
    {
       Point2D contourPoint = contourIterator.next();
       listOfAllYInContour.add(contourPoint.y);
    }

    // Получем IndexRange(min, max)
    return FindMinMaxRange(listOfAllYInContour);
  }

  // out | range = {low, high}
  IndexRange FindMinMaxRange(ArrayList<Integer> collection)
  {
    println(collection); // DBG
    return new IndexRange( Collections.min(collection), Collections.max(collection) );
  }

  // В Java есть Range, но он не понравился мне, т.к. я не нашел, как менять значения low, high
  class IndexRange
  {
    IndexRange(int low, int high)
    {
      this.low  = low;
      this.high = high;
    }

    public int GetLength()
    {
      return high - low;
    }

    public int low, high;
  }

  // **********
  // *o   o**** Строка дырки
  // **********
  // Хранит индексы точек o по осям x и y
  class HoleLine
  {
    public IndexRange xRange;
    public int y;

    HoleLine(IndexRange xRange, int y)
    {
      this.xRange = xRange;
      this.y = y;
    }

    // Рисует линию, соединяющую крайние точки дырки
    void Draw(PointCloud cloudWithHoles)
    {
      PVector leftBorderOfHole  = cloudWithHoles.GetPoint(xRange.low, y);
      PVector rightBorderOfHole = cloudWithHoles.GetPoint(xRange.high, y);
      line(leftBorderOfHole.x, leftBorderOfHole.y, rightBorderOfHole.x, rightBorderOfHole.y);
    }

    String toString()
    {
      return "{{ " + xRange.low + "; " + xRange.high + "} ; y = " + y + "}\n";
    }
  }

  // Рисует массив дырок
  void DrawHoleLineArray(ArrayList<HoleLine> holes, PointCloud cloudWithHoles)
  {
    Iterator<HoleLine> holeIterator = holes.iterator();
    while(holeIterator.hasNext())
    {
      HoleLine hole = holeIterator.next();
      hole.Draw(cloudWithHoles);
    }
  }

}