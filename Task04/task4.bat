#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Найти все пары пользователей, оценивших один и тот же фильм. Устранить дубликаты, проверить отсутствие пар с самим собой. Для каждой пары должны быть указаны имена пользователей и название фильма, который они ценили. В списке оставить первые 100 записей."
echo ------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT DISTINCT u1.name, u2.name, m.title FROM ratings r1 JOIN ratings r2 ON r1.movieId = r2.movieId AND r1.userId < r2.userId JOIN users u1 ON r1.userId = u1.id JOIN users u2 ON r2.userId = u2.id JOIN movies m ON r1.movieId = m.movieId LIMIT 100;"
echo " "

echo "2. Найти 10 самых свежих оценок от разных пользователей, вывести названия фильмов, имена пользователей, оценку, дату отзыва в формате ГГГГ-ММ-ДД."
echo ------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RankedRatings AS (SELECT r.movieId, r.userId, r.rating, r.timestamp, ROW_NUMBER() OVER(PARTITION BY r.userId ORDER BY r.timestamp DESC) as rn FROM ratings r) SELECT m.title, u.name, rr.rating, rr.timestamp FROM RankedRatings rr JOIN movies m ON rr.movieId = m.movieId JOIN users u ON rr.userId = u.id WHERE rr.rn = 1 ORDER BY rr.timestamp DESC LIMIT 10;"
echo " "

echo "3. Вывести в одном списке все фильмы с максимальным средним рейтингом и все фильмы с минимальным средним рейтингом. Общий список отсортировать по году выпуска и названию фильма. В зависимости от рейтинга в колонке 'Рекомендуем' для фильмов должно быть написано 'Да' или 'Нет'."
echo ------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH AvgRatings AS (SELECT movieId, AVG(rating) as avg_rating FROM ratings GROUP BY movieId), MinMax AS (SELECT MAX(avg_rating) as max_r, MIN(avg_rating) as min_r FROM AvgRatings) SELECT m.title, CASE WHEN ar.avg_rating = mm.max_r THEN 'Да' ELSE 'Нет' END as 'Рекомендуем' FROM AvgRatings ar JOIN movies m ON ar.movieId = m.movieId CROSS JOIN MinMax mm WHERE ar.avg_rating = mm.max_r OR ar.avg_rating = mm.min_r ORDER BY CAST(substr(m.title, -5, 4) AS INTEGER), m.title;"
echo " "

echo "4. Вычислить количество оценок и среднюю оценку, которую дали фильмам пользователи-женщины в период с 2010 по 2012 год."
echo ------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT COUNT(r.rating) as count_ratings, AVG(r.rating) as avg_rating FROM ratings r JOIN users u ON r.userId = u.id WHERE u.gender = 'female' AND strftime('%Y', r.timestamp, 'unixepoch') BETWEEN '2010' AND '2012';"
echo " "

echo "5. Составить список фильмов с указанием их средней оценки и места в рейтинге по средней оценке. Полученный список отсортировать по году выпуска и названиям фильмов. В списке оставить первые 20 записей."
echo ------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH MovieAvg AS (SELECT movieId, AVG(rating) as avg_rating FROM ratings GROUP BY movieId), RankedMovies AS (SELECT movieId, avg_rating, RANK() OVER(ORDER BY avg_rating DESC) as rating_place FROM MovieAvg) SELECT m.title, rm.avg_rating, rm.rating_place FROM RankedMovies rm JOIN movies m ON rm.movieId = m.movieId ORDER BY CAST(substr(m.title, -5, 4) AS INTEGER), m.title LIMIT 20;"
echo " "

echo "6. Вывести список из 10 последних зарегистрированных пользователей в формате 'Фамилия Имя|Дата регистрации' (сначала фамилия, потом имя)."
echo ------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT substr(name, instr(name, ' ') + 1) || ' ' || substr(name, 1, instr(name, ' ') - 1) || '|' || register_date as formatted_user FROM users ORDER BY register_date DESC LIMIT 10;"
echo " "

echo "7. С помощью рекурсивного CTE составить таблицу умножения для чисел от 1 до 10."
echo ------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE numbers(n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM numbers WHERE n < 10) SELECT n1.n || 'x' || n2.n || '=' || (n1.n * n2.n) as multiplication FROM numbers n1 CROSS JOIN numbers n2 ORDER BY n1.n, n2.n;"
echo " "

echo "8. С помощью рекурсивного CTE выделить все жанры фильмов, имеющиеся в таблице movies (каждый жанр в отдельной строке)."
echo ------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE split(genres, rest) AS (SELECT '', genres || '|' FROM movies UNION ALL SELECT substr(rest, 0, instr(rest, '|')), substr(rest, instr(rest, '|') + 1) FROM split WHERE rest <> '') SELECT DISTINCT genres FROM split WHERE genres <> '' ORDER BY genres;"
echo " "