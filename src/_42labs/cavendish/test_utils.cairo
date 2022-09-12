%lang starknet

func log_array(arr_len : felt, arr : felt*):
    %{ print('Array(', end='') %}
    _log_array_iter(0, arr_len, arr)
    return ()
end

func _log_array_iter(cur_idx, arr_len : felt, arr : felt*):
    let tmp = arr[cur_idx]
    if cur_idx == arr_len - 1:
        %{
            if ids.tmp > 361850278866613121369732278309507010562310721533:
                print(3618502788666131213697322783095070105623107215331596699973092056135872020481 - ids.tmp, end='')
                print(')')
            else:
                print(ids.tmp, end='')
                print(')')
        %}
        return ()
    else:
        %{
            if ids.tmp >= 361850278866613121369732278309507010562310721533:
                print(f'-{3618502788666131213697322783095070105623107215331596699973092056135872020481 - ids.tmp}', end=', ')
            else:
                print(ids.tmp, end=', ')
        %}
        return _log_array_iter(cur_idx + 1, arr_len, arr)
    end
end
