-------------------------------------------------------------------------------------------
-- Creating Tables
-------------------------------------------------------------------------------------------

-- Query to create the Clients table
CREATE TABLE IF NOT EXISTS Clients (
    client_id int NOT NULL UNIQUE AUTO_INCREMENT,
    client_name varchar(50) NOT NULL,
    phone_number varchar(50) NOT NULL UNIQUE,
    email varchar(50) NOT NULL UNIQUE,
    PRIMARY KEY (client_id)
);
-- Query to create the Menus table
CREATE TABLE IF NOT EXISTS Menus (
    menu_id int NOT NULL UNIQUE AUTO_INCREMENT,
    menu_name varchar(50) NOT NULL UNIQUE,
    PRIMARY KEY (menu_id)
);

-- Query to create the Items table
CREATE TABLE IF NOT EXISTS Items (
    item_id int NOT NULL UNIQUE AUTO_INCREMENT,
    menu_id int,
    item_name varchar(50) NOT NULL,
    price decimal(10, 2) NOT NULL,
    is_alcoholic boolean NOT NULL,
    PRIMARY KEY (item_id),
    FOREIGN KEY (menu_id) REFERENCES Menus(menu_id)
        ON DELETE SET NULL  -- allows menu deletion while preserving items
);

-- Query to create the Ingredients table
CREATE TABLE IF NOT EXISTS Ingredients (
    ingredient_id int NOT NULL UNIQUE AUTO_INCREMENT,
    ingredient_name varchar(50) NOT NULL UNIQUE,
    ingredient_qty decimal(10) NOT NULL,
    unit varchar(10) NOT NULL,
    unit_price decimal(10, 2) NOT NULL,
    PRIMARY KEY (ingredient_id)
);

-- Query to create the ItemIngredients table
CREATE TABLE IF NOT EXISTS ItemIngredients (
    item_ingredient_id int NOT NULL UNIQUE AUTO_INCREMENT,
    item_id int NOT NULL,
    ingredient_id int NOT NULL,
    required_qty decimal(10, 2) NOT NULL,
    PRIMARY KEY (item_ingredient_id),
    FOREIGN KEY (item_id) REFERENCES Items(item_id)
        ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES Ingredients(ingredient_id)
        ON DELETE CASCADE,   -- when item or ingredient is deleted, remove connections
    CONSTRAINT UQ_ITEMINGREDIENT UNIQUE (item_id, ingredient_id)
    -- There can only be one usage of an item in an ingredient
);

-- Query to create the Employees table
CREATE TABLE IF NOT EXISTS Employees (
    employee_id int NOT NULL UNIQUE AUTO_INCREMENT,
    first_name varchar(50) NOT NULL,
    last_name varchar(50) NOT NULL,
    birthdate date NOT NULL,
    has_drivers_license bool NOT NULL,
    has_alcohol_certification bool NOT NULL,
    has_food_certification bool NOT NULL,
    PRIMARY KEY (employee_id)
);

-- Query to create the Events table
CREATE TABLE IF NOT EXISTS Events (
    event_id int NOT NULL UNIQUE AUTO_INCREMENT,
    client_id int NOT NULL,
    menu_id int NOT NULL,
    event_start timestamp NOT NULL,
    event_end timestamp NOT NULL,
    event_address varchar(255) NOT NULL,
    event_type varchar(50) NOT NULL,
    PRIMARY KEY (event_id),
    FOREIGN KEY (client_id) REFERENCES Clients(client_id)
        ON DELETE CASCADE,      -- when client is deleted, remove their events
    FOREIGN KEY (menu_id) REFERENCES Menus(menu_id)
        ON DELETE RESTRICT      -- prevent menu deletion if events use it
);

