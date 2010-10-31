#!/bin/bash
autoreconf --force --install || exit 1
intltoolize --force || exit 1

