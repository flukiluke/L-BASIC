all: sds.a

sds.a: sds.o $(wildcard *.h)
	rm $@ 2> /dev/null || true
	$(AR) rcs $@ sds.o

sds-test: sds.c sds.h testhelp.h
	$(CC) -o sds-test sds.c -Wall -std=c99 -pedantic -O2 -DSDS_TEST_MAIN
	@echo ">>> Type ./sds-test to run the sds.c unit tests."

clean:
	rm -f sds-test sds.o sds.a 2> /dev/null
