FROM debian:stable-slim
RUN apt-get update && apt-get install -y --no-install-recommends build-essential libc6-dbg curl netcat-traditional

# Copy in source code
WORKDIR /app
COPY Makefile Makefile
COPY src src

# Binary build
RUN make
#RUN gcc -o gps_uploader -g -fsanitize=undefined -fno-sanitize-recover src/gps_uploader.c
#RUN gcc -o gps_uploader_gcov -g -fprofile-arcs -ftest-coverage src/gps_uploader.c

# Some demo example GPS data
COPY testsuite testsuite
COPY gps_data.txt gps_data.txt

# REMOVEME
COPY crashers crashers

CMD ["/app/src/wait-for-it.sh", "api", "--", "make",  "upload"]
