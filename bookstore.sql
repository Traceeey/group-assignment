-- Create the database
CREATE DATABASE bookstore_db;
USE bookstore_db;

-- Reference Tables
CREATE TABLE country (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL
);

CREATE TABLE address_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL
);

CREATE TABLE book_language (
    language_id INT AUTO_INCREMENT PRIMARY KEY,
    language_name VARCHAR(100) NOT NULL
);

CREATE TABLE publisher (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(255) NOT NULL
);

CREATE TABLE author (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    bio TEXT
);

-- Main Tables
CREATE TABLE book (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    publisher_id INT,
    language_id INT,
    publication_year YEAR,
    price DECIMAL(10,2),
    FOREIGN KEY (publisher_id) REFERENCES publisher(publisher_id),
    FOREIGN KEY (language_id) REFERENCES book_language(language_id)
);

CREATE TABLE book_author (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES book(book_id),
    FOREIGN KEY (author_id) REFERENCES author(author_id)
);

CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    phone_number VARCHAR(20)
);

CREATE TABLE address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    street VARCHAR(255),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    country_id INT,
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);

CREATE TABLE customer_address (
    customer_id INT,
    address_id INT,
    status_id INT,
    PRIMARY KEY (customer_id, address_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (address_id) REFERENCES address(address_id),
    FOREIGN KEY (status_id) REFERENCES address_status(status_id)
);

CREATE TABLE shipping_method (
    shipping_method_id INT AUTO_INCREMENT PRIMARY KEY,
    method_name VARCHAR(100),
    cost DECIMAL(10,2)
);

CREATE TABLE order_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100)
);

CREATE TABLE cust_order (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    shipping_method_id INT,
    status_id INT,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (shipping_method_id) REFERENCES shipping_method(shipping_method_id),
    FOREIGN KEY (status_id) REFERENCES order_status(status_id)
);

CREATE TABLE order_line (
    order_id INT,
    book_id INT,
    quantity INT,
    price DECIMAL(10,2),
    PRIMARY KEY (order_id, book_id),
    FOREIGN KEY (order_id) REFERENCES cust_order(order_id),
    FOREIGN KEY (book_id) REFERENCES book(book_id)
);

CREATE TABLE order_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    status_id INT,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES cust_order(order_id),
    FOREIGN KEY (status_id) REFERENCES order_status(status_id)
);

-- Sample Data
INSERT INTO country (country_name) VALUES ('USA'), ('UK'), ('Kenya');
INSERT INTO address_status (status_name) VALUES ('Current'), ('Old');
INSERT INTO book_language (language_name) VALUES ('English'), ('French');
INSERT INTO publisher (publisher_name) VALUES ('Penguin Books'), ('HarperCollins');
INSERT INTO author (first_name, last_name, bio)
VALUES ('J.K.', 'Rowling', 'Author of Harry Potter'),
       ('George', 'Orwell', 'Author of 1984 and Animal Farm');

INSERT INTO book (title, isbn, publisher_id, language_id, publication_year, price)
VALUES ('Harry Potter and the Sorcerer''s Stone', '9780747532699', 1, 1, 1997, 29.99);

INSERT INTO book_author (book_id, author_id) VALUES (1, 1);

INSERT INTO customer (first_name, last_name, email, phone_number)
VALUES ('Alice', 'Walker', 'alice@example.com', '0712345678');

INSERT INTO address (street, city, postal_code, country_id)
VALUES ('123 Elm St', 'Nairobi', '00100', 3);

INSERT INTO customer_address (customer_id, address_id, status_id)
VALUES (1, 1, 1);

INSERT INTO shipping_method (method_name, cost)
VALUES ('Standard', 5.00), ('Express', 15.00);

INSERT INTO order_status (status_name)
VALUES ('Pending'), ('Shipped'), ('Delivered'), ('Cancelled');

INSERT INTO cust_order (customer_id, shipping_method_id, status_id)
VALUES (1, 1, 1);

INSERT INTO order_line (order_id, book_id, quantity, price)
VALUES (1, 1, 2, 29.99);

INSERT INTO order_history (order_id, status_id)
VALUES (1, 1);



-- Create roles
CREATE ROLE db_readonly;
CREATE ROLE db_readwrite;

-- Grant privileges
GRANT SELECT ON bookstore.* TO db_readonly;
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstore.* TO db_readwrite;

-- Create users and assign roles
CREATE USER 'read_user'@'localhost' IDENTIFIED BY 'readpass';
CREATE USER 'write_user'@'localhost' IDENTIFIED BY 'writepass';

GRANT db_readonly TO 'read_user'@'localhost';
GRANT db_readwrite TO 'write_user'@'localhost';


-- Get all books with author names
SELECT b.title, CONCAT(a.first_name, ' ', a.last_name) AS author
FROM book b
JOIN book_author ba ON b.book_id = ba.book_id
JOIN author a ON ba.author_id = a.author_id;

-- List customers and their current addresses
SELECT c.first_name, c.last_name, a.street, a.city,  a.postal_code
FROM customer c
JOIN customer_address ca ON c.customer_id = ca.customer_id
JOIN address a ON ca.address_id = a.address_id
JOIN address_status s ON ca.status_id = s.status_id
WHERE s.status_name = 'current';
