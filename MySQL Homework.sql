use sakila;
-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(first_name,' ',last_name) as Actor_name from actor;
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor where first_name = 'JOE';
-- 2b. Find all actors whose last name contain the letters GEN:
select actor_id, first_name, last_name from actor where last_name like '%GEN%';
-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select actor_id, first_name, last_name from actor where last_name like '%LI%' order by last_name, first_name;
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select * from country where country in ('Afghanistan', 'Bangladesh', 'China');
-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
alter table actor add column middle_name varchar(50) AFTER `first_name`;
-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
alter table actor modify column middle_name blob; 
-- 3c. Now delete the middle_name column.
alter table actor drop column middle_name;
-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name last_name, count(*) num from actor group by last_name;
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name last_name, count(*) num from actor group by last_name having num > 1;
-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
update actor set first_name = 'HARPO' where first_name = 'GROUCHO' and last_name='WILLIAMS';
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
update actor
set first_name = 
	case 
		when  first_name = "HARPO"
			then "GROUCHO"
		else "MUCHO GROUCHO"
	end
where actor_id = 172;
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;
show columns from address;
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select s.first_name, s.last_name, a.address from staff s inner join address a using (address_id);
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select s.first_name, s.last_name, sum(p.amount) total from staff s join payment p using(staff_id) where p.payment_date > '2005-08'group by s.first_name, s.last_name;
-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select f.title, count(fa.actor_id) num_of_actors from film f join film_actor fa using(film_id) group by f.film_id order by num_of_actors desc;
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select f.title, count(f.film_id) num_of_copies from film f join inventory i using(film_id) where f.title = 'Hunchback Impossible' group by f.title;
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select c.first_name, c.last_name, sum(p.amount) Total_amount_paid from customer c join payment p using(customer_id) group by c.first_name, c.last_name order by c.last_name;
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title from film  where title like 'K%' or title like 'Q%' and language_id = (select language_id from language where name = 'English');
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name 
from actor 
where actor_id in -- use in if actor_id is more than 1 result. 
(select fa.actor_id
from film_actor fa 
join film f 
using (film_id)
where f.title= 'Alone Trip');
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select c.first_name, c.last_name, c.email 
from customer c
left join address a
using (address_id)
left join city cty
using (city_id)
left join country cy
using (country_id)
where cy.country = 'Canada';
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
select f.title 
from film f
join film_category fc
using(film_id)
join category c
using(category_id)
where c.name = 'Family';
-- 7e. Display the most frequently rented movies in descending order.
select f.title, count(r.rental_id) num_of_rental
from film f 
join inventory i
using (film_id)
join rental r
using(inventory_id)
group by f.title
order by num_of_rental desc;
-- 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(p.amount) total_revenue
from store s
left join staff st
using(store_id)
left join payment p
using(staff_id)
group by s.store_id;
-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, cty.city, cy.country
from store s
left join staff st
on s.store_id = st.store_id
left join address a
on st.address_id = a.address_id
left join city cty
on a.city_id = cty.city_id
left join country cy
using(country_id);
-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select c.name, sum(p.amount) revenue
from category c
join film_category 
using(category_id)
join inventory
using(film_id)
join rental 
using(inventory_id)
join payment p
using(rental_id)
group by c.name
order by revenue desc
limit 5;
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view genres_revenue
as select c.name, sum(p.amount) revenue
from category c
join film_category 
using(category_id)
join inventory
using(film_id)
join rental 
using(inventory_id)
join payment p
using(rental_id)
group by c.name
order by revenue desc
limit 5;
-- 8b. How would you display the view that you created in 8a?
select * from genres_revenue;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view genres_revenue;







