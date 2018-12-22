
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
    
    // wenn die zahl kleiner als 0 ist, dann invertieren wir die zahl.
    // das += 1 ist weil es ein 2er kompliment ist
    
    if ( 0 > (int16_t)num )
    {
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
    
    return num_float;
}

void print_1q15( uint16_t num )
{
    if ( 0 > (int16_t)num )
    {
        printf( "-" );
    }
    else
    {
        printf( " " );
    }
    
    printf( "%f\n", convert_1q15(num) );
    
    return;
}

void print_9q23( uint32_t num )
{
    uint8_t i = 0;
    uint8_t shift_by = 0;
    
    float num_float = 0;
    
    // wenn die zahl kleiner als 0 ist, dann invertieren wir die zahl.
    // das += 1 ist weil es ein 2er kompliment ist
    
    // wir printen auch gleich ein "-"
    
    //~ printf( "%x - ", num );
    
    if ( 0 > (int32_t)num )
    {
        num = ~num;
        num += 1;
        
        printf( "-" );
    }
    else
    {
        printf( " " );
    }
    
    // die 9 hoechsten bits raus holen.
    
    printf( "%lx\n", num );
    printf( "%lx>>23\n", num>>23 );
    
    num_float += num>>23;
    
    // bei dem 16q15 format muessen wir bei 15 anfangen.
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
    
    //~ printf( "%f\n", num_float );
    //~ printf( "%.10e\n", num_float );
    printf( "%f\n", num_float );
}
