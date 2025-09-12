# Mayhem Demo App Service

Welcome to the Mayhem Demo App!

The Mayhem Demo Appshowcases security testing capabilities across code, API,
and SBOM/SCA vulnerabilities. The architecture consists of:

- **Car service**: C-based GPS uploader with intentional memory vulnerabilities
- **API service**: FastAPI (Python) with SQL injection, path traversal, and auth bypass vulnerabilities
- **UI service**: React frontend displaying GPS telemetry data
- **Redis**: Data storage backend

## Quickstart

```
# Build the demo app
docker compose up --build -d

# Download mayhem cli
curl --fail -L https://app.mayhem.security/cli/Linux/install.sh | sh

# Login -- See https://app.mayhem.security/-/installation for creating a token.
mayhem login https://app.mayhem.security/  <your token>

# Find vulnerabilities in the car service
mayhem run car

# Download from a completed run
mayhem download -o results demos/mayhem-demo/car-finished

# Replay a crash
# Should result in...
# src/gps_uploader.c:37:9: runtime error: index 79927775 out of bounds for type 'char [8]'
docker run --rm -i ghcr.io/forallsecure-customersolutions/mayhem-demo/car < results/testsuite/fb4f8c935dec4708e39a1f8402caab91e8b038589d3a2f7a725df3e7de2d4449

# Find vulnerabilities in the API
mapi run mayhem-demo/api 30s http://localhost:8000/openapi.json --url http://localhost:8000 --interactive --basic-auth 'me@me.com:123456'
```

Mayhem integrates with your CICD, as in this [PR](https://github.com/ForAllSecure-CustomerSolutions/mayhem-demo/pull/31) showing Mayhem results to a developer.


## Structure and Vulnerabilities

- **Code Security**: The GPS code is a native app that transmits GPS sensor
  data to a Cloud API. The source [./car/src/gps_uploader.c](./car/src/gps_uploader.c)
  contains vulnerabilities such as:

  - Integer overflow
  - Integer underflow
  - Stack-based buffer overflow
  - Heap overflow
  - Double Free
  - Use-after-free
  - Memory leaks

- **API Security**: The cloud API receives GPS data from cars, and services a UI
  for displaying that information. The source
  [./api/app/main.py](./api/app/main.py) contains vulnerabilities including:
  - SQL Injection
  - Path Traversal
  - Authentication bypass
  - Spec/implementation mismatch.
- **SBOM/SCA Security**: There are four images in this repo: redis, car, api,
  and UI. Each is built with OSS components and has vulnerabilities both on and
  off the attack surface.

## Troubleshooting

**Web page not showing** 
If you don't see the webpage, make sure the services (workspace-api, workspace-redis, workspace-ui) came up properly. To check, run:
```
# Check status - This shows all services healthy
docker compose ps
NAME                IMAGE                                                           COMMAND                  SERVICE   CREATED          STATUS                    PORTS
workspace-api-1     ghcr.io/forallsecure-customersolutions/mayhem-demo/api:latest   "uvicorn app.main:ap…"   api       11 minutes ago   Up 10 minutes (healthy)   0.0.0.0:8000->8000/tcp, [::]:8000->8000/tcp
workspace-redis-1   redis:latest                                                    "docker-entrypoint.s…"   redis     11 minutes ago   Up 10 minutes             0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp
workspace-ui-1      ghcr.io/forallsecure-customersolutions/mayhem-demo/ui:latest    "docker-entrypoint.s…"   ui        10 minutes ago   Up 10 minutes             0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
```

To fix, try restarting:
```
docker compose down # Shut down
docker compose up -d   # bring back up
```

## Next Steps

Now that you’ve run Mayhem on this app, let's look at how to get you started on
your own apps. We’ve compiled extensive documentation and tutorials online at [https://app.mayhem.security/docs/overview/](https://app.mayhem.security/docs/overview/)

## License

This project is licensed under the MIT License. See the [LICENSE.txt](./LICENSE.txt) file for details.
