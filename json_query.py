from flask import Flask, render_template, request, redirect, url_for, flash, Blueprint
from flask_mysqldb import MySQL, MySQLdb
import os
from MySQLdb import IntegrityError
from app import mysql

json_query = Blueprint("json_query", __name__, url_prefix="/requestJSON")

@json_query.route('/requestJSON')
def getEmployees():
    if request == "GET":
        print(request.data)
        