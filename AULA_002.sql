select * from categories;

---  Quantos produtos únicos existem? Quantos produtos no total? Qual é o valor total pago?

select * from products; --- Produtos existentes(product_id) - Produtos no total(units_in_stock) --- Valor total pago(unit_price)

select 
	product_id ,
	COUNT( DISTINCT product_id) quantos_existentes,  --- Para mim não fez contexto essa pergunta do desafio
	SUM(units_in_stock) quantidade_estoque, 
	SUM(unit_price * units_in_stock) AS valor_produto
from products
group by product_id
order by product_id;

--- Window Funtition 
select 
	product_id ,
	product_name,
	COUNT(product_id) OVER(PARTITION BY product_id) quantos_existentes,  --- Para mim não fez contexto essa pergunta do desafio
	SUM(units_in_stock) OVER(PARTITION BY product_id) quantidade_estoque,
	unit_price valor_unitario,
	SUM(unit_price * units_in_stock) OVER(PARTITION BY product_id) AS valor_estoque_total
from products
order by product_id;


--- Quais são os valores mínimo, máximo e médio de frete pago por cada cliente? (tabela pedidos)

select * from orders;

SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'orders';

----- freight --- MAX, MIN, AVG 
select e
	customer_id,
	MAX(freight) AS valor_maximo,
	MIN(freight) AS valor_minimo ,
	AVG(freight) AS valor_medio
from orders
GROUP BY customer_id 
ORDER BY customer_id;

select
	distinct customer_id,
	MAX(freight) OVER(Partition BY customer_id) AS valor_maximo,
	MIN(freight) OVER(Partition BY customer_id) AS valor_minimo ,
	AVG(freight) OVER(Partition BY customer_id) AS valor_medio
from orders
ORDER BY customer_id;

---------------
select 
	distinct p.product_id,
	p.product_name,
	SUM(o.unit_price * o.quantity) as total_vendas
from 
	order_details o
join 
	products p on p.product_id = o.product_id
GROUP BY p.product_id;

---rank 
SELECT  
  o.order_id, 
  p.product_name, 
  (o.unit_price * o.quantity) AS total_sale,
  ROW_NUMBER() OVER (ORDER BY (o.unit_price * o.quantity) DESC) AS order_rn, 
  RANK() OVER (ORDER BY (o.unit_price * o.quantity) DESC) AS order_rank, 
  DENSE_RANK() OVER (ORDER BY (o.unit_price * o.quantity) DESC) AS order_dense
FROM  
  order_details o
JOIN 
  products p ON p.product_id = o.product_id;
	

---- LEG e lEAD
SELECT
    order_id,
    order_date,
    freight,
    LAG(freight)  OVER (ORDER BY order_date)  AS frete_anterior,
    LEAD(freight) OVER (ORDER BY order_date)  AS frete_proximo
FROM orders;






---- Desafio 
-- Faça a classificação dos produtos mais venvidos usando usando RANK(), DENSE_RANK() e ROW_NUMBER()
select * from products; --product_name 

select * from order_details; --- quantity, unit_price 

select * from orders;

SELECT 
	p.product_id,
	p.product_name,
	SUM(o.quantity) as total_vendido,
	ROW_NUMBER() OVER(ORDER BY SUM(o.quantity) ) AS quantidade_rn,
	RANK() OVER(ORDER BY SUM(o.quantity) ) AS quantidade_rn,
	DENSE_RANK() OVER(ORDER BY SUM(o.quantity) ) AS quantidade_rn
FROM products p
INNER JOIN  order_details o ON p.product_id = o.product_id
GROUP BY p.product_id;

---- Teste de conhecimento puxando variação do preço do produto ao longo do tempo com o rank
select * from products; --- product_id, product_name, unit_price 
select * from orders; --- order_id, order_date 
select* from order_details; --- order_id, product_id, unit_price, quantity

