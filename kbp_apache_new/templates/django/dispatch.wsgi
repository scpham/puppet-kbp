#!/usr/bin/env python

import os
import sys

sys.path.append('/srv/django<%= django_root_django %>')
sys.path.append('/srv/django<%= django_static_django %>')
os.environ['DJANGO_SETTINGS_MODULE'] = '<%= django_settings %>'

import django.core.handlers.wsgi
application = django.core.handlers.wsgi.WSGIHandler()
