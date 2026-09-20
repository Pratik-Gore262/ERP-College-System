from flask import Flask, render_template, request

app = Flask(__name__)
students = []

@app.route("/", methods=["GET","POST"])
def login():
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]
        role = request.form["role"]

        if username=="admin" and password=="123" and role=="Admin":
            return render_template("admin.html", user=username)

    return render_template("login.html")

@app.route("/student", methods=["GET","POST"])
def student():
    return render_template("student.html", students=students)

app.run(debug=True)