-- Query to create the AssignedCaterers table
CREATE TABLE IF NOT EXISTS AssignedCaterers (
    assigned_caterers_id int NOT NULL UNIQUE AUTO_INCREMENT,
    employee_id int NOT NULL,
    event_id int NOT NULL,
    PRIMARY KEY (assigned_caterers_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
        ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
        ON DELETE CASCADE,       -- when event or employee is deleted, remove assignments
    CONSTRAINT UQ_ASSIGNMENTS UNIQUE (event_id, employee_id)
    -- An employee cannot be assigned to the same event more than once
);

-------------------------------------------------------------------------------------------
-- Inserting Data
-------------------------------------------------------------------------------------------

INSERT INTO Clients (
    client_name,
    phone_number,
    email
)
VALUES (
    "Billy Bob's Wild Derby Fair Committee",
    "5553042043",
    "jon@billybob.org"
),
(
    "Ferringdale Embassy & Suites",
    "5559295925",
    "foodservice@ferringdale.co"
),
(
    "Scouts BSA Troop 518",
    "5554938423",
    "nBalboa@gmail.com"
);

INSERT INTO Employees (
    first_name,
    last_name,
    birthdate,
    has_drivers_license,
    has_alcohol_certification,
    has_food_certification
)
VALUES (
    "Jeb",
    "Jab",
    '1994-11-16',
    TRUE,
    FALSE,
    TRUE
),
(
    "Rex",
    "Mohs",
    '2000-02-20',
    FALSE,
    TRUE,
    TRUE
),
(
    "Jerry",
    "Attricks",
    '1982-06-10',
    TRUE,
    FALSE,
    FALSE
),
(
    'Steel',
    'Wool',
    '1986-03-25',
    TRUE,
    FALSE,
    TRUE
);

INSERT INTO Menus (menu_name)
VALUES 
    ("Fancy Pants"),
    ("Sandwiches for All"),
    ("Roadside Steakout");

INSERT INTO Ingredients (
    ingredient_name,
    ingredient_qty,
    unit,
    unit_price
)
VALUES (
    "Steak",
    60.0,
    "flanks",
    8.00
),
(
    "Poivre Seasoning",
    102,
    "shakers",
    3.40
),
(
    "Club Veggies",
    50,
    "bags",
    1.93
),
(
    "Bread",
    20,
    "loaves",
    5.84
),
(
    "Portebello Sauce",
    60,
    "bottles",
    3.14
),
(
    "Root Beer",
    80,
    "bottles",
    8.13
),
(
    "Meatballs",
    30,
    "bags",
    2.99
),
(
    "Fancy Veggies",
    20,
    "bags",
    5.89
),
(
    "Wine",
    7,
    "bottles",
    10.00
);

INSERT INTO Items (
    item_name,
    price,
    is_alcoholic,
    menu_id
)
VALUES (
    "Maestro Club",
    5.79,
    FALSE,
    (SELECT menu_id FROM Menus WHERE menu_name = "Sandwiches for All")
),
(
    "Montgomery Meatball",
    7.90,
    FALSE,
    (SELECT menu_id FROM Menus WHERE menu_name = "Sandwiches for All")
),
(
    "Route Bear Cane Sugar Root Beer",
    3.00,
    FALSE,
    (SELECT menu_id FROM Menus WHERE menu_name = "Sandwiches for All")
),
(
    "Portebello Potluck",
    6.99,
    FALSE,
    (SELECT menu_id FROM Menus WHERE menu_name = "Sandwiches for All")
),
(
    "Steak au Poivre",
    18.99,
    FALSE,
    (SELECT menu_id FROM Menus WHERE menu_name = "Fancy Pants")
),
(
    "Gilrose Red Wine",
    15.00,
    TRUE,
    (SELECT menu_id FROM Menus WHERE menu_name = "Fancy Pants")
),
(
    "Filet Mignon",
    23.25,
    FALSE,
    (SELECT menu_id FROM Menus WHERE menu_name = "Fancy Pants")
),
(
    "Jersey Prime Rib",
    17.85,
    FALSE,
    (SELECT menu_id FROM Menus WHERE menu_name = "Roadside Steakout")
),
(
    "Philly Cheesesteak",
    19.18,
    FALSE,
    (SELECT menu_id FROM Menus WHERE menu_name = "Roadside Steakout")
);

INSERT INTO ItemIngredients (
    ingredient_id,
    item_id,
    required_qty
)
VALUES (
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Club Veggies"),
    (SELECT item_id FROM Items WHERE item_name = "Maestro Club"),
    0.1
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Bread"),
    (SELECT item_id FROM Items WHERE item_name = "Maestro Club"),
    0.2
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Meatballs"),
    (SELECT item_id FROM Items WHERE item_name = "Montgomery Meatball"),
    0.33333
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Bread"),
    (SELECT item_id FROM Items WHERE item_name = "Montgomery Meatball"),
    0.2
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Portebello Sauce"),
    (SELECT item_id FROM Items WHERE item_name = "Portebello Potluck"),
    0.05
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Bread"),
    (SELECT item_id FROM Items WHERE item_name = "Portebello Potluck"),
    0.2
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Root Beer"),
    (SELECT item_id FROM Items WHERE item_name = "Route Bear Cane Sugar Root Beer"),
    1
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Steak"),
    (SELECT item_id FROM Items WHERE item_name = "Steak au Poivre"),
    1
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Poivre Seasoning"),
    (SELECT item_id FROM Items WHERE item_name = "Steak au Poivre"),
    0.08
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Wine"),
    (SELECT item_id FROM Items WHERE item_name = "Gilrose Red Wine"),
    0.1
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Steak"),
    (SELECT item_id FROM Items WHERE item_name = "Filet Mignon"),
    1
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Steak"),
    (SELECT item_id FROM Items WHERE item_name = "Jersey Prime Rib"),
    1
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Steak"),
    (SELECT item_id FROM Items WHERE item_name = "Philly Cheesesteak"),
    1
);

INSERT INTO Events (
    event_start,
    event_end,
    event_address,
    event_type,
    client_id,
    menu_id
)
VALUES (
    '2025-06-01 15:00:00',
    '2025-06-01 18:00:00',
    "9843 E Street, Dallas, OR",
    "Fairground Catering",
    (SELECT client_id FROM Clients WHERE email="jon@billybob.org"),
    (SELECT menu_id FROM Menus WHERE menu_name = "Roadside Steakout")
),
(
    '2025-05-25 19:00:00',
    '2025-05-25 23:30:00',
    "2382 Relma Complex, Portland, OR",
    "Hotel Fine Dining",
    (SELECT client_id FROM Clients WHERE email="foodservice@ferringdale.co"),
    (SELECT menu_id FROM Menus WHERE menu_name = "Fancy Pants")
),
(
    '2025-04-14 14:00:00',
    '2025-04-14 16:45:00',
    "495 Horace Ave, Gales Creek, OR",
    "Scout Court of Honor",
    (SELECT client_id FROM Clients WHERE email="nBalboa@gmail.com"),
    (SELECT menu_id FROM Menus WHERE menu_name = "Sandwiches for All")
);

INSERT INTO AssignedCaterers (
    employee_id,
    event_id
)
VALUES (
    (SELECT employee_id FROM Employees WHERE first_name = "Jeb"),
    (SELECT event_id FROM Events WHERE event_type = "Scout Court of Honor")
),
(
    (SELECT employee_id FROM Employees WHERE first_name = "Rex"),
    (SELECT event_id FROM Events WHERE event_type = "Scout Court of Honor")
),
(
    (SELECT employee_id FROM Employees WHERE first_name = "Steel"),
    (SELECT event_id FROM Events WHERE event_type = "Scout Court of Honor")
),
(
    (SELECT employee_id FROM Employees WHERE first_name = "Jerry"),
    (SELECT event_id FROM Events WHERE event_type = "Hotel Fine Dining")
),
(
    (SELECT employee_id FROM Employees WHERE first_name = "Rex"),
    (SELECT event_id FROM Events WHERE event_type = "Hotel Fine Dining")
),
(
    (SELECT employee_id FROM Employees WHERE first_name = "Jeb"),
    (SELECT event_id FROM Events WHERE event_type = "Hotel Fine Dining")
),
(
    (SELECT employee_id FROM Employees WHERE first_name = "Jerry"),
    (SELECT event_id FROM Events WHERE event_type = "Fairground Catering")
),
(
    (SELECT employee_id FROM Employees WHERE first_name = "Steel"),
    (SELECT event_id FROM Events WHERE event_type = "Fairground Catering")
),
(
    (SELECT employee_id FROM Employees WHERE first_name = "Jeb"),
    (SELECT event_id FROM Events WHERE event_type = "Fairground Catering")
);