local Observable = require('src/observable')
local Subscription = require('src/subscription')

--- Catches errors from the source observable and switches to a fallback observable.
-- @arg {function} selector_fn - A function that takes an error and returns a new observable.
-- @returns {Observable} An observable that switches to the fallback observable on error.
function Observable:catch_error(selector_fn)
    return Observable.new(function(observer)
        return self:subscribe(
            function(value) observer:next(value) end,
            function(err)
                local fallback = selector_fn(err)
                fallback:subscribe(
                    function(value) observer:next(value) end,
                    function(err2) observer:error(err2) end,
                    function() observer:complete() end
                )
            end,
            function() observer:complete() end
        )
    end)
end