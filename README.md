<div align="center">
  <h1 align="center">Cavendish</h1>
</div>


- A scientist from the late 1700's that discovered Hydrogen, which he called "inflammable air"
- A small town in Southern Vermont
- A library for matrix multiplication, time series analysis, and numeric calculation

<br /><br />

## Installation

### If you are using [Protostar](https://docs.swmansion.com/protostar/)

```bash
protostar install https://github.com/42labs/Cavendish
```

## Usage

To import the library in a cairo file, add this line:

```cairo
from _42labs.cavendish.prelude import _cavendish
```

### Matrices and Vectors

There are several methods for vectors, matrices, and statistics introduced in this library.  For example, generate a range, reshape a vector to a matrix, pairwise operations on matrices, dot product, and a variety of statistics utilities.

Signature:
```cairo
struct Matrix2D:
    member x_dim : felt
    member y_dim : felt
    member m : felt**
end

func range(start : felt, end_ : felt) -> (arr : felt*):
end

func reshape(arr_len : felt, arr : felt*, x_dim : felt, y_dim : felt) -> (output_matrix : Matrix2D):
end

func matrix_mult(matrix : Matrix2D, r_matrix : Matrix2D) -> (_m : Matrix2D):
end
```

<details>
  <summary>Example</summary>

```cairo
from _42labs.cavendish.prelude import range, reshape, matrix_mult, vector_matrix_mult, log_array, log_matrix

let arr_len = 15

let (r) = range(0, 15)
let (matrix_) = reshape(arr_len, r, 3, 5)

let (arr) = range(10, 25)
let (r_matrix) = reshape(arr_len, arr, 5, 3)

let (output_len, output) = vector_matrix_mult(5, arr, r_matrix)
log_array(output_len, output)
# Array(990, 1050, 1110)

let (output_matrix) = matrix_mult(matrix_, r_matrix)
log_matrix(output_matrix)
# Matrix[
#         Array(190, 200, 210)
#         Array(590, 625, 660)
#         Array(990, 1050, 1110)
# ]
```
</details>

### Statistics

Additionally, there are some useful methods for creating and working with statistical data.  For example, pdf, cdf and ppf for a normal distribution.

```cairo
from _42labs.cavendish.prelude import mean, variance, standard_deviation, norm
# norm include erf, erfinv, pdf, cdf and ppf
```
  
<details>
  <summary>Example</summary>

```cairo
from _42labs.cavendish.prelude import FixedPoint, ONE
from _42labs.cavendish.stats.norm import norm

let (TWO) = FixedPoint.fromFelt(2)
let (x) = norm.pdf(TWO)
assert x = 124494689016914193   # 0.053990964918018254
let (x1) = norm.erf(ONE)
assert x1 = 1943135515416033133  # 0.8427006988991214
let (x2) = norm.cdf(ONE)
assert x2 = 1940008856356186113  # 0.8413447460685429
```
</details>
  
Inspiration was taken from the excellent <b>cairo-streams</b> library by <b>onlydust</b>, and the <b>cairo-math-64x61</b> library by <b>influenceth</b>

    - https://github.com/influenceth/cairo-math-64x61
    - https://github.com/onlydustxyz/cairo-streams
    
As well as numpy, scipy and pandas:

- https://numpy.org/
- https://scipy.org/
- https://pandas.pydata.org/

