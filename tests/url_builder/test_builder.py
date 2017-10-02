#!/usr/bin/env python
# -*- coding: utf-8 -*-

import pytest
from pytest import raises, approx
from crawlib.url_builder.builder import BaseUrlBuilder


class PythonOrgUrlBuilder(BaseUrlBuilder):
    domain = "https://www.python.org"


url_builder = PythonOrgUrlBuilder()


def test_join_all():
    assert url_builder.join_all("/a", "/b") == "https://www.python.org/a/b"


def test_add_params():
    with raises(AssertionError):
        url_builder.add_params("www.google.com/q", {"q": "Python"})

    url = url_builder.add_params(
        "https://www.python.org/q", {"version": "2.7"})
    assert url == "https://www.python.org/q?version=2.7"


if __name__ == "__main__":
    import os

    basename = os.path.basename(__file__)
    pytest.main([basename, "-s", "--tb=native"])
