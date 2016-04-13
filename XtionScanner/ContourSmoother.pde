import java.util.*;

/**
 * Сглаживание контура
 * 1) уменьшает число точек контура
 * 2) строит кривую безье
 */
public class ContourSmoother
{
	//Сглаживает контур
	public void SmoothContour(PointCloud cloud, int count, int step, float eps)
	{

	  	/*
	    Алгоритм:
	    1. Сглаживаем контур
	    2. Фиксим индексы, чтобы форма контура в координатах и в "форма в индексах"
	       совпадали

	    Вычисление координат по индексам
	    x = x0 + i*dx
	    y = y0 + j*dx

	    Вычисление индексов новых точек
	    i' = (x' - x0)/dx
	    j' = (y' - y0)/dy 

	    Видим, что нужны (X0, y0) (dx,dy). Их надо найти ДО(!!!)
	    сглаживания контура

	    Берем строку и две точки (x1, y-) (x2, y-) в начале и конце
	      Y-нас не интересует, потому что в строке он изменяется мало

	      Решаем систему:
	      x1 = x0 + i1*dx
	      x2 = x0 + i2*dx

	      Решение:
	      dx = (x2-x1)/(i2-i1)
	      x0 = x1 - i1*dx
	      

	      Аналогично поступаем с Y: берем две точки по вертикали
	      y1 = y0 + j1*dy
	      y2 = y0 + j2*dy

	      dy = (y2-y1)/(j2-j1)
	      y0 = y1 - j1*dy

	  	*/

	  	//Находим значения
	  	float x0, y0, dx, dy;
	  	PVector sp = cloud.GetPointFromContour(0);
	  	float x_min=sp.x, x_max=sp.x, y_min=sp.y, y_max=sp.y;
	  	//x_min=sp.x; x_max=sp.x; y_min=sp.y; y_max=sp.y;

	  	int i_min=0, i_max=0, j_min = 0, j_max=0;

	  	//Просто ищем минимальное и максимальное значение
	  	for(int i = 0; i<cloud.ContourSize(); i++)
	  	{
	    	PVector p = cloud.GetPointFromContour(i);
	    	Point2D pc = cloud.GetContourPoint(i);

	    	//X
	    	if(p.x<x_min)
	    	{
	     		x_min=p.x;
	    		i_min=pc.x;
	    	}
	   	 	else if(p.x>x_max)
	    	{
	      		x_max=p.x;
	      		i_max=pc.x;
	    	}

	    	//Y
	    	if(p.y<y_min)
	    	{
	      		y_min=p.y;
	      		j_min=pc.y;
	    	}
	    	else if(p.y>y_max)
	    	{
	      		y_max=p.y;
	      		j_max=pc.y;
	    	}

	  	}


		//Расчет этих параметров
	  	dx=(x_max-x_min)/(i_max-i_min);
	  	x0=x_min - dx*i_min;

	  	dy=(y_max-y_min)/(j_max-j_min);
	  	y0=y_min - dy*j_min;

	  	println(x0, ' ', y0, "; ", dx, ' ',dy);

	  	//Сглаживаем контур
	  	//Копия контура
	  	ArrayList<PVector> copy_contour = new ArrayList<PVector>();
	  	for(int i = 0; i<cloud.ContourSize(); i++)
	    	copy_contour.add(cloud.GetPointFromContour(i).copy());



		for(int i = 0; i<count; i++)
	  		alex_smooth_contour(copy_contour, step, eps);
	  	//simple_smooth(copy_contour);

	  	//Фиксим индексы контура
	  	repairContour(cloud, copy_contour, new PVector(x0,y0), new PVector(dx, dy));
	}


	// Step - какая разница в индексах будет между усредняемыми точками
	// Суть алгоритма: берутся две точки, координаты второй из них приравниваются среднему этих 2-ух,
	// если они далеко друг от друга
	void alex_smooth_contour(List<PVector> contour, int step, float eps)
	{
	  PVector a, b;             // Текущая и следующая точка
	  for (int i = 0; i <= contour.size(); i++)
	  {
	    a = get_point_cycle(contour, i);
	    b = get_point_cycle(contour, i+step);

	    if (PVector.dist(a, b) > eps)
	    {
	      b = new PVector((a.x+b.x)/2, (a.y+b.y)/2, (a.z+b.z)/2);
	      set_point_cycle(contour, i, b);
	    }
	  }
	}


	void simple_smooth(List<PVector> contour)
	{
		//Averaging list
		ArrayList<PVector> list=new ArrayList<PVector>();
		int n=50;  //number of averaging points

		for (int i=-n; i<contour.size(); i++)
		{
			//Add point to the list
			//Keep number of points is N
			PVector p = get_point_cycle(contour, i);
			list.add(p);
			if (list.size()>n)
			list.remove(0);
		 
			//Drawing points
			if (i>0)
			{
				PVector av = average(list);
				//point(av.x, av.y, av.z);
				contour.set(i,av);
			}
		}
	}

	//Average list of coordinates
	PVector average(ArrayList<PVector> list)
	{
		PVector av = new PVector();
	  	for (int i=0; i<list.size(); i++)
	    	av.add(list.get(i));

	  	av.div(list.size());
	  	return av;
	}

	//Делает из сглаженных точек контур
	void repairContour(PointCloud cloud, List<PVector> contour, PVector center, PVector step)
	{

	  //ArrayList<Point2D> new_contour=new ArrayList<Point2D>();
	  cloud.ClearContour();

	  //Проходим по сглаженному контуру и генерим индексы
	  for(int i=0; i<contour.size(); i++)
	  { 
	    /*
	        Вычисление индексов новых точек
	      i' = (x' - x0)/dx
	      j' = (y' - y0)/dy 
	    */

	    PVector point = contour.get(i);
	    int _i = (int)((point.x - center.x)/step.x);
	    int _j = (int)((point.y - center.y)/step.y);

	    cloud.SetPoint(_i, _j, point);

	    /*print(_i, " ", _j);
	    if(is_in_contour(cloud, _i, _j))
	    {
	    	//_i++;
	    	_j++;
	    	if(is_in_contour(cloud, _j, _j))
	    		println(" already in contour");
	    	else println();
	    }*/

	    cloud.AddContourPoint(_i, _j);
	  }
	}

	boolean is_in_contour(PointCloud cloud, int x, int y)
	{
		for(int i = 0; i<cloud.ContourSize(); i++)
		{
			Point2D p = cloud.GetContourPoint(i);;
			if(p.x==x && p.y==y)
				return true;
		}

		return false;
	}


	//Возвращет точку, словно контур замкнут
	PVector get_point_cycle(List<PVector> contour, int index)
	{
	  return contour.get(get_cycle_index(contour, index));
	}

	//Задает точку, словно контур замкнут
	void set_point_cycle(List<PVector> contour, int index, PVector value)
	{
	  contour.set(get_cycle_index(contour, index),value);
	}

	//Возвращает индекс точки, для перевода из замкнутого в обычный
	int get_cycle_index(List<PVector> contour, int index)
	{
	  if (index<0)
	   index=contour.size()+index;
	  else if (index>=contour.size())
	    index=index-contour.size();
	  return index;
	}
}