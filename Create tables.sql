drop table if exists books;
create table books(
isbn varchar(20) unique primary key,
book_title varchar(75),
category varchar(20),
rental_price float,
status varchar(5),
author varchar(30),
publisher varchar(40)
);


drop table if exists branch;
create table branch(
branch_id varchar(6) unique primary key,
manager_id varchar(6),
branch_address varchar(20),
contact_no varchar(20) unique
);


drop table if exists employees;
create table employees(
emp_id varchar(6)  unique primary key,
emp_name varchar(25),
position varchar(15),
salary float,
branch_id varchar(6) references branch(branch_id) on delete set null
);


drop table if exists members;
create table members(
member_id varchar(6) unique primary key,
member_name varchar(25),
member_address varchar(40),
reg_date date
);


drop table if exists issued_status;
create table issued_status(
issued_id varchar(8) primary key,
issued_member_id varchar(6) references members(member_id) on delete set null ,
issued_book_name varchar(75),
issued_date date,
issued_book_isbn varchar(20) references books(isbn) on delete set null,
issued_emp_id varchar(6) references employees(emp_id) on delete set null
);


drop table if exists return_status;
create table return_status(
return_id varchar(8) primary key ,
issued_id_fk varchar(8) references issued_status(issued_id) on delete set null ,
return_book_name varchar(75),
return_date date,
return_book_isbn varchar(20) 
);


INSERT INTO return_status(return_id, issued_id_fk , return_date) 
VALUES
('RS106', 'IS108', '2024-05-05'),
('RS107', 'IS109', '2024-05-07'),
('RS108', 'IS110', '2024-05-09'),
('RS110', 'IS112', '2024-05-13'),
('RS111', 'IS113', '2024-05-15'),
('RS112', 'IS114', '2024-05-17'),
('RS113', 'IS115', '2024-05-19'),
('RS114', 'IS116', '2024-05-21'),
('RS115', 'IS117', '2024-05-23'),
('RS116', 'IS118', '2024-05-25'),
('RS117', 'IS119', '2024-05-27'),
('RS118', 'IS120', '2024-05-29');

--the rest of data can be imported from the exel files
