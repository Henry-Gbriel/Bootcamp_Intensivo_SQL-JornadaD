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

------ LEFT JOIN 
select * from employees;
select * from customers;

--- LEFT vão sempre priorizar a devida coluna à esquerda 
--- Sempre olhar o questionamento ou insight que teve para desenvolvimento
select e.employee_id, e.last_name, c.customer_id, e.city,c.city from employees e 
Left JOIN customers c ON e.city = c.city 
order by e.employee_id;

--- RIGHT 
select e.employee_id, e.last_name, c.customer_id, e.city,c.city from employees e 
RIGHT JOIN customers c ON e.city = c.city 
order by e.employee_id;

--- FULL

select COALESCE(c.city, e.city),
count(distinct e.employee_id) as quantidade_funcionarios,
count(distinct c.customer_id) as quantidade_clientes 
from employees e 
FULL JOIN customers c ON e.city = c.city 
GROUP BY c.city, e.city
ORDER BY c.city, e.city;

----- Desafio 
-- 1. Cria um relatório para todos os pedidos de 1996 e seus clientes (152 linhas)
select * from  orders; --- customer_id, order_id e order_date 
select * from customers ; --- customer_id e company_name 

select distinct(o.order_id), o.order_date, c.company_name  from orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
where EXTRACT(YEAR from o.order_date) = 1996
order by o.order_date;

-- 2. Cria um relatório que mostra o número de funcionários e clientes de cada cidade que tem funcionários (5 linhas)
select * from customers; --- city, company_name, customer_id 
select * from employees; --- city, employee_id, last_name 

select 
	e.city, 
	count(distinct e.employee_id) as quant_funcionarios,
	count(distinct c.customer_id ) as quant_clientes
from employees e 
LEFT JOIN customers c ON e.city= c.city
group by e.city
order by e.city;

-- 3. Cria um relatório que mostra o número de funcionários e clientes de cada cidade que tem clientes (69 linhas)
select * from customers; --- customer_id company_name, city 
select*from  employees; --- employee_id, last_name, city --- funcionários 

select c.city, 
	count(distinct c.customer_id) as quant_cliente,
	count(distinct e.employee_id) as quant_funcionario
from customers c
LEFT JOIN employees e ON c.city = e.city
group by c.city 
order by c.city;

-- 4.Cria um relatório que mostra o número de funcionários e clientes de cada cidade (71 linhas)
SELECT 
    COALESCE(e.city, c.city) AS city,
    COUNT(DISTINCT e.employee_id) AS quant_funcionarios,
    COUNT(DISTINCT c.customer_id) AS quant_clientes
FROM employees e
FULL OUTER JOIN customers c 
    ON e.city = c.city
GROUP BY COALESCE(e.city, c.city)
ORDER BY city;



-- 5. Cria um relatório que mostra a quantidade total de produtos encomendados.
-- Mostra apenas registros para produtos para os quais a quantidade encomendada é menor que 200 (5 linhas)

--- condição menor que quant_prduto < 200 

select * from products; --- produtos encomendados  --- product_id, product_name 
select*from order_details; ---  order_id, product_id, quantity

SELECT 
    p.product_name,
    SUM(od.quantity) AS total_encomendado
FROM products p
INNER JOIN order_details od 
    ON p.product_id = od.product_id
GROUP BY p.product_name
HAVING SUM(od.quantity) < 200
ORDER BY total_encomendado;




-- 6. Cria um relatório que mostra o total de pedidos por cliente desde 31 de dezembro de 1996.
-- O relatório dev
e retornar apenas linhas para as quais o total de pedidos é maior que 15 (5 linhas)
select * from customers; --- customer_id, company_name 
select*from orders; ---- order_id, customer_id, order_date 

SELECT 
    c.company_name,
    COUNT(o.order_id) AS total_pedidos
FROM customers c
INNER JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE o.order_date >= DATE '1996-12-31'
GROUP BY c.company_name
HAVING COUNT(o.order_id) > 15
ORDER BY total_pedidos DESC;







