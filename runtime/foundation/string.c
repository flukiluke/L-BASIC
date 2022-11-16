// Copyright Luke Ceddia
// SPDX-License-Identifier: Apache-2.0
// String routines

#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <string.h>
#include "lbasic.h"

static LB_STRING *duplicate(LB_STRING *src);
static LB_STRING *alloc_new(LB_STRING_SIZE_T alloc_size);
static LB_STRING *acquire(LB_STRING *s);
static void release(LB_STRING *s);

/**
 * Make a new instance of a string with the same content as
 * src. The refcount is set to 0 and flags are cleared.
 */
static LB_STRING *duplicate(LB_STRING *src) {
    LB_STRING *dup = alloc_new(src->len);
    dup->len = src->len;
    memmove(dup->data, src->data, src->len);
    return dup;
}

/**
 * Return a string suitable for permanent assignment. The refcount
 * is incremented if the string is mutable. A copy may be made if
 * the refcount is at its limit.
 */
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

/**
 * Remove an assignment of a string. If mutable, the refcount is
 * decremented and the string's memory is freed if it is 0.
 */
static void release(LB_STRING *s) {
    if (s->flags & LB_STRING_READONLY) {
        // Cannot modify readonly string
        return;
    }
    if (s->refcount == 0) {
        // TODO: Consider whether a fatal error should be thrown here
        return;
    }
    s->refcount--;
    if (s->refcount == 0) {
        free(s);
    }
}

/**
 * Allocate memory for a string that can hold alloc_size bytes.
 * Flags are cleared, refcount and len are set to 0.
 */
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
    lbs->refcount = 0;
    lbs->len = 0;
    lbs->alloc = alloc_size;
    return lbs;
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
 * Free a string if it is no longer needed. Calls to this
 * are emitted periodically to free strings that are thought
 * to be temporary, or when a variable goes out of scope.
 */
void STRING_MAYBE_FREE(LB_STRING **src_p) {
    LB_STRING *src = *src_p;
    release(src);
    *src_p = NULL; // Help catch use-after-free errors
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
