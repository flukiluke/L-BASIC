// Copyright Luke Ceddia
// SPDX-License-Identifier: Apache-2.0
// String routines header

#ifndef LB_STRING_H
#define LB_STRING_H

#include <stdint.h>

struct lbstr_t {
    uint8_t flags;
    uint32_t used;
    uint32_t alloc;
    char data[];
};

typedef struct lbstr_t *LB_STRING;

#endif
