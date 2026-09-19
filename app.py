from flask import Flask, render_template, request

app = Flask(__name__)

@app.route("/", methods=["GET","POST"])
def login():
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]
        role = request.form["role"]

        if username == "admin" and password == "123":
            return f"Welcome {role}"
        return "Invalid Login"

    return render_template("login.html")

if __name__ == "__main__":
    app.run(debug=True)
