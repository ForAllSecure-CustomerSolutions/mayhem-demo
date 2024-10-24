TESTSUITE_DIR := /testsuite

TESTS := $(addprefix $(TESTSUITE_DIR)/test,1 2 3 4 5 6 7 8 9)

all:
	gcc -o gps_uploader -g -fsanitize=undefined -fno-sanitize-recover src/gps_uploader.c

test: $(TESTS)
	@for test in $^; do \
		echo "- Running $$test..."; \
		./gps_uploader  $$test; \
	done

upload: $(TESTS)
	@for test in $^; do \
		echo "- Running $$test..."; \
		./gps_uploader  $$test http://api:8000/location; \
	done
