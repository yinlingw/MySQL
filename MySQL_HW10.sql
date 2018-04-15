--  select sakila database
use sakila;
-- 1a.Display the first and last names of all actors from the table `actor`.
select first_name, last_name from actor;
-- 1b.Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select concat (first_name," ", last_name) as Actor_Name from actor;

-- 2a. find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
select actor_id, first_name, last_name from actor
where first_name = 'Joe';
-- 2b. Find all actors whose last name contain the letters `GEN`
select * from actor
where last_name like '%GEN%';
-- 2c. Find all actors whose last names contain the letters `LI`.
select actor_id, first_name, last_name from actor
where last_name like '%LI%'
order by last_name, first_name;
-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China
select country_id, country from country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a.  Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`.
alter table actor 
add column middle_name varchar(30) after first_name;
select * from actor;
-- 3b. Change the data type of the `middle_name` column to `blobs`.
alter table actor 
modify column middle_name BLOB;
select * from actor;
-- 3c. Delet the middle_name column
alter table actor
drop column middle_name;
select * from actor;

-- 4a. List the last names of actors
select last_name, count(*) from actor 
group by last_name ;
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(*) from actor 
group by last_name having count(*)>1;
-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. please fix it.
update sakila.actor 
set first_name = 'HARPO', last_name = 'WILLIAMS' 
where actor_id = 172;
-- 4d. change 4c. name back
update sakila.actor 
set first_name = 'GROUCHO'
where first_name = 'HARPO' and last_name = 'WILLIAMS';

-- 5a. cannot reach schema 'address', recreate it.
show create table address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`
select  staff.first_name, staff.last_name, address.address
from staff left join address on staff.address_id = address.address_id;
-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
select * from payment;
select staff.first_name, staff.last_name, sum(payment.amount)
from staff left join payment on staff.staff_id = payment.staff_id
where payment_date like "2005-08%"
group by staff.first_name, staff.last_name;
-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select * from film;
select * from film_actor;
select f.title, count(film_actor.actor_id) as 'Number of Actors'
from film f  inner join film_actor on f.film_id = film_actor.film_id
group by f.title;
-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select title, count(inventory_id) from film forceinner join inventory inv
on f.film_id = inv.film_id
where title = "Hunchback Impossible";
-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer.
select * from customer;
select * from payment;
select customer.first_name, customer.last_name, sum(payment.amount) AS 'Total Payment'
from customer  
inner join payment 
on customer.customer_id = payment.customer_id
group by customer.first_name, customer.last_name
order by customer.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select title from film
where title like 'K%' or title like 'Q%';
-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select title, first_name, last_name 
from
(select * from film where title = 'Alone Trip') a
join film_actor fa
on a.film_id = fa.film_id
join actor 
on fa.actor_id = actor.actor_id;
-- 7c. get names and email addresses of all Canadian customers. Use joins to retrieve this information.
select first_name, last_name, email  from customer
join address on(customer.address_id = address.address_id)
join city on(address.city_id=city.city_id)
join country on(city.country_id=country.country_id)
where country like 'Canada';
-- 7d. Identify all movies categorized as famiy films.
select title from film
join film_category on (film.film_id = film_category.film_id)
join category on (film_category.category_id = category.category_id);
-- 7e. Display the most frequently rented movies in descending order.
select film.title as 'Movie', count(rental.rental_id) as 'Rent Times' from film
join inventory 
on film.film_id = inventory.film_id
join rental 
on inventory.inventory_id = rental.inventory_id
group by film.film_id
order by count(rental.rental_id) desc;
-- 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(amount) as 'Total Sales'
from store s
join customer c
on s.store_id = c.store_id
join payment p 
on p.customer_id = c.customer_id
group by store_id
order by 'Total Sales' desc;
-- 7g. Write a query to display for each store its store ID, city, and country.
select store_id, city, country from store s
join address a on (s.address_id = a.address_id)
join city c on (a.city_id = c.city_id)
join country coun on (c.countyr_id = coun.country_id);
-- 7h. List the top five genres in gross revenue in descending order.
select  c.name as 'Movie Genres', sum(p.amount) as 'Gross Revenue'
from category c
join film_category fc
on c.category_id = fc.category_id
join inventory i
on fc.film_id = i.film_id
join rental r
on i.inventory_id = r.inventory_id
join payment p
on r.rental_id = p.rental_id
group by c.category_id
order by sum(p.amount) desc
limit 5;

-- 8a. create a easier way view 
drop view if exists top_five_genres;
create view top_five_genres (category, Total_Sales) as
select name,sum(amount) as Total_Sales
from category
join film_category
using (category_id)
join inventory
using (film_id)
join rental
using (inventory_id)
join payment
using (rental_id)
group by name
order by Total_Sales desc
limit 5;
-- 8b. Display the view in 8a.
select * from top_five_genres;
-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view top_five_genres;
