// Copyright Luke Ceddia
// SPDX-License-Identifier: Apache-2.0
// String routines

#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "lbasic.h"

static LB_STRING alloc_new(size_t alloc_size) {
    size_t total_size = sizeof(LB_STRING) + alloc_size;
    if (total_size < alloc_size) {
        fatal_error(ERR_STR_ALLOC_TOO_BIG);
    }
    LB_STRING lbs = malloc(total_size);
    if (!lbs) {
        fatal_error(ERR_STR_ALLOC_FAILED);
    }
    lbs->flags = 0;
    lbs->used = 0;
    lbs->alloc = alloc_size;
    return lbs;
}

LB_STRING STRING_COPY(LB_STRING *src) {
    LB_STRING dest = alloc_new((*src)->used);
    dest->flags = (*src)->flags;
    dest->used = (*src)->used;
    memmove(dest->data, (*src)->data, (*src)->used);
    return dest;
}
