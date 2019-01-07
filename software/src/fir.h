
#ifndef __FIR_H__
#define __FIR_H__

#include <stdint.h>
#include "structs.h"

// das wird am start der software ausgefuehrt um die ersten 512
// samples von ir zu bekommen.
// diese samples werden nicht in einem bestimmten speicher abgelegt.
// daher werden die werte immer als pointer uebergeben.

void fir_filter_setup_sw( uint16_t*, uint16_t*, struct wav* );
void fir_filter_setup_hw( struct wav*, uint16_t );

// damit wird der fir filter ausgefuehrt

void fir_filter_sample_sw
(
     int32_t*,int32_t*
    ,uint16_t*,uint16_t*
    ,uint16_t*,uint16_t*
);

void fir_filter_sample_hw
(
     int32_t* sample_result_1
    ,int32_t* sample_result_2
    ,uint16_t* i_samples_1
    ,uint16_t* i_samples_2
);

#endif


