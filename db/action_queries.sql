--======== CREATE ===========================================================--
-- Add a client
INSERT INTO Clients (client_name, phone_number, email)
VALUES (:client_name, :phone_number, :email);

-- Add an employee
INSERT INTO Employees (first_name, last_name, birthdate, has_drivers_license, has_alcohol_certification, has_food_certification)
VALUES (:first_name, :last_name, :birthdate, :has_drivers_license, :has_alcohol_certification, :has_food_certification);

-- Add an event
INSERT INTO Events (client_id, event_name, menu_id, event_start, event_end, event_address)
VALUES (:client_id, :event_name, :menu_id, :event_start, :event_end, :event_address);

-- Add a menu
INSERT INTO Menus (menu_name)
VALUES (:menu_name);

-- Add a menu item
INSERT INTO Items (menu_id, item_name, price, is_alcoholic)
VALUES (:menu_id, :item_name, :price, :is_alcoholic);

-- Add an ingredient
INSERT INTO Ingredients (ingredient_name, ingredient_qty, unit, unit_price)
VALUES (:ingredient_name, :ingredient_qty :unit, :unit_price);

-- Assign an ingredient to a menu
INSERT INTO ItemIngredients (item_id, ingredient_id, required_qty)
VALUES (:item_id, :ingredient_id, :required_qty);

-- Assign an employee to an event
INSERT INTO AssignedCaterers (employee_id, event_id)
VALUES (:employee_id, :event_id);
--===========================================================================--


--======== READ =============================================================--
-- Select a client
SELECT client_id, client_name, phone_number, email
   FROM Clients

-- Select an employee
SELECT employee_id, first_name, last_name, birthdate, has_drivers_license, has_alcohol_certification, has_food_certification
   FROM Employees
   
-- Select an event
SELECT event_id, event_name, client_id, menu_id, event_start, event_end, event_address
   FROM Events

-- Select an event (with client name and menu name added)
SELECT Events.event_id, Events.event_name, Events.client_id, Clients.client_name, Events.menu_id, Menus.menu_name, Events.event_start, Events.event_end, Events.event_address
FROM Events
INNER JOIN Clients ON Events.client_id = Clients.client_id
INNER JOIN Menus ON Events.menu_id = Menus.menu_id
ORDER BY Events.event_id ASC;

-- Select a menu
SELECT menu_id, menu_name
   FROM Menus

-- Select a menu item
SELECT item_id, menu_id, item_name, price, is_alcoholic
   FROM Items

-- Select an ingredient
SELECT ingredient_id, ingredient_name, ingredient_qty, unit, unit_price
   FROM Ingredients

-- Select an ingredient's link to a menu
SELECT ItemIngredients.item_ingredient_id, 
       ItemIngredients.item_id, 
       Items.item_name, 
       ItemIngredients.ingredient_id, 
       Ingredients.ingredient_name, 
       ItemIngredients.required_qty
FROM ItemIngredients
INNER JOIN Items ON ItemIngredients.item_id = Items.item_id
INNER JOIN Ingredients ON ItemIngredients.ingredient_id = Ingredients.ingredient_id
ORDER BY ItemIngredients.item_ingredient_id ASC;

-- Select an employee's assignment to an event
SELECT AssignedCaterers.assigned_caterers_id, AssignedCaterers.employee_id, 
    CONCAT(Employees.first_name, ' ', Employees.last_name) AS caterer_name, 
    AssignedCaterers.event_id, Events.event_name AS event_name
FROM AssignedCaterers 
INNER JOIN Employees ON AssignedCaterers.employee_id = Employees.employee_id 
INNER JOIN Events ON AssignedCaterers.event_id = Events.event_id
ORDER BY AssignedCaterers.assigned_caterers_id ASC;

--===========================================================================--


--======== DELETE ===========================================================--

-- Unassign an employee from an event
DELETE FROM AssignedCaterers WHERE assigned_caterers_id = :selected_id;
--===========================================================================--


--======== UPDATE ===========================================================--

-- Update an event
UPDATE Events
    SET event_name = :event_name_in 
        client_id = :client_in,
        menu_id = :menu_in, 
        event_start = :start_in,
        event_end = :end_in,
        event_address = :address_in
    WHERE event_id = :selected_id;

-- Reassign/update an employee assignment to an event
UPDATE AssignedCaterers
    SET employee_id = :employee_in,
    event_id = event_in
    WHERE item_ingredient_id = :selected_id;
--===========================================================================--
