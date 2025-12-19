local Observable = require('src/observable')

--- Prepends initial values to the source observable.
-- @arg {*...} values - The initial values to prepend.
-- @returns {Observable} An observable that emits the initial values followed by the source values.
function Observable:start_with(...)
    local initial_values = {...}
    return Observable.new(function(observer)
        for _, value in ipairs(initial_values) do
            observer:next(value)
        end
        
        return self:subscribe(
            function(value) observer:next(value) end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end