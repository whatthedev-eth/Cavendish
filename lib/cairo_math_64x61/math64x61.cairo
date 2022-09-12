# https://github.com/influenceth/cairo-math-64x61

from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math_cmp import is_le, is_not_zero
from starkware.cairo.common.pow import pow as pow_int
from starkware.cairo.common.math import (
    assert_le,
    assert_lt,
    sqrt as sqrt_int,
    sign,
    abs_value,
    signed_div_rem,
    unsigned_div_rem,
    assert_not_zero,
)

const INT_PART = 2 ** 64
const FRACT_PART = 2 ** 61
const BOUND = 2 ** 125
const ONE = 1 * FRACT_PART
const E = 6267931151224907085
const PI = 7244019458077122560

namespace FixedPoint:
    func assert64x61{range_check_ptr}(x : felt):
        assert_le(x, BOUND)
        assert_le(-BOUND, x)
        return ()
    end

    # Converts a fixed point value to a felt, truncating the fractional component
    func toFelt{range_check_ptr}(x : felt) -> (res : felt):
        let (res, _) = signed_div_rem(x, FRACT_PART, BOUND)
        return (res)
    end

    # Converts a felt to a fixed point value ensuring it will not overflow
    func fromFelt{range_check_ptr}(x : felt) -> (res : felt):
        assert_le(x, INT_PART)
        assert_le(-INT_PART, x)
        return (x * FRACT_PART)
    end

    # Converts a fixed point 64.61 value to a uint256 value
    func toUint256(x : felt) -> (res : Uint256):
        let res = Uint256(low=x, high=0)
        return (res)
    end

    # Converts a uint256 value into a fixed point 64.61 value ensuring it will not overflow
    func fromUint256{range_check_ptr}(x : Uint256) -> (res : felt):
        assert x.high = 0
        let (res) = fromFelt(x.low)
        return (res)
    end

    # Calculates the floor of a 64.61 value
    func floor{range_check_ptr}(x : felt) -> (res : felt):
        let (int_val, mod_val) = signed_div_rem(x, ONE, BOUND)
        let res = x - mod_val
        assert64x61(res)
        return (res)
    end

    # Calculates the ceiling of a 64.61 value
    func ceil{range_check_ptr}(x : felt) -> (res : felt):
        let (int_val, mod_val) = signed_div_rem(x, ONE, BOUND)
        let res = (int_val + 1) * ONE
        assert64x61(res)
        return (res)
    end

    # Returns the minimum of two values
    func min{range_check_ptr}(x : felt, y : felt) -> (res : felt):
        let (x_le) = is_le(x, y)

        if x_le == 1:
            return (x)
        else:
            return (y)
        end
    end

    # Returns the maximum of two values
    func max{range_check_ptr}(x : felt, y : felt) -> (res : felt):
        let (x_le) = is_le(x, y)

        if x_le == 1:
            return (y)
        else:
            return (x)
        end
    end

    # Convenience addition method to assert no overflow before returning
    func add{range_check_ptr}(x : felt, y : felt) -> (res : felt):
        let res = x + y
        assert64x61(res)
        return (res)
    end

    # Convenience subtraction method to assert no overflow before returning
    func sub{range_check_ptr}(x : felt, y : felt) -> (res : felt):
        let res = x - y
        assert64x61(res)
        return (res)
    end

    # Multiples two fixed point values and checks for overflow before returning
    func mul{range_check_ptr}(x : felt, y : felt) -> (res : felt):
        tempvar product = x * y
        let (res, _) = signed_div_rem(product, FRACT_PART, BOUND)
        assert64x61(res)
        return (res)
    end

    # Divides two fixed point values and checks for overflow before returning
    # Both values may be signed (i.e. also allows for division by negative b)
    func div{range_check_ptr}(x : felt, y : felt) -> (res : felt):
        alloc_locals
        let (div) = abs_value(y)
        let (div_sign) = sign(y)
        tempvar product = x * FRACT_PART
        let (res_u, _) = signed_div_rem(product, div, BOUND)
        assert64x61(res_u)
        return (res=res_u * div_sign)
    end

    # Calclates the value of x^y and checks for overflow before returning
    # x is a 64x61 fixed point value
    # y is a 64x61 fixed point value
    func pow{range_check_ptr}(x : felt, y : felt) -> (res : felt):
        alloc_locals
        let (y_int, y_frac) = signed_div_rem(y, ONE, BOUND)

        # use the more performant integer pow when y is an int
        if y_frac == 0:
            return _pow_int(x, y_int)
        end

        # x^y = exp(y*ln(x)) for x > 0 (will error for x < 0
        let (ln_x) = ln(x)
        let (y_ln_x) = mul(y, ln_x)
        let (res) = exp(y_ln_x)
        return (res)
        # assert64x61(res)
        # return (res)
    end

    # Calculates the square root of a fixed point value
    # x must be positive
    func sqrt{range_check_ptr}(x : felt) -> (res : felt):
        alloc_locals
        let (root) = sqrt_int(x)
        let (scale_root) = sqrt_int(FRACT_PART)
        let (res, _) = signed_div_rem(root * FRACT_PART, scale_root, BOUND)
        assert64x61(res)
        return (res)
    end

    # Calculates the binary exponent of x: 2^x
    func exp2{range_check_ptr}(x : felt) -> (res : felt):
        alloc_locals

        let (exp_sign) = sign(x)

        if exp_sign == 0:
            return (ONE)
        end

        let (exp_value) = abs_value(x)
        let (int_part, frac_part) = unsigned_div_rem(exp_value, FRACT_PART)
        let (int_res) = _pow_int(2 * ONE, int_part)

        # 1.069e-7 maximum error
        const a1 = 2305842762765193127
        const a2 = 1598306039479152907
        const a3 = 553724477747739017
        const a4 = 128818789015678071
        const a5 = 20620759886412153
        const a6 = 4372943086487302

        let (r6) = mul(a6, frac_part)
        let (r5) = mul(r6 + a5, frac_part)
        let (r4) = mul(r5 + a4, frac_part)
        let (r3) = mul(r4 + a3, frac_part)
        let (r2) = mul(r3 + a2, frac_part)
        tempvar frac_res = r2 + a1

        let (res_u) = mul(int_res, frac_res)

        if exp_sign == -1:
            let (res_i) = div(ONE, res_u)
            assert64x61(res_i)
            return (res_i)
        else:
            assert64x61(res_u)
            return (res_u)
        end
    end

    # Calculates the natural exponent of x: e^x
    func exp{range_check_ptr}(x : felt) -> (res : felt):
        const mod = 3326628274461080623
        let (bin_exp) = mul(x, mod)
        let (res) = exp2(bin_exp)
        return (res)
    end

    # Calculates the binary logarithm of x: log2(x)
    # x must be greather than zero
    func log2{range_check_ptr}(x : felt) -> (res : felt):
        alloc_locals

        if x == ONE:
            return (0)
        end

        let (is_frac) = is_le(x, FRACT_PART - 1)

        # Compute negative inverse binary log if 0 < x < 1
        if is_frac == 1:
            let (div_x) = div(ONE, x)
            let (res_i) = log2(div_x)
            return (-res_i)
        end

        let (x_over_two, _) = unsigned_div_rem(x, 2)
        let (b) = _msb(x_over_two)
        let (divisor) = pow_int(2, b)
        let (norm, _) = unsigned_div_rem(x, divisor)

        # 4.233e-8 maximum error
        const a1 = -7898418853509069178
        const a2 = 18803698872658890801
        const a3 = -23074885139408336243
        const a4 = 21412023763986120774
        const a5 = -13866034373723777071
        const a6 = 6084599848616517800
        const a7 = -1725595270316167421
        const a8 = 285568853383421422
        const a9 = -20957604075893688

        let (r9) = mul(a9, norm)
        let (r8) = mul(r9 + a8, norm)
        let (r7) = mul(r8 + a7, norm)
        let (r6) = mul(r7 + a6, norm)
        let (r5) = mul(r6 + a5, norm)
        let (r4) = mul(r5 + a4, norm)
        let (r3) = mul(r4 + a3, norm)
        let (r2) = mul(r3 + a2, norm)
        local norm_res = r2 + a1

        let (int_part) = fromFelt(b)
        local res = int_part + norm_res
        assert64x61(res)
        return (res)
    end

    # Calculates the natural logarithm of x: ln(x)
    # x must be greater than zero
    func ln{range_check_ptr}(x : felt) -> (res : felt):
        const ln_2 = 1598288580650331957
        let (log2_x) = log2(x)
        let (product) = mul(log2_x, ln_2)
        return (product)
    end

    # Calculates the base 10 log of x: log10(x)
    # x must be greater than zero
    func log10{range_check_ptr}(x : felt) -> (res : felt):
        const log10_2 = 694127911065419642
        let (log10_x) = log2(x)
        let (product) = mul(log10_x, log10_2)
        return (product)
    end

    # Calclates the value of x^y and checks for overflow before returning
    # x is a 64x61 fixed point value
    # y is a standard felt (int)
    func _pow_int{range_check_ptr}(x : felt, y : felt) -> (res : felt):
        alloc_locals
        let (exp_sign) = sign(y)
        let (exp_val) = abs_value(y)

        if exp_sign == 0:
            return (ONE)
        end

        if exp_sign == -1:
            let (num) = _pow_int(x, exp_val)
            return div(ONE, num)
        end

        let (half_exp, rem) = unsigned_div_rem(exp_val, 2)
        let (half_pow) = _pow_int(x, half_exp)
        let (res_p) = mul(half_pow, half_pow)

        if rem == 0:
            assert64x61(res_p)
            return (res_p)
        else:
            let (res) = mul(res_p, x)
            assert64x61(res)
            return (res)
        end
    end

    # Calculates the most significant bit where x is a fixed point value
    func _msb{range_check_ptr}(x : felt) -> (res : felt):
        alloc_locals

        let (cmp) = is_le(x, FRACT_PART)

        if cmp == 1:
            return (0)
        end

        let (div, _) = unsigned_div_rem(x, 2)
        let (rest) = _msb(div)
        local res = 1 + rest
        assert64x61(res)
        return (res)
    end
end
