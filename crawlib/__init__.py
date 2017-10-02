#!/usr/bin/env python
# -*- coding: utf-8 -*-

__version__ = "0.0.7"
__short_description__ = "Crawl library."
__license__ = "MIT"
__author__ = "Sanhe Hu"
__author_email__ = "husanhe@gmail.com"
__maintainer__ = "Sanhe Hu"
__maintainer_email__ = "husanhe@gmail.com"
__github_username__ = "MacHu-GWU"


try:
    from .url_builder import BaseUrlBuilder, util
    from .html_parser import ParseResult, BaseHtmlParser
except ImportError: # pragma: no cover
    pass