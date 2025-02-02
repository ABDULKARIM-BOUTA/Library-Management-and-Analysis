-- Project TASKS

--Task 1: a stored procedure that updates the status of a book based on its issuance or return by giving the book's isbn:
    --If a book is issued, the status should change to 'no'.
    --If a book is returned, the status should change to 'yes'.

create or replace procedure issued_or_returned(p_isbn varchar(25))
language plpgsql
as $$

declare
	v_issued_id varchar(8);
	re_statue varchar(8);
begin
	select issued_id
 	into v_issued_id
 	from issued_status is2
 	where issued_book_isbn = p_isbn;

 	select issued_id_fk
	into re_statue
 	from return_status rs
	where issued_id_fk = v_issued_id;
	
	update books
	set status = 'yes' 
	where isbn = p_isbn
	and re_statue is not null;
	
	update books
	set status = 'no' 
	where isbn = p_isbn
	and re_statue is null;
	
	raise notice'the book have been added successfuly';

end;
$$

--testing the procedure

select * from books b where isbn = '978-0-553-29698-2' ; --before

call issued_or_returned('978-0-553-29698-2'); 

select * from books b where isbn = '978-0-553-29698-2' ; --after


--Task 2: Branch Performance Report
--Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
select * from issued_status;
select * from books;
select * from employees e ;
select * from return_status rs;

create table branch_report
as
select e.branch_id,
count(*) as num_iussued_books,
count(rs.*) as num_books_returned,
sum(b.rental_price) as revenue
from issued_status is2 
join employees e 
on is2.issued_emp_id = e.emp_id 
left join return_status rs 
on is2.issued_id = rs.issued_id_fk 
join books b 
on is2.issued_book_isbn = b.isbn 
group by 1 
order by e.branch_id;

select * from branch_report br;


-- Task 3: List Employees' name with Their Branch Manager's Name and their branch details**:
select * from employees e ;
select e.emp_name, e2.emp_name as manager_name,
b.branch_address, b.branch_id,
b.contact_no , b.manager_id from branch b 
join employees e 
on e.branch_id = b.branch_id
join employees e2 
on b.manager_id = e2.emp_id 
;


--Task 4: CTAS: Create a Table of Active Members who rented a book in the last 6 months
select * from members m ;
select * from issued_status is2;

select distinct m.member_name,  m.member_id
from issued_status is2
left join members m 
on is2.issued_member_id = m.member_id 
where is2.issued_date > (current_date - interval '6 months')
order by  m.member_id;

select * from active_members am;


--Task5: Write a query to update the status of books in the books table to "yes" when they are returned (based on entries in the return_status table)
select * from books b;
select * from return_status rs;
select * from issued_status is2;


create or replace procedure update_book_status (p_return_id varchar(8), p_issued_id_fk varchar(8))
language plpgsql
as $$

declare
	v_isbn varchar(50);

begin
	insert into return_status (return_id, issued_id_fk, return_date)
		values(p_return_id, p_issued_id_fk, current_date);
	
	select issued_book_isbn
	into v_isbn 
	from issued_status is2 
	where issued_id = p_issued_id_fk;
	
	update books
	set status = 'yes'
	where isbn = v_isbn;
	
	raise notice 'The book has been returned';
end;
$$

--testing the function
select * from issued_status where issued_book_isbn= '978-0-307-58837-1';
select status from books where isbn = '978-0-307-58837-1';
select * from return_status where issued_id_fk = 'IS135';


call update_book_status('RS120', 'IS135');

--check if it has ben returned
select status from books where isbn = '978-0-307-58837-1';
select * from return_status where issued_id_fk = 'IS135';


--Task 6: Find Employees with the Most Book Issues Processed
--Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
select * from employees e;
select * from issued_status is2;
select * from branch b ;

select e.emp_name, is2.issued_emp_id,
e.branch_id, b.branch_address,
count(*) num_books
from issued_status is2
join employees e 
on is2.issued_emp_id = e.emp_id
join branch b 
on b.branch_id = e.branch_id 
group by 1,2,3,4
order by count(*) desc 
limit 3;



--Task 7: Write a query to identify members who have overdue books (30 days return period). Display the member's name, book title, issue date, fine(0.50 per day), and days overdue.

select m.member_name, is2.issued_book_name, is2.issued_date ,
(issued_date + 30) - current_date as overdue_days,
((issued_date + 30) - current_date) * 0.50 as fine
from members m
join issued_status is2 
on m.member_id = is2.issued_member_id 
left join return_status rs 
on is2.issued_id = rs.issued_id_fk 
where is2.issued_date + 30 > current_date
and rs.return_date is null


--Task 9: create a summary table of issued books and how many times they have been issued
create table book_issued_cnt as
select b.book_title, b.isbn, count(is2.issued_id)
from books b join
issued_status is2 
on b.isbn = is2.issued_book_isbn 
group by 2 ;

select * from book_issued_cnt bic 


-- Task 10: Retrieve the List of Books Not Yet Returned

select is2.issued_book_name
from issued_status is2 
left join return_status rs    
on is2.issued_id = rs.issued_id_fk 
where rs.return_date is null
order by is2.issued_book_name



--Task 11: retrieve a list of books that have been issued more than once in the last year

select issued_book_name, count(*) as total from
(select * from issued_status is2 
where is2.issued_date > (current_date- interval '12 months'))
group by issued_book_name
having count(*) > 1 ;



-- Task 12: Find Total Rental Income by Category:
select b. category, sum(b.rental_price), count(is2.issued_id)
from issued_status is2 
join books b 
on is2.issued_book_isbn = b.isbn 
group by 1

-- Task 13: List Members Who Registered in the Last 12 months**:
select * from members m  where reg_date > current_date - 360 ; 



-- Task 14. Create a Table of Books with Rental Price Above 5
create table high_priced_books as
select book_title ,rental_price from books b where rental_price > 5;
select * from high_priced_books hpb ;



-- Task 15: List Members Who Have Issued More Than two Books
select issued_member_id, count(issued_id) as total_books
from issued_status is2 group by issued_member_id 
having count(issued_id) > 2 ;


