local Observable = require('src/observable')

--- Determines whether any item emitted by the source observable satisfies the specified predicate.
-- @arg {function} predicate_fn - A function to test each emitted value.
-- @returns {Observable}
function Observable:find(predicate_fn)
    local source = self
    return Observable.new(function(observer)
        return source:subscribe(
            function(value)
                if predicate_fn(value) then
                    observer:next(value)
                    observer:complete()
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end