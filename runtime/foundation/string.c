// Copyright Luke Ceddia
// SPDX-License-Identifier: Apache-2.0
// String routines

#include <stddef.h>
#include "../extlib/sds/sds.h"
#include "lbasic.h"

LB_STRING STR_NEW_FROM(char *data, size_t len) {
    return sdsnewlen(data, len);
}

