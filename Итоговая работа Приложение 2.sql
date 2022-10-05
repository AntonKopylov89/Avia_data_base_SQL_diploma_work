--ЗАДАНИЕ №1
--В каких городах больше одного аэропорта?
select city as "Город", count(city) as "Количество аэропортов" -- с помощью функции count подсчитываем количество записей в колонке city
from airports
group by city -- сгруппируем значения по городам
having count(city) > 1; -- выведем только те города, в которых более одного аэропорта

--ЗАДАНИЕ №2
-- В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?
select distinct a.airport_code, a.airport_name
from airports a join flights f on f.arrival_airport = a.airport_code 
join aircrafts a2 on a2.aircraft_code = f.aircraft_code
where a2.aircraft_code = (
  select a3.aircraft_code 
  from aircrafts a3 
  order by a3."range" desc
  limit 1
);

--ЗАДАНИЕ №3
-- Вывести 10 рейсов с максимальным временем задержки вылета
select flight_no as "Номер рейса", actual_departure - scheduled_departure as "Длительность задержки" -- вычисляем время задержки вычитанием столбца с планируемым временем вылета из столбца с фактическим временем вылета
from flights f 
where actual_departure is not null -- исключаем строки с пустыми значениями фактического времени вылета
order by "Длительность задержки" desc -- упорядочиваем по длительности задержки от большего к меньшему
limit 10; -- ограничиваем результат десятью первыми записями


--ЗАДАНИЕ №4
-- Были ли брони, по которым не были получены посадочные талоны?
select distinct b.book_ref as "Номер бронирования", b.book_date as "Дата бронирования", case when bp.boarding_no is null then 'Отсутствует' end as "Посадочный талон" -- используем условный оператор case, чтобы заменить null значения номеров посадочных талонов строкой "Отсутствует"
from bookings b  
join tickets t on t.book_ref = b.book_ref -- присоединяем таблицу tickets по столбцу book_ref
left join boarding_passes bp on bp.ticket_no = t.ticket_no -- присоединяем таблицу boarding_passes по столбцу ticket_no, используем left join, чтобы получить все данные из таблицы boarding_passes, в том числе и те, что не совпадают с даннми из таплицы tickets и принимают значение null
where bp.boarding_no is null; -- оставляем только строки столбца с номерами посадочных талонов значения в которых отсутствуют

--ЗАДАНИЕ №5
-- Найдите количество свободных мест для каждого рейса, их % отношение к общему количеству мест в самолете.
-- Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день. Т.е. в этом столбце должна отражаться накопительная сумма - сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах в течении дня.
with aircraft_seats as ( -- создадим cte, в котором хранится общее количество мест на каждом воздушном судне
select s.aircraft_code, count(s.seat_no) as "Общее количество мест" -- используем функцию count, чтобы получить количество строк с местами по каждому воздушному судну
from seats s 
group by s.aircraft_code 
), 
seats_with_boarding_passes as ( -- создадим cte, хранящее количество свободных и занятых мест на каждом рейсе
select f.flight_id, f.flight_no, f.departure_airport,f.actual_departure, f.aircraft_code, 
count(bp.boarding_no) as "Количество занятых мест",  -- используем функцию count, чтобы получить количество строк с посадочными талонами
aircraft_seats."Общее количество мест", 
"Общее количество мест" - count(bp.boarding_no) as "Количество свободных мест" -- посчитаем количество свободных мест путем вычитание количества мест с посадочными талонами из общего количества мест
from flights f 
join boarding_passes bp on bp.flight_id = f.flight_id -- присоединим таблицу boarding_passes по столбцу flight_id
join aircraft_seats on aircraft_seats.aircraft_code = f.aircraft_code -- присоединим cte aircraft_seats по столбцу aircraft_code 
group by f.flight_id, aircraft_seats."Общее количество мест"
)
select flight_no as "Номер рейса", departure_airport as "Аэропорт вылета", actual_departure::date as "Дата вылета", "Количество свободных мест", 
round("Количество свободных мест" / "Общее количество мест"::numeric, 2) * 100 as "Свободные места в %", -- посчитаем количество свободных мест в процентов и округлим его до целых чисел с помощью функции round 
sum ("Количество свободных мест") over (partition by (departure_airport, actual_departure::date)  order by departure_airport) as "Вылетевшие за день пассажиры" -- используя оконную функцию посчитаем количество вывезеных в день пассажиров с накопительным итогом, отсортировав по аэропорту вылета 
from seats_with_boarding_passes;

