# -*-cython-*-
#
# Common functions required when doing complex arithmetic with Cython.
#

cimport numpy as np
cimport libc.math

cdef extern from "_complexstuff.h":
    double npy_cabs(np.npy_cdouble z) nogil
    double npy_carg(np.npy_cdouble z) nogil
    np.npy_cdouble npy_clog(np.npy_cdouble z) nogil
    np.npy_cdouble npy_cexp(np.npy_cdouble z) nogil
    np.npy_cdouble npy_csin(np.npy_cdouble z) nogil
    np.npy_cdouble npy_csqrt(np.npy_cdouble z) nogil
    np.npy_cdouble npy_cpow(np.npy_cdouble x, np.npy_cdouble y) nogil
    double npy_log1p(double x) nogil
    int npy_isnan(double x) nogil
    int npy_isinf(double x) nogil
    int npy_isfinite(double x) nogil
    double inf "NPY_INFINITY"
    double pi "NPY_PI"
    double nan "NPY_NAN"

ctypedef double complex double_complex

ctypedef fused number_t:
    double
    double_complex

cdef inline bint zisnan(number_t x) nogil:
    if number_t is double_complex:
        return npy_isnan(x.real) or npy_isnan(x.imag)
    else:
        return npy_isnan(x)

cdef inline bint zisfinite(number_t x) nogil:
    if number_t is double_complex:
        return npy_isfinite(x.real) and npy_isfinite(x.imag)
    else:
        return npy_isfinite(x)

cdef inline bint zisinf(number_t x) nogil:
    if number_t is double_complex:
        return not zisnan(x) and not zisfinite(x)
    else:
        return npy_isinf(x)

cdef inline double zabs(number_t x) nogil:
    if number_t is double_complex:
        return npy_cabs((<np.npy_cdouble*>&x)[0])
    else:
        return libc.math.fabs(x)

cdef inline double zarg(double complex x) nogil:
    return npy_carg((<np.npy_cdouble*>&x)[0])

cdef inline number_t zlog(number_t x) nogil:
    cdef np.npy_cdouble r
    if number_t is double_complex:
        r = npy_clog((<np.npy_cdouble*>&x)[0])
        return (<double_complex*>&r)[0]
    else:
        return libc.math.log(x)

cdef inline number_t zexp(number_t x) nogil:
    cdef np.npy_cdouble r
    if number_t is double_complex:
        r = npy_cexp((<np.npy_cdouble*>&x)[0])
        return (<double_complex*>&r)[0]
    else:
        return libc.math.exp(x)

cdef inline number_t zsin(number_t x) nogil:
    cdef np.npy_cdouble r
    if number_t is double_complex:
        r = npy_csin((<np.npy_cdouble*>&x)[0])
        return (<double_complex*>&r)[0]
    else:
        return libc.math.sin(x)

cdef inline number_t zsqrt(number_t x) nogil:
    cdef np.npy_cdouble r
    if number_t is double_complex:
        r = npy_csqrt((<np.npy_cdouble*>&x)[0])
        return (<double_complex*>&r)[0]
    else:
        return libc.math.sqrt(x)

cdef inline number_t zpow(number_t x, double y) nogil:
    cdef np.npy_cdouble r, z
    # FIXME
    if number_t is double_complex:
        z.real = y
        z.imag = 0.0
        r = npy_cpow((<np.npy_cdouble*>&x)[0], z)
        return (<double_complex*>&r)[0]
    else:
        return libc.math.pow(x, y)

cdef inline double_complex zpack(double zr, double zi) nogil:
    cdef np.npy_cdouble z
    z.real = zr
    z.imag = zi
    return (<double_complex*>&z)[0]
