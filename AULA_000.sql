select * from customers;

select city  from customers where region is null; 

select UPPER(city) from customers
where LOWER(city) like 'a%';

select city from customers 
where city similar to '(B|S|P)%';

select description from categories 
where category_name IN (select region_description from region); ---Precisa ter relação entre as tabelas e colunas 

select * from products 
where unit_price BETWEEN 18 and 30;

select * from
products where unit_price MIN(unit_price);

select product_name, MIN(unit_price), quantity_per_unit from products
group by product_name , quantity_per_unit
order by  product_name
limit 2;

select * from products;

---Desafio 
-- 1. Obter todas as colunas das tabelas Clientes, Pedidos e Fornecedores
select * from customers, orders, suppliers;

-- 2. Obter todos os Clientes em ordem alfabética por país e nome
select country, company_name, contact_name from customers
order by country, company_name, contact_name; 

-- 3. Obter os 5 pedidos mais antigos
select ship_name, order_date from orders
order by order_date
limit 5;

-- 4. Obter a contagem de todos os Pedidos feitos durante 1997
select COUNT(order_date) from orders
WHERE TO_CHAR(order_date, 'YYYY') = '1997';

-- 5. Obter os nomes de todas as pessoas de contato onde a pessoa é um gerente, em ordem alfabética
select * from customers;

select contact_name, contact_title, phone from customers
where contact_title like '%Manager%'
order by contact_name;

-- 6. Obter todos os pedidos feitos em 19 de maio de 1997
select * from orders
where TO_CHAR(order_date, 'YYYY-MM-dd') = '1997-05-19';