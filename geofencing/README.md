# Windows Geofencing Demo with Mayhem

This project demonstrates how to fuzz a C++ application that processes GPS points and checks if a car is within a defined boundary. Using Mayhem, we can identify exploitable vulnerabilities, such as buffer overflows, in the code by running a fuzzing session.

## Prerequisites

To run this demo, you'll need:

1. **Visual Studio 2022**: Install Visual Studio 2022 with the C++ development workload.
2. **Mayhem CLI**: Install the Mayhem CLI from https://app.mayhem.security/-/installation.
3. **Mayhem Authentication**: Authenticate with your Mayhem account using the following command:

   mayhem login https://app.mayhem.security/ <your-authentication-token>

## Project Setup

1. **Open Developer PowerShell for Visual Studio 2022**:
   Run the script in a Developer PowerShell prompt for Visual Studio 2022. This environment includes all necessary environment variables and tools for building the project.

## Build and Run Instructions

1. **Build the Solution**:
   Use MSBuild to compile the `geofencing.sln` solution file. This generates an executable file for testing.

   msbuild geofencing.sln

2. **Package the Executable for Mayhem**:
   Package the built executable to prepare it for the fuzzing session with Mayhem.

   mayhem package .\x64\Debug\geofencing.exe -o package

3. **Copy Test Suite Files**:
   If your project includes any input test files, copy them to the `testsuite` folder within the package directory:

   cp testsuite/* package/testsuite

4. **Run the Fuzzing Session with Mayhem**:
   Start the fuzzing session by running Mayhem with the packaged executable.

   mayhem run package --owner <workspace> --project geofencing --target geofencing

   - `--owner`: Specifies your Mayhem workspace name.
   - `--project`: Names the project for organizational purposes in Mayhem.
   - `--target`: An identifier associated with the binary, tracking the specific target being fuzzed.

## Source Code Overview

The `geofencing.cpp` file contains the following key components:

- **GPSPoint Struct**: Defines latitude and longitude for GPS points.
- **isPointInPolygon**: A function to check if a given GPS point (the car's location) is inside a defined quadrilateral.
- **readGPSPointsFromFile**: Reads a file containing GPS points and returns a list of points along with a car identifier.
- **logGPSPoints**: Logs GPS points and the car identifier.
- **Main Function**: Processes input files, reads GPS points, logs data, and checks if the car is within the boundary.

## Usage Example

Run the executable with a file containing GPS points and a car identifier, formatted as follows:

40.748817 -73.985428
40.748941 -73.987152
40.747409 -73.987128
40.747331 -73.985407
123ABC456

The file should contain exactly 5 lines: 4 for the boundary points and 1 for the car identifier.
