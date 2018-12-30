
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
    
    uint32_t a = i.r;
    uint32_t b = i.i;
    
    uint32_t c = r.r;
    uint32_t d = r.i;
    
    float a_f;
    float b_f;
    float c_f;
    float d_f;
    
    convert_9q23_pointer( &a_f, a );
    convert_9q23_pointer( &b_f, b );
    convert_9q23_pointer( &c_f, c );
    convert_9q23_pointer( &d_f, d );
    
    float c_ret_r = 0;
    float c_ret_i = 0;
    
    c_ret_r = (a_f * c_f) - (b_f * d_f);
    c_ret_i = (a_f * d_f) + (b_f * c_f);
    
    c_return.r = convert_to_fixed_9q23( c_ret_r );
    c_return.i = convert_to_fixed_9q23( c_ret_i );
    
    //~ c_return.r = (a * c) - (b * d);
    //~ c_return.i = (a * d) + (b * c);
    
    //~ c_print_as_float( i );
    //~ c_print_as_float( r );
    //~ c_print_as_float( c_return );
    
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