--ЗАДАНИЕ №6
-- Найдите процентное соотношение перелетов по типам самолетов от общего количества.
select distinct a.model as "Модель воздушного судна", 
sum(count(f.flight_id)) over (partition by a.model) as "Общее количество рейсов", -- используем оконную функции sum с агрегатной функцией count для подсчета общего количества рейсов для каждой модели воздушного судна  
round(count(flight_id) over (partition by a.model) / sum(count(f.flight_id)) over ()::numeric * 100, 1) as "% от общего количества рейсов" -- воспользуемся оконными функциями count и sum для подсчета % перелетов для каждого воздушного судна от общего количества перелетов, приведем получившиеся значения к типу numeric и округлим до 1 знака после запятой
from flights f 
join aircrafts a on a.aircraft_code = f.aircraft_code -- присоединим таблицу aircrafts по столбцу aircraft_code
where f.actual_departure is not null -- исключим еще не вылетевшие рейсы
group by a.model, f.flight_id;

--ЗАДАНИЕ №7
-- Были ли города, в которые можно добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?
with min_max_amount as ( -- создаем cte, в котором будут расчитываться минимальная стоимость бизнесс-класса и максимальная стоимость эконом-класса
select flight_id, fare_conditions,
case when fare_conditions = 'Business' then min(amount) end as "Мин. стоимость бизнесс-класса",
case when fare_conditions = 'Economy' then max(amount) end as "Макс. стоимость эконом-класса"
from ticket_flights tf 
group by fare_conditions, flight_id 
)
select f.flight_no as "Номер рейса", f.arrival_airport as "Аэропорт прибытия", a.city as "Город прибытия", m.fare_conditions as "Класс обслуживания"
from min_max_amount m
join flights f on f.flight_id = m.flight_id
join airports a on a.airport_code = f.departure_airport 
group by m.flight_id, f.flight_id, a.airport_code, m."Мин. стоимость бизнесс-класса", m."Макс. стоимость эконом-класса", m.fare_conditions
having min("Мин. стоимость бизнесс-класса") < max("Макс. стоимость эконом-класса"); -- зададим условие, при выполнении которого будут выведены данные о городах в которые  можно добраться бизнес-классом дешевле, чем эконом-классом
-- Ответ: таких городов нет.

--ЗАДАНИЕ №8
-- Между какими городами нет прямых рейсов?
create view cities_with_direct_flights as -- создаем представление, в котором будут города, между которыми есть прямые рейсы
  select a.city as "Город вылета", a2.city as "Город прилета"
  from flights f 
  join airports a on a.airport_code  = f.arrival_airport 
  join airports a2 on a2.airport_code = f.departure_airport
  
select a.city as "Город вылета", a2.city as "Город прилета"
from airports a cross join airports a2 -- с помощью оператора cross join получаем декартово произведение таблиц airports
where a.city != a2.city -- задаем условия, позволяющее исключить один и тот же город вылета и прибытия
except select * from cities_with_direct_flights; -- оператор except позволяет вывести только те значения городов, которые отсутствуют в представлении

--ЗАДАНИЕ №9
-- Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной дальностью перелетов  в самолетах, обслуживающих эти рейсы.
with range_of_cities as ( -- создади cte, в котором посчитаем расстояние между аэропортами
  select distinct a.airport_name as "Аэропорт вылета", a2.airport_name as "Аэропорт прибытия", a3.model as "Воздушное судно, выполняющее рейс", a3."range" as "Максимальная дальность полета", 
  round((acos(sin(radians(a.latitude)) * sin(radians(a2.latitude)) + cos(radians(a.latitude)) * cos(radians(a2.latitude)) * cos(radians(a.longitude - a2.longitude))) * 6371)::numeric, 0) as "Расстояние между аэропортами" 
  -- Посчитаем расстояние между аэропортами по формуле: "расстояние между двумя точками A и B на земной поверхности", 6371 км радиус окружности (Земли), используем оператор radians, который преобразует градусы в радианы, округлим получившееся значение до целого числа
  from flights f 
  join airports a on a.airport_code = f.departure_airport 
  join airports a2 on a2.airport_code = f.arrival_airport 
  join aircrafts a3 on a3.aircraft_code = f.aircraft_code 
)
select *, 
  case when range_of_cities."Максимальная дальность полета" > range_of_cities."Расстояние между аэропортами" then 'Долетит' 
  else 'Не долетит' 
  end as "Хватит ли дальности полета" -- зададим условие, которое будет выводить значение долетит или нет воздушное судно, выполняющее рейс между аэропортами
from range_of_cities;
