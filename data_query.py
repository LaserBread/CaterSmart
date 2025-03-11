from config import *

@app.route('/requestJSON')
def sendJSON():
    if request == "GET":
        print(request.data)