from flask import Flask, render_template, request

app = Flask(__name__)

@app.route("/", methods=["GET","POST"])
def login():
    if request.method == "POST":
        u = request.form["username"]
        p = request.form["password"]
        r = request.form["role"]

        if u=="admin" and p=="123" and r=="Admin":
            return render_template("admin.html", user=u)

    return render_template("login.html")

@app.route("/student")
def student():
    return render_template("student.html")

if __name__ == "__main__":
    app.run(debug=True)
