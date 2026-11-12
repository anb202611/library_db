/* 1.	Вывод списка доступных экземпляров с указанием названия, автора и места хранения и сортировкой по названию (WHERE, ORDER BY)
 */
SELECT e.book_name, a.author_name, c.bookshelf_num
FROM editions as e, copies as c, authors as a
WHERE e.isbn = c.isbn AND a.author_id = e.author_id AND c.status = "доступен"
ORDER BY e.book_name;

/* 2.	Вывод информации обо всех изданиях с указанием их жанров, издательств, стран и языков (WHERE, ORDER BY DESC).
 */
SELECT a.author_name, e.book_name, g.genre_name, ct.country_name, l.lang_name
FROM editions as e, authors as a, genres as g, countries as ct, languages as l
WHERE a.author_id = e.author_id AND g.genre_id = e.genre_id AND ct.country_id = e.country_id AND l.lang_id = e.lang_id
ORDER BY e.book_name DESC;

/* 3.	Вывод истории выдачи книг с указанием названия книги и ФИО читателя (INNER JOIN).
 */
SELECT bc.copy_id, e.book_name, r.reader_name, bc.checkout_date, bc.return_date_plan, bc.return_date_fact
FROM book_circulation as bc
INNER JOIN copies as c ON bc.copy_id = c.copy_id
INNER JOIN editions as e ON c.isbn = e.isbn
INNER JOIN readers as r ON bc.reader_id = r.reader_id
ORDER BY bc.checkout_date DESC;

/* 4.	Вывод самой старой книги (MIN)
 */
SELECT book_name, year_of_publication
FROM editions
WHERE year_of_publication = (SELECT MIN(year_of_publication) FROM editions);

/* 5.	Вывод экземпляра с самой высокой ценой (MAX)
 */
SELECT e.book_name, c.cost_at_receipt
FROM editions as e, copies as c
WHERE e.isbn = c.isbn AND c.cost_at_receipt = (SELECT MAX(cost_at_receipt) FROM copies);

/* 6.	Вывод количества экземпляров с группировкой по изданиям (COUNT, GROUP BY)
 */
SELECT e.book_name, COUNT(c.copy_id) AS copies_count
FROM editions AS e INNER JOIN copies AS c ON e.isbn = c.isbn
GROUP BY e.isbn
ORDER BY copies_count DESC;

/* 7.	Вывод количества книг, общей стоимости книжного фонда и средней стоимости одной книги (COUNT, SUM, AVG)
 */
SELECT
COUNT(copy_id) AS total_copies,
SUM(cost_at_receipt) AS total_cost,
AVG(cost_at_receipt) AS average_cost
FROM copies;

/* 8.	Вывод количества и общей стоимости невозвращенных книг (COUNT, SUM)
 */
SELECT
COUNT(c.copy_id) AS total_copies,
SUM(c.cost_at_receipt) AS total_cost
FROM copies AS c, book_circulation AS bc
WHERE c.copy_id = bc.copy_id AND bc.return_date_fact IS NULL;

/* 9.	Вывод доступных книг, у которых больше одного экземпляра
 */
SELECT e.book_name, COUNT(c.copy_id) AS copies_count
FROM editions AS e INNER JOIN copies AS c ON e.isbn = c.isbn
WHERE c.status = 'доступен'
GROUP BY e.isbn
HAVING copies_count > 1
ORDER BY copies_count DESC;

/* 10.	Поиск книг по автору (вложенный запрос)
 */
SELECT * 
FROM copies AS c, editions AS e
WHERE c.isbn = e.isbn AND e.author_id = (
SELECT a.author_id 
FROM authors as a 
WHERE a.author_name = "Михаил Булгаков");

/* 11.	Вывод списка всех издательств, книги от которых доступны в библиотеке (вложенный подзапрос, ALL, IN)
 */
SELECT p.publ_name
FROM publisher AS p
WHERE p.publ_id IN (
SELECT e.publ_id
FROM editions AS e, copies as c
WHERE e.isbn = c.isbn AND c.copy_id != ALL (
SELECT w.copy_id
            FROM write_offs as w)
)

