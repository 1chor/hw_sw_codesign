
#include <inttypes.h>

#include "fixed_point.h"

/*
 * zahlen von unterschiedlichen quellen
 * 
 *   matlab  | c %x | hexdump |  c printf_1q15
 *  ---------+------+---------+---------------
 *   0.00003 | 0001 | 0001    |  0.000031
 *   0.00000 | 0000 | 0000    |  0.000000
 *  -0.00015 | fffb | fffb    | -0.000153
 *   0.00015 | 0005 | 0005    |  0.000153
 *  -0.00003 | ffff | ffff    | -0.000031
 *   0.00015 | 0005 | 0005    |  0.000153
 *  -0.00018 | fffa | fffa    | -0.000183
 *   0.00009 | 0003 | 0003    |  0.000092
 *  -0.00003 | ffff | ffff    | -0.000031
 *  -0.00009 | fffd | fffd    | -0.000092
 *   0.00006 | 0002 | 0002    |  0.000061
 *  -0.00003 | ffff | ffff    | -0.000031
 *   0.00006 | 0002 | 0002    |  0.000061
 *  -0.00006 | fffe | fffe    | -0.000061
**/

float convert_1q15( uint16_t num )
{
    uint8_t i = 0;
    uint8_t shift_by = 0;
    
    float num_float = 0;
    
    uint8_t invert = 0;
    
    // wenn die zahl kleiner als 0 ist, dann invertieren wir die zahl.
    // das += 1 ist weil es ein 2er kompliment ist
    
    if ( 0 > (int16_t)num )
    {
        invert = 1;
        
        num = ~num;
        num += 1;
    }
    
    // bei dem 1q15 format muessen wir bei 15 anfangen.
    // das kleinste was addiert werden kann ist dann 2^-15
    
    for ( i = 15; i > 0; i-- )
    {
        // wenn das lsb 1 ist ...
        
        if ( ( (num>>shift_by) & 1 ) == 1 )
        {
            // ... dann wird 2^-i dazu addiert
            num_float += pow( 2, i*(-1) );
        }
        
        // das naechste mal werden wir eins weiter shiften
        
        shift_by += 1;
    }
    
    if ( invert == 1 )
    {
        num_float *= -1;
    }
    
    return num_float;
}

void convert_1q15_pointer( float* f, uint16_t num )
{
    uint8_t i = 0;
    uint8_t shift_by = 0;
    
    float num_float = 0;
    
    uint8_t invert = 0;
    
    // wenn die zahl kleiner als 0 ist, dann invertieren wir die zahl.
    // das += 1 ist weil es ein 2er kompliment ist
    
    if ( 0 > (int16_t)num )
    {
        invert = 1;
        
        num = ~num;
        num += 1;
    }
    
    // bei dem 1q15 format muessen wir bei 15 anfangen.
    // das kleinste was addiert werden kann ist dann 2^-15
    
    for ( i = 15; i > 0; i-- )
    {
        // wenn das lsb 1 ist ...
        
        if ( ( (num>>shift_by) & 1 ) == 1 )
        {
            // ... dann wird 2^-i dazu addiert
            num_float += pow( 2, i*(-1) );
        }
        
        // das naechste mal werden wir eins weiter shiften
        
        shift_by += 1;
    }
    
    if ( invert == 1 )
    {
        num_float *= -1;
    }
    
    *f = num_float;
}

float convert_9q23( uint32_t num )
{
    uint8_t i = 0;
    uint8_t shift_by = 0;
    
    float num_float = 0;
    
    uint8_t invert = 0;
    
    // wenn die zahl kleiner als 0 ist, dann invertieren wir die zahl.
    // das += 1 ist weil es ein 2er kompliment ist
    
    if ( 0 > (int32_t)num )
    {
        invert = 1;
        
        num = ~num;
        num += 1;
    }
    
    num_float += num>>23;
    
    for ( i = 23; i > 0; i-- )
    {
        // wenn das lsb 1 ist ...
        
        if ( ( (num>>shift_by) & 1 ) == 1 )
        {
            // ... dann wird 2^-i dazu addiert
            num_float += pow( 2, i*(-1) );
        }
        
        // das naechste mal werden wir eins weiter shiften
        
        shift_by += 1;
    }
    
    if ( invert == 1 )
    {
        num_float *= -1;
    }
    
    //~ printf( "float: %f\n", num_float );
    
    return num_float;
}

void convert_9q23_pointer( float* f, uint32_t num )
{
    uint8_t i = 0;
    uint8_t shift_by = 0;
    
    float num_float = 0;
    
    uint8_t invert = 0;
    
    // wenn die zahl kleiner als 0 ist, dann invertieren wir die zahl.
    // das += 1 ist weil es ein 2er kompliment ist
    
    if ( 0 > (int32_t)num )
    {
        invert = 1;
        
        num = ~num;
        num += 1;
    }
    
    num_float += num>>23;
    
    for ( i = 23; i > 0; i-- )
    {
        // wenn das lsb 1 ist ...
        
        if ( ( (num>>shift_by) & 1 ) == 1 )
        {
            // ... dann wird 2^-i dazu addiert
            num_float += pow( 2, i*(-1) );
        }
        
        // das naechste mal werden wir eins weiter shiften
        
        shift_by += 1;
    }
    
    if ( invert == 1 )
    {
        num_float *= -1;
    }
    
    //~ printf( "num_float %f\n", num_float );
    
    *f = num_float;
}

void convert_2q30_pointer( float* f, uint32_t num )
{
    uint8_t i = 0;
    uint8_t shift_by = 0;
    
    float num_float = 0;
    
    uint8_t invert = 0;
    
    // wenn die zahl kleiner als 0 ist, dann invertieren wir die zahl.
    // das += 1 ist weil es ein 2er kompliment ist
    
    if ( 0 > (int32_t)num )
    {
        invert = 1;
        
        num = ~num;
        num += 1;
    }
    
    num_float += num>>30;
    
    for ( i = 30; i > 0; i-- )
    {
        // wenn das lsb 1 ist ...
        
        if ( ( (num>>shift_by) & 1 ) == 1 )
        {
            // ... dann wird 2^-i dazu addiert
            num_float += pow( 2, i*(-1) );
        }
        
        // das naechste mal werden wir eins weiter shiften
        
        shift_by += 1;
    }
    
    if ( invert == 1 )
    {
        num_float *= -1;
    }
    
    //~ printf( "num_float %f\n", num_float );
    
    *f = num_float;
}

uint16_t convert_to_fixed_1q15( float num )
{
    return (uint16_t)(num * (1 << 15));
}

uint32_t convert_to_fixed_9q23( float num )
{
    return (uint32_t)(num * (1 << 23));
}
