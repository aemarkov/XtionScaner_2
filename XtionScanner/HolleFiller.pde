/*
	Этот класс заполняет отверстия в PointCloud

	Принцип работы: 
		Построчно сканирует облако в пределах контура.
		В строке, если встречается разрыв, находит его границы и заполняет.

		При проходе построчно возникает вопрос - с каких индексов в облаке начать?
		Воспользуемся тем фактом, что точка 0 контура - САМАЯ ПЕРВАЯ ВСТРЕТИВШАЯСЯ НЕ ПУСТАЯ ТОЧКА.
		Это одна из обязательных особенностей контура, поэтому мы можем начать с нее.
*/

public class HoleFiller
{


	public PointCloud Fill(PointCloud source_cloud)
	{
		println("Filling holes...");

		
		PointCloud dest_cloud = source_cloud.clone();

		//Проврека на то, что контур уже найден
		if(source_cloud.ContourSize()==0)
			throw new Error("Contour doesn't exist");

		//В качестве начальной точки берем 0ую точку контура //<>//
		Point2D start_point = source_cloud.GetContourPoint(0);

		//Поиск конечной строки
		Point2D end_point = get_last_point(source_cloud);

		for(int y = start_point.y; y<end_point.y; y++)
			find_and_fill_row(source_cloud, dest_cloud, y);
		

		FindContour(dest_cloud);

		println("Done");
		println("");
		return dest_cloud;

	}


	//Возвращает индекс точки контура, которая находиться ниже все
	private Point2D get_last_point(PointCloud source_cloud)
	{
		Point2D min_pos = source_cloud.GetContourPoint(0);
		int min_index = 0;

		for(int i = 1; i<source_cloud.ContourSize(); i++)
		{
			Point2D cur_point = source_cloud.GetContourPoint(i);

			if(cur_point.y>min_pos.y)
			{
				min_pos = cur_point;
				min_index = i;
			}
		}
		return min_pos;
	}


	//Заполняет отверстия в строке (если есть)
	private void find_and_fill_row(PointCloud source_cloud, PointCloud dest_cloud, int y)
	{
		//Определяем левую и правую точки границы на этой высоте
		//Для этого "пускаем луч" отмечая точки, пренадлежащие границе
		//Совсем неэффективно

		int start_x=0, end_x=0;

		//Находим левую границу
		for(int x = 0; x<source_cloud.Width(); x++)
		{
			if(is_border(source_cloud, new Point2D(x,y)))
			{
				start_x = x;
				break;
			}
		}

		//Находим правую границу
		for(int x = source_cloud.Width()-1; x>start_x; x--)
		{
			if(is_border(source_cloud, new Point2D(x,y)))
			{
				end_x = x;
				break;
			}
		}

		/*PVector v1 = source_cloud.GetPoint(start_x,y);
		PVector v2 = source_cloud.GetPoint(end_x,y);

		strokeWeight(3);
		stroke(0, 255, 0);
		point(v1.x, v1.y, v1.z);

		stroke(0, 0, 255);
		point(v2.x, v2.y, v2.z);*/

		fill_row(source_cloud, dest_cloud, start_x, end_x, y);

	}


	//Действительно заполняет точки
	private void fill_row(PointCloud source_cloud, PointCloud dest_cloud, int start_x, int end_x, int y)
	{
		int x = start_x;								//Текущая позиция
		//PVector last_point = source_cloud.GetPoint(x,y);		//Последняя существующая точка
		//PVector cur_point;

		//Проходим по всей строке
		x++;
		while(x<end_x)
		{
						
			if(source_cloud.GetPoint(x,y)==null)
			{
				//Если точки не существует, находим слудующую
				//существуюущую точку и заполняем пробел

				int next_index = get_next_existing_point(source_cloud, x, end_x, y);

				//Теперь собственно заполняем
				fill_hole(source_cloud, dest_cloud, x-1, next_index, y);

				x=next_index;
			}
			else
			{
				x++;
			}

		}
	}

	//Заполняет линию отверстие
	private  void fill_hole(PointCloud source_cloud, PointCloud dest_cloud, int start_x, int end_x, int y)
	{
		PVector last_point = source_cloud.GetPoint(start_x, y);
		PVector next_point = source_cloud.GetPoint(end_x, y);

		stroke(0,255,255);
		strokeWeight(1);
		//line(last_point.x, last_point.y, last_point.z, next_point.x, next_point.y, next_point.z);

		/*
			Немного матанчика:
			A = last_point
			B = next_point

			Рассмотрим вектор AB. Разделим его длину на N частей
			(сколько нам надо точек), и получим маленький вектор V, который
			будем использовать для перехода к очередной точке.

			Ее координата будет:
			A + V*i, где i - номер точки, считая от A
			
		*/		

		//Вычисляем число шагов
		int n = end_x - start_x;

		//Вычисляем вектор шага
		PVector v = next_point.copy();
		v.sub(last_point);
		v.div(n);

		for(int i = 1; i<=n; i++) 
		{
			PVector step = v.copy();
			step.mult(i);

			PVector p =last_point.copy();
			p.add(step);

			dest_cloud.SetPoint(start_x+i,y,p);
		}
	}


	//Находит следующую существующую точку в пределах строки
	private int get_next_existing_point(PointCloud source_cloud,  int start_x, int end_x, int y)
	{
		int x = start_x;
		while(x<=end_x)
		{
			if(source_cloud.GetPoint(x,y)!=null)
				return x;

			x++;
		}

		return end_x;
	}


	//Проверяет, принадлежит ли точка границе
	private boolean is_border(PointCloud source_cloud, Point2D p) 
	{
		for(int i = 0; i<source_cloud.ContourSize(); i++)
		{
			Point2D contour_point=source_cloud.GetContourPoint(i);
			if((contour_point.x==p.x)&&(contour_point.y==p.y))
			{
				return true	;
			}
		}

		return false;
	}
} 