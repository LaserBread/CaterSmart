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

@app.route('/')
def index():
    return render_template('index.html')  

# currently for STEP 4: just rendering other pages, not connected to db/functional
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
            # # this is the error raised when the UNIQUE constraint is violated
            # if e.args[0] == 1062:  # 1062 is MySQL's error code for duplicate entry
            #     flash('This employee is already assigned to this event.', 'danger')
            # else:
            #     flash('An unexpected error occurred.', 'danger')
            pass
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
        has_drivers_license = True if request.form['has_drivers_license'] == 'True' else False
        has_alcohol_certification = True if request.form['has_alcohol_certification'] == 'True' else False
        has_food_certification = True if request.form['has_food_certification'] == 'True' else False

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
            # # this is the error raised when the UNIQUE constraint is violated
            # if e.args[0] == 1062:  # 1062 is MySQL's error code for duplicate entry
            #     flash('This employee is already assigned to this event.', 'danger')
            # else:
            #     flash('An unexpected error occurred.', 'danger')
            pass
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
            if e.args[0] == 1062:  # duplicate event name
                flash('An event with this name already exists. Please use a different name.', 'danger')
                return redirect(url_for('events'))
            # handle any other unexpected database error
            flash('An unexpected error occurred. Please try again.', 'danger')
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

@app.route('/menus')
def menus():
    return render_template('menus.html')

@app.route('/items')
def items():
    return render_template('items.html')

@app.route('/item_ingredients')
def item_ingredients():
    return render_template('item_ingredients.html')

@app.route('/ingredients')
def ingredients():
    return render_template('ingredients.html')

'''SELECT/INSERT ASSIGNED_CATERERS route'''
@app.route('/assigned_caterers', methods=['GET', 'POST'])
def assigned_caterers():
    if request.method == 'POST':
        # add new assignment
        employee_id = request.form['employee_id']
        event_id = request.form['event_id']
        cur = mysql.connection.cursor()

        # try/except block: handles when user attempts to assign caterer to event they're already assigned to
        try:
            cur.execute("""
                INSERT INTO AssignedCaterers (employee_id, event_id)
                VALUES (%s, %s)
            """, (employee_id, event_id))
            mysql.connection.commit()
            flash('Caterer assigned successfully!', 'success')
        except MySQLdb.IntegrityError as e:
            # this is the error raised when the UNIQUE constraint is violated
            if e.args[0] == 1062:  # 1062 is MySQL's error code for duplicate entry
                flash('This employee is already assigned to this event.', 'danger')
            else:
                flash('An unexpected error occurred.', 'danger')
        finally:
            cur.close()

        return redirect(url_for('assigned_caterers'))

    # display the assigned caterers table
    cur = mysql.connection.cursor()
    # query:
    cur.execute("""
                SELECT AssignedCaterers.assigned_caterers_id, AssignedCaterers.employee_id, 
                    CONCAT(Employees.first_name, ' ', Employees.last_name) AS caterer_name, AssignedCaterers.event_id 
                FROM AssignedCaterers 
                INNER JOIN Employees ON AssignedCaterers.employee_id = Employees.employee_id 
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
    except MySQLdb.IntegrityError:
        flash('This employee/event combination already exists.', 'danger')
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