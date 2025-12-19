local Observable = require('src/Observable')

-- Accumulates values from the source observable using an accumulator function.
-- @arg {function} accumulator_fn - A function that takes the accumulated value and the current value, and returns the new accumulated value.
-- @arg {*} seed  - An optional initial value for the accumulator.
-- @returns {Observable}
function Observable:scan(accumulator_fn, seed)
    return Observable.new(function(observer)
        local acc = seed
        local has_seed = seed ~= nil
        
        return self:subscribe(
            function(value)
                if has_seed then
                    acc = accumulator_fn(acc, value)
                else
                    acc = value
                    has_seed = true
                end
                observer:next(acc)
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end