%lang starknet
# https://github.com/influenceth/cairo-math-64x61

from cairo_math_64x61.math64x61 import FixedPoint

@view
func math64x61_floor_test{range_check_ptr}(x : felt) -> (res : felt):
    let (res) = FixedPoint.floor(x)
    return (res)
end

@view
func math64x61_ceil_test{range_check_ptr}(x : felt) -> (res : felt):
    let (res) = FixedPoint.ceil(x)
    return (res)
end

@view
func math64x61_min_test{range_check_ptr}(x : felt, y : felt) -> (res : felt):
    let (res) = FixedPoint.min(x, y)
    return (res)
end

@view
func math64x61_max_test{range_check_ptr}(x : felt, y : felt) -> (res : felt):
    let (res) = FixedPoint.max(x, y)
    return (res)
end

@view
func math64x61_mul_test{range_check_ptr}(x : felt, y : felt) -> (res : felt):
    let (res) = FixedPoint.mul(x, y)
    return (res)
end

@view
func math64x61_div_test{range_check_ptr}(x : felt, y : felt) -> (res : felt):
    let (res) = FixedPoint.div(x, y)
    return (res)
end

@view
func math64x61_pow_test{range_check_ptr}(x : felt, y : felt) -> (res : felt):
    let (res) = FixedPoint.pow(x, y)
    return (res)
end

@view
func math64x61_sqrt_test{range_check_ptr}(x : felt) -> (res : felt):
    let (res) = FixedPoint.sqrt(x)
    return (res)
end

@view
func math64x61_exp2_test{range_check_ptr}(x : felt) -> (res : felt):
    let (res) = FixedPoint.exp2(x)
    return (res)
end

# Calculates the natural exponent of x: e^x
@view
func math64x61_exp_test{range_check_ptr}(x : felt) -> (res : felt):
    let (res) = FixedPoint.exp(x)
    return (res)
end

@view
func math64x61_log2_test{range_check_ptr}(x : felt) -> (res : felt):
    let (res) = FixedPoint.log2(x)
    return (res)
end

@view
func math64x61_ln_test{range_check_ptr}(x : felt) -> (res : felt):
    let (res) = FixedPoint.ln(x)
    return (res)
end

@view
func math64x61_log10_test{range_check_ptr}(x : felt) -> (res : felt):
    let (res) = FixedPoint.log10(x)
    return (res)
end
