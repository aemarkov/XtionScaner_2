import java.util.*;

/**
 * Сглаживание контура
 * 1) уменьшает число точек контура
 * 2) строит кривую безье
 */
public class ContourSmoother
{
	/**
	 *	Уменьшает количество точек, используя алгоритм Рамера-Дугласа-Пекера
	 *  https://ru.wikipedia.org/wiki/Алгоритм_Рамера_—_Дугласа_—_Пекера
	 * 
	 *  source_cloud - исходное облако
	 *  epsilon максимальное расстояние от точки до прямой, при котором она еще
	 *  выбрасывается
	 */
	public PointCloud SimplifyContour(PointCloud source_cloud, float epsilon)
	{
		println("Simplifing contour...");

		int points_count =  source_cloud.ContourSize();

		//Стек индексов вершин
		Stack<Pair<Integer,Integer>> points_stack = new Stack<Pair<Integer,Integer>>();

		//Массив - сохранять точки или нет
		boolean[] keep_point = new boolean[points_count];
		for(int i = 0; i<keep_point.length; i++)
			keep_point[i]=true;

		//Заносим в стек первую и последнюю точку
		points_stack.push(new Pair<Integer,Integer>(0, points_count-1));
		
		//Выполняем алгоритм
		while(!points_stack.empty())
		{
			//Берем граничные точки очередного разбиения
			int start_index = points_stack.peek().X;		//A
			int end_index = points_stack.peek().Y;			//B
			points_stack.pop();


			//Ищем наиболее удаленную от линии AB точку
			float max_dist = 0;
			int max_index = start_index;
			for(int i=start_index+1; i<end_index; i++)
			{
				if(keep_point[i])
				{
					float d = distance(source_cloud.GetPointFromContour(i), 
							new Pair<PVector, PVector>(
								source_cloud.GetPointFromContour(start_index),
								source_cloud.GetPointFromContour(end_index)));

					//println(d);
					//println("----");

					if(d>max_dist)
					{
						max_dist = d;
						max_index = i;
					}
				}
			}

			//Если эта точка (С) откланяется от прямой на расстояние
			//Больше, чем константа, то разбиваем отрезок AB на AC и CB
			if(max_dist>epsilon)
			{
				points_stack.push(new Pair<Integer, Integer>(start_index, max_index));
				points_stack.push(new Pair<Integer, Integer>(max_index, end_index));
			}
			else
			{
				//Все точки между A и B лежат достаточно близко к прямой, чтобы выкинуть их
				for(int i = start_index+1; i<end_index; i++)
					keep_point[i]=false;
			}

		}

		PointCloud new_cloud = source_cloud.clone_cloud();

		for(int i = 0; i<points_count; i++)
			if(keep_point[i])
				new_cloud.AddContourPoint(source_cloud.GetContourPoint(i));


		return new_cloud;
	}


	//Расстояние от точки до прямой в пространстве
	private float distance(PVector point, Pair<PVector,PVector> line)
	{
		/*
			Расстояние от точки до прямой в 3д:
			d = |M0M1 x s|/|s|
			M0 - точка
			M1 - некая точка на прямой
			s - направляющий вектор прямой
		*/


		PVector s = PVector.sub(line.Y, line.X);
		//println("s",s);

		PVector m0m1 = PVector.sub(line.X, point);
		//println("m0m1", m0m1);

		//Векторное произведение
		PVector cr_pr = m0m1.cross(s);		

		//Расстояние
		float dist = cr_pr.mag()/s.mag();
		return dist;
	}

}