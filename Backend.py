#!/usr/bin/env python3

from flask import Flask, request, send_from_directory
import os
from random import choice
import sqlite3
from string import ascii_uppercase

app = Flask(__name__)


@app.route('/')
def index():
    return 'Go away'


@app.route('/signup', methods=['POST'])
def signup():
    conn = sqlite3.connect('ttcserver.db')
    cur = conn.cursor()
    
    email = request.headers.get('email')
    password = request.headers.get('password')
    
    if email is not None and password is not None:
        # If user exists
        cur.execute("SELECT email FROM user WHERE email = '{0}'".format(email))
        if cur.fetchone() is not None:
            return 'User already exists', 401   # TODO: make sure HTTP codes are correct
        
        # Insert user
        cur.execute("INSERT INTO user (email, password) VALUES ('{0}', '{1}');".format(email, password))
        conn.commit()
        
        # Get new user's id
        cur.execute("SELECT id FROM user WHERE email = '{0}'".format(email))
        uid = cur.fetchone()[0]
        
        # Insert initial recipes
        for row in conn.execute("SELECT recipe_id FROM user_recipe WHERE user_id = 1"):
            cur.execute("INSERT INTO user_recipe (user_id, recipe_id) VALUES ({0}, {1})".format(uid, row[0]))
        conn.commit()
        
        # Initialize settings
        cur.execute("INSERT INTO settings (user_id, autoplay, speech) VALUES ({0}, 'false', 'false')".format(uid))
        conn.commit()
        conn.commit()
        
        # return send_from_directory('.', get_users_recipes(uid))
        return send_from_directory('.', 'ttcserver.db')
    else:
        return '', 400


# TODO: need to delete temp dbs after sending
@app.route('/login', methods=['POST'])
def signin():
    conn = sqlite3.connect('ttcserver.db')
    cur = conn.cursor()
    
    email = request.headers.get('email')
    password = request.headers.get('password')
    
    if email is not None and password is not None:
        statement = 'SELECT id, email, password FROM user WHERE email = "{0}"'.format(email)
        cur.execute(statement)
        first_row = cur.fetchone()
        if first_row is None:
            return 'User does not exist', 400
        actual_pass = first_row[2]
        if password == actual_pass:
            # return send_from_directory('.', get_users_recipes(first_row[0]))
            return send_from_directory('.', 'ttcserver.db')
        else:
            return 'Incorrect password', 401
    else:
        return 'Invalid syntax', 400
        
        
@app.route('/initdb', methods=['POST'])
def initdb():
    if os.path.isfile('ttcserver.db'):
        os.remove('ttcserver.db')
    
    create_tables('ttcserver.db')
    
    conn = sqlite3.connect('ttcserver.db')
    cur = conn.cursor()
    
    # Insert data for default user
    cur.execute("INSERT INTO USER (email, password) VALUES ('default', 'password');")
    cur.execute("INSERT INTO RECIPE (name, type) VALUES ('Grilled Cheese', 'Sandwich');")
    cur.execute("INSERT INTO STEP (number, directions, seconds, recipe_id) VALUES (1, 'Butter one side of two pieces of bread.', 30, 1);")
    cur.execute("INSERT INTO STEP (number, directions, seconds, recipe_id) VALUES (2, 'Place one piece of bread on skillet butter side down on medium heat. Place american cheese on the top of the bread, and place the second piece of bread butter side up on the cheese. Flip as needed to make both sides golden brown.', 300, 1);")
    cur.execute("INSERT INTO STEP (number, directions, seconds, recipe_id) VALUES (3, 'Remove grilled cheese from skillet and enjoy', 10, 1);")
    cur.execute("INSERT INTO INGREDIENT (name) VALUES ('White bread');")
    cur.execute("INSERT INTO INGREDIENT (name) VALUES ('Butter');")
    cur.execute("INSERT INTO INGREDIENT (name) VALUES ('American cheese');")
    cur.execute("INSERT INTO STEP_INGREDIENT (step_id, ingredient_id, quantity, partial_quantity, unit) VALUES (1, 1, 2, '0', 'slices');")
    cur.execute("INSERT INTO STEP_INGREDIENT (step_id, ingredient_id, quantity, partial_quantity, unit) VALUES (1, 2, 1, '0', 'spread');")
    cur.execute("INSERT INTO STEP_INGREDIENT (step_id, ingredient_id, quantity, partial_quantity, unit) VALUES (2, 3, 1, '0', 'slice');")
    cur.execute("INSERT INTO USER_RECIPE (user_id, recipe_id) VALUES (1, 1);")
    cur.execute("INSERT INTO SHOPPING_LIST (id, user_id, ingredient_id, quantity, partial_quantity, unit, checked) VALUES (1, 1, 1, 1, '0', 'slices', 'true');")
    cur.execute("INSERT INTO SETTINGS (id, user_id, autoplay, speech) VALUES (1, 1, 'false', 'false');")

    conn.commit()
    conn.close()
    return 'Database initialized'

        
