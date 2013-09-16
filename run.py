import argparse

from sharecounts import app

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--port', type=int, default=5000, help='port to listen [%(default)s]')
    parser.add_argument('--nodebug', action='store_true', default=False, help='no debug mode? [%(default)s]')
    args = parser.parse_args()
    app.run(debug=not args.nodebug, host='0.0.0.0', port=args.port)
