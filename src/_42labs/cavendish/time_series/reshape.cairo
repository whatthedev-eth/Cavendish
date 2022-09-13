%lang starknet

from starkware.cairo.common.alloc import alloc

from _42labs.cavendish.structs import Matrix2D
from _42labs.cavendish.utils import safe_div, modulo

using Matrix2DArray = felt**

func range(start : felt, end_ : felt) -> (arr : felt*):
    let (arr) = alloc()
    let (arr) = _range_iter(start, end_, arr, 0)
    return (arr)
end

func _range_iter(start : felt, end_ : felt, arr : felt*, cur_ix : felt) -> (arr : felt*):
    if cur_ix == end_ - start:
        return (arr)
    end

    assert arr[cur_ix] = start + cur_ix
    return _range_iter(start, end_, arr, cur_ix + 1)
end

func linspace{range_check_ptr}(start : felt, end_ : felt, num_ : felt) -> (arr : felt*):
    alloc_locals
    let (arr) = alloc()
    let (interval) = safe_div(end_ - start, num_)
    let (arr) = _linspace_iter(start, end_, interval, num_, arr, 0)
    return (arr)
end

func _linspace_iter(
    start : felt, end_ : felt, interval : felt, num_ : felt, arr : felt*, cur_ix : felt
) -> (arr : felt*):
    if cur_ix == num_ + 1:
        return (arr)
    end
    assert arr[cur_ix] = start + cur_ix * interval

    return _linspace_iter(start, end_, interval, num_, arr, cur_ix + 1)
end

func reshape(arr_len : felt, arr : felt*, x_dim : felt, y_dim : felt) -> (output_matrix : Matrix2D):
    alloc_locals
    let (output : Matrix2DArray) = alloc()
    let (x_dim_arr) = alloc()
    _reshape_iter(0, 0, arr, x_dim, y_dim, output, x_dim_arr)
    return (Matrix2D(x_dim, y_dim, output))
end

func _reshape_iter(
    cur_x_index : felt,
    cur_y_index : felt,
    arr : felt*,
    x_dim : felt,
    y_dim : felt,
    output : Matrix2DArray,
    x_dim_arr : felt*,
):
    alloc_locals
    if cur_x_index == x_dim:
        return ()
    end
    if cur_y_index == y_dim:
        assert output[cur_x_index] = x_dim_arr
        let (new_x_dim_arr) = alloc()
        return _reshape_iter(cur_x_index + 1, 0, arr, x_dim, y_dim, output, new_x_dim_arr)
    end
    assert x_dim_arr[cur_y_index] = arr[cur_x_index * y_dim + cur_y_index]
    return _reshape_iter(cur_x_index, cur_y_index + 1, arr, x_dim, y_dim, output, x_dim_arr)
end

func transpose(matrix : Matrix2D) -> (output_matrix : Matrix2D):
    alloc_locals
    let (output : Matrix2DArray) = alloc()
    let (x_dim_arr) = alloc()
    _transpose_iter(0, 0, matrix.m, matrix.x_dim, matrix.y_dim, output, x_dim_arr)
    return (Matrix2D(matrix.x_dim, matrix.y_dim, output))
end

func _transpose_iter(
    cur_x_index : felt,
    cur_y_index : felt,
    arr : Matrix2DArray,
    x_dim : felt,
    y_dim : felt,
    output : Matrix2DArray,
    x_dim_arr : felt*,
):
    alloc_locals
    if cur_x_index == y_dim:
        return ()
    end
    if cur_y_index == x_dim:
        assert output[cur_x_index] = x_dim_arr
        let (new_x_dim_arr) = alloc()
        return _transpose_iter(cur_x_index + 1, 0, arr, x_dim, y_dim, output, new_x_dim_arr)
    end
    assert x_dim_arr[cur_y_index] = arr[cur_y_index][cur_x_index]
    return _transpose_iter(cur_x_index, cur_y_index + 1, arr, x_dim, y_dim, output, x_dim_arr)
end

func fill_1d(arr_len, fill_value : felt) -> (arr : felt*):
    alloc_locals
    let (output : felt*) = alloc()
    _fill_1d_iter(0, arr_len, fill_value, output)
    return (output)
end

func _fill_1d_iter(cur_ix : felt, arr_len : felt, fill_value : felt, output : felt*):
    if cur_ix == arr_len:
        return ()
    end
    assert output[cur_ix] = fill_value
    return _fill_1d_iter(cur_ix + 1, arr_len, fill_value, output)
end

func fill_2d(x_dim : felt, y_dim : felt, fill_value : felt) -> (m : Matrix2D):
    alloc_locals
    let (output : Matrix2DArray) = alloc()
    _fill_2d_iter(0, x_dim, y_dim, output, fill_value)
    return (Matrix2D(x_dim, y_dim, output))
end

func _fill_2d_iter(
    cur_x_index : felt, x_dim : felt, y_dim : felt, output : Matrix2DArray, fill_value : felt
):
    alloc_locals
    if cur_x_index == x_dim:
        return ()
    end
    let (x_arr) = fill_1d(y_dim, fill_value)
    assert output[cur_x_index] = x_arr
    return _fill_2d_iter(cur_x_index + 1, x_dim, y_dim, output, fill_value)
end

func identity(n : felt) -> (m : Matrix2D):
    alloc_locals
    let (output : Matrix2DArray) = alloc()
    let (x_dim_arr) = alloc()
    _identity_iter(0, 0, n, output, x_dim_arr)
    return (Matrix2D(n, n, output))
end

func _identity_iter(
    cur_x_index : felt, cur_y_index : felt, dim_ : felt, output : Matrix2DArray, x_dim_arr : felt*
):
    alloc_locals
    if cur_x_index == dim_:
        return ()
    end
    if cur_y_index == dim_:
        assert output[cur_x_index] = x_dim_arr
        let (new_x_dim_arr) = alloc()
        return _identity_iter(cur_x_index + 1, 0, dim_, output, new_x_dim_arr)
    end
    if cur_x_index == cur_y_index:
        assert x_dim_arr[cur_y_index] = 1
    else:
        assert x_dim_arr[cur_y_index] = 0
    end
    return _identity_iter(cur_x_index, cur_y_index + 1, dim_, output, x_dim_arr)
end

func subsample{range_check_ptr}(arr_len : felt, arr : felt*, skip : felt) -> (output : felt*):
    alloc_locals
    # TODO: take size argument?
    with_attr error_message("Invalid skip size"):
        let (_m) = modulo(arr_len, skip)
        assert _m = 0
    end
    let (output) = alloc()
    _subsample_iter(0, arr_len, arr, skip, output)
    return (output)
end

func _subsample_iter{range_check_ptr}(
    cur_idx : felt, arr_len : felt, arr : felt*, skip : felt, output : felt*
):
    if cur_idx == arr_len:
        return ()
    end
    assert output[cur_idx] = arr[cur_idx * skip]
    return _subsample_iter(cur_idx + 1, arr_len, arr, skip, output)
end
