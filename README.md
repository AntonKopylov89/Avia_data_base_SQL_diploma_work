# Задание

## Описание задания
Для выполнения работы Вам необходимо:

1. Перейти по ссылке и ознакомиться с описанием базы данных: edu.postgrespro.ru...okings.pdf
1. Подключиться к базе данных avia по одному из следующих вариантов:
    - облачное подключение, те же настройки, что и у dvd-rental, только название базы demo, схема bookings.
    - импорт sql запроса из sql файла, представленных на 2 странице описания базы
    - восстановить базу из .backup файла по ссылке avia
1. Оформить работу согласно “Приложения №1” в формате .pdf или .doc
    - перелет, рейс = flight_id
1. Создать запросы, позволяющие ответить на вопросы из “Приложения №2”, решения должны быть приложены в формате .sql одним файлом
1. Отправить работу на проверку
Критерии оценивания итоговой работы

Приложение №1

1.	В работе использовался локальный тип подключения. Если база была развернута из .sql или .backup файла, необходимо приложить скриншот успешного импорта или восстановления
2.	Скриншот ER-диаграммы из DBeaver согласно вашего подключения	
3.	Краткое описание БД - из каких таблиц и представлений состоит	
4.	Развернутый анализ БД - описание таблиц, логики, связей и бизнес области (частично можно взять из описания базы данных, оформленной в виде анализа базы данных). Бизнес задачи, которые можно решить, используя БД	
5.	Список SQL запросов из приложения №2 с описанием логики их выполнения	


Приложение №2

1.	В каких городах больше одного аэропорта?		
2.	В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?	Подзапрос	
3.	Вывести 10 рейсов с максимальным временем задержки вылета	Оператор LIMIT	
4.	Были ли брони, по которым не были получены посадочные талоны?	Верный тип JOIN	
5.	Найдите количество свободных мест для каждого рейса, их % отношение к общему количеству мест в самолете. Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день. Т.е. в этом столбце должна отражаться накопительная сумма - сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах в течении дня	Оконная функция; подзапросы или/и cte	
6.	Найдите процентное соотношение перелетов по типам самолетов от общего количества	Подзапрос или окно; оператор ROUND	
7.	Были ли города, в которые можно добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?	CTE	
8.	Между какими городами нет прямых рейсов?	Декартово произведение в предложении FROM; самостоятельно созданные представления (если облачное подключение, то без представления); оператор EXCEPT	
9.	Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной дальностью перелетов в самолетах, обслуживающих эти рейс*	Оператор RADIANS или использование sind/cosd; CASE	
* В облачной базе координаты находятся в столбце airports_data.coordinates - работаете, как с массивом. В локальной базе координаты находятся в столбцах airports.longitude и airports.latitude.
Кратчайшее расстояние между двумя точками A и B на земной поверхности (если принять ее за сферу) определяется зависимостью:
d = arccos {sin(latitude_a)·sin(latitude_b) + cos(latitude_a)·cos(latitude_b)·cos(longitude_a - longitude_b)}, где latitude_a и latitude_b — широты, longitude_a, longitude_b — долготы данных пунктов, d — расстояние между пунктами измеряется в радианах длиной дуги большого круга земного шара.
Расстояние между пунктами, измеряемое в километрах, определяется по формуле:
L = d·R, где R = 6371 км — средний радиус земного шара.