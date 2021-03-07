select distinct city
	from customers
    where country = 'Spain'
    order by city ASC;
    
select employeeNumber, lastName, firstName 
	from employees 
    where officeCode in (
		
        select officeCode
			from offices
            where city = 'Paris');

select productCode, productName, productScale, productVendor, buyPrice 
	from products 
    where productLine = "Motorcycles" and (50 < buyPrice and buyPrice < 80);
    
select productCode, productName, productLine, quantityInStock, buyPrice 
	from products
    where productLine = 'Vintage Cars' and productVendor = 'Exoto Designs'
    order by buyPrice ASC
    LIMIT 1;
    
 select  O.productName, O.productVendor, E.quantityOrdered,
    E.quantityOrdered * E.priceEach as totalcost
	from products O, orderdetails E
    where O.productCode = E.productCode
    order by totalcost DESC
    LIMIT 5;

select customerNumber, customerName, phone, country, state, salesRepEmployeeNumber, creditLimit
	from customers
    where creditLimit > 130000
    order by creditLimit ASC;
    
select O.productCode, O.productName, 
	count(E.orderNumber) as OrderCount
	from products O, orderdetails E
    where O.productVendor = 'Welly Diecast Productions' and E.productCode = O.productCode
    group by O.productCode
    order by OrderCount DESC /*There is actually a tie for the largest order count*/ 
    LIMIT 2;
    
select O.customerName,  O.city, O.state, O.country, O.creditLimit,
	count(E.orderNumber) as TotalProducts
    from customers O, orders E
    where E.orderNumber in (
    
		select orderNumber
			from orders
            where customerNumber = O.customerNumber)
	group by O.customerNumber
    order by TotalProducts DESC
    LIMIT 3;
    
select officeCode, city, state, country 
	from offices
    where NOT country = 'USA' and addressLine2 is NULL;
    
select productName, productLine
	from products
    where (productName like '193%') and (productLine = 'Vintage Cars');
    
select orderNumber, requiredDate, shippedDate, 
	datediff(requiredDate, shippedDate) as Datediff
    from orders
    where (datediff(requiredDate, shippedDate) < 3) and (shippedDate like '2005%');
    
select O.customerNumber, O.customerName, O.city, O.country, 
	count(E.orderNumber) as Orders
    from customers O left outer join orders E
    on O.customerNumber = E.customerNumber
    where (O.customerNumber < 150)
	group by O.customerNumber
    order by Orders DESC;
    
select distinct O.customerNumber, O.customerName 
	from customers O left outer join orders E
    on O.customerNumber = E.customerNumber
    where (E.customerNumber is NULL) and (O.country = 'Switzerland');
    
select O.productLine, 
	SUM(E.quantityOrdered) as quantity
    from products O, orderdetails E
    where (O.productCode = E.productCode) 
    group by O.productLine
    having SUM(E.quantityOrdered) > 12000;

drop   table TopCustomers;
create table if not exists TopCustomers(
	CustomerNumber INT not null,
    ContactDate DATE not null,
    OrderCount INT not null, 
    OrderTotal decimal(9, 2) not null,
    constraint TopCustomer_PK primary key (CustomerNumber)
		);

insert into TopCustomers
	select O.customerNumber, '2021-02-28',
	count(E.orderNumber) as quantity,
    sum(P.quantityOrdered * P.priceEach) as TotalPrice
    from customers O 
    inner join
    orders as E
    on O.customerNumber = E.customerNumber 
    inner join 
    orderdetails as P
    on E.orderNumber = P.orderNumber
	group by O.customerNumber
    having sum(P.quantityOrdered * P.priceEach) > 130000;
    
select customerNumber, contactDate, orderCount, orderTotal
	from topcustomers
	order by orderTotal DESC
	LIMIT 5;
	
alter table TopCustomers
	add column CustomerRatings INT 
    default (0);


SET SQL_SAFE_UPDATES = 0;
update TopCustomers
	set CustomerRatings = FLOOR(RAND()*(10+1))
    where customerNumber is not NULL;
/*
select customerNumber, contactDate, orderCount, orderTotal, CustomerRatings
from TopCustomers
	order by CustomerRatings DESC;
    
 drop   table TopCustomers;*/