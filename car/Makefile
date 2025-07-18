TESTSUITE_DIR := ./testsuite

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
		./gps_uploader  $$test https://api:8443/location; \
	done

clean:
	-rm -f gps_uploader
	-rm -rf results/
