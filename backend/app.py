from flask import Flask, request


app = Flask(__name__)


@app.route('/')
@app.route('/<path:path>')
def index(path='/'):
    return 'Path: %s\n%s' % (request.path, request.headers)
