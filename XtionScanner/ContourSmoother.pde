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


		println("Done");
		println("");
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


	/**
	 * Сглаживает контур методом скользящей медианы
	 * 
	 */
	void SlidingMedianSmooth(PointCloud cloud)
	{
		ArrayList<PVector> list=new ArrayList<PVector>();
		PVector prev=null;
	  	//Число сглаживаемых точек
	  	int n=60;
	  	for (int i=0; i<cloud.ContourSize()/3; i++)
	  	{
	    
	    	Point2D p = cloud.GetContourPointCycle(i);
	    	list.add(cloud.GetPoint(p));

	    	if (list.size()>n)
	      		list.remove(0);
	 
	    	//Рисуем точки
	    	if (i>0)
	    	{
	      		PVector av = median(list);
	      		stroke(0,i,0);
	      		//strokeWeight(8);
	      		//point(av.x, av.y, av.z);

	      		if(prev!=null)
	      			line(prev.x, prev.y, prev.z, av.x, av.y, av.z);

	      		prev=av;

	    	}
	  	}
	}

	
	PVector average(ArrayList<PVector> list)
	{
		Pair<PVector, PVector> line = new Pair<PVector, PVector>(list.get(0), list.get(list.size()-1));
		//stroke(random(0,255),random(0,255),random(0,255));
		//line(line.X.x, line.X.y, line.X.z,line.Y.x, line.Y.y, line.Y.z);

		PVector av = new PVector();
	  	for (int i=0; i<list.size(); i++)
	    	av.add(list.get(i));

	  	av.div(list.size());
	  	return av; 
	}



	//Нахождение медианы списка точек
	PVector median(ArrayList<PVector> list)
	{
		Pair<PVector, PVector> line = new Pair<PVector, PVector>(list.get(0), list.get(list.size()-1));
		//stroke(0,0,255);
		//stroke(random(0,255),random(0,255),random(0,255));
		//strokeWeight(0.5);
		//line(line.X.x, line.X.y, line.X.z,line.Y.x, line.Y.y, line.Y.z);

		/*stroke(0,255,0);
	    strokeWeight(8);
	    point(line.Y.x, line.Y.y, line.Y.z);

	    stroke(255,0,0);
	    strokeWeight(6);
	    point(line.X.x, line.X.y, line.X.z);*/

		//ОПТИМИЗИРОВАТЬ
		//https://ru.wikipedia.org/wiki/Алгоритм_выбора

		/* Сортируем точки
		   В качестве значения мы берем расстояние точки
		   до прямой, соединящей концы этого наборра точек.
		   Это что-то вроде меры откланения точки от какого-то
		   среднего значения
		*/
		ArrayList<PVector> copy_l = (ArrayList<PVector>)list.clone();

		Collections.sort(copy_l, new VectorComarator(line));
	  	PVector a = copy_l.get(copy_l.size()/2);
	  	return a;
	}


	private class VectorComarator implements Comparator<PVector>
	{
		Pair<PVector, PVector> line;

		public VectorComarator(Pair<PVector, PVector> line)
		{
			this.line = line;
		}

		public int compare(PVector a, PVector b)
		{
			Float d_a = (Float)distance(a, line);
			Float d_b = (Float)distance(b, line);
			if(d_a<d_b)return -1;
			else if(d_a>d_b)return 1;
			else return 0;
		}
	}

}