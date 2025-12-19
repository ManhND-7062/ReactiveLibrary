local Observable = require('src/observable')

--- Emits values from the source observable while the predicate function returns true.
-- @arg {function} predicate_fn - A function to test each emitted value.
-- @returns {Observable}
function Observable:skip_while(predicate_fn)
    local source = self
    return Observable.new(function(observer)
        local skipping = true
        
        return source:subscribe(
            function(value)
                if skipping then
                    skipping = predicate_fn(value)
                end
                if not skipping then
                    observer:next(value)
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end