// Copyright Luke Ceddia
// SPDX-License-Identifier: Apache-2.0
// String routines header

#ifndef LB_STRING_H
#define LB_STRING_H

#include <stdint.h>

typedef uint32_t LB_STRING_SIZE_T;

struct lbstr_t {
    uint8_t flags;
    uint8_t refcount;
    LB_STRING_SIZE_T len;
    LB_STRING_SIZE_T alloc;
    char data[];
};

typedef struct lbstr_t LB_STRING;

#define LB_STRING_READONLY (1<<0)

#endif
