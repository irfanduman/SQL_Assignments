/*
Charlie's Chocolate Factory company produces chocolates. 
The following product information is stored: product name, product ID, and quantity on hand. 
These chocolates are made up of many components. Each component can be supplied by one or more suppliers. 
The following component information is kept: 
    component ID, name, description, quantity on hand, suppliers who supply them, when and how much they supplied, and products in which they are used. 
On the other hand following supplier information is stored: supplier ID, name, and activation status.

Assumptions:
A supplier can exist without providing components.
A component does not have to be associated with a supplier. It may already have been in the inventory.
A component does not have to be associated with a product. Not all components are used in products.
A product cannot exist without components. 

Do the following exercises, using the data model.
     a) Create a database named "Manufacturer"
     b) Create the tables in the database.
     c) Define table constraints.
*/

CREATE DATABASE Manufacturer

USE Manufacturer


--create Product table
CREATE TABLE [Product] (
    [prod_id] INT PRIMARY KEY NOT NULL,
    [prod_name] VARCHAR(50) NOT NULL,
    [quantity] INT
);

--create Component table
CREATE TABLE [Component] (
    [comp_id] INT PRIMARY KEY NOT NULL,
    [comp_name] VARCHAR(50) NOT NULL,
    [description] VARCHAR(50) NULL,
    [quantity_comp] INT NOT NULL
);

--create Supplier table
CREATE TABLE [Supplier] (
    [supp_id] INT PRIMARY KEY NOT NULL,
    [supp_name] VARCHAR(50) NOT NULL,
    [supp_location] VARCHAR(50) NOT NULL,
    [supp_country] VARCHAR(50) NOT NULL,
    [is_active] BIT NOT NULL
);

--create Prod_Comp table
CREATE TABLE [Prod_Comp] (
    [prod_id] INT NOT NULL,
    [comp_id] INT NOT NULL,
    [quantity_comp] INT NOT NULL,
    PRIMARY KEY ([prod_id], [comp_id])
);

--create Comp_Supp table
CREATE TABLE [Comp_Supp] (
    [supp_id] INT NOT NULL,
    [comp_id] INT NOT NULL,
    [order_date] DATE NULL,
    [quantity] INT NULL,
    PRIMARY KEY ([supp_id], [comp_id])
);

--ADD KEY CONSTRAINTS
ALTER TABLE Prod_Comp 
ADD CONSTRAINT FK_Product FOREIGN KEY (prod_id) REFERENCES Product (prod_id)

ALTER TABLE Prod_Comp
ADD CONSTRAINT FK_Component FOREIGN KEY (comp_id) REFERENCES Component (comp_id)

ALTER TABLE Comp_Supp 
ADD CONSTRAINT FK_Supplier FOREIGN KEY (supp_id) REFERENCES Supplier (supp_id)

ALTER TABLE Comp_Supp
ADD CONSTRAINT FK_Component_Supp FOREIGN KEY (comp_id) REFERENCES Component (comp_id)



-- Let's join all tables togather
select * 
from Product a 
join Prod_Comp b on a.prod_id = b.prod_id
join Component c on b.comp_id = c.comp_id
join Comp_Supp d on c.comp_id = d.comp_id
join Supplier e on d.supp_id = e.supp_id
