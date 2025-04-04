from datetime import datetime, timedelta
from flask import Flask, render_template, request, redirect, url_for, session, flash
import pymysql
import credentials

app = Flask(__name__, template_folder="templates")
app.secret_key = 'secret_key'  # Replace with a secure random string

class Database:
    def __init__(self):
        self.con = pymysql.connect(
            host=credentials.DB_HOST,
            user=credentials.DB_USER,
            password=credentials.DB_PWD,
            db=credentials.DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )
        self.cur = self.con.cursor()

    # Updated to return only active menu items
    def get_menu_items(self):
        try:
            self.cur.execute("SELECT * FROM MenuItem WHERE is_active = TRUE")
            result = self.cur.fetchall()
        except pymysql.Error as e:
            print("Error retrieving menu items:", e)
            result = []
        finally:
            self.con.close()
        return result

    def insert_customer(self, name, phone, address):
        try:
            self.cur.execute(
                "INSERT INTO Customer (name, phone, address) VALUES (%s, %s, %s)",
                (name, phone, address)
            )
            self.con.commit()
            customer_id = self.cur.lastrowid
        except pymysql.Error as e:
            print("Error inserting customer:", e)
            self.con.rollback()
            customer_id = None
        finally:
            self.con.close()
        return customer_id

    def insert_order(self, customer_id, total):
        try:
            self.cur.execute(
                "INSERT INTO Orders (customer_id, total) VALUES (%s, %s)",
                (customer_id, total)
            )
            self.con.commit()
            order_id = self.cur.lastrowid
        except pymysql.Error as e:
            print("Error inserting order:", e)
            self.con.rollback()
            order_id = None
        finally:
            self.con.close()
        return order_id

    def insert_order_detail(self, order_id, menu_item_id, quantity):
        try:
            self.cur.execute(
                "INSERT INTO Order_Items (order_id, menu_item_id, quantity) VALUES (%s, %s, %s)",
                (order_id, menu_item_id, quantity)
            )
            self.con.commit()
            result = "OK"
        except pymysql.Error as e:
            print("Error inserting order detail:", e)
            self.con.rollback()
            result = None
        finally:
            self.con.close()
        return result

    def insert_payment(self, order_id, amount, payment_method, card_number, card_expiry, card_cvv):
        try:
            default_location = "Online"
            self.cur.execute(
                "INSERT INTO Payment (OrderID, PaymentMethod, Amount_paid, PaymentLocation, CardNumber, CardExpiry, CardCVV) VALUES (%s, %s, %s, %s, %s, %s, %s)",
                (order_id, payment_method, amount, default_location, card_number, card_expiry, card_cvv)
            )
            self.con.commit()
            payment_id = self.cur.lastrowid
        except pymysql.Error as e:
            print("Error inserting payment:", e)
            self.con.rollback()
            payment_id = None
        finally:
            self.con.close()
        return payment_id

    def get_order_summary(self, order_id):
        try:
            query = """
            SELECT o.id AS order_id, o.total, o.order_date,
                   c.name AS customer_name, c.address,
                   p.Amount_paid AS amount_paid,
                   p.PaymentMethod AS payment_method,
                   p.PaymentLocation AS payment_location
            FROM Orders o
            JOIN Customer c ON o.customer_id = c.id
            LEFT JOIN Payment p ON o.id = p.OrderID
            WHERE o.id = %s
            """
            self.cur.execute(query, (order_id,))
            result = self.cur.fetchone()
            print("Order Summary Result:", result)
        except pymysql.Error as e:
            print("Error retrieving order summary:", e)
            result = None
        finally:
            self.con.close()
        return result

    def get_menu_item(self, item_id):
        try:
            self.cur.execute("SELECT * FROM MenuItem WHERE id = %s", (item_id,))
            result = self.cur.fetchone()
        except pymysql.Error as e:
            print("Error retrieving menu item:", e)
            result = None
        finally:
            self.con.close()
        return result

    def insert_menu_item(self, name, description, price):
        try:
            self.cur.execute(
                "INSERT INTO MenuItem (name, description, price) VALUES (%s, %s, %s)",
                (name, description, price)
            )
            self.con.commit()
            msg = "Menu item added successfully!"
        except pymysql.Error as e:
            print("Error inserting menu item:", e)
            self.con.rollback()
            msg = f"Error inserting menu item: {e}"
        finally:
            self.con.close()
        return msg

    def update_menu_item(self, item_id, name, description, price):
        try:
            self.cur.execute(
                "UPDATE MenuItem SET name = %s, description = %s, price = %s WHERE id = %s",
                (name, description, price, item_id)
            )
            self.con.commit()
            msg = "Menu item updated successfully!"
        except pymysql.Error as e:
            print("Error updating menu item:", e)
            self.con.rollback()
            msg = f"Error updating menu item: {e}"
        finally:
            self.con.close()
        return msg

    # Soft delete: Update the item to set is_active to FALSE
    def delete_menu_item(self, item_id):
        try:
            self.cur.execute("UPDATE MenuItem SET is_active = FALSE WHERE id = %s", (item_id,))
            self.con.commit()
            msg = "Menu item deleted successfully!"
        except pymysql.Error as e:
            print("Error deleting menu item:", e)
            self.con.rollback()
            msg = f"Error deleting menu item: {e}"
        finally:
            self.con.close()
        return msg

