%lang starknet

from _42labs.cavendish.prelude import (
    Matrix2D,
    PAIRWISE_OPERATION,
    range,
    reshape,
    matrix_vector_mult,
    matrix_mult,
    vector_matrix_mult,
    get_vec_by_index,
    log_array,
    log_matrix,
)

@view
func test_docs_example():
    alloc_locals
    let arr_len = 15

    let (r) = range(0, 15)
    let (matrix_) = reshape(arr_len, r, 3, 5)

    let (arr) = range(10, 25)
    let (r_matrix) = reshape(arr_len, arr, 5, 3)

    let (output_len, output) = vector_matrix_mult(5, arr, r_matrix)
    log_array(output_len, output)

    let (output_matrix) = matrix_mult(matrix_, r_matrix)

    log_matrix(output_matrix)
    return()
end
