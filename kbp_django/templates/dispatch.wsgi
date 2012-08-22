#!/usr/bin/env python

import os
import sys

sys.path.append('/srv/django<%= root_django %>')
sys.path.append('/srv/django<%= static_django %>')
os.environ['DJANGO_SETTINGS_MODULE'] = '<%= settings %>'

import django.core.handlers.wsgi
application = django.core.handlers.wsgi.WSGIHandler()
