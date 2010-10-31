#!/bin/bash
autoreconf --force --install || exit 1
intltoolize || exit 1

