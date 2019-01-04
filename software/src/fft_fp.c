
#include "structs.h"
#include "fft_fp.h"
#include <math.h>
#include <stdio.h>

#define PI 3.14159265

void fft_cfp(complex_float_t *f, int16_t m, int16_t inverse)
{
    int32_t mr, nn, i, j, l, istep, n;
    
    complex_float_t t;
    complex_float_t q;
    
    complex_float_t w;
    
    n = 1 << m;
    
    mr = 0;
    nn = n - 1;
    
    /* decimation in time - re-order data */
    for (m=1; m<=nn; ++m) {
        l = n;
        do {
            l >>= 1;
        } while (mr+l > nn);
        mr = (mr & (l-1)) + l;
        
        if (mr <= m)
            continue;
        t = f[m];
        f[m] = f[mr];
        f[mr] = t;
    }
    
    l = 1;

    while (l < n) {
        
        istep = l << 1;
        
        //~ printf("while\n");
        
        for (m=0; m<l; ++m)
        {
            w.real = cos(2*PI*m/istep);
            w.imag = -sin(2*PI*m/istep); 
            
            //~ printf( "cos(%f) = %f\n", (2*PI*m/istep), w.real );
            
            if (inverse)
            {
                w.imag = -w.imag;
            }
            
            for (i=m; i<n; i+=istep) 
            {
                j = i + l;
                
                t.real = w.real*f[j].real - w.imag*f[j].imag;
                t.imag = w.real*f[j].imag + w.imag*f[j].real;

                q = f[i];

                f[j].real = q.real - t.real;
                f[j].imag = q.imag - t.imag;
                f[i].real = q.real + t.real;
                f[i].imag = q.imag + t.imag;
            }
        }
        
        l = istep;
    }
    
    if(inverse)
    {
        for(i=0; i<n; i++)
        {
            f[i].real /= n;
            f[i].imag /= n;
        }
    }
}


