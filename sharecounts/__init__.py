import argparse

import requests
from flask import Flask, request, jsonify
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
    return '''<p class="sharecounts" data-for="%(url)s">
    <span class="facebook-count"    data-n="%(fbcount)d">%(fbcount)d fb total.</span>    
    <span class="facebook-shares"   data-n="%(fbshares)d">%(fbshares)d likes.</span>    
    <span class="facebook-comments" data-n="%(fbcomments)d">%(fbcomments)d comments.</span>    
    <span class="twitter-count"     data-n="%(twcount)d">%(twcount)d tweets.</span>    
</p>''' % data


