import argparse

import requests
from flask import Flask, request, render_template
app = Flask(__name__)
app.config.from_object('sharecounts.settings')

@app.route('/', methods=['GET'])
def sharecounts():
    url = request.args['url']
    twitter_api = app.config['TWITTER_API']
    facebook_api = app.config['FACEBOOK_API']
    fb = requests.get(facebook_api, params = {'id': url}).json()
    tw = requests.get(twitter_api, params = {'url': url}).json()
    fbshares = fb.get('shares', 0)
    fbcomments = fb.get('comments', 0)
    fbcount = fbshares + fbcomments
    twcount = tw.get('count', 0)
    data = {'url': url, 'fbcount': fbcount, 'fbshares': fbshares, 'fbcomments': fbcomments, 'twcount': twcount }
    return render_template('sharecounts_ssi.html', **data)

