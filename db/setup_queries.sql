CREATE TABLE IF NOT EXISTS Clients (
    client_id int NOT NULL UNIQUE AUTO_INCREMENT,
    client_name varchar(100) NOT NULL,
    phone_number varchar(12) NOT NULL UNIQUE,
    email varchar(100) NOT NULL UNIQUE,
    PRIMARY KEY (client_id)
);

CREATE TABLE IF NOT EXISTS Menus (
    menu_id int NOT NULL UNIQUE AUTO_INCREMENT,
    menu_name varchar(100) NOT NULL UNIQUE,
    PRIMARY KEY (menu_id)
);


CREATE TABLE IF NOT EXISTS Items (
    item_id int NOT NULL UNIQUE AUTO_INCREMENT,
    menu_id int NOT NULL,
    item_name varchar(100) NOT NULL,
    price decimal not NULL,
    is_alcoholic boolean NOT NULL,
    PRIMARY KEY (item_id),
    FOREIGN KEY (menu_id) REFERENCES Menus(menu_id)
);

CREATE TABLE IF NOT EXISTS Ingredients (
    ingredient_id int NOT NULL UNIQUE AUTO_INCREMENT,
    ingredient_name varchar(100) NOT NULL UNIQUE,
    ingredient_qty decimal NOT NULL,
    unit varchar(50) NOT NULL,
    unit_price decimal NOT NULL,
    PRIMARY KEY (ingredient_id)
);

CREATE TABLE IF NOT EXISTS ItemIngredients (
    item_ingredient_id int NOT NULL UNIQUE AUTO_INCREMENT, 
    item_id int NOT NULL,
    ingredient_id int NOT NULL,
    required_qty decimal NOT NULL,
    PRIMARY KEY (item_ingredient_id),
    FOREIGN KEY (item_id) REFERENCES Items(item_id),
    FOREIGN KEY (ingredient_id) REFERENCES Ingredients(ingredient_id)
);

CREATE TABLE IF NOT EXISTS Employees (
    employee_id int NOT NULL UNIQUE AUTO_INCREMENT,
    first_name varchar(50) NOT NULL,
    last_name varchar(50) NOT NULL,
    age int NOT NULL,
    has_drivers_license boolean NOT NULL, 
    has_alcohol_certification boolean NOT NULL, 
    has_food_certification boolean NOT NULL,
    PRIMARY KEY (employee_id)
);

CREATE TABLE IF NOT EXISTS Events (
    event_id int NOT NULL UNIQUE AUTO_INCREMENT,
    client_id int NOT NULL,
    menu_id int NOT NULL,
    event_start timestamp NOT NULL,
    event_end timestamp NOT NULL,
    event_address varchar(100) NOT NULL,
    event_type varchar(100),
    PRIMARY KEY (event_id),
    FOREIGN KEY (client_id) REFERENCES Clients(client_id),
    FOREIGN KEY (menu_id) REFERENCES Menus(menu_id)
);

