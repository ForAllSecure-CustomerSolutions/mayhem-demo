#define _CRT_SECURE_NO_WARNINGS
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <cmath>
#include <cstring> 
#include <iomanip> 
#include <utility> 

// Structure to represent a GPS coordinate with latitude and longitude
struct GPSPoint {
    double latitude;
    double longitude;
};

// Determine if a given GPS point is inside a polygon (quadrilateral).
bool isPointInPolygon(const std::vector<GPSPoint>& polygon, const GPSPoint& point) {
    int numVertices = static_cast<int>(polygon.size());
    bool inside = false;

    for (int i = 0, j = numVertices - 1; i < numVertices; j = i++) {
        if (((polygon[i].longitude > point.longitude) != (polygon[j].longitude > point.longitude)) &&
            (point.latitude < (polygon[j].latitude - polygon[i].latitude) *
                (point.longitude - polygon[i].longitude) /
                (polygon[j].longitude - polygon[i].longitude) + polygon[i].latitude)) {
            inside = !inside; 
        }
    }

    return inside;
}

// Read GPS points and a car identifier from a file
// - The file is expected to contain 5 lines: 4 for boundary points and 1 for car location.
// - The car identifier is assumed to be a non-numeric string at the end.
std::pair<std::vector<GPSPoint>, std::string> readGPSPointsFromFile(const std::string& filename) {
    std::vector<GPSPoint> points;
    std::ifstream file(filename);

    if (!file.is_open()) {
        std::cerr << "Error opening file: " << filename << std::endl;
        return { points, "" };
    }

    std::string line;
    while (std::getline(file, line)) {
        GPSPoint point;
        std::stringstream ss(line);

        if (!(ss >> point.latitude >> point.longitude)) {
            file.close();
            return { points, line }; 
        }

        points.push_back(point); 
    }

    file.close();
    return { points, "" }; 
}

// Log GPS points to the console with a car identifier.
// This function contains a **deliberate buffer overflow vulnerability** for demonstration purposes.
void logGPSPoints(const std::vector<GPSPoint>& points, const std::string& carIdentifier) {
    char logBuffer[200]; // Fixed-size buffer (200 bytes)
    std::string logString;

    for (int i = 0; i < static_cast<int>(points.size()); i++) {
        std::stringstream ss;
        ss << std::fixed << std::setprecision(6)
            << "Lat: " << points[i].latitude
            << ", Lon: " << points[i].longitude;

        if (i == points.size() - 1) {
            ss << "\nCar ID: " << carIdentifier;
        }
        ss << "\n";

        logString += ss.str(); 
    }

    // Copies the log string into a fixed-size buffer without checking its length.
    // If logString is longer than 200 characters, it will cause a buffer overflow.
    strcpy(logBuffer, logString.c_str()); 

    std::cout << "Logging GPS Points: \n" << logBuffer << std::endl;
}

// Processes input files, reads GPS points, logs data, 
// and checks if the car is within the boundary.
int main(int argc, char* argv[]) {
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " <gps_points_file>" << std::endl;
        return 1;
    }

    std::string filename = argv[1];
    auto result = readGPSPointsFromFile(filename);
    std::vector<GPSPoint> gpsPoints = result.first;
    std::string carIdentifier = result.second;

    if (gpsPoints.size() != 5) {
        std::cerr << "The input file must contain exactly 5 GPS points (4 boundary points + 1 car point)." << std::endl;
        return 1;
    }

    if (carIdentifier.empty()) {
        std::cerr << "Car identifier not found in the file." << std::endl;
        return 1;
    }

    std::vector<GPSPoint> boundaryPoints(gpsPoints.begin(), gpsPoints.begin() + 4);

    GPSPoint carLocation = gpsPoints[4];

    logGPSPoints(gpsPoints, carIdentifier);

    if (isPointInPolygon(boundaryPoints, carLocation)) {
        std::cout << "The car is inside the boundary!" << std::endl;
    } else {
        std::cout << "The car is NOT inside the boundary!" << std::endl;
    }

    return 0;
}
