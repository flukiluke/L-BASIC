// Copyright Luke Ceddia
// SPDX-License-Identifier: Apache-2.0
// Basic interactions with the operating environment

#include <stdlib.h>
#include "lbasic.h"

void SYSTEM(LB_INTEGER *return_code) {
    if (return_code) {
        exit(*return_code);
    }
    else {
        exit(0);
    }
}

void END(LB_INTEGER *return_code) {
    if (return_code) {
        exit(*return_code);
    }
    else {
        exit(0);
    }
}
