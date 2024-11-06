#define _CRT_SECURE_NO_WARNINGS
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <cmath>
#include <cstring>  
#include <iomanip>  
#include <utility>  // For std::pair

struct GPSPoint {
    double latitude;
    double longitude;
};

// Function to check if a point is inside a quadrilateral
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

// Function to read GPS points and car identifier from a file
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

        // Check if the line is the car identifier
        if (!(ss >> point.latitude >> point.longitude)) {
            // If it fails to read lat/lon, assume it's the car identifier
            file.close();
            return { points, line };
        }

        points.push_back(point);
    }

    file.close();
    return { points, "" }; // Default return with an empty identifier if missing
}

void logGPSPoints(const std::vector<GPSPoint>& points, const std::string& carIdentifier) {
    char logBuffer[200];
    std::string logString;

    for (int i = 0; i < static_cast<int>(points.size()); i++) {
        std::stringstream ss;
        ss << std::fixed << std::setprecision(6)
            << "Lat: " << points[i].latitude
            << ", Lon: " << points[i].longitude;

        // Add car identifier only for the last point, representing the car location
        if (i == points.size() - 1) {
            ss << "\nCar ID: " << carIdentifier;
        }
        ss << "\n";

        logString += ss.str();
    }

    // Intentionally unsafe copy without length checking
    strcpy(logBuffer, logString.c_str());  // Potentially dangerous

    std::cout << "Logging GPS Points: \n" << logBuffer << std::endl;
}

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

    // First 4 points are the boundary (quadrilateral)
    std::vector<GPSPoint> boundaryPoints(gpsPoints.begin(), gpsPoints.begin() + 4);

    // Last point is the car's location
    GPSPoint carLocation = gpsPoints[4];

    // Log the GPS points with car identifier
    logGPSPoints(gpsPoints, carIdentifier);

    // Check if the car is inside the boundary
    if (isPointInPolygon(boundaryPoints, carLocation)) {
        std::cout << "The car is inside the boundary!" << std::endl;
    }
    else {
        std::cout << "The car is NOT inside the boundary!" << std::endl;
    }

    return 0;
}