CREATE TABLE IF NOT EXISTS AssignedCaterers (
    assigned_caterers_id int NOT NULL UNIQUE AUTO_INCREMENT,
    employee_id int NOT NULL,
    event_id int NOT NULL,
    PRIMARY KEY (assigned_caterers_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);
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

INSERT INTO Employees (first_name, last_name, age, has_drivers_license, has_alcohol_certification, has_food_certification) VALUES
(
    "Jeb",
    "Jab",
    27,
    TRUE,
    FALSE,
    TRUE
),
(
    "Rex",
    "Mohs",
    25,
    FALSE,
    TRUE,
    TRUE
),
(
    "Jerry",
    "Attricks",
    43,
    TRUE,
    FALSE,
    FALSE
),
(
    'Steel',
    'Wool',
    39,
    TRUE,
    FALSE,
    TRUE
);

INSERT INTO Menus (menu_name) VALUES
("Fancy Pants"),("Sandwiches for All"),("Roadside Steakout");


INSERT INTO Ingredients (ingredient_name, unit, unit_price) VALUES
(
    "Steak",
    "flanks",
    8.00
),
(
    "Poivre Seasoning",
    "shakers",
    3.40
),
(
    "Club Veggies",
    "bags",
    1.93
),
(
    "Bread",
    "loaves",
    5.84
),
(
    "Portebello Sauce",
    "bottles",
    3.14
),
(
    "Root Beer",
    "bottles",
    8.13
),
(
    "Meatballs",
    "bags",
    2.99
),
(
    "Fancy Veggies",
    "bags",
    5.89
),
(
    "Wine",
    "bottles",
    10.00
);

INSERT INTO Items(item_name, price, is_alcoholic, menu_id) VALUES
(
    "Maestro Club",
    5.79,
    FALSE,
    (SELECT menu_id FROM Menus where menu_name = "Sandwiches for All")
),
(
    "Montgomery Meatball",
    7.90,
    FALSE,
    (SELECT menu_id FROM Menus where menu_name = "Sandwiches for All")
),
(
    "Route Bear Cane Sugar Root Beer",
    3.00,
    FALSE,
    (SELECT menu_id FROM Menus where menu_name = "Sandwiches for All")
),
(
    "Portebello Potluck",
    6.99,
    FALSE,
    (SELECT menu_id FROM Menus where menu_name = "Sandwiches for All")
),
(
    "Steak au Poivre",
    18.99,
    FALSE,
    (SELECT menu_id FROM Menus where menu_name = "Fancy Pants")
),
(
    "Gilrose Red Wine",
    15.00, -- I don't drink so idk if this is a good price lol
    TRUE,
    (SELECT menu_id FROM Menus where menu_name = "Fancy Pants")
),
(
    "Filet Mignon",
    23.25,
    FALSE,
    (SELECT menu_id FROM Menus where menu_name = "Fancy Pants")
),
(
    "Jersey Prime Rib",
    17.85,
    FALSE,
    (SELECT menu_id FROM Menus where menu_name = "Roadside Steakout")
),
(
    "Philly Cheesesteak",
    19.18,
    FALSE,
    (SELECT menu_id FROM Menus where menu_name = "Roadside Steakout")
);

INSERT INTO ItemIngredients (ingredient_id, item_id, quantity) VALUES
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Club Veggies" ),
    (SELECT item_id FROM Items WHERE item_name = "Maestro Club"),
    10.0
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Bread" ),
    (SELECT item_id FROM Items WHERE item_name = "Maestro Club"),
    10.0
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Meatballs" ),
    (SELECT item_id FROM Items WHERE item_name = "Montgomery Meatball"),
    10.0
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Bread" ),
    (SELECT item_id FROM Items WHERE item_name = "Montgomery Meatball"),
    10.0
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Portebello Sauce" ),
    (SELECT item_id FROM Items WHERE item_name = "Portebello Potluck"),
    10.0
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Bread" ),
    (SELECT item_id FROM Items WHERE item_name = "Portebello Potluck"),
    10.0
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Root Beer" ),
    (SELECT item_id FROM Items WHERE item_name = "Route Bear Cane Sugar Root Beer"),
    10.0
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Steak" ),
    (SELECT item_id FROM Items WHERE item_name = "Steak au Poivre"),
    10.0
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Poivre Seasoning" ),
    (SELECT item_id FROM Items WHERE item_name = "Steak au Poivre"),
    10.0
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Wine" ),
    (SELECT item_id FROM Items WHERE item_name = "Gilrose Red Wine"),
    10.0
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Steak" ),
    (SELECT item_id FROM Items WHERE item_name = "Filet Mignon"),
    10.0
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Steak" ),
    (SELECT item_id FROM Items WHERE item_name = "Jersey Prime Rib"),
    10.0
),
(
    (SELECT ingredient_id FROM Ingredients WHERE ingredient_name = "Steak" ),
    (SELECT item_id FROM Items WHERE item_name = "Philly Cheesesteak"),
    10.0
);

INSERT INTO Events (event_start, event_end, event_address, event_type, client_id, menu_id) VALUES
(
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

INSERT INTO AssignedCaterers (employee_id, event_id) VALUES
(
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