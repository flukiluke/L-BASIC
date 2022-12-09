// Copyright Luke Ceddia
// SPDX-License-Identifier: Apache-2.0
// Error codes and handling functions

#ifndef LB_ERROR_H
#define LB_ERROR_H

enum error_code {
    ERR_STR_ALLOC_FAILED = 1,
    ERR_STRING_TOO_BIG
};

void fatal_error(enum error_code code);

#endif
