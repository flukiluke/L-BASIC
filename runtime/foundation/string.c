// Copyright Luke Ceddia
// SPDX-License-Identifier: Apache-2.0
// String routines

#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <string.h>
#include "lbasic.h"

/**
 * Make a new instance of a string with the same content as
 * src. The refcount is set to 0 and flags are cleared.
 */
static LB_STRING *duplicate(LB_STRING *src);

/**
 * Allocate memory for a string that can hold alloc_size bytes.
 * Flags are cleared, refcount and len are set to 0.
 */
static LB_STRING *alloc_new(LB_STRING_SIZE_T alloc_size);

/**
 * Return a string suitable for permanent assignment. The refcount
 * is incremented if the string is mutable. A copy may be made if
 * the refcount is at its limit.
 */
static LB_STRING *acquire(LB_STRING *s);

/**
 * Remove an assignment of a string. If mutable, the refcount is
 * decremented and the string's memory is freed if it is 0.
 */
static void release(LB_STRING *s);


static LB_STRING *alloc_new(LB_STRING_SIZE_T alloc_size) {
    size_t total_size = sizeof(LB_STRING) + alloc_size;
    if (total_size < alloc_size) {
        fatal_error(ERR_STRING_TOO_BIG);
    }
    LB_STRING *lbs = malloc(total_size);
    if (!lbs) {
        fatal_error(ERR_STR_ALLOC_FAILED);
    }
    lbs->flags = 0;
    lbs->refcount = 0;
    lbs->len = 0;
    lbs->alloc = alloc_size;
    return lbs;
}

static LB_STRING *duplicate(LB_STRING *src) {
    LB_STRING *dup = alloc_new(src->len);
    dup->len = src->len;
    memmove(dup->data, src->data, src->len);
    return dup;
}

static LB_STRING *acquire(LB_STRING *s) {
    if (s->flags & LB_STRING_READONLY) {
        // Cannot modify readonly string
        return s;
    }
    if (s->refcount == UINT8_MAX) {
        // Max number of references to this string
        LB_STRING *dup = duplicate(s);
        dup->refcount = 1;
        return dup;
    }
    s->refcount++;
    return s;
}

static void release(LB_STRING *s) {
    if (s->flags & LB_STRING_READONLY) {
        // Cannot modify readonly string
        return;
    }
    // Do not decrement if already at 0. A string may already have a 0
    // refcount if, e.g., it is the return value of a function.
    if (s->refcount > 0) {
        s->refcount--;
    }
    if (s->refcount == 0) {
        free(s);
    }
}

/**
 * Implement string assignment
 */
void STRING_ASSIGN(LB_STRING **dest_p, LB_STRING *src) {
    LB_STRING *dest = *dest_p;
    if (dest) {
        release(dest);
    }
    *dest_p = acquire(src);
}

/**
 * Implement string concatenation
 */
LB_STRING *STRING_ADD(LB_STRING *left, LB_STRING *right) {
    // It may be more efficient to reuse the left string if it
    // can be modified.
    size_t new_len = left->len + right->len;
    if (new_len < left->len) {
        fatal_error(ERR_STRING_TOO_BIG);
    }
    LB_STRING *result = alloc_new(new_len);
    result->len = new_len;
    memmove(result->data, left->data, left->len);
    memmove(result->data + left->len, right->data, right->len);
    return result;
}

/**
 * Free a string if it is no longer needed. Calls to this
 * are emitted periodically to free strings that are thought
 * to be temporary, or when a variable goes out of scope.
 */
void STRING_MAYBE_FREE(LB_STRING *src) {
    release(src);
}

LB_STRING *MID(LB_STRING *src, LB_LONG start, LB_LONG *length_p) {
    LB_LONG length;
    if (start > src->len) {
        return alloc_new(0);
    }

    if (length_p) {
        length = *length_p - max(1 - start, 0);
        start = max(1, start);
        length = min(src->len - start + 1, length);
    }
    else {
        start = min(1, start);
        length = src->len - start + 1;
    }

    LB_STRING *dest = alloc_new(length);
    dest->len = length;
    memmove(dest->data, src->data + start - 1, length);
    return dest;
}
    
LB_LONG LEN_STRING(LB_STRING *s) {
    return s->len;
}

LB_STRING *CHR(LB_INTEGER64 v) {
    LB_STRING *result = alloc_new(1);
    result->len = 1;
    if (v < 0 || v > 255) {
        fatal_error(ERR_ARG_RANGE);
    }
    result->data[0] = (char) v;
    return result;
}
