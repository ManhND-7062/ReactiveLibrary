local Observable = require('src/observable')

--- Finds the index of the first item emitted by the source observable that satisfies the specified predicate.
-- @arg {function} predicate_fn - A function to test each emitted value.
-- @returns {Observable}
function Observable:find_index(predicate_fn)
    local source = self
    return Observable.new(function(observer)
        local index = 0
        return source:subscribe(
            function(value)
                if predicate_fn(value) then
                    observer:next(index)
                    observer:complete()
                else
                    index = index + 1
                end
            end,
            function(err) observer:error(err) end,
            function()
                observer:next(-1)
                observer:complete()
            end
        )
    end)
end