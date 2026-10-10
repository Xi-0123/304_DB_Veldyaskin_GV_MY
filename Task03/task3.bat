#!/bin/bash
chcp 65001 2>/dev/null || true

echo "Создание/пересоздание базы данных movies_rating.db..."
sqlite3 movies_rating.db < db_init.sql
echo "Готово!"
echo " "

echo "1. Список фильмов с хотя бы одной оценкой (первые 10, по году и названию)."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT DISTINCT m.title, m.year FROM movies m JOIN ratings r ON m.id = r.movie_id WHERE m.year IS NOT NULL AND m.year > 0 ORDER BY m.year ASC, m.title ASC LIMIT 10;"
echo " "

echo "2. Пользователи, чьи фамилии начинаются на 'A' (первые 5, по дате регистрации)."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT name, register_date FROM users WHERE SUBSTR(name, INSTR(name, ' ') + 1) LIKE 'A%' ORDER BY register_date ASC LIMIT 5;"
echo " "

echo "3. Рейтинги в читаемом формате: имя, фильм, год, оценка, дата (ГГГГ-ММ-ДД) (первые 50)."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT u.name AS user_name, m.title AS movie_title, m.year, r.rating, strftime('%Y-%m-%d', r.timestamp, 'unixepoch') AS rating_date FROM ratings r JOIN users u ON r.user_id = u.id JOIN movies m ON r.movie_id = m.id ORDER BY u.name ASC, m.title ASC, r.rating DESC LIMIT 50;"
echo " "

echo "4. Фильмы с тегами (первые 40, по году, названию и тегу)."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT m.title, m.year, t.tag FROM movies m JOIN tags t ON m.id = t.movie_id ORDER BY m.year ASC, m.title ASC, t.tag ASC LIMIT 40;"
echo " "

echo "5. Самые свежие фильмы (универсальный запрос для последнего года)."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT title, year FROM movies WHERE year = (SELECT MAX(year) FROM movies WHERE year IS NOT NULL AND year > 0) ORDER BY title ASC;"
echo " "

echo "6. Комедии после 2000 года, понравившиеся мужчинам (оценка >= 4.5), с количеством оценок."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT m.title, m.year, COUNT(r.id) AS high_rating_count FROM movies m JOIN ratings r ON m.id = r.movie_id JOIN users u ON r.user_id = u.id WHERE m.year > 2000 AND m.genres LIKE '%Comedy%' AND u.gender = 'male' AND r.rating >= 4.5 GROUP BY m.id, m.title, m.year ORDER BY m.year ASC, m.title ASC;"
echo " "

echo "7. Анализ профессий: количество пользователей, самая распространенная и самая редкая."
echo "--------------------------------------------------"
echo "--- Полная статистика ---"
sqlite3 movies_rating.db -box -echo "SELECT occupation, COUNT(id) AS user_count FROM users GROUP BY occupation ORDER BY user_count DESC;"
echo " "
echo "--- Самая частая и самая редкая ---"
sqlite3 movies_rating.db -box -echo "SELECT * FROM (SELECT 'Самая распространенная' AS type, occupation, COUNT(id) AS count FROM users GROUP BY occupation ORDER BY count DESC LIMIT 1) UNION ALL SELECT * FROM (SELECT 'Самая редкая' AS type, occupation, COUNT(id) AS count FROM users GROUP BY occupation ORDER BY count ASC LIMIT 1);"
echo " "
