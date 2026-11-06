*** Settings ***
Documentation    Shared libraries and their configuration.

Library          Browser    timeout=30s    retry_assertions_for=10s
Library          ${CURDIR}/../libraries/prices.py
