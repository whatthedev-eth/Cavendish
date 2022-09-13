%lang starknet

from starkware.cairo.common.alloc import alloc

from _42labs.cavendish.structs import Matrix2D, PAIRWISE_OPERATION
from _42labs.cavendish.utils import safe_div

using ENUM = felt

func pairwise_1D{range_check_ptr}(operation : ENUM, x_len : felt, x : felt*, y : felt*) -> (
    _result : felt*
):
    alloc_locals
    let (output : felt*) = alloc()
    _pairwise_1D_iter(operation, 0, x_len, x, y, output)
    return (output)
end

func _pairwise_1D_iter{range_check_ptr}(
    operation : ENUM, cur_ix : felt, x_len : felt, x : felt*, y : felt*, output : felt*
):
    alloc_locals
    if cur_ix == x_len:
        return ()
    end
    let x1 = x[cur_ix]
    let y1 = y[cur_ix]
    if operation == PAIRWISE_OPERATION.MULTIPLICATION:
        jmp multiplication
    end
    if operation == PAIRWISE_OPERATION.DIVISION:
        jmp division
    end
    if operation == PAIRWISE_OPERATION.SUBTRACTION:
        jmp subtraction
    end
    assert output[cur_ix] = x1 + y1
    tempvar range_check_ptr = range_check_ptr
    return _pairwise_1D_iter(operation, cur_ix + 1, x_len, x, y, output)

    multiplication:
    assert output[cur_ix] = x1 * y1
    tempvar range_check_ptr = range_check_ptr
    return _pairwise_1D_iter(operation, cur_ix + 1, x_len, x, y, output)

    division:
    let (quotient) = safe_div(x1, y1)
    assert output[cur_ix] = quotient
    tempvar range_check_ptr = range_check_ptr
    return _pairwise_1D_iter(operation, cur_ix + 1, x_len, x, y, output)

    subtraction:
    assert output[cur_ix] = x1 - y1
    tempvar range_check_ptr = range_check_ptr
    return _pairwise_1D_iter(operation, cur_ix + 1, x_len, x, y, output)
end

func dot_product(x_len : felt, x : felt*, y : felt*) -> (_product : felt):
    return _dot_product_iter(0, 0, x_len, x, y)
end

func _dot_product_iter(total : felt, cur_ix : felt, x_len : felt, x : felt*, y : felt*) -> (
    _product : felt
):
    if cur_ix == x_len:
        return (total)
    end
    let tmp1 = x[cur_ix]
    let tmp2 = y[cur_ix]
    return _dot_product_iter(total + x[cur_ix] * y[cur_ix], cur_ix + 1, x_len, x, y)
end

func matrix_vector_mult(matrix : Matrix2D, arr_len : felt, arr : felt*) -> (
    vector_len : felt, vector : felt*
):
    alloc_locals
    assert matrix.y_dim = arr_len
    let (output) = alloc()
    _matrix_vector_mult_iter(0, matrix, arr, output)
    return (matrix.y_dim, output)
end

func _matrix_vector_mult_iter(idx : felt, matrix : Matrix2D, arr : felt*, output : felt*):
    if idx == matrix.x_dim:
        return ()
    end
    let (_prod) = dot_product(matrix.y_dim, matrix.m[idx], arr)
    assert output[idx] = _prod
    return _matrix_vector_mult_iter(idx + 1, matrix, arr, output)
end

func vector_matrix_mult(arr_len : felt, arr : felt*, matrix : Matrix2D) -> (
    vector_len : felt, vector : felt*
):
    alloc_locals
    assert matrix.x_dim = arr_len
    let (output) = alloc()
    _vector_matrix_mult_iter(0, arr, matrix, output)
    return (matrix.y_dim, output)
end

func _vector_matrix_mult_iter(idx : felt, arr : felt*, matrix : Matrix2D, output : felt*) -> ():
    if idx == matrix.y_dim:
        return ()
    end
    let (_vec) = get_vec_by_index(idx, matrix)
    let (_prod) = dot_product(matrix.x_dim, arr, _vec)
    assert output[idx] = _prod
    return _vector_matrix_mult_iter(idx + 1, arr, matrix, output)
end

func get_vec_by_index(idx : felt, matrix : Matrix2D) -> (vec_ : felt*):
    alloc_locals
    let (output : felt*) = alloc()
    _get_vec_by_index_iter(0, idx, output, matrix)
    return (output)
end

func _get_vec_by_index_iter(idx : felt, j : felt, output : felt*, matrix : Matrix2D):
    if idx == matrix.x_dim:
        return ()
    end
    assert output[idx] = matrix.m[idx][j]
    return _get_vec_by_index_iter(idx + 1, j, output, matrix)
end

func matrix_mult(matrix : Matrix2D, r_matrix : Matrix2D) -> (_m : Matrix2D):
    alloc_locals
    assert matrix.y_dim = r_matrix.x_dim
    let (output : felt**) = alloc()
    _matrix_mult_iter(0, matrix, r_matrix, output)
    return (Matrix2D(matrix.x_dim, r_matrix.y_dim, output))
end

func _matrix_mult_iter(idx : felt, matrix : Matrix2D, r_matrix : Matrix2D, output : felt**):
    if idx == r_matrix.y_dim:
        return ()
    end
    let _vec = matrix.m[idx]

    let (_, _vec) = vector_matrix_mult(matrix.y_dim, _vec, r_matrix)

    assert output[idx] = _vec

    return _matrix_mult_iter(idx + 1, matrix, r_matrix, output)
end
