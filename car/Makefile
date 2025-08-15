API_HOST := localhost

TESTSUITE_DIR := ./testsuite

TESTS := $(addprefix $(TESTSUITE_DIR)/test,1 2 3 4 5 6 7 8 9)

.PHONY: all
all: gps_uploader

.PHONY: gps_uploader
gps_uploader:
	gcc -o $@ -g -fsanitize=undefined -fno-sanitize-recover src/gps_uploader.c

.PHONY: test
test: $(TESTS) gps_uploader
	@for test in $^; do \
		echo "- Running $$test..."; \
		./gps_uploader  $$test; \
	done

.PHONY: upload
upload: $(TESTS) gps_uploader
	@for test in $^; do \
		echo "- Running $$test..."; \
		./gps_uploader  $$test https://${API_HOST}:8443/location; \
	done

.PHONY: upload
clean:
	-rm -f gps_uploader
	-rm -rf results/
