from flask import Flask, render_template, request, redirect, url_for, flash
from flask_mysqldb import MySQL, MySQLdb
from dotenv import load_dotenv
import os
from MySQLdb import IntegrityError


load_dotenv()

app = Flask(__name__)
app.secret_key = os.urandom(24)     # for flashing messages

# Configure MySQL connection
app.config["MYSQL_HOST"] = "classmysql.engr.oregonstate.edu"
app.config["MYSQL_USER"] = "cs340_montgale"
app.config["MYSQL_PASSWORD"] = "6470"
app.config["MYSQL_DB"] = "cs340_montgale"
app.config["MYSQL_CURSORCLASS"] = "DictCursor"

mysql = MySQL(app)

'''Homepage route'''
@app.route('/')
def index():
    return render_template('index.html')  

'''SELECT/INSERT CLIENTS route'''
@app.route('/clients', methods=['GET', 'POST'])
def clients():
    if request.method == 'POST':
        # add new client
        client_name = request.form['client_name']
        phone_number = request.form['phone_number']
        email = request.form['email']
        cur = mysql.connection.cursor()

        # try/except block
        try:
            cur.execute("""
                INSERT INTO Clients (client_name, phone_number, email)
                VALUES (%s, %s, %s)
            """, (client_name, phone_number, email))
            mysql.connection.commit()
            flash('Client added successfully!', 'success')

        except MySQLdb.IntegrityError as e:
            error_message = str(e.args[1])  # Convert error message to string
            if e.args[0] == 1062:  # MySQL error code for duplicate entry - in Clients, email and phone_number must be UNIQUE
                if 'email' in error_message:
                    flash('Error adding client: this client email is already in the database.', 'danger')
                elif 'phone_number' in error_message:
                    flash('Error adding client: this phone number is already in the database.', 'danger')
            else:
                flash(f'An unexpected error occurred: {e.args[1]}', 'danger')

        finally:
            cur.close()
        
        return redirect(url_for('clients'))

    # display the clients table
    cur = mysql.connection.cursor()
    # query:
    cur.execute("SELECT client_id, client_name, phone_number, email FROM Clients")
    data = cur.fetchall()
    cur.close()
    return render_template('clients.html', data=data)

'''SELECT/INSERT EMPLOYEES route'''
@app.route('/employees', methods=['GET', 'POST'])
def employees():
    if request.method == 'POST':
        # add new employee
        first_name = request.form['first_name']
        last_name = request.form['last_name']
        birthdate = request.form['birthdate']
        # handle boolean inputs
        # Ethan: These actually don't need a conditional assignment because the
        # == operator returns True or False, which will get stored as such
        has_drivers_license = request.form['has_drivers_license'] == 'True'
        has_alcohol_certification = request.form['has_alcohol_certification'] == 'True'
        has_food_certification = request.form['has_food_certification'] == 'True'

        cur = mysql.connection.cursor()

        # try/except block
        try:
            cur.execute("""
                INSERT INTO Employees (first_name, last_name, birthdate, has_drivers_license, has_alcohol_certification, has_food_certification)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (first_name, last_name, birthdate, has_drivers_license, has_alcohol_certification, has_food_certification))
            mysql.connection.commit()
            flash('Employee added successfully!', 'success')

        except MySQLdb.IntegrityError as e:
            flash(f'An unexpected error occurred: {e.args[1]}.', 'danger')

        finally:
            cur.close()
    
        return redirect(url_for('employees'))

    # display the employees table
    cur = mysql.connection.cursor()
    # query:
    cur.execute("SELECT employee_id, first_name, last_name, birthdate, has_drivers_license, has_alcohol_certification, has_food_certification FROM Employees")
    data = cur.fetchall()
    cur.close()

    # convert 0/1 to True/False
    for row in data:
        row['has_drivers_license'] = 'True' if row['has_drivers_license'] else 'False'
        row['has_alcohol_certification'] = 'True' if row['has_alcohol_certification'] else 'False'
        row['has_food_certification'] = 'True' if row['has_food_certification'] else 'False'
    return render_template('employees.html', data=data)

'''SELECT/INSERT EVENTS route'''
@app.route('/events', methods=['GET', 'POST'])
def events():
    if request.method == 'POST':
        # add new event
        event_name = request.form['event_name']
        client_id = request.form['client_id']
        menu_id = request.form['menu_id']
        event_start = request.form['event_start']
        event_end = request.form['event_end']
        event_address = request.form['event_address']
        
        cur = mysql.connection.cursor()

        # try/except block
        try:
            cur.execute("""
                INSERT INTO Events (event_name, client_id, menu_id, event_start, event_end, event_address)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (event_name, client_id, menu_id, event_start, event_end, event_address))
            mysql.connection.commit()
            flash('Event added successfully!', 'success')

        except MySQLdb.IntegrityError as e:
            if e.args[0] == 1062:  # MySQL error code for duplicate entry - in Events, event_name must be UNIQUE
                flash('An event with this name already exists. Please use a different name.', 'danger')
            else:
                flash(f'An unexpected error occurred: {e.args[1]}', 'danger')

        finally:
            cur.close()
    
        return redirect(url_for('events'))

    # display the events table
    cur = mysql.connection.cursor()
    # query:
    cur.execute("""
        SELECT Events.event_id, Events.event_name, Events.client_id, Clients.client_name, Events.menu_id, Menus.menu_name, Events.event_start, Events.event_end, Events.event_address
        FROM Events
        INNER JOIN Clients ON Events.client_id = Clients.client_id
        INNER JOIN Menus ON Events.menu_id = Menus.menu_id
        ORDER BY Events.event_id ASC;
    """)
    data = cur.fetchall()

    # get data for client and menu dropdowns
    cur = mysql.connection.cursor()
    cur.execute("SELECT client_id, client_name FROM Clients")
    clients = cur.fetchall()
    cur.execute("SELECT menu_id, menu_name FROM Menus")
    menus = cur.fetchall()
    return render_template('events.html', data=data, clients=clients, menus=menus)

