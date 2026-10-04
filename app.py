cat > app.py <<'EOF'
from flask import Flask, render_template, request, redirect
import sqlite3

app = Flask(__name__)

DATABASE = "erp.db"


# ==========================================
# DATABASE CONNECTION
# ==========================================

def get_db():

    conn = sqlite3.connect(DATABASE)

    conn.row_factory = sqlite3.Row

    return conn


# ==========================================
# DATABASE INITIALIZATION
# ==========================================

def init_db():

    conn = get_db()

    cursor = conn.cursor()


    # --------------------------------------
    # USERS TABLE
    # --------------------------------------

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (

            id INTEGER PRIMARY KEY AUTOINCREMENT,

            username TEXT UNIQUE NOT NULL,

            password TEXT NOT NULL,

            role TEXT NOT NULL

        )
    """)


    # --------------------------------------
    # STUDENTS TABLE
    # --------------------------------------

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS students (

            id INTEGER PRIMARY KEY AUTOINCREMENT,

            name TEXT NOT NULL,

            roll_no TEXT NOT NULL,

            course TEXT NOT NULL,

            email TEXT NOT NULL

        )
    """)


    # --------------------------------------
    # FACULTY TABLE
    # --------------------------------------

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS faculty (

            id INTEGER PRIMARY KEY AUTOINCREMENT,

            name TEXT NOT NULL,

            department TEXT NOT NULL,

            email TEXT NOT NULL

        )
    """)


    conn.commit()

    conn.close()


# ==========================================
# LOGIN
# ==========================================

@app.route("/", methods=["GET", "POST"])
def login():

    if request.method == "POST":

        username = request.form["username"]

        password = request.form["password"]

        role = request.form["role"]


        conn = get_db()


        user = conn.execute("""
            SELECT *

            FROM users

            WHERE username = ?

            AND password = ?

            AND role = ?

        """, (
            username,
            password,
            role
        )).fetchone()


        conn.close()


        if user:

            if role == "Admin":

                return render_template(
                    "admin.html",
                    user=username
                )


            elif role == "Student":

                return redirect(
                    "/student?username=" + username
                )


            elif role == "Faculty":

                return redirect(
                    "/faculty?username=" + username
                )


        return "Invalid username, password or role"


    return render_template("login.html")


# ==========================================
# REGISTER
# ==========================================

@app.route("/register", methods=["GET", "POST"])
def register():

    if request.method == "POST":

        username = request.form["username"]

        password = request.form["password"]

        role = request.form["role"]


        conn = get_db()


        try:

            conn.execute("""
                INSERT INTO users
                (username, password, role)

                VALUES (?, ?, ?)

            """, (
                username,
                password,
                role
            ))


            conn.commit()


        except sqlite3.IntegrityError:

            conn.close()

            return "Username already exists"


        conn.close()


        return redirect("/")


    return render_template("register.html")


# ==========================================
# STUDENT MANAGEMENT
# ==========================================

@app.route("/student", methods=["GET", "POST"])
def student():

    conn = get_db()


    if request.method == "POST":

        name = request.form["name"]

        roll_no = request.form["roll_no"]

        course = request.form["course"]

        email = request.form["email"]


        conn.execute("""
            INSERT INTO students
            (name, roll_no, course, email)

            VALUES (?, ?, ?, ?)

        """, (
            name,
            roll_no,
            course,
            email
        ))


        conn.commit()


    students = conn.execute("""
        SELECT *

        FROM students

        ORDER BY id DESC

    """).fetchall()


    total_students = conn.execute("""
        SELECT COUNT(*)

        FROM students

    """).fetchone()[0]


    conn.close()


    username = request.args.get(
        "username",
        "Admin"
    )


    return render_template(
        "student.html",

        students=students,

        total_students=total_students,

        username=username
    )


# ==========================================
# DELETE STUDENT
# ==========================================

@app.route("/student/delete/<int:student_id>")
def delete_student(student_id):

    conn = get_db()


    conn.execute("""
        DELETE FROM students

        WHERE id = ?

    """, (student_id,))


    conn.commit()

    conn.close()


    return redirect("/student")


# ==========================================
# EDIT STUDENT
# ==========================================

@app.route(
    "/student/edit/<int:student_id>",

    methods=["GET", "POST"]
)
def edit_student(student_id):

    conn = get_db()


    if request.method == "POST":

        name = request.form["name"]

        roll_no = request.form["roll_no"]

        course = request.form["course"]

        email = request.form["email"]


        conn.execute("""
            UPDATE students

            SET
                name = ?,

                roll_no = ?,

                course = ?,

                email = ?

            WHERE id = ?

        """, (
            name,
            roll_no,
            course,
            email,
            student_id
        ))


        conn.commit()

        conn.close()


        return redirect("/student")


    student_data = conn.execute("""
        SELECT *

        FROM students

        WHERE id = ?

    """, (student_id,)).fetchone()


    conn.close()


    return render_template(
        "edit_student.html",

        student=student_data
    )


# ==========================================
# FACULTY MANAGEMENT
# ==========================================

@app.route("/faculty", methods=["GET", "POST"])
def faculty_page():

    conn = get_db()


    if request.method == "POST":

        name = request.form["name"]

        department = request.form["department"]

        email = request.form["email"]


        conn.execute("""
            INSERT INTO faculty
            (name, department, email)

            VALUES (?, ?, ?)

        """, (
            name,
            department,
            email
        ))


        conn.commit()


    faculty = conn.execute("""
        SELECT *

        FROM faculty

        ORDER BY id DESC

    """).fetchall()


    total_faculty = conn.execute("""
        SELECT COUNT(*)

        FROM faculty

    """).fetchone()[0]


    conn.close()


    username = request.args.get(
        "username",
        "Admin"
    )


    return render_template(
        "faculty.html",

        faculty=faculty,

        total_faculty=total_faculty,

        username=username
    )


# ==========================================
# DELETE FACULTY
# ==========================================

@app.route("/faculty/delete/<int:faculty_id>")
def delete_faculty(faculty_id):

    conn = get_db()


    conn.execute("""
        DELETE FROM faculty

        WHERE id = ?

    """, (faculty_id,))


    conn.commit()

    conn.close()


    return redirect("/faculty")


# ==========================================
# EDIT FACULTY
# ==========================================

@app.route(
    "/faculty/edit/<int:faculty_id>",

    methods=["GET", "POST"]
)
def edit_faculty(faculty_id):

    conn = get_db()


    if request.method == "POST":

        name = request.form["name"]

        department = request.form["department"]

        email = request.form["email"]


        conn.execute("""
            UPDATE faculty

            SET
                name = ?,

                department = ?,

                email = ?

            WHERE id = ?

        """, (
            name,
            department,
            email,
            faculty_id
        ))


        conn.commit()

        conn.close()


        return redirect("/faculty")


    faculty_data = conn.execute("""
        SELECT *

        FROM faculty

        WHERE id = ?

    """, (faculty_id,)).fetchone()


    conn.close()


    return render_template(
        "edit_faculty.html",

        faculty=faculty_data
    )


# ==========================================
# START FLASK APPLICATION
# ==========================================

if __name__ == "__main__":

    init_db()


    app.run(

        host="127.0.0.1",

        port=5000,

        debug=True

    )
EOF
