#
# See LICENSE file for copyright and license details.
#

# configuration {on, off}
assert   = on
debug    = on
analyzer = on
sanitize = on
profile  = off

# compiler
CC = gcc
AR = gcc-ar rcs

#
# compilation recipes
#

# targets
.PHONY: default lib run clean check memcheck test solutions format

# default target
default: run

# default flags
CFLAGS = -std=c11 -g3 -Wall -Wextra -Wpedantic

# additional warnings
CFLAGS += -Wshadow -Wfloat-equal -Wundef -Wunreachable-code -Wswitch-default \
		  -Wswitch-enum -Wpointer-arith -Wwrite-strings -Wstrict-prototypes

# included directories
INCS = -Iaoc

# assert flags
ifneq ($(assert), on)
CFLAGS += -DNDEBUG
CFLAGS += -Wno-return-type
endif

# optimization flags
ifeq ($(debug), on)
CFLAGS += -Og -fno-omit-frame-pointer
ifeq ($(analyzer), on)
ifeq ($(CC), gcc)
CFLAGS += -fanalyzer
endif
endif
else
CFLAGS += -march=native -mtune=native
CFLAGS += -O3 -ffast-math -funroll-loops
CFLAGS += -fdata-sections -ffunction-sections
CFLAGS += -flto=auto
endif

# sanitation flags
ifeq ($(sanitize), on)
CFLAGS += -fsanitize=undefined -fsanitize=address
endif

# profiler flags
ifeq ($(profile), on)
CFLAGS += -pg -fno-lto
endif

# linking
LDFLAGS = -Wl,--gc-sections
LDLIBS  = -lm

# objects
SRC = $(shell find aoc -type f -name '*.c')
OBJ = $(SRC:%.c=%.o)

# library
LIB = aoc/libaoc.a

# binaries
RUN = $(shell find 20* -type f -name '*.c')
BIN = $(RUN:%.c=%)

# dependencies
CFLAGS += -MMD -MP
DEP = $(OBJ:.o=.d) $(BIN:=.d)
-include $(DEP)

# build objects
$(OBJ): %.o: %.c Makefile
	$(CC) $(CFLAGS) $(INCS) -c $< -o $@

# build library
lib: $(LIB)

$(LIB): $(OBJ)
	$(AR) $@ $^

# build binaries
run: $(BIN)

$(BIN): %: %.c $(LIB) Makefile
	-$(CC) $(CFLAGS) $(INCS) $(LDFLAGS) $< $(LIB) $(LDLIBS) -o $@

# run all
run: $(BIN)
	@for prog in $(sort $(BIN)); do \
		echo "--- $$prog ---" && \
		./$$prog; \
	done

# auxiliary functions
clean:
	rm -rf $(OBJ) $(BIN) $(DEP) $(LIB) gmon.out perf.data*

check:
	-cppcheck --enable=all --inconclusive --suppress=missingIncludeSystem \
		--suppress=unusedFunction --project=compile_commands.json

memcheck:
	-valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes \
		--suppressions=.memcheck.supp $(BIN)

test: $(BIN)
	@for prog in $(sort $(BIN)); do \
		echo "--- $$prog ---" && \
		./$$prog; \
	done | grep -v wtime | diff --color=auto solutions.txt - \
	&& echo "*** All tests passed. ***"

solutions: $(BIN)
	@for prog in $(sort $(BIN)); do \
		echo "--- $$prog ---" && \
		./$$prog; \
	done | grep -v wtime > solutions.txt

format:
	-clang-format -i $(shell find . -type f -name '*.c' -o -name '*.h')
