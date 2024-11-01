#!/bin/bash

mayhem run --project forallsecure-demo/mayhem-demo --target car --image "ghcr.io/forallsecure-customersolutions/mayhem-demo/car:latest" --cmd "/app/gps_uploader @@" --cwd "/app" --advanced-triage true --all ./car

