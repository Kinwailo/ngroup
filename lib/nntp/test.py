# from http.server import HTTPServer, BaseHTTPRequestHandler

# class Request(BaseHTTPRequestHandler):
#     def do_GET(self):
#         print(self.headers)

# server =  HTTPServer(("", 80), Request)
# server.serve_forever()

import socketserver

class _Handler(socketserver.StreamRequestHandler):
    def _send(self, r):
        self.wfile.write(bytes(r + '\n', "utf-8"))
        print('out: ' + r)

    def handle(self):
        self._send('200 server ready - posting allowed')
        while True:
            cmd = self.rfile.readline().strip().decode("utf-8")
            if len(cmd) == 0:
                continue
            print('in: ' + cmd)
            if cmd in ['CAPABILITIES', 'LIST OVERVIEW.FMT'] :
                self._send('500 Unknown')
            if cmd in ['MODE READER'] :
                self._send('200 OK')
            if cmd == 'LIST' :
                self._send('200 OK')
                self._send('self.test 3 1 *')
                self._send('.')
            if cmd.startswith('GROUP') :
                self._send('211 3 1 3 self.test')
            if cmd.startswith('XOVER') :
                self._send('224 Overview')
                out = '\t'.join(['1000', 'test', 'tt <t@t.t>', 'Mon, 01 Apr 2024 20:59:11 +0800', '1000', '', '100', '2'])
                self._send(out)
                out = '\t'.join(['1001', 'test1', 'tt <t@t.t>', 'Mon, 01 Apr 2024 21:59:11 +0800', '1001', '1000', '100', '2'])
                self._send(out)
                out = '\t'.join(['1002', 'test2', 'tt <t@t.t>', 'Mon, 01 Apr 2024 22:59:11 +0800', '1002', '1000 1001', '100', '2'])
                self._send(out)
                self._send('.')
            if cmd.startswith('ARTICLE 1000') :
                self._send('220 1000 1000')
                self._send('From: tt <t@t.t>')
                self._send('Subject: test')
                self._send('Date: Mon, 01 Apr 2024 20:59:11 +0800')
                self._send('Message-ID: 1000')
                self._send('')
                self._send('test')
                self._send('.')

server = socketserver.TCPServer(("", 119), _Handler)
try:
    server.serve_forever()
except KeyboardInterrupt:
    pass
server.server_close()
