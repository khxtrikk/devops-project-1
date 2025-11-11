#!/bin/bash
# Simple HTTP server using Python3's http.server module
python3 -m http.server 8080 --directory / > /tmp/http_server.log 2>&1 &
echo "HTTP server started on port 8080"