SELECT 
    p.product_id,
    p.product_name AS name,
	
    -- Ranking por quantidade (por produto)
    ROW_NUMBER() OVER (
        PARTITION BY p.product_id
        ORDER BY od.quantity DESC
    ) AS quantidade_row_number,

    RANK() OVER (
        PARTITION BY p.product_id
        ORDER BY od.quantity DESC
    ) AS quantidade_rank,

    DENSE_RANK() OVER (
        PARTITION BY p.product_id
        ORDER BY od.quantity DESC
    ) AS quantidade_dense_rank,

    -- Preço
    od.unit_price AS preco_unidade,

    -- Variação de preço ao longo do tempo
    LEAD(od.unit_price) OVER (
        PARTITION BY p.product_id
        ORDER BY o.order_date
    ) AS preco_futuro,

    LAG(od.unit_price) OVER (
        PARTITION BY p.product_id
        ORDER BY o.order_date
    ) AS preco_anterior,
	
	o.order_date as data

FROM products p
JOIN order_details od ON p.product_id = od.product_id
JOIN orders o ON od.order_id = o.order_id;

---- TESTE PARA CTEs

WITH vendas_produto AS (
    -- 1) Total vendido por produto (granularidade: PRODUTO)
    SELECT
        p.product_id,
        p.product_name,
        SUM(od.quantity) AS total_vendido
    FROM products p
    JOIN order_details od
        ON p.product_id = od.product_id
    GROUP BY
        p.product_id,
        p.product_name
),

ranking_produtos AS (
    -- 2) Ranking dos produtos mais vendidos
    SELECT
        product_id,
        product_name,
        total_vendido,

        ROW_NUMBER() OVER (
            ORDER BY total_vendido DESC
        ) AS row_number_vendas,

        RANK() OVER (
            ORDER BY total_vendido DESC
        ) AS rank_vendas,

        DENSE_RANK() OVER (
            ORDER BY total_vendido DESC
        ) AS dense_rank_vendas
    FROM vendas_produto
),

preco_tempo AS (
    -- 3) Preço do produto ao longo do tempo (granularidade: LINHA / DATA)
    SELECT
        p.product_id,
        o.order_date,
        od.unit_price,

        LAG(od.unit_price) OVER (
            PARTITION BY p.product_id
            ORDER BY o.order_date
        ) AS preco_anterior,

        LEAD(od.unit_price) OVER (
            PARTITION BY p.product_id
            ORDER BY o.order_date
        ) AS preco_futuro
    FROM products p
    JOIN order_details od
        ON p.product_id = od.product_id
    JOIN orders o
        ON o.order_id = od.order_id
)

-- 4) Resultado final: ranking + histórico de preço
SELECT
    r.product_id,
    r.product_name,
    r.total_vendido,
    r.row_number_vendas,
    r.rank_vendas,
    r.dense_rank_vendas,
    p.order_date,
    p.unit_price,
    p.preco_anterior,
    p.preco_futuro
FROM ranking_produtos r
JOIN preco_tempo p
    ON r.product_id = p.product_id
ORDER BY
    r.rank_vendas,
    p.order_date;


-- Listar funcionários dividindo-os em 3 grupos usando NTILE
-- FROM employees;

select * from employees; --- city 

select NTILE(3) OVER(ORDER BY city) as grupo,
	employee_id,
	last_name
from employees;

-- Ordenando os custos de envio pagos pelos clientes de acordo 
-- com suas datas de pedido, mostrando o custo anterior e o custo posterior usando LAG e LEAD:
-- FROM orders JOIN shippers ON shippers.shipper_id = orders.ship_via;
select * from orders; --- freight, order_date 

select * from shippers; --- shipper_id company_name 

SELECT 
    s.shipper_id,
    s.company_name,
    o.order_date,

    LEAD(o.freight) OVER (
        PARTITION BY s.shipper_id 
        ORDER BY o.order_date
    ) AS preco_futuro,

    LAG(o.freight) OVER (
        PARTITION BY s.shipper_id 
        ORDER BY o.order_date
    ) AS preco_anterior

FROM orders o
JOIN shippers s 
    ON s.shipper_id = o.ship_via;

-- Desafio extra: questão intrevista Google
-- https://medium.com/@aggarwalakshima/interview-question-asked-by-google-and-difference-among-row-number-rank-and-dense-rank-4ca08f888486#:~:text=ROW_NUMBER()%20always%20provides%20unique,a%20continuous%20sequence%20of%20ranks.
-- https://platform.stratascratch.com/coding/10351-activity-rank?code_type=3
-- https://www.youtube.com/watch?v=db-qdlp8u3o

select 
    from_user, 
    count(from_user) as total_emails, 
    row_number() over (order by count(from_user) desc, from_user) rank_emails
from google_gmail_emails
group by from_user;