'''UPDATE EVENT route'''
@app.route('/update_event', methods=['POST'])
def update_event():
    event_id = request.form['event_id']
    event_name = request.form['event_name']
    menu_id = request.form['menu_id']
    event_start = request.form['event_start']
    event_end = request.form['event_end']
    event_address = request.form['event_address']

    cur = mysql.connection.cursor()

    # update the event
    try:
        cur.execute("""
            UPDATE Events 
            SET event_name = %s,
                menu_id = %s, 
                event_start = %s, 
                event_end = %s, 
                event_address = %s
            WHERE event_id = %s
        """, (event_name, menu_id, event_start, event_end, event_address, event_id))
        
        mysql.connection.commit()
        flash("Event updated successfully!", "success")
    except MySQLdb.Error as e:
        flash("An event with this name already exists. Please try again.", "danger")
    finally:
        cur.close()
    return redirect(url_for('events'))

'''SELECT/INSERT MENUS route'''
@app.route('/menus', methods=['GET', 'POST'])
def menus():
    if request.method == 'POST':
        # add new menu
        menu_name = request.form['menu_name']
        cur = mysql.connection.cursor()

        # try/except block
        try:
            cur.execute("""
                INSERT INTO Menus (menu_name) 
                VALUES (%s)
            """, [menu_name])
            mysql.connection.commit()
            flash('Menu added successfully!', 'success')

        except MySQLdb.IntegrityError as e:
            if e.args[0] == 1062:  # MySQL error code for duplicate entry - in Menus, menu_name must be UNIQUE
                flash('A menu with this name already exists. Please use a different name.', 'danger')
            else:
                flash(f'An unexpected error occurred: {e.args[1]}', 'danger')
        finally:
            cur.close()
    
        return redirect(url_for('menus'))

    cur = mysql.connection.cursor()
    # query:
    cur.execute("""
            SELECT Menus.menu_id, Menus.menu_name FROM Menus
                ORDER BY Menus.menu_id ASC;
    """)
    data = cur.fetchall()
    cur.close()
    return render_template("menus.html", data = data)

'''SELECT/INSERT ITEMS route'''
@app.route('/items', methods=['GET', 'POST'])
def items():
    if request.method == 'POST':
        item_name = request.form['item_name']
        menu_id = request.form['menu_id']
        price = request.form['price']
        is_alcoholic = request.form['is_alcoholic'] == 'True'

        if menu_id == "NULL":  # Convert "NULL" string to Python None
            menu_id = None

        cur = mysql.connection.cursor()

        try:
            cur.execute("""
                INSERT INTO Items (item_name, menu_id, price, is_alcoholic)
                VALUES (%s, %s, %s, %s)
            """, (item_name, menu_id, price, is_alcoholic))
            mysql.connection.commit()
            flash('Item created successfully!', 'success')

        except MySQLdb.IntegrityError as e:
            # this is the error raised when the UNIQUE constraint is violated
            if e.args[0] == 1062:  # 1062 is MySQL's error code for duplicate entry
                flash('An item with this name already exists.', 'danger')
            else:
                flash(f'An unexpected error occurred: {e.args[1]}', 'danger')
        return redirect(url_for("items"))
    
    cur = mysql.connection.cursor()
    # query:
    cur.execute("""
        SELECT Items.item_id, Items.item_name, Items.price, Items.is_alcoholic, Items.menu_id, Menus.menu_name
            FROM Items LEFT JOIN Menus on Items.menu_id = Menus.menu_id
        ORDER BY Items.item_id ASC;
    """)
    data = cur.fetchall()
    cur.close()

    cur = mysql.connection.cursor()
    cur.execute(""" SELECT Menus.menu_id, CONCAT(Menus.menu_id, ' - ', Menus.menu_name) AS idname FROM Menus 
                ORDER BY Menus.menu_id ASC;
        """)
    menu = cur.fetchall()
    cur.close()

    # convert 0/1 to True/False
    for row in data:
        row['is_alcoholic'] = 'True' if row['is_alcoholic'] else 'False'
    return render_template("items.html", data = data, menu=menu)

