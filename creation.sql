--Создание БД
CREATE DATABASE book_accounting;
USE book_accounting;
--Создание таблиц
CREATE TABLE genres (
    genre_id INT(3) ZEROFILL NOT NULL AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(100) NOT NULL
);

CREATE TABLE types_of_edition (
    type_id VARCHAR(10) NOT NULL,
    type_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (type_id)
);

CREATE TABLE publisher (
    publ_id INT(4) ZEROFILL NOT NULL AUTO_INCREMENT,
    publ_name VARCHAR(150) NOT NULL,
    PRIMARY KEY (publ_id)
);

CREATE TABLE countries (
    country_id INT(3) ZEROFILL NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (country_id)
);

CREATE TABLE languages (
    lang_id VARCHAR(3) NOT NULL,
    lang_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (lang_id)
);

CREATE TABLE editions (
    isbn VARCHAR(17) NOT NULL,
    book_name VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    genre_id INT(3) ZEROFILL NOT NULL,
    type_id VARCHAR(10) NOT NULL,
    year_of_publication SMALLINT NOT NULL,
    publ_id INT(4) ZEROFILL NOT NULL,
    country_id INT(3) ZEROFILL NOT NULL,
    lang_id VARCHAR(3) NOT NULL,
    PRIMARY KEY (isbn),

    CONSTRAINT fk_edition_genre
        FOREIGN KEY (genre_id)
        REFERENCES genres (genre_id),

    CONSTRAINT fk_edition_type
        FOREIGN KEY (type_id)
        REFERENCES types_of_edition (type_id),

    CONSTRAINT fk_edition_publisher
        FOREIGN KEY (publ_id)
        REFERENCES publisher (publ_id),

    CONSTRAINT fk_edition_country
        FOREIGN KEY (country_id)
        REFERENCES countries (country_id),

    CONSTRAINT fk_edition_language
        FOREIGN KEY (lang_id)
        REFERENCES languages (lang_id)
);

CREATE TABLE copies (
    copy_id INT(6) ZEROFILL NOT NULL AUTO_INCREMENT,
    isbn VARCHAR(17) NOT NULL,
    date_of_receipt DATE NOT NULL DEFAULT (CURRENT_DATE),
    bookshelf_num VARCHAR(50) NOT NULL,
    status ENUM('доступен', 'выдан', 'списан') NOT NULL DEFAULT 'доступен',
    PRIMARY KEY (copy_id),

    CONSTRAINT fk_copies_edition
        FOREIGN KEY (isbn)
        REFERENCES editions (isbn)
);

CREATE TABLE readers (
    reader_id INT(7) ZEROFILL NOT NULL AUTO_INCREMENT,
    reader_name VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    home_address VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    date_of_registration DATE NOT NULL DEFAULT (CURRENT_DATE),
    expiration_date DATE NOT NULL,
    PRIMARY KEY (reader_id)
);

CREATE TABLE book_circulation (
    copy_id INT(6) ZEROFILL NOT NULL,
    reader_id INT(7) ZEROFILL NOT NULL,
    checkout_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    return_date_plan DATE NOT NULL,
    return_date_fact DATE DEFAULT NULL,
    PRIMARY KEY (copy_id, reader_id, checkout_date),

    CONSTRAINT fk_circulation_copy
        FOREIGN KEY (copy_id)
        REFERENCES copies (copy_id),

    CONSTRAINT fk_circulation_reader
        FOREIGN KEY (reader_id)
        REFERENCES readers (reader_id)
);

CREATE TABLE write_off_reasons (
    reason_id INT(2) ZEROFILL NOT NULL AUTO_INCREMENT,
    reason_name VARCHAR(255) NOT NULL,

    PRIMARY KEY (reason_id)
);

