FROM debian:testing
RUN apt-get update && apt-get install -y --no-install-recommends build-essential libc6-dbg curl netcat-traditional

# Copy in source code
WORKDIR /app
COPY Makefile Makefile
COPY src src

# Binary build
RUN make

# Some demo example GPS data
COPY testsuite /testsuite
COPY gps_data.txt gps_data.txt

CMD ["/app/gps_uploader", "@@"]