@app.route('/getdb', methods=['GET'])
def getdb():
    return send_from_directory('.', 'ttcserver.db')
        
        
@app.route('/upload', methods=['POST'])
def upload():
    conn = sqlite3.connect('ttcserver.db')
    cur = conn.cursor()
    
    statements = request.headers.get('sql').split(';')
    for statement in statements:
        cur.execute(statement)
    
    conn.commit()
    conn.close()
    
    # cur.execute(request.headers.get('sql'))
    
    return ''
    
    
    
    # file = request.files['ttc.db']
    # print('Past file')
    # if file:
    #     filename = file.filename
    #     file.save('.', filename)
    # return 'Hey'


# def get_users_recipes(user_id):
#     '''takes user_id, creates a sqlite database just for them
#     
#     returns the path of the database
#     '''
# 
#     conn = sqlite3.connect('ttcserver.db')
#     cur = conn.cursor()
#     
#     # new database path, joined with 5 random characters
#     new_path = str(user_id) + ''.join(choice(ascii_uppercase) for i in range(5)) + '.db'
#     create_tables(new_path)
#     new_conn = sqlite3.connect(new_path)
#     new_cur = new_conn.cursor()
#     
#     # Insert the user
#     cur.execute("SELECT id, email, password FROM user WHERE id = {0}".format(user_id))
#     row = cur.fetchone()
#     new_cur.execute("INSERT INTO user (id, email, password) VALUES ({0}, '{1}', '{2}')".format(row[0], row[1], row[2]))
#     new_conn.commit()
#     
#     # Insert the user_recipe values
#     recipe_ids = []
#     for row in cur.execute("SELECT id, user_id, recipe_id FROM user_recipe WHERE user_id = {0}".format(user_id)):
#         recipe_ids.append(row[2])
#         new_cur.execute("INSERT INTO user_recipe (id, user_id, recipe_id) VALUES ({0}, {1}, {2})".format(row[0], row[1], row[2]))
#     new_conn.commit()
#     
#     # Insert the recipes
#     for rid in recipe_ids:
#         cur.execute("SELECT id, name FROM recipe WHERE id = {0}".format(rid))
#         row = cur.fetchone()
#         new_cur.execute("INSERT INTO recipe (id, name) VALUES ({0}, '{1}')".format(row[0], row[1]))
#     new_conn.commit()
#     
#     # Insert the steps
#     step_ids = []
#     for rid in recipe_ids:
#         for row in cur.execute("SELECT id, number, directions, seconds, recipe_id FROM step WHERE recipe_id = {0}".format(rid)):
#             step_ids.append(row[0])
#             new_cur.execute("INSERT INTO step (id, number, directions, seconds, recipe_id) VALUES ({0}, {1}, '{2}', {3}, {4})".format(row[0], row[1], row[2], row[3], row[4]))
#     new_conn.commit()
#     
#     # Insert the step_ingredient values
#     ingredient_ids = []
#     for sid in step_ids:
#         for row in cur.execute("SELECT id, step_id, ingredient_id, quantity, unit FROM step_ingredient WHERE step_id = {0}".format(sid)):
#             ingredient_ids.append(row[2])
#             new_cur.execute("INSERT INTO step_ingredient (id, step_id, ingredient_id, quantity, unit) VALUES ({0}, {1}, {2}, {3}, '{4}')".format(row[0], row[1], row[2], row[3], row[4]))
#     new_conn.commit()
#     
#     # Insert the ingredients
#     for iid in ingredient_ids:
#         for row in cur.execute("SELECT id, name FROM ingredient WHERE id = {0}".format(iid)):
#             new_cur.execute("INSERT INTO ingredient (id, name) VALUES ({0}, '{1}')".format(row[0], row[1]))
#     new_conn.commit()
#     
#     conn.close()
#     new_conn.close()
#     return new_path
    
        
def create_tables(path):
    conn = sqlite3.connect(path)
    cur = conn.cursor()
    
    cur.execute('CREATE TABLE IF NOT EXISTS USER (ID INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT UNIQUE, PASSWORD TEXT);')
    cur.execute('CREATE TABLE IF NOT EXISTS RECIPE (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, TYPE TEXT);')
    cur.execute('CREATE TABLE IF NOT EXISTS INGREDIENT (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT);')
    cur.execute('CREATE TABLE IF NOT EXISTS STEP (ID INTEGER PRIMARY KEY AUTOINCREMENT, NUMBER INTEGER, DIRECTIONS TEXT, SECONDS INTEGER, RECIPE_ID INTEGER, FOREIGN KEY (RECIPE_ID) REFERENCES RECIPE(ID));')
    cur.execute('CREATE TABLE IF NOT EXISTS STEP_INGREDIENT (ID INTEGER PRIMARY KEY AUTOINCREMENT, STEP_ID INTEGER, INGREDIENT_ID INTEGER, QUANTITY INTEGER, PARTIAL_QUANTITY TEXT, UNIT TEXT, FOREIGN KEY (STEP_ID) REFERENCES STEP(ID), FOREIGN KEY (INGREDIENT_ID) REFERENCES INGREDIENT(ID));')
    cur.execute('CREATE TABLE IF NOT EXISTS USER_RECIPE(ID INTEGER PRIMARY KEY AUTOINCREMENT, USER_ID INTEGER, RECIPE_ID INTEGER, FOREIGN KEY (USER_ID) REFERENCES USER(ID), FOREIGN KEY (RECIPE_ID) REFERENCES RECIPE(ID));')
    cur.execute('CREATE TABLE IF NOT EXISTS SHOPPING_LIST(ID INTEGER PRIMARY KEY AUTOINCREMENT, USER_ID INTEGER, INGREDIENT_ID INTEGER, QUANTITY INTEGER, PARTIAL_QUANTITY TEXT, UNIT TEXT, CHECKED TEXT, FOREIGN KEY (USER_ID) REFERENCES USER(ID), FOREIGN KEY (INGREDIENT_ID) REFERENCES INGREDIENT(ID));')
    cur.execute('CREATE TABLE IF NOT EXISTS SETTINGS(ID INTEGER PRIMARY KEY AUTOINCREMENT, USER_ID INTEGER, AUTOPLAY TEXT, SPEECH TEXT, FOREIGN KEY (USER_ID) REFERENCES USER(ID));')
    
    conn.commit()
    conn.close()
    

@app.route('/test')
def test():
    email = request.headers.get('email')
    password = request.headers.get('password')
    
    conn = sqlite3.connect('ttcserver.db')
    cur = conn.cursor()
    
    if email is not None and password is not None:
        cur.execute("SELECT id, email, password FROM user WHERE email = '{0}'".format(email))
        x = cur.fetchone()
        print(x)
        print(x[0])
        return '', 200
    
    return '', 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
