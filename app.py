from config import *
from data_query import *

@app.route('/')
def index():
    return render_template('index.html')  

# currently for STEP 4: just rendering other pages, not connected to db/functional
@app.route('/clients')
def clients():
    return render_template('clients.html')

@app.route('/employees')
def employees():
    return render_template('employees.html')

@app.route('/events')
def events():
    return render_template('events.html')

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

@app.route('/assigned_caterers', methods=['GET', 'POST'])
def assigned_caterers():
    if request.method == 'POST':
        # Add new assignment
        employee_id = request.form['employee_id']
        event_id = request.form['event_id']
        cur = mysql.connection.cursor()
        cur.execute("INSERT INTO AssignedCaterers (employee_id, event_id) VALUES (%s, %s)", (employee_id, event_id))
        mysql.connection.commit()
        cur.close()
        return redirect(url_for('assigned_caterers'))

    # Display the assigned caterers table
    cur = mysql.connection.cursor()
    # query to display employee_id, employee's full name, and event_id
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
    cur.execute("SELECT event_id FROM Events")
    events = cur.fetchall()
    cur.close()

    return render_template('assigned_caterers.html', data=data, employees=employees, events=events)

@app.route('/update_assignment', methods=['POST'])
def update_assignment():
    assignment_id = request.form['assignment_id']
    employee_id = request.form['employee_id']
    event_id = request.form['event_id']
    cur = mysql.connection.cursor()
    cur.execute("UPDATE AssignedCaterers SET employee_id = %s, event_id = %s WHERE assigned_caterers_id = %s", (employee_id, event_id, assignment_id))
    mysql.connection.commit()
    cur.close()
    return redirect(url_for('assigned_caterers'))

@app.route('/delete_assignment/<int:id>')
def delete_assignment(id):
    cur = mysql.connection.cursor()
    cur.execute("DELETE FROM AssignedCaterers WHERE assigned_caterers_id = %s", (id,))
    mysql.connection.commit()
    cur.close()
    return redirect(url_for('assigned_caterers'))

if __name__ == '__main__':
    app.run(port=10456, debug=True)


