// Copyright Luke Ceddia
// SPDX-License-Identifier: Apache-2.0
// Error handling

#include <stdio.h>
#include <stdlib.h>
#include "lbasic.h"

void fatal_error(enum error_code code) {
    fprintf(stderr, "Fatal error %d\n", code);
    exit(2);
}
