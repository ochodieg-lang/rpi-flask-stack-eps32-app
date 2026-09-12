from flask import Flask
from flask import render_template

app = Flask(__name__)
#app.debug = True

@app.route("/")
def hello():
    msg = "Testing hello route..."
    print("Hello from lab-app console!")
    return render_template('hello.html', message="what is up!", message_2=msg)
    #return "<h1>hello world!!!!</h1>"

@app.route("/ex")
def examp_route():
	return "<h3> Testing ex route, right now</h3>"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)
