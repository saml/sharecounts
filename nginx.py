import argparse
import subprocess



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--nginx', default='nginx', help='nginx command [%(default)s]')
    parser.add_argument('--config', default='nginx.conf.tmpl', help='nginx.conf template [%(default)s]')
    parser.add_argument('--port', type=int, default=8080, help='port to listen [%(default)s]')
    parser.add_argument('--daemon', action='store_true', default=False, help='deamonize? [%(default)s]')
    args = parser.parse_args()
