// Copyright Luke Ceddia
// SPDX-License-Identifier: Apache-2.0
// PRINT statement

#include <stdio.h>
#include <inttypes.h>
#include "lbasic.h"

void PRINT_INTEGER(LB_INTEGER *num) {
    printf("%" PRId16, *num);
}

void PRINT_LONG(LB_LONG *num) {
    printf("%" PRId32, *num);
}

void PRINT_INTEGER64(LB_INTEGER64 *num) {
    printf("%" PRId64, *num);
}

void PRINT_SINGLE(LB_SINGLE *num) {
    printf("%f", *num);
}

void PRINT_DOUBLE(LB_DOUBLE *num) {
    printf("%f", *num);
}

void PRINT_STRING(LB_STRING *str) {
    fwrite((*str)->data, 1, (*str)->used, stdout);
}