# Flask Routes

@app.route('/')
def index():
    return render_template("index.html")

@app.route('/menu')
def menu():
    db = Database()
    items = db.get_menu_items()
    return render_template("menu.html", items=items)

@app.route('/about')
def about():
    return render_template("about.html")

# Order and Checkout routes
@app.route('/order', methods=['GET', 'POST'])
def order():
    db = Database()
    menu_items = db.get_menu_items()
    if 'order' not in session:
        order_dict = {}
        for item in menu_items:
            order_dict[str(item['id'])] = 0
        session['order'] = order_dict

    if request.method == 'POST':
        order_dict = session.get('order', {})
        for item in menu_items:
            key = str(item['id'])
            qty_str = request.form.get(f"quantity_{key}", "0")
            try:
                qty = int(qty_str)
            except ValueError:
                qty = 0
            order_dict[key] = qty
        session['order'] = order_dict
        return redirect(url_for('checkout'))
    return render_template("order.html", menu_items=menu_items, order=session['order'])

@app.route('/checkout', methods=['GET', 'POST'])
def checkout():
    db = Database()
    menu_items = db.get_menu_items()
    order = session.get('order', {})
    total = 0.0
    order_items_details = []
    for item in menu_items:
        key = str(item['id'])
        qty = order.get(key, 0)
        if qty > 0:
            subtotal = float(item['price']) * qty
            total += subtotal
            order_items_details.append({
                'name': item['name'],
                'price': float(item['price']),
                'quantity': qty,
                'subtotal': subtotal
            })
    total = round(total, 2)
    tax = round(total * 0.13, 2)
    final_total = round(total + tax, 2)

    if request.method == 'POST':
        name = request.form['name']
        phone = request.form['phone']
        address = request.form['address']
        payment_method = request.form['payment_method']
        card_number = request.form.get('card_number', '')
        card_expiry = request.form.get('card_expiry', '')
        card_cvv = request.form.get('card_cvv', '')

        try:
            exp_month, exp_year = card_expiry.split('/')
            exp_month = int(exp_month)
            exp_year = int(exp_year)
            if exp_year < 100:
                exp_year += 2000
            expiry_date = datetime(exp_year, exp_month, 1) + timedelta(days=32)
            expiry_date = datetime(expiry_date.year, expiry_date.month, 1) - timedelta(days=1)
            if datetime.now() > expiry_date:
                flash("Card is expired!", "error")
                return redirect(url_for('checkout'))
        except Exception as e:
            flash("Invalid expiry format. Use MM/YY.", "error")
            return redirect(url_for('checkout'))

        db_customer = Database()
        customer_id = db_customer.insert_customer(name, phone, address)
        if not customer_id:
            return "Error inserting customer", 500

        db_order = Database()
        order_id = db_order.insert_order(customer_id, final_total)
        if not order_id:
            return "Error inserting order", 500

        for item in menu_items:
            key = str(item['id'])
            qty = order.get(key, 0)
            if qty > 0:
                db_detail = Database()
                db_detail.insert_order_detail(order_id, item['id'], qty)

        db_payment = Database()
        payment_id = db_payment.insert_payment(order_id, final_total, payment_method, card_number, card_expiry, card_cvv)
        session.pop('order', None)
        return redirect(url_for('order_confirmation', order_id=order_id))

    return render_template("checkout.html", total=total, tax=tax, final_total=final_total, order_items=order_items_details)

