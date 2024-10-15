#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <assert.h>

void divide_by_zero(int lat, int lon) {
  volatile int res = 0;
  if (lat == 1)
    res = lat / lon; // Divide by zero when lon = 0
}

void integer_overflow_negative(int lat, int lon) {
  // Integer overflow with negative values, difference > INT_MAX
  volatile int res = 0;

  if (lat == 2 && lon == -79927771) {
    res = lat - lon + 2067556990;
  }
}

void oob_read(int lat, int lon) {
  volatile char OOBR;
  char line[8];
  strcpy(line, "AAAAAA");
  if (lat == 3 && lon == -79927771) {
    OOBR = line[lat - lon]; // Out of bounds read
  }
}

void oob_write(int lat, int lon) {
  volatile char OOBR;
  char line[8];
  strcpy(line, "AAAAAA");
  if (lat == 4 && lon == -79927771) {
    line[lat - lon] = 'w'; // Out of bounds write
  }
}

void double_free(int lat, int lon) {
  char* buf = malloc(lat);
  free(buf);
  if (lat == 5 && lon == -79927771) // Check to pass
    free(buf); // double free
}

void stack_exhaustion(int lat, int lon) {
  char buff[0x1000];
  if (lat == 6 && lon == -79927771) // Check to get pass
    stack_exhaustion(lat, lon);
}


void vulnerable_c(int bug_num, char* line, int latitude, int longitude) {
  if (bug_num == 0) {
    divide_by_zero(latitude, longitude);
    integer_overflow_negative(latitude, longitude);
    oob_read(latitude, longitude);
    oob_write(latitude, longitude);
    double_free(latitude, longitude);
    stack_exhaustion(latitude, longitude);
  }

  if (bug_num == 1) integer_overflow_negative(latitude, longitude);
  if (bug_num == 2) divide_by_zero(latitude, longitude);
  if (bug_num == 3) oob_read(latitude, longitude);
  if (bug_num == 4) oob_write(latitude, longitude);
  if (bug_num == 5) double_free(latitude, longitude);
  if (bug_num == 6) stack_exhaustion(latitude, longitude);
}


// Function to parse a NMEA line and extract latitude and longitude
int parse_lat_lon(char* line, int* latitude, int* longitude) {
  char* str = NULL;
  char* fields[15];
  int field_count = 0;
  int lat = 0, lon = 0;

  str = line;

  fields[field_count++] = str;
  for (char* ptr = str; *ptr != '\0' && field_count < 15; ptr++) {
    if (*ptr == ',') {
      *ptr = '\0'; // Terminate the current field
      fields[field_count++] = ptr + 1; // Start of the next field
    }
  }
  if (field_count != 15 || atoi(fields[1]) <= 1) {
    return -1;
  }

  lat = atoi(fields[2]);
  lon = atoi(fields[4]);

  if (fields[3][0] == 'S') lat = -lat; // Integer overflow when lat = INT_MIN
  if (fields[5][0] == 'W') lon = -lon; // Integer overflow when lon = INT_MIN


  *latitude = lat;
  *longitude = lon;

  return 0;
}

// Function to upload position data to API server
void upload_position(const char* URL, double latitude, double longitude)
{
  char command[256];
  if (URL == NULL) {
    printf("No server to upload latitude: %f, longitude: %f\n", latitude, longitude);
    return;
  }

  printf("Uploading lat %f lon %f to %s\n", latitude, longitude, URL);
  snprintf(command, sizeof(command),
    "curl -X POST -H \"Content-Type: application/json\"  -u me@me.com:123456 -d '{\"latitude\": %.6f, \"longitude\": %.6f}' %s",
    latitude, longitude, URL);

  system(command);
}

int main(int argc, char* argv[])
{
  char line[256];
  int lat = 0, lon = 0;
  double latitude = 0.0, longitude = 0.0;
  const char* GPS_FILE_PATH = NULL;
  int fd, in_bytes;

  GPS_FILE_PATH = argv[1];

  if ((fd = open(GPS_FILE_PATH, O_RDONLY)) == -1) {
    printf("Couldn't open %s. Check your file path.\n", GPS_FILE_PATH);
    exit(-1);
  }

  if ((in_bytes = read(fd, line, sizeof(line) - 1)) == -1) {
    fprintf(stderr, "Couldn't read any bytes. Check your file.\n");
    exit(-1);
  }

  line[in_bytes] = 0;
  parse_lat_lon(line, &lat, &lon);
  vulnerable_c(0, line, lat, lon);

  if (argc == 3) {
    upload_position(argv[2], (double)lat / (double)1000000, (double)lon / (double)1000000);
  }
  return 0;
}