CREATE TABLE write_offs (
    write_off_id INT(6) ZEROFILL NOT NULL AUTO_INCREMENT,
    copy_id INT(6) ZEROFILL NOT NULL,
    reason_id INT(2)ZEROFILL  NOT NULL,
    write_off_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    PRIMARY KEY (write_off_id),

    CONSTRAINT uq_write_off_copy
        UNIQUE (copy_id),

    CONSTRAINT fk_write_offs_copy
        FOREIGN KEY (copy_id)
        REFERENCES copies (copy_id),

    CONSTRAINT fk_write_offs_reason
        FOREIGN KEY (reason_id)
        REFERENCES write_off_reasons (reason_id)
);
CREATE TABLE authors (
    author_id INT(5) ZEROFILL NOT NULL AUTO_INCREMENT,
    author_name VARCHAR(150) NOT NULL,
    PRIMARY KEY (author_id)
);

--Alter table
ALTER TABLE copies ADD COLUMN cost_ar_receipt DECIMAL(10,2) AFTER date_of_receipt;

ALTER TABLE copies DROP COLUMN cost_ar_receipt;
ALTER TABLE copies ADD COLUMN cost_at_receipt DECIMAL(10,2) AFTER date_of_receipt;


ALTER TABLE editions
    DROP COLUMN author,
    ADD COLUMN author_id INT(5) ZEROFILL NOT NULL AFTER book_name,
    ADD CONSTRAINT fk_editions_authors
        FOREIGN KEY (author_id)
        REFERENCES authors(author_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;

--Добавление записей
INSERT INTO genres (genre_name) 
VALUES
('Фэнтези'),
('Детектив'),
('Фантастика'),
('Детская литература'),
('Роман');

INSERT INTO types_of_edition (type_id, type_name) 
VALUES
('MONO', 'Моноиздание'),
('COLL', 'Сборник'),
('PER', 'Периодическое издание'),
('REF', 'Справочное издание'),
('DIG', 'Дайджест');

INSERT INTO publisher (publ_name) 
VALUES
('АСТ'),
('Эксмо'),
('Просвещение'),
('Penguin Books'),
('Gallimard');

INSERT INTO countries (country_id, country_name) 
VALUES
(643, 'Россия'),
(840, 'Соединённые Штаты Америки'),
(826, 'Соединённое Королевство'),
(250, 'Франция'),
(276, 'Германия');

INSERT INTO languages (lang_id, lang_name) 
VALUES
('rus', 'Русский'),
('eng', 'Английский'),
('fra', 'Французский'),
('deu', 'Немецкий'),
('spa', 'Испанский');

INSERT INTO authors (author_name) 
VALUES
('Михаил Булгаков'),
('Фёдор Достоевский'),
('Джон Рональд Руэл Толкин'),
('Джоан Роулинг'),
('Джордж Оруэлл'),
('Антуан де Сент-Экзюпери'),
('Артур Конан Дойл');

INSERT INTO editions
    (isbn, book_name, author_id, genre_id, type_id,
     year_of_publication, publ_id, country_id, lang_id)
VALUES
('978-5-17-123456-1', 'Мастер и Маргарита',
 1, 5, 'MONO', 2020, 1, 643, 'rus'),
('978-5-04-123456-2', 'Преступление и наказание',
 2, 5, 'MONO', 2021, 2, 643, 'rus'),
('978-0-14-123456-3', 'The Hobbit',
 3, 1, 'MONO', 2019, 4, 826, 'eng'),
('978-5-17-123457-8', 'Гарри Поттер и философский камень',
 4, 1, 'MONO', 2022, 1, 643, 'rus'),
('978-0-45-152493-5', 'Nineteen Eighty-Four',
 5, 3, 'MONO', 2020, 4, 826, 'eng'),
('978-2-07-061275-8', 'Le Petit Prince',
 6, 4, 'MONO', 2018, 5, 250, 'fra'),
('978-5-04-123457-9', 'Война и мир',
 2, 5, 'MONO', 2023, 2, 643, 'rus'),
('978-0-14-123457-0', 'The Adventures of Sherlock Holmes',
 7, 2, 'COLL', 2017, 4, 826, 'eng');
 
INSERT INTO copies
    (copy_id, isbn, date_of_receipt, cost_at_receipt,
     bookshelf_num, status)
VALUES
(1, '978-5-17-123456-1', '2024-09-01', 650.00, 'А-01', 'доступен'),
(2, '978-5-17-123456-1', '2025-02-15', 720.00, 'А-02', 'выдан'),
(3, '978-5-04-123456-2', '2024-10-10', 580.00, 'Б-01', 'доступен'),
(4, '978-0-14-123456-3', '2025-01-20', 950.00, 'В-03', 'выдан'),
(5, '978-0-14-123456-3', '2024-03-12', 800.00, 'В-04', 'списан'),
(6, '978-5-17-123457-8', '2025-03-01', 890.00, 'А-03', 'доступен'),
(7, '978-5-17-123457-8', '2025-03-01', 890.00, 'А-04', 'выдан'),
(8, '978-0-45-152493-5', '2023-11-05', 700.00, 'Г-01', 'списан'),
(9, '978-2-07-061275-8', '2024-05-17', 600.00, 'Д-01', 'доступен'),
(10, '978-5-04-123457-9', '2025-04-10', 1100.00, 'Б-02', 'выдан'),
(11, '978-0-14-123457-0', '2024-12-01', 750.00, 'В-05', 'доступен'),
(12, '978-5-17-123456-1', '2025-06-20', 760.00, 'А-05', 'доступен');

INSERT INTO readers
    (reader_name, date_of_birth, home_address,
     phone_number, date_of_registration, expiration_date)
VALUES
('Иванов Иван Иванович', '2002-04-15',
 'г. Пермь, ул. Ленина, д. 10', '+79000000001',
 '2024-09-01', '2027-09-01'),
('Петрова Анна Сергеевна', '2000-07-22',
 'г. Пермь, ул. Мира, д. 25', '+79000000002',
 '2024-10-10', '2027-10-10'),
('Сидоров Максим Андреевич', '2003-11-08',
 'г. Пермь, ул. Крупской, д. 18', '+79000000003',
 '2025-01-15', '2028-01-15'),
('Смирнова Елена Викторовна', '1998-02-03',
 'г. Пермь, ул. Попова, д. 40', '+79000000004',
 '2025-02-01', '2028-02-01'),
('Кузнецов Артём Павлович', '2001-06-19',
 'г. Пермь, ул. Советская, д. 12', '+79000000005',
 '2025-03-10', '2028-03-10'),
('Волкова Мария Игоревна', '2004-09-27',
 'г. Пермь, ул. Екатерининская, д. 30', '+79000000006',
 '2025-04-12', '2028-04-12'),
('Орлов Дмитрий Олегович', '1999-12-05',
 'г. Пермь, ул. Газеты Звезда, д. 15', '+79000000007',
 '2025-05-20', '2028-05-20');
 
INSERT INTO book_circulation
    (copy_id, reader_id, checkout_date,
     return_date_plan, return_date_fact)
VALUES
(1, 1, '2025-01-10', '2025-01-24', '2025-01-22'),
(2, 2, '2025-02-20', '2025-03-06', '2025-03-04'),
(3, 3, '2025-03-01', '2025-03-15', '2025-03-12'),
(4, 4, '2025-04-05', '2025-04-19', '2025-04-18'),
(6, 5, '2025-05-10', '2025-05-24', '2025-05-20'),
(9, 6, '2025-06-01', '2025-06-15', '2025-06-14'),
(11, 7, '2025-07-10', '2025-07-24', '2025-07-21'),
(2, 1, '2025-08-01', '2025-08-15', '2025-08-14'),
(2, 3, '2026-10-10', '2026-10-24', NULL),
(4, 2, '2026-10-15', '2026-10-29', NULL),
(7, 4, '2026-10-20', '2026-11-03', NULL),
(10, 5, '2026-10-22', '2026-11-05', NULL);

INSERT INTO write_off_reasons (reason_name) 
VALUES
('Физический износ'),
('Повреждение страниц'),
('Утрата экземпляра'),
('Устаревшее содержание'),
('Невозможность восстановления');

INSERT INTO write_offs
    (copy_id, reason_id, write_off_date)
VALUES
(5, 1, '2025-09-15'),
(8, 2, '2025-10-20');

--Изменение записей

UPDATE book_circulation SET return_date_fact = '2026-10-29' WHERE copy_id = 10 AND reader_id = 5 AND checkout_date = '2026-10-22';
UPDATE copies SET status = 'доступен' WHERE copy_id = 10;

--Удаление записей
INSERT INTO genres (genre_name) VALUES ('Временный жанр');
SELECT * FROM genres;
DELETE FROM genres WHERE genre_name = 'Временный жанр';
SELECT * FROM genres;

--Создание пользователей и наделение правами

CREATE USER IF NOT EXISTS 'librarian'@'localhost' IDENTIFIED BY 'libr';
CREATE USER IF NOT EXISTS 'cataloger'@'localhost' IDENTIFIED BY 'cat';
CREATE USER IF NOT EXISTS 'director'@'localhost' IDENTIFIED BY 'dir';
SELECT * FROM mysql.user;

--права библиотекаря
GRANT SELECT ON book_accounting.authors TO 'librarian'@'localhost';
GRANT SELECT ON book_accounting.copies TO 'librarian'@'localhost';
GRANT SELECT ON book_accounting.countries TO 'librarian'@'localhost';
GRANT SELECT ON book_accounting.editions TO 'librarian'@'localhost';
GRANT SELECT ON book_accounting.genres TO 'librarian'@'localhost';
GRANT SELECT ON book_accounting.languages TO 'librarian'@'localhost';
GRANT SELECT ON book_accounting.publisher TO 'librarian'@'localhost';
GRANT SELECT ON book_accounting.types_of_edition TO 'librarian'@'localhost';
GRANT SELECT ON book_accounting.write_offs TO 'librarian'@'localhost';
GRANT SELECT ON book_accounting.write_off_reasons TO 'librarian'@'localhost';
GRANT UPDATE (status) ON book_accounting.copies TO 'librarian'@'localhost';
GRANT SELECT, INSERT, UPDATE ON book_accounting.book_circulation TO 'librarian'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON book_accounting.readers TO 'librarian'@'localhost';

--права каталогизатора
GRANT SELECT ON book_accounting.book_circulation TO 'cataloger'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON book_accounting.authors TO 'cataloger'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON book_accounting.countries TO 'cataloger'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON book_accounting.editions TO 'cataloger'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON book_accounting.genres TO 'cataloger'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON book_accounting.languages TO 'cataloger'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON book_accounting.publisher TO 'cataloger'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON book_accounting.types_of_edition TO 'cataloger'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON book_accounting.write_off_reasons TO 'cataloger'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON book_accounting.write_offs TO 'cataloger'@'localhost';
GRANT SELECT, INSERT, UPDATE ON book_accounting.copies TO 'cataloger'@'localhost';

--права директора
GRANT SELECT ON book_accounting.* TO 'director'@'localhost';

SHOW GRANTS FOR 'librarian'@'localhost';
SHOW GRANTS FOR 'cataloger'@'localhost';
SHOW GRANTS FOR 'director'@'localhost';

--Выгрузка метаданных
DESCRIBE authors;
DESCRIBE book_circulation;
DESCRIBE copies;
DESCRIBE countries;
DESCRIBE editions;
DESCRIBE genres;
DESCRIBE languages;
DESCRIBE publisher;
DESCRIBE readers;
DESCRIBE types_of_edition;
DESCRIBE write_offs;
DESCRIBE write_off_reasons;