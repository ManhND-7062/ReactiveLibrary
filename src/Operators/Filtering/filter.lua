local Observable = require('src/Observable')

-- Emits only those values that pass the predicate function test.
-- @arg {function} predicate_fn - A function to test each emitted value.
-- @returns {Observable}
function Observable:filter(predicate_fn)
    local source = self
    return Observable.new(function(observer)
        return source:subscribe(
            function(value)
                local success, result = pcall(predicate_fn, value)
                if success and result then
                    observer:next(value)
                elseif not success then
                    observer:error(result)
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end