// Copyright Luke Ceddia
// SPDX-License-Identifier: Apache-2.0
// String routines

#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "lbasic.h"

static LB_STRING *alloc_new(LB_STRING_SIZE_T alloc_size) {
    size_t total_size = sizeof(LB_STRING) + alloc_size;
    if (total_size < alloc_size) {
        fatal_error(ERR_STR_ALLOC_TOO_BIG);
    }
    LB_STRING *lbs = malloc(total_size);
    if (!lbs) {
        fatal_error(ERR_STR_ALLOC_FAILED);
    }
    lbs->flags = 0;
    lbs->len = 0;
    lbs->alloc = alloc_size;
    return lbs;
}

LB_STRING *STRING_ASSIGN(LB_STRING **src_p) {
    LB_STRING *src = *src_p;
    LB_STRING *dest = alloc_new(src->len);
    dest->len = src->len;
    memmove(dest->data, src->data, src->len);
    return dest;
}

LB_STRING *LEFT(LB_STRING **src_p, LB_LONG *length) {
    LB_STRING *src = *src_p;
    LB_STRING *dest;
    LB_STRING_SIZE_T dest_length = *length <= src->len ? *length : src->len;
    dest = alloc_new(dest_length);
    dest->len = dest_length;
    memmove(dest->data, src->data, dest_length);
    return dest;
}

LB_STRING *RIGHT(LB_STRING **src_p, LB_LONG *length) {
    LB_STRING *src = *src_p;
    LB_STRING *dest;
    LB_STRING_SIZE_T dest_length = *length <= src->len ? *length : src->len;
    dest = alloc_new(dest_length);
    dest->len = dest_length;
    memmove(dest->data, src->data + (src->len - dest_length), dest_length);
    return dest;
}
