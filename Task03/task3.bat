#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Составить список фильмов, имеющих хотя бы одну оценку. Список фильмов отсортировать по году выпуска и по названиям. В списке оставить первые 10 фильмов."
echo ------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT DISTINCT m.title, m.genres FROM movies m JOIN ratings r ON m.movieId = r.movieId ORDER BY CAST(substr(m.title, -5, 4) AS INTEGER), m.title LIMIT 10;"
echo " "

echo "2. Вывести список всех пользователей, фамилии (не имена!) которых начинаются на букву 'A'. Полученный список отсортировать по дате регистрации. В списке оставить первых 5 пользователей."
echo ------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT name, register_date FROM users WHERE name LIKE '% A%' ORDER BY register_date LIMIT 5;"
echo " "

echo "3. Написать запрос, возвращающий информацию о рейтингах в более читаемом формате: имя и фамилия эксперта, название фильма, год выпуска, оценка и дата оценки в формате ГГГГ-ММ-ДД. Отсортировать данные по имени эксперта, затем названию фильма и оценке. В списке оставить первые 50 записей."
echo ------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT u.name, m.title, r.rating, r.timestamp FROM ratings r JOIN users u ON r.userId = u.id JOIN movies m ON r.movieId = m.movieId ORDER BY u.name, m.title, r.rating LIMIT 50;"
echo " "

echo "4. Вывести список фильмов с указанием тегов, которые были им присвоены пользователями. Сортировать по году выпуска, затем по названию фильма, затем по тегу. В списке оставить первые 40 записей."
echo ------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT m.title, t.tag FROM movies m JOIN tags t ON m.movieId = t.movieId ORDER BY CAST(substr(m.title, -5, 4) AS INTEGER), m.title, t.tag LIMIT 40;"
echo " "

echo "5. Вывести список самых свежих фильмов. В список должны войти все фильмы последнего года выпуска, имеющиеся в базе данных. Запрос должен быть универсальным, не зависящим от исходных данных (нужный год выпуска должен определяться в запросе, а не жестко задаваться)."
echo ------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT title FROM movies WHERE CAST(substr(title, -5, 4) AS INTEGER) = (SELECT MAX(CAST(substr(title, -5, 4) AS INTEGER)) FROM movies);"
echo " "

echo "6. Найти все комедии, выпущенные после 2000 года, которые понравились мужчинам (оценка не ниже 4.5). Для каждого фильма в этом списке вывести название, год выпуска и количество таких оценок. Результат отсортировать по году выпуска и названию фильма."
echo ------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT m.title, COUNT(r.rating) as count_ratings FROM movies m JOIN ratings r ON m.movieId = r.movieId JOIN users u ON r.userId = u.id WHERE m.genres LIKE '%Comedy%' AND CAST(substr(m.title, -5, 4) AS INTEGER) > 2000 AND u.gender = 'male' AND r.rating >= 4.5 GROUP BY m.movieId, m.title ORDER BY CAST(substr(m.title, -5, 4) AS INTEGER), m.title;"
echo " "

echo "7. Провести анализ занятий (профессий) пользователей - вывести количество пользователей для каждого рода занятий. Найти самую распространенную и самую редкую профессию посетителей сайта."
echo ------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT occupation, COUNT(*) as user_count FROM users GROUP BY occupation ORDER BY user_count DESC;"
echo " "