--======== CREATE ===========================================================--
-- Add a client
INSERT INTO Clients (client_name, phone_number, email)
VALUES (:client_name, :phone_number, :email);

-- Add an employee
INSERT INTO Employees (first_name,last_name,age,has_drivers_license,has_alcohol_certification,has_food_certification)
VALUES (:first_name,:last_name,:age,:has_drivers_license,:has_alcohol_certification,:has_food_certification);

-- Add an event
INSERT INTO Events (client_id, menu_id, event_start, event_end, event_address) VALUES
(:client_id, :menu_id, :event_start, :event_end, :event_address);

-- Add a menu
INSERT INTO Menus (menu_name) VALUES
(:menu_name);

-- Add a menu item
INSERT INTO Items (menu_id, item_name, price, is_alcoholic) VALUES
(:menu_id, :item_name, :price, :is_alcoholic);

-- Add an ingredient
INSERT INTO Ingredients (ingredient_name, unit, unit_price) VALUES
(:ingredient_name, :unit, :unit_price);

-- Assign an ingredient to a menu
INSERT INTO ItemIngredients (item_id, ingredient_id, quantity) VALUES
(:item_id, :ingredient_id, :quantity);

-- Assign an employee to an event
INSERT INTO AssignedCaterers (employee_id, event_id) VALUES
(:employee_id, :event_id);
--===========================================================================--


--======== READ =============================================================--
-- Select a client
SELECT client_id, client_name, phone_number
   FROM Clients
   WHERE client_id = :selected_id;

-- Select an employee
SELECT employee_id, first_name,last_name,age,has_drivers_license,has_alcohol_certification,has_food_certification
   FROM Employees
   WHERE employee_id = :selected_id;
   
-- Select an event
SELECT event_id, client_id, menu_id, event_start, event_end, event_address
   FROM Events
   WHERE event_id = :selected_id;

-- Select a menu
SELECT menu_id, menu_name
   FROM Menus
   WHERE menu_id = :selected_id;

-- Select a menu item
SELECT item_id, menu_id, item_name, price, is_alcoholic
   FROM Items
   WHERE item_id = :selected_id;

-- Select an ingredient
SELECT ingredient_id, ingredient_name, unit, unit_price
   FROM Ingredients
   WHERE ingredient_id = :selected_id;

-- Select an ingredient's link to a menu
SELECT item_ingredient_id, item_id, ingredient_id, quantity
   FROM ItemIngredients
   WHERE item_ingredient_id = :selected_id;

-- Select an employee's assignment to an event
SELECT assigned_caterers_id, employee_id, event_id
   FROM AssignedCaterers
   WHERE assigned_caterers_id = :selected_id;
--===========================================================================--


--======== DELETE ===========================================================--
-- Delete a client
DELETE FROM Clients WHERE client_id = :selected_id;

-- Delete an employee
DELETE FROM Employees WHERE employee_id = :selected_id;

-- Delete an event
DELETE FROM Events WHERE event_id = :selected_id;

-- Delete a menu
DELETE FROM Menus WHERE menu_id = :selected_id;

-- Delete a menu item
DELETE FROM Items WHERE item_id = :selected_id;

-- Unlink an ingredient from an item
DELETE FROM ItemIngredients WHERE item_ingredient_id = :selected_id;

-- Delete an ingredient
DELETE FROM Ingredients WHERE ingredient_id = :selected_id;

-- Unassign an employee from an event
DELETE FROM AssignedCaterers WHERE assigned_caterers_id = :selected_id;
--===========================================================================--


--======== UPDATE ===========================================================--
-- Update a client
UPDATE Clients
    SET client_name = :client_name_in,
        phone_number = :phone_number_in, 
        email = :email_in
    WHERE client_id = :selected_id;

-- Update an employee
UPDATE Employees
    SET first_name = :fname_in,
        last_name = :lname_in
        age = :age_in, 
        has_drivers_license = :driver_in,
        has_alcohol_certification = alcohol_in,
        has_food_certification = food_in
    WHERE employee_id = :selected_id;

-- Update an event
UPDATE Events
    SET client_id = :client_in,
        menu_id = :menu_in, 
        event_start = :start_in,
        event_end = :end_in,
        event_address = :address_in
    WHERE event_id = :selected_id;

-- Update a menu
UPDATE Menus
    SET menu_name = :name_in
    WHERE menu_id = :selected_id;

-- Update a menu item
UPDATE Items
    SET menu_id = :menu_in,
    item_name = :name_in,
    price = :price_in,
    is_alcoholic = :alcohol_in
    WHERE item_id = :selected_id;

-- Update an ingredient
UPDATE Ingredients
    SET ingredient_name = :name_in, 
    unit = :unit_in, 
    unit_price = :price_in
    WHERE ingredient_id = :selected_id;

-- Update an item's link to an ingredient
UPDATE ItemIngredients
    item_id = item_in,
    ingredient_id = ingredient_in,
    quantity = qty_in
    WHERE item_ingredient_id = :selected_id;

-- Reassign an employee to an event
UPDATE AssignedCaterers
    employee_id = employee_in,
    event_id = event_in
    WHERE item_ingredient_id = :selected_id;
--===========================================================================--