/* 12.	Книги, цена которых при поступлении была выше средней (вложенный подзапрос)
 */
SELECT * FROM copies
WHERE cost_at_receipt > (
SELECT AVG(cost_at_receipt) 
    	FROM copies);

/* 13.	На основании количества выдач разделять читателей на категории: «Активный», «Умеренно активный», «Редко посещающий библиотеку» (CASE)
 */
SELECT r.reader_id, r.reader_name, COUNT(bc.copy_id) AS issue_count,
    CASE
        WHEN COUNT(bc.copy_id) >= 10 THEN 'Активный'
        WHEN COUNT(bc.copy_id) >= 4 THEN 'Умеренно активный'
        WHEN COUNT(bc.copy_id) >= 1 THEN 'Редко посещающий'
        ELSE 'Нет выдач'
    END AS activity_category
FROM readers AS r LEFT JOIN book_circulation AS bc ON r.reader_id = bc.reader_id
GROUP BY r.reader_id;

/* 14.	Определение наличия книги в библиотеке (IF)
 */
SELECT e.isbn, e.book_name, COUNT(c.copy_id) AS available_copies,
    IF(COUNT(c.copy_id) > 0, 'Есть в наличии', 'Нет в наличии') AS availability
FROM editions AS e LEFT JOIN copies AS c ON e.isbn = c.isbn AND c.status = 'доступен'
GROUP BY e.isbn;

/* 15.	Представление «Текущие выдачи книг» (VIEW)
 */
CREATE VIEW current_circulation AS
SELECT e.isbn, e.book_name, r.reader_name, bc.checkout_date, bc.return_date_plan
FROM book_circulation AS bc, readers AS r, copies AS c, editions as e
WHERE e.isbn = c.isbn AND c.copy_id = bc.copy_id AND r.reader_id = bc.reader_id AND bc.return_date_fact IS NULL;

/* 16.	Временное представление количество книг по жанрам (WITH)
 */
WITH genre_copies AS (
    SELECT g.genre_name, COUNT(c.copy_id) AS copies_count
    FROM genres AS g LEFT JOIN editions AS e ON g.genre_id = e.genre_id LEFT JOIN copies AS c ON e.isbn = c.isbn
    GROUP BY g.genre_id
)
SELECT * FROM genre_copies;

/* 17.	EXPLAIN
 */
EXPLAIN SELECT e.book_name, a.author_name, c.bookshelf_num
FROM editions as e, copies as c, authors as a
WHERE e.isbn = c.isbn AND a.author_id = e.author_id AND c.status = "доступен"
ORDER BY e.book_name;

CREATE INDEX index_status_isbn
ON copies (status, isbn);

EXPLAIN SELECT e.book_name, a.author_name, c.bookshelf_num
FROM editions as e, copies as c, authors as a
WHERE e.isbn = c.isbn AND a.author_id = e.author_id AND c.status = "доступен"
ORDER BY e.book_name;

/* 18.	Оформление выдачи книги читателю (TRANSACTION)
 */
START TRANSACTION;

INSERT INTO book_circulation (copy_id, reader_id, checkout_date, return_date_plan, return_date_fact)
VALUES (1, 2, CURDATE(), '2026-12-12', NULL);

UPDATE copies
SET status = 'выдан'
WHERE copy_id = 1 AND status = 'доступен';

COMMIT;

/* 19.	Выборка книг по автору (PREPARE, EXECUTE, DEALLOCATE)
 */
PREPARE search_by_author FROM 'SELECT a.author_name, e.book_name, c.copy_id, c.status FROM editions AS e, copies AS c, authors AS a 
WHERE a.author_name = ? AND e.author_id = a.author_id AND e.isbn = c.isbn';

SET @author_name = 'Михаил Булгаков';

EXECUTE search_by_author USING @author_name;

DEALLOCATE PREPARE search_by_author;

