
#include <inttypes.h>

//~ #include "system.h"

#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include <unistd.h>
#include <malloc.h>
#include "system.h"
#include "io.h"
#include "nios2.h"

#include "complex.h"
#include "fixed_point.h"

// cmp mit hex

//~ uint8_t cmp_complex( complex_32_t a, complex_32_t b )
//~ {
    //~ if (
        //~ ( (int32_t)(a.r - b.r) > 10 ) ||
        //~ ( (int32_t)(a.i - b.i) > 10 )
    //~ )
    //~ {
        //~ printf("failed for\n");
        //~ printf(">%lx %lx i\n", a.r, a.i);
        //~ printf(">%lx %lx i\n", b.r, b.i);
        
        //~ printf(">%lx %lx i\n", (a.r - b.r), (a.i - b.i));
        
        //~ printf("---------------------\n");
        
        //~ return 1;
    //~ }
    
    //~ return 0;
//~ }

// cmp mit float

uint8_t cmp_complex( complex_32_t a, complex_32_t b )
{
    float a_r;
    float a_i;
    float b_r;
    float b_i;
    
    // hier muss ich das pointer zeugs verwenden
    // sonst funktioniert es nicht.
    
    (void) convert_9q23_pointer( &a_r, a.r);
    (void) convert_9q23_pointer( &a_i, a.i);
    (void) convert_9q23_pointer( &b_r, b.r);
    (void) convert_9q23_pointer( &b_i, b.i);
    
    if (
        ( (a_r - b_r) > 0.5 ) ||
        ( (a_i - b_i) > 0.5 )
    )
    {
        return 1;
    }
    
    return 0;
}

complex_32_t complex_from_float_9q23( float r, float i )
{
    complex_32_t c;
    
    c.r = convert_to_fixed_9q23( r );
    c.i = convert_to_fixed_9q23( i );
    
    return c;
}
