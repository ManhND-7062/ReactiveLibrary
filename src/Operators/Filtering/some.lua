local Observable = require('src/observable')

--- Determines whether any item emitted by the source observable satisfies the specified predicate.
-- @arg {function} predicate_fn  - A function to test each emitted value.
-- @return {Observable}
function Observable:some(predicate_fn)
    local source = self
    return Observable.new(function(observer)
        return source:subscribe(
            function(value)
                if predicate_fn(value) then
                    observer:next(true)
                    observer:complete()
                end
            end,
            function(err) observer:error(err) end,
            function()
                observer:next(false)
                observer:complete()
            end
        )
    end)
end