"""UPDATE ITEM route"""
@app.route('/update_item', methods=['POST'])
def update_item():
    item_id = request.form['item_id']
    menu_id = request.form['menu_id']
    item_name = request.form['item_name']
    price = request.form['price']
    is_alcoholic = request.form['is_alcoholic'] == 'True'

    if menu_id == "NULL":  # Convert "NULL" string to Python None
            menu_id = None
    
    # try/except block: handles when user attempts to update items
    cur = mysql.connection.cursor()
    try:
        cur.execute("""
            UPDATE Items
            SET  menu_id = %s, price = %s, is_alcoholic = %s, item_name = %s
            WHERE item_id = %s
        """, (menu_id, price, is_alcoholic, item_name, item_id))
        mysql.connection.commit()
        flash('Item updated successfully!', 'success')

    except MySQLdb.IntegrityError as e:
        # this is the error raised when the UNIQUE constraint is violated
        if e.args[0] == 1062:  # 1062 is MySQL's error code for duplicate entry
            flash('This item name already exists.', 'danger')
        else:
            flash(f'An unexpected error occurred: {e.args[1]}', 'danger')

    finally:
        cur.close()
    return redirect(url_for('items'))

'''SELECT/INSERT ITEMINGREDIENTS route'''
@app.route('/item_ingredients', methods=['GET', 'POST'])
def item_ingredients():
    if request.method == 'POST':
        # add new ItemIngredient
        item_id = request.form['item_id']
        ingredient_id = request.form['ingredient_id']
        required_qty = request.form['required_qty']

        cur = mysql.connection.cursor()

        # try/except block
        try:
            cur.execute("""
                INSERT INTO ItemIngredients (item_id, ingredient_id, required_qty)
                VALUES (%s, %s, %s)
            """, (item_id, ingredient_id, required_qty))
            mysql.connection.commit()
            flash('ItemIngredient added successfully!', 'success')

        except MySQLdb.IntegrityError as e:
            # this is the error raised when the UNIQUE constraint is violated
            if e.args[0] == 1062:  # 1062 is MySQL's error code for duplicate entry - in ItemIngredients, UNIQUE constraint is defined for combo of item_id/ingredient_id
                flash('This item already contains this ingredient.', 'danger')
            else:
                flash(f'An unexpected error occurred: {e.args[1]}', 'danger')

        finally:
            cur.close()
        return redirect(url_for('item_ingredients'))

    # display the ItemIngredients table
    cur = mysql.connection.cursor()
    # query:
    cur.execute("""
            SELECT ItemIngredients.item_ingredient_id, 
                ItemIngredients.item_id, 
                ItemIngredients.ingredient_id,
                Items.item_name, 
                Ingredients.ingredient_name, 
                Ingredients.unit, 
                ItemIngredients.required_qty
            FROM ItemIngredients 
            INNER JOIN Items ON ItemIngredients.item_id = Items.item_id 
            INNER JOIN Ingredients ON ItemIngredients.ingredient_id = Ingredients.ingredient_id
            ORDER BY ItemIngredients.item_ingredient_id ASC
    """)
    data = cur.fetchall()
    cur.close()

    # get item and ingredient data for the dropdown lists
    cur = mysql.connection.cursor()
    cur.execute("SELECT item_id, item_name FROM Items")
    items = cur.fetchall()
    cur.execute("SELECT ingredient_id, ingredient_name FROM Ingredients")
    ingredients = cur.fetchall()
    cur.close()
    return render_template('item_ingredients.html', data=data, items=items, ingredients=ingredients)

'''SELECT/INSERT INGREDIENTS route'''
@app.route('/ingredients', methods=['GET', 'POST'])
def ingredients():
    if request.method == 'POST':
        # add new ingredient
        ingredient_name = request.form['ingredient_name']
        ingredient_qty = request.form['ingredient_qty']
        unit = request.form['unit']
        unit_price = request.form['unit_price']
        
        cur = mysql.connection.cursor()

        # try/except block
        try:
            cur.execute("""
                INSERT INTO Ingredients (ingredient_name, ingredient_qty, unit, unit_price)
                VALUES (%s, %s, %s, %s)
            """, (ingredient_name, ingredient_qty, unit, unit_price))
            mysql.connection.commit()
            flash('Ingredient added successfully!', 'success')

        except MySQLdb.IntegrityError as e:
            if e.args[0] == 1062:  # MySQL error code for duplicate entry
                flash('An ingredient with this name already exists. Please use a different name.', 'danger')
            else:
                flash(f'An unexpected error occurred: {e.args[1]}', 'danger')

        finally:
            cur.close()
    
        return redirect(url_for('ingredients'))

    cur = mysql.connection.cursor()
    # query:
    cur.execute("""
            SELECT Ingredients.ingredient_id, Ingredients.ingredient_name,
                Ingredients.ingredient_qty, Ingredients.unit, 
                Ingredients.unit_price FROM Ingredients 
                ORDER BY Ingredients.ingredient_id ASC;
    """)
    data = cur.fetchall()
    cur.close()
    return render_template("ingredients.html", data=data)

'''SELECT/INSERT ASSIGNED_CATERERS route'''
@app.route('/assigned_caterers', methods=['GET', 'POST'])
def assigned_caterers():
    if request.method == 'POST':
        # add new assignment
        employee_id = request.form['employee_id']
        event_id = request.form['event_id']
        cur = mysql.connection.cursor()

        # try/except block
        try:
            cur.execute("""
                INSERT INTO AssignedCaterers (employee_id, event_id)
                VALUES (%s, %s)
            """, (employee_id, event_id))
            mysql.connection.commit()
            flash('Caterer assigned successfully!', 'success')

        except MySQLdb.IntegrityError as e:
            # this is the error raised when the UNIQUE constraint is violated
            if e.args[0] == 1062:  # 1062 is MySQL's error code for duplicate entry - in AssignedCaterers, UNIQUE constraint is defined for combo of employee_id/event_id
                flash('This employee is already assigned to this event.', 'danger')
            else:
                flash(f'An unexpected error occurred: {e.args[1]}', 'danger')

        finally:
            cur.close()

        return redirect(url_for('assigned_caterers'))

    # display the assigned caterers table
    cur = mysql.connection.cursor()
    # query:
    cur.execute("""
            SELECT AssignedCaterers.assigned_caterers_id, AssignedCaterers.employee_id, 
                CONCAT(Employees.first_name, ' ', Employees.last_name) AS caterer_name, 
                AssignedCaterers.event_id, Events.event_name AS event_name
            FROM AssignedCaterers 
            INNER JOIN Employees ON AssignedCaterers.employee_id = Employees.employee_id 
            INNER JOIN Events ON AssignedCaterers.event_id = Events.event_id
            ORDER BY AssignedCaterers.assigned_caterers_id ASC
    """)
    data = cur.fetchall()
    cur.close()

    # get employee and event data for the dropdown lists
    cur = mysql.connection.cursor()
    cur.execute("SELECT employee_id, CONCAT(first_name, ' ', last_name) AS name FROM Employees")
    employees = cur.fetchall()
    cur.execute("SELECT event_id, event_name FROM Events")
    events = cur.fetchall()
    cur.close()
    return render_template('assigned_caterers.html', data=data, employees=employees, events=events)

'''UPDATE ASSIGNED_CATERERS route'''
@app.route('/update_assignment', methods=['POST'])
def update_assignment():
    assignment_id = request.form['assignment_id']
    employee_id = request.form['employee_id']
    event_id = request.form['event_id']
    cur = mysql.connection.cursor()

    # try/except block: handles when user attempts to update assignment to have caterer/event combo that already exists
    try:
        cur.execute("""
            UPDATE AssignedCaterers 
            SET employee_id = %s, event_id = %s 
            WHERE assigned_caterers_id = %s
        """, (employee_id, event_id, assignment_id))
        mysql.connection.commit()
        flash('Assignment updated successfully!', 'success')

    except MySQLdb.IntegrityError as e:
        # this is the error raised when the UNIQUE constraint is violated
        if e.args[0] == 1062:  # 1062 is MySQL's error code for duplicate entry - in AssignedCaterers, UNIQUE constraint is defined for combo of employee_id/event_id
            flash('This employee is already assigned to this event.', 'danger')
        else:
            flash(f'An unexpected error occurred: {e.args[1]}', 'danger')

    finally:
        cur.close()
    return redirect(url_for('assigned_caterers'))

'''DELETE from ASSIGNED_CATERERS route'''
@app.route('/delete_assignment/<int:id>')
def delete_assignment(id):
    cur = mysql.connection.cursor()
    cur.execute("DELETE FROM AssignedCaterers WHERE assigned_caterers_id = %s", (id,))
    mysql.connection.commit()
    cur.close()
    return redirect(url_for('assigned_caterers'))

if __name__ == '__main__':
    app.run(port=10456, debug=True)
