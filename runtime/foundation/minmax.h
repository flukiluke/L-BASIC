// This file incorporates a max macro by David Titarenco,
// (https://stackoverflow.com/a/3437484).
// SPDX-License-Identifier:  CC-BY-SA-2.5

#ifndef LB_MINMAX_H
#define LB_MINMAX_H

#define max(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a > _b ? _a : _b; })

#define min(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a < _b ? _a : _b; })

#endif
