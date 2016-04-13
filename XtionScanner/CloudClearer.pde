
/**
 * Очищает облако, удаляет лишние элементы вне контура
 */
public class CloudClearer
{

	PointCloud CutCloud(PointCloud source_cloud)
	{
		println("Cutting cloud...");

		//PointCloud destination = new PointCloud(source_cloud.Width(), source_cloud.Height());

		//Поиск наименьшей и наибольшей точки
		int h = source_cloud.Height();
		int w = source_cloud.Width();
		
		boolean is_in_contour;

		for(int y = 0; y<h; y++)
		{
			is_in_contour = false;
			for(int x=0; x<w; x++)
			{
				if(!is_in_contour && source_cloud.IsContour(x,y))
					is_in_contour = true;
				else if(is_in_contour && source_cloud.IsContour(x,y))
					is_in_contour = false;

				if(!is_in_contour)
					source_cloud.SetPoint(x,y, null);
			}
		}		

		/*
		PVector sp = source_cloud.GetPointFromContour(0);
		float y_min=sp.y, y_max=sp.y;
		int j_min=0, j_max=0;

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

		stroke(0,255,0);

		//Проходим по всем точкам и добавляем только те, что в контуре
		for(int j = j_max; j<=j_min; j++)
		{
			Pair<Integer, Integer> borders = find_borders(source_cloud, j);
			for(int i = 0; i<borders.X-1; i++)
				source_cloud.SetPoint(i, j, null);

			for(int i = borders.Y+1; i<cloud.Width(); i++)
				source_cloud.SetPoint(i, j, null);

		}*/

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