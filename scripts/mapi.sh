#!/bin/bash

mapi run mayhem-demo/api 1m http://localhost:8000/openapi.json --url http://localhost:8000 --html mapi.html --interactive --basic-auth "me@me.com:123456" --experimental-rules --ignore-rule internal-server-error
