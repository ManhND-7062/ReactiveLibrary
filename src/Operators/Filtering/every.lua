local Observable = require('src/observable')
local Subscription = require('src/subscription')

--- Determines whether all items emitted by the source observable satisfy the specified predicate.
-- @arg {function} predicate_fn - A function to test each emitted value.
-- @returns {Observable}
function Observable:every(predicate_fn)
    local source = self
    return Observable.new(function(observer)
        return source:subscribe(
            function(value)
                if not predicate_fn(value) then
                    observer:next(false)
                    observer:complete()
                end
            end,
            function(err) observer:error(err) end,
            function()
                observer:next(true)
                observer:complete()
            end
        )
    end)
end