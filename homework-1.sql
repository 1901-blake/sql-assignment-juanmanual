-- begin section 2.0
-- 2.1
select * from employee;
select * from employee where lastname= 'King';
select * from employee where firstname = 'Andrew' and reportsto is null;

-- 2.2 order by
select * from album order by title desc;
select firstname from customer order by city asc;

-- 2.3 insert into 
  -- genre
delete from genre where genreid = 26;
delete from genre where genreid = 27;

delete from employee where employeeid = 404;
delete from employee where employeeid = 405;

delete from customer where customerid = 500;
delete from customer where customerid = 501;

insert into genre (genreid, name) values (26, 'German folk');
insert into genre (genreid, name) values (27, 'American folk');
  -- employee
insert into employee (employeeid, firstname, lastname, birthdate, hiredate, 
  address, city, state, country, postalcode, phone, fax, email)
  values (404, 'john', 'smith', current_date, current_date,
  '101 main st','Tampa','AR','United States','72034','888-555-5555','887-555-5555','me@you.com');

insert into employee (employeeid, firstname, lastname, birthdate, hiredate, 
  address, city, state, country, postalcode, phone, fax, email)
  values (405, 'john', 'jones', current_date, current_date,
  '102 main st','Tampa','AR','United States','72034','888-555-5555','887-555-5555','me@you.com');

insert into customer (customerid,firstname, lastname, company, address,
city, state, country, postalcode,
phone, fax, email, supportrepid)
values (500, 'hon', 'myth', 'revvietrue', '304 main st', 
'tampa','FL', 'US', '72035',
'404-404-0404', '888-555-5556', 'you@me.com', 1);

insert into customer (customerid,firstname, lastname, company, address,
city, state, country, postalcode,
phone, fax, email, supportrepid)
values (501, 'bun', 'bar', 'revvietrue', '305 main st', 
'tampa','FL', 'US', '72035',
'404-404-0404', '888-555-5556', 'you@me.com', 1);

-- 2.4 update
  --aaron mitchel -> robert walker
update customer
set firstname = 'Robert', lastname = 'Walter'
where firstname = 'Aaron' and lastname = 'Mitchell';

  --artist Creedence Clearwater Revival to CCR
update artist
set name = 'CCR'
where name = 'Creedence Clearwater Revival';
 
-- 2.5 like
  --select all invoices with a billing address like "T%"
select * from invoice where billingaddress like 'T%';

-- 2.6 between
  --select all invoices that have a total between 15 and 50
select * from invoice where total between 15 and 50;

-- 2.7 delete

delete from customer 
  where firstname = 'Robert' 
  and lastname = 'Walker';
 
-- 3.0 functions
--------------------------
-- 3.1 system defined functions
  -- current time
create or replace function my_date_time () returns timetz as $$
   select current_time;
$$ language sql;

  -- length of mediatype
create or replace function my_lengthof_mediatype (varchar(120)) returns int as $$
  select length($1);
$$ language sql;

select length(name) from mediatype where mediatypeid = 1;
 
-- 3.2 system defined agregate functions
  -- returns average of all invoices
create or replace function invoice_averages () returns numeric as $$
  select avg(total) from invoice;
$$ language sql;

  -- returns the most expensive track
-- drop function if exists most_expensive_track;
create or replace function most_expensive_track () returns setof track as $$
  select * from track where unitprice = (
  select max(unitprice) from track);
$$ language sql;

-- select most_expensive_track();
-- 3.3 user defined scalar functions
  -- create the average price of invoiceline items in the invoiceline table

create or replace function average_invoice_line () returns numeric as $$ 
  select avg(unitprice * quantity) from invoiceline;
$$ language sql;

  -- returns all employees born after 1968
create or replace function employees_born_after_1968 () returns setof employee as $$
  select * from employee where birthdate > '12/31/1968';
$$ language sql;

-- 4.0 stored procedures
------------------------------
-- 4.1 basic 
  -- selects the first and last name of the user
----------------------------------------------------
create or replace function employee_first_and_last_names (out varchar(20), out varchar(20)) as $$ 
  select firstname, lastname from employee;
$$ language sql;
-- 4.2 input params
  -- create a stored procedure that updates the personal information of an employee
create or replace function employee_update_first_last (int4, varchar(20), varchar(20)) returns void as $$ 
  update employee
  set firstname = $2, lastname = $3
  where employeeid = $1;
$$ language sql;
  
  -- create a stored procedure that finds the managers of an employee
create or replace function employee_managers (id int4) returns employee as $$ 
  select * from employee where employeeid = id;
$$ language sql;
-- 4.3 out params
  -- create a stored procedure that returns the
  -- name and company of a customer
create or replace function customer_name_company (id int4, 
  out fname varchar(40), out lname varchar(80),
  out company varchar(80)) as $$
    select firstname,lastname, company from customer where customerid = id;
$$ language sql;
------------------------------------------
-- 5.0 transactions
  -- create a transaction that given a 
  -- invoiceid will delete that invoice
    -- this relies on stored procedures
create function delete_invoice (transaction_id int4) returns void as $$
  begin;
    delete from invoiceline where invoiceid = transaction_id;
    delete from invoice where invoiceid = transaction_id;
  commit;
$$ language sql;
------------------------------------------
-- 6.0 triggers
------------------------------------------
-- 6.1 after/for
  -- create an after insert trigger on the employee
  -- table fired after a new record is inserted
  -- into the table
create or replace function do_nothing() 
  returns trigger as $$
  begin
    return null;
  end;
$$ language plpgsql;

create trigger employee_insert_after
  after insert
  on employee
  for each statement
  execute procedure do_nothing();

-- after update trigger for
  -- row inserted into album
create trigger album_update_after
  after update
  on album
  for each statement
  execute procedure do_nothing();

-- after delete trigger for
  -- row deleted from customer table
create trigger customer_delete_after
  after delete
  on customer
  for each statement
  execute procedure do_nothing();

--------------------------
-- 7.0 joins
--------------------------
-- 7.1 inner joins
  -- create an inner join that joins
  -- customers and orders and
  -- specifies the name of the customer
  -- and the invoice id
select firstname, lastname, invoiceid
  from customer cust join invoice ord
  on cust.customerid = ord.customerid;
 
-- 7.2
  -- create an outer join that joins
  -- the customer and invoice table,
  -- specifying the customerid,
  -- customer firstname, lastname,
  -- invoiceid, and total
select cust.customerid, firstname, lastname,
  invoiceid, total from customer cust
  full join invoice ord 
  on cust.customerid = ord.customerid;
  
-- create a right join that joins album
  -- and artist and sorts by artist name ascending
select maker.name, al.title from
  album al right join artist maker 
  on al.artistid = maker.artistid
  order by maker.name asc;

-- create a cross join that joins album
  -- and artist and sorts by artist name
  -- in ascending order
select maker.name, al.title from
  album al cross join artist maker
  order by maker.name asc;
 
-- perform a self-join on the employee table, joining
  -- on the reportsto column
select e.firstname as "employee first", 
  e.lastname as "employee last", 
  m.firstname as "manager first", 
  m.lastname as "manager last" from
  employee e, employee m
  where e.reportsto = m.employeeid;
 