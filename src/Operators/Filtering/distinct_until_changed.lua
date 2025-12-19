local Observable = require('src/observable')

--- Emits values from the source observable only when they are different from the previous value.
-- @arg {function} compare_fn - An optional function to compare the previous and current values.
-- @returns {Observable} An observable that emits only distinct consecutive values.
function Observable:distinct_until_changed( compare_fn)
    compare_fn = compare_fn or function(a, b) return a == b end
    
    return Observable.new(function(observer)
        local has_prev = false
        local prev_value = nil
        
        return self:subscribe(
            function(value)
                if not has_prev or not compare_fn(prev_value, value) then
                    observer:next(value)
                    prev_value = value
                    has_prev = true
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end