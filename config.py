from flask import Flask, render_template, request, redirect, url_for
from flask_mysqldb import MySQL
from dotenv import load_dotenv
import os

load_dotenv()

app = Flask(__name__)

# Configure MySQL connection
app.config["MYSQL_HOST"] = "classmysql.engr.oregonstate.edu"
app.config["MYSQL_USER"] = "cs340_montgale"
app.config["MYSQL_PASSWORD"] = "6470"
app.config["MYSQL_DB"] = "cs340_montgale"
app.config["MYSQL_CURSORCLASS"] = "DictCursor"

mysql = MySQL(app)