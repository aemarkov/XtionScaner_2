
/**
 * Очищает облако, удаляет лишние элементы вне контура
 */
public class CloudClearer
{

	PointCloud CutCloud(PointCloud source_cloud)
	{
		println("Cutting cloud...");

		PVector sp = source_cloud.GetPointFromContour(0);
		float y_min=sp.y, y_max=sp.y;
		int j_min=0, j_max=0;

		//Поиск минимальной	и максимальной по Y точек
		for(int i = 0; i<source_cloud.ContourSize(); i++)
		{
			PVector p = source_cloud.GetPointFromContour(i);
			Point2D pc = source_cloud.GetContourPoint(i);

			if(p.y<y_min)
			{
				y_min = p.y;
				j_min = pc.y;
			}
			else if(p.y>y_max)
			{
				y_max = p.y;
				j_max = pc.y;
			}
		}


		//Шаг точке по Y - расстояние между граничными точками / разницу индексов граничных точек
		float dy = (y_max-y_min)/(j_max-j_min);

		//Иногда багает, надо точно сделать, что max>min
		if(j_min>j_max)
		{
			int tmp =j_max;
			j_max = j_min;
			j_min = tmp;
		}

		//Поиск наименьшей и наибольшей точки
		int h = source_cloud.Height();
		int w = source_cloud.Width();


		int removed;
		int contour_begin;

		for(int y = 0; y<h; y++)
		{
			contour_begin = -1;
			removed = 0;
			for(int x=0; x<w; x++)
			{
				if(source_cloud.IsContour(x,y))
				{
					contour_begin = x;
					break;
				}

				source_cloud.SetPoint(x,y, null);
				removed++;
			}

			if(contour_begin==-1)
				contour_begin=w;
			//println(y, " ", removed);

			for(int x = w-1; x>contour_begin; x--)
			{
				if(source_cloud.IsContour(x,y))
					break;

				source_cloud.SetPoint(x,y, null);
				removed++;
			}

			//PSHE-MAGIC
			//Если мы в контуре, но удалил все точки - значит дыра
			//ЗАполним ее, опираясь на данные вышестоящей линии
			if((removed==w-1)&&(y>=j_min) && (y<=j_max))
			{
				contour_begin = -1;
				int contour_end = 0;

				for(int k=0; k<w; k++)
					if(source_cloud.IsContour(k,y-1))
					{
						contour_begin = k;
						println(source_cloud.GetPoint(k, y-1)==null);
						break;
					}

				for(int k=w-1; k>contour_begin; k--)
					if(source_cloud.IsContour(k,y-1))
					{
						contour_end = k;
						println(source_cloud.GetPoint(k, y-1)==null);
						break;
					}

				for(int k = contour_begin; k<=contour_end; k++)
				{
					PVector p = source_cloud.GetPoint(k,y-1);
					if(p==null)continue;

					source_cloud.SetPoint(k, y, new PVector(p.x, p.y+dy, p.z));
				}

				println(removed);
			}

			//println(y, " ", j_min, " ",j_max);

		}


		println("Done...");
		println("");
		return source_cloud;

	}

	//Находит Х, У границы контура по заданному Y
	private Pair<Integer, Integer> find_borders(PointCloud cloud, int y)
	{
		PVector sp = cloud.GetPointFromContour(0);
		float x_min=Float.MAX_VALUE, x_max=Float.MIN_VALUE;
		int i_min=0, i_max=0;

		for(int i = 0; i<cloud.ContourSize(); i++)
		{
			PVector p = cloud.GetPointFromContour(i);
			Point2D pc = cloud.GetContourPoint(i);

			if((p.x<x_min) && (pc.y==y))
			{
				x_min = p.x;
				i_min = pc.x;
			}
			else if((p.x>x_max) && (pc.y==y))
			{
				x_max = p.x;
				i_max = pc.x;
			}
		}

		return new Pair<Integer,Integer>(min(i_min, i_max), max(i_min, i_max));
	}
}