@app.route('/order_confirmation/<int:order_id>')
def order_confirmation(order_id):
    db = Database()
    summary = db.get_order_summary(order_id)
    return render_template("order_confirmation.html", summary=summary)

# Admin Login Route
@app.route('/admin/login', methods=['GET', 'POST'])
def admin_login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        if username == 'admin' and password == 'admin123':
            session['admin'] = True
            flash('Admin login successful!', 'success')
            return redirect(url_for('admin_menu'))
        else:
            flash('Invalid credentials!', 'error')
    return render_template('admin_login.html')

# Admin Dashboard Route
@app.route('/admin/dashboard')
def admin_dashboard():
    if not session.get('admin'):
        flash('Please log in as admin!', 'error')
        return redirect(url_for('admin_login'))
    return render_template('admin_dashboard.html')

# Admin Menu Management (List)
@app.route('/admin/menu')
def admin_menu():
    if not session.get('admin'):
        flash("Admin access required!")
        return redirect(url_for('admin_login'))
    db = Database()
    items = db.get_menu_items()
    return render_template("admin_menu.html", items=items)

# Add New Menu Item
@app.route('/admin/menu/new', methods=['GET', 'POST'])
def new_menu_item():
    if not session.get('admin'):
        flash("Admin access required!")
        return redirect(url_for('admin_login'))
    if request.method == 'POST':
        name = request.form['name']
        description = request.form['description']
        price = request.form['price']
        db = Database()
        msg = db.insert_menu_item(name, description, price)
        flash(msg)
        return redirect(url_for('admin_menu'))
    return render_template("new_menu_item.html")

# Edit Existing Menu Item
@app.route('/admin/menu/edit/<int:item_id>', methods=['GET', 'POST'])
def edit_menu_item(item_id):
    if not session.get('admin'):
        flash("Admin access required!")
        return redirect(url_for('admin_login'))
    db = Database()
    if request.method == 'POST':
        name = request.form['name']
        description = request.form['description']
        price = request.form['price']
        msg = db.update_menu_item(item_id, name, description, price)
        flash(msg)
        return redirect(url_for('admin_menu'))
    else:
        item = db.get_menu_item(item_id)
        if not item:
            flash("Item not found!")
            return redirect(url_for('admin_menu'))
        return render_template("edit_menu_item.html", item=item)

# Delete Menu Item
@app.route('/admin/menu/delete/<int:item_id>', methods=['POST'])
def delete_menu_item(item_id):
    if not session.get('admin'):
        flash("Admin access required!")
        return redirect(url_for('admin_login'))
    db = Database()
    msg = db.delete_menu_item(item_id)
    flash(msg)
    return redirect(url_for('admin_menu'))

# Admin Logout
@app.route('/admin/logout')
def admin_logout():
    session.pop('admin', None)
    flash('Logged out successfully!', 'success')
    return redirect(url_for('admin_login'))

if __name__ == '__main__':
    app.run(debug=True)
