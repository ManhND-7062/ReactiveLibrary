local Observable = require('src/observable')

--- Emits values from the source observable while the predicate function returns true.
-- @arg {function} predicate_fn - A function to test each emitted value.
-- @arg {boolean} inclusive - If true, includes the first value that causes the predicate to return false.
-- @return {Observable}
function Observable:take_while(predicate_fn, inclusive)
    local source = self
    return Observable.new(function(observer)
        return source:subscribe(
            function(value)
                local should_take = predicate_fn(value)
                if should_take then
                    observer:next(value)
                else
                    if inclusive then
                        observer:next(value)
                    end
                    observer:complete()
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end