select * from orders;


select * from customers;

select * from orders o 
JOIN customers c ON o.customer_id = c.customer_id;

--- Encontrar a junção por data de referencia 
select * from orders o 
INNER JOIN customers c ON o.customer_id = c.customer_id 
WHERE EXTRACT(YEAR FROM o.order_date) = 1996;
--- Outra forma de junção por data 
select * from orders o 
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE DATE_PART('YEAR', o.order_date) = 1997;

------------

