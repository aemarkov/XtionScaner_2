/**************************************************************************************************
 *                              ЧТЕНИЕ ОБЛАКА ТОЧЕК ИЗ ФАЙЛА OCF
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

  public class OCFReader implements ICloudReader
  {
  	public PointCloud OpenCloud(String filename)
  	{
  		PointCloud cloud;

  		println("Reading cloud point...");

		BufferedReader r = createReader(filename);
    	String line;

    	int v=-1, w=-1, h=-1;

    	//Чтение файла
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
        		Pair<String,Integer>  pair = parse_line(line);

        		//Заполняем соотвествующие значения. в зависимости от этой строки
        		if(pair.X.equals("VERSION"))
          			v=pair.Y;
        		else if(pair.X.equals("WIDTH"))
          			w=pair.Y;
        		if(pair.X.equals("HEIGHT"))
          			h=pair.Y;
      		}

      		//Проверка на то, что все необходимые значения ввеедены
      		if((v==-1)||(w==-1)||(h==-1))
        		throw new Error("Invalid file format: expected parameters not set");

        	//Создаем облако на основе прочитанных значений
        	cloud = new PointCloud(w, h);


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
            			cloud.SetPoint(639-x, 479-y, new PVector(xc, yc, zc));
          			}
        		}
        		y++;
      		}
    	}
    	catch (Exception e)
    	{
    		println("Open cloud error");
    		return null;
    	}

    	println("Done");
    	println("");
    	return cloud;
  	}


  	//Парсинг строки ключ-значение
    Pair<String,Integer> parse_line(String line)
  	{
    	String[] strings = line.split("=");
    	return new Pair<String,Integer>(strings[0], Integer.parseInt(strings[1]));
  	}
  }