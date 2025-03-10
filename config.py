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