# Note: This script should be run in a Developer PowerShell for Visual Studio 2022 prompt.
# This ensures that all necessary environment variables and tools (like MSBuild) are available.

# Step 1: Build the solution using MSBuild
# This compiles the 'geofencing.sln' solution file, generating an executable.
msbuild geofencing.sln

# Step 2: Package the executable for Mayhem
# This command packages the built executable (geofencing.exe) into a format that Mayhem can work with.
# The '-o package' flag specifies the output directory for the package.
mayhem package .\x64\Debug\geofencing.exe -o package

# Step 2a: Copy the test suite files into the package directory
# This copies any test files needed for Mayhem's fuzzing process into the package's 'testsuite' subdirectory.
# The 'testsuite' files contain inputs and scenarios that Mayhem can use to test for edge cases and vulnerabilities.
cp testsuite/* package/testsuite

# Step 3: Run the packaged executable with Mayhem For Code
# Initiates the fuzzing session with Mayhem, using the geofencing package.
# --owner specifies the user or organization that owns the project in Mayhem.
# --project identifies this particular fuzzing project by name.
# --target is a label associated with this binary, used to track the specific target being fuzzed.
mayhem run package --owner forallsecure-demo --project geofencing --target geofencing
