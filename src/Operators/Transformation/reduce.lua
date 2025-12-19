local Observable = require('src/Observable')

--- Applies an accumulator function to each emitted value.
-- @arg {function} accumulator_fn - A function to accumulate values.
-- @arg {*} seed - The initial value for the accumulator.
-- @returns {Observable}
function Observable:reduce(accumulator_fn, seed)
    local source = self
    return Observable.new(function(observer)
        local acc = seed
        return source:subscribe(
            function(value)
                local success, result = pcall(accumulator_fn, acc, value)
                if success then
                    acc = result
                else
                    observer:error(result)
                end
            end,
            function(err) observer:error(err) end,
            function()
                observer:next(acc)
                observer:complete()
            end
        )
    end)
end