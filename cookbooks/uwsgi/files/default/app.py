#!/usr/bin/env python
##
# example uwsgi module application
# 
# This is really just here so I can remember how to write one of these files
# 
# this corresponds to configuration:
#     module = app
##

import os

def application(environ, start_response):
  start_response("200 OK", [("Content-Type", "text/plain")])
  
  print os.environ
  
  return ["uWSGI is working for Python"]
