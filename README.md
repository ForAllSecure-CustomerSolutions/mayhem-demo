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

# Reproduce vulnerabilities locally 
mayhem download -o results mayhem-demo/car

# Optional: You can also download from other runs, like completed runs
mayhem download -o results demos/mayhem-demo/car

# Find vulnerabilities in the API
mapi run mayhem-demo/api 30s http://localhost:8000/openapi.json --url http://localhost:8000 --interactive --basic-auth 'me@me.com:123456'
```


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



**Steps:**

1. Run `mdsbom scout ghcr.io/forallsecure-customersolutions/mayhem-demo/api:latest --sca-report-out dsbom-api.sarif`

2. That’s it! View the results on the Mayhem UI.

**Details:**

The command line about did several things all at once:

1. Built an SBOM and SCA report from `docker scout`
2. Identified the attack surface in the `api` image.
3. Reduced the SCA findings to only those items on the attack surface. In our
   run, 90\% of the `docker scout` SBOM/SCA results were irrelevant to
   security!

In more detail, the arguments:

- `scout` specified to run docker scout to get the initial SBOM/SCA result.
  Mayhem supports any SBOM/SCA tool that creates a CycloneDX or SPDX file.
  You can run `mdsbom help` to see other possibilities, like anchore, trivy,
  and more generally any source using a standardized format.

- `ghcr.io/forallsecure-customersolutions/mayhem-demo/api:latest` is path to
  the docker image (`docker compose build` will default to this name).

- ``--sca-report-out dsbom-api.sarif` says to output a SARIF format as file
  `dsbom-api.sarif`.

Tip: You can use `--workspace <name>` to specify a different workspace to
upload results.

### Step 4C: Run Mayhem for Code to find code vulnerabilities

**Prerequisites**
You need to have the built docker images from the `docker compose build` step,
and a registry you can push the images to. You can also use our pre-built
containers [here](https://github.com/orgs/ForAllSecure-CustomerSolutions/packages?repo_name=mayhem-demo).

**Steps:**

1. Push the docker image to a registry such as Dockerhub or Github Container
   Registry. If you are an enterprise customer, Mayhem comes with a docker
   registry built-in.

   ```
   docker tag ghcr.io/forallsecure-customersolutions/mayhem-demo/car:latest <docker id>/mayhem-demo/car:latest
   docker push <docker id>/mayhem-demo/car:latest
   ```

2. Start analysis with `mayhem run mayhem-demo/car --image ghcr.io/forallsecure-customersolutions/mayhem-demo/car:latest --duration 1800`

And that’s it! You should be able to see results for Mayhem for Code in your project!

**Details:**

- `run` tells Mayhem to start a run.
- `--image ghcr.io/forallsecure-customersolutions/mayhem-demo/` tells
  Mayhem the location of your app's image.
- `--duration 1800` tells Mayhem to run analysis for up to 30 minutes. (If you
  leave this off, Mayhem will continually pentest your app.)

## Next Steps

Now that you’ve run Mayhem on this app, let's look at how to get you started on
your own apps.  We’ve compiled extensive documentation and tutorials online at [https://app.mayhem.security/docs/overview/](https://app.mayhem.security/docs/overview/)



## License

This project is licensed under the MIT License. See the [LICENSE.txt](./LICENSE.txt) file for details.
