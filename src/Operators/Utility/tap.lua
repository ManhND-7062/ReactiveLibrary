local Observable = require('src/Observable')

--- Invokes a side-effect function for each value emitted by the source observable.
-- @arg {function} side_effect_fn - A function to invoke for each emitted value.
-- @returns {Observable}
function Observable:tap(side_effect_fn)
    return Observable.new(function(observer)
        return self:subscribe(
            function(value)
                pcall(side_effect_fn, value)
                observer:next(value)
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end