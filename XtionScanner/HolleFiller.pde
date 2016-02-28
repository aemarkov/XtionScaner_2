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
		//println("Smoothing contour...");

		//Проврека на то, что контур уже найден


		if(source_cloud.ContourSize()==0)
			throw new Error("Contour doesn't exist");

		//В качестве начальной точки берем 0ую точку контура //<>//
		Point2D start_point = source_cloud.GetContourPoint(0);

		//Поиск конечной строки
		Point2D end_point = get_last_point(source_cloud);

		for(int y = start_point.y; y<end_point.y; y++)
		{
			fill_row(source_cloud, y);
		}


		return source_cloud;

	}


	//Возвращает индекс точки контура, которая находиться ниже все
	private Point2D get_last_point(PointCloud cloud)
	{
		Point2D min_pos = cloud.GetContourPoint(0);
		int min_index = 0;

		for(int i = 1; i<cloud.ContourSize(); i++)
		{
			Point2D cur_point = cloud.GetContourPoint(i);

			if(cur_point.y>min_pos.y)
			{
				min_pos = cur_point;
				min_index = i;
			}
		}
		return min_pos;
	}


	//Заполняет отверстия в строке (если есть)
	private void fill_row(PointCloud cloud, int y)
	{
		//Определяем левую и правую точки границы на этой высоте
		//Для этого "пускаем луч" отмечая точки, пренадлежащие границе
		//Совсем неэффективно

		int start_x=0, end_x=0;

		//Находим левую границу
		for(int x = 0; x<cloud.Width(); x++)
		{
			if(is_border(cloud, new Point2D(x,y)))
			{
				start_x = x;
				break;
			}
		}

		//Находим правую границу
		for(int x = cloud.Width()-1; x>start_x; x--)
		{
			if(is_border(cloud, new Point2D(x,y)))
			{
				end_x = x;
				break;
			}
		}

		PVector v1 = cloud.GetPoint(start_x,y);
		PVector v2 = cloud.GetPoint(end_x,y);

		strokeWeight(3);
		stroke(0, 255, 0);
		point(v1.x, v1.y, v1.z);

		stroke(0, 0, 255);
		point(v2.x, v2.y, v2.z);

		fill_row_2(cloud, start_x, end_x, y);

	}


	//Действительно заполняет точки
	private void fill_row_2(PointCloud cloud, int start_x, int end_x, int y)
	{
		int x = start_x;								//Текущая позиция
		PVector last_point = cloud.GetPoint(x,y);		//Последняя существующая точка
		PVector cur_point;

		//Проходим по всей строке
		x++;
		while(x<end_x)
		{
			cur_point=cloud.GetPoint(x,y);

			
			if(cur_point==null)
			{
				//Если точки не существует, находим слудующую
				//существуюущую точку и заполняем пробел

				int next_index = get_next_existing_point(cloud, x, end_x, y);
				PVector next_point = cloud.GetPoint(next_index, y);

				stroke(0,255,255);
				strokeWeight(1);
				line(last_point.x, last_point.y, last_point.z, next_point.x, next_point.y, next_point.z);

				x=next_index;
			}
			else
			{
				last_point = cur_point;
				x++;
			}

		}
	}


	//Находит следующую существующую точек в пределах строки
	private int get_next_existing_point(PointCloud cloud,  int start_x, int end_x, int y)
	{
		int x = start_x;
		while(x<=end_x)
		{
			if(cloud.GetPoint(x,y)!=null)
				return x;

			x++;
		}

		return end_x;
	}


	//Проверяет, принадлежит ли точка границе
	private boolean is_border(PointCloud cloud, Point2D p) 
	{
		for(int i = 0; i<cloud.ContourSize(); i++)
		{
			Point2D contour_point=cloud.GetContourPoint(i);
			if((contour_point.x==p.x)&&(contour_point.y==p.y))
			{
				return true	;
			}
		}

		return false;
	}
} 