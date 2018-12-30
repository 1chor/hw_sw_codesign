
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
        printf("failed for\n");
        printf(">%f %f i\n", a_r, a_i);
        printf(">%f %f i\n", b_r, b_i);
        printf("---------------------\n");
        
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

complex_32_t c_mul( complex_32_t i, complex_32_t r )
{
    complex_32_t c_return;
    
    int32_t a = (int32_t)i.r;
    int32_t b = (int32_t)i.i;
    int32_t c = (int32_t)r.r;
    int32_t d = (int32_t)r.i;
    
    int64_t temp_64;
    int32_t temp_32;
    
    temp_64 = ( (int64_t)a * (int64_t)c ) - ( (int64_t)b * (int64_t)d );
    temp_32 = (int32_t)(temp_64>>23);
    
    c_return.r = (uint32_t)(temp_32);
    
    temp_64 = ( (int64_t)a * (int64_t)d ) + ( (int64_t)b * (int64_t)c );
    temp_32 = (int32_t)(temp_64 >> 23);
    
    c_return.i = (uint32_t)(temp_32);
    
    return c_return;
}

void c_print( complex_32_t c )
{
    printf("%lx %lx i\n", c.r, c.i);
}

void c_print_as_float( complex_32_t c )
{
    float c_r;
    float c_i;
    
    (void) convert_9q23_pointer( &c_r, c.r);
    (void) convert_9q23_pointer( &c_i, c.i);
    
    printf("%f %f i\n", c_r, c_i);
}
