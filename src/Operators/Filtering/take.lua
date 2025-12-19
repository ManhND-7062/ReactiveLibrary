local Observable = require('src/Observable')

--- Emits only the first `count` values from the source observable.
-- @arg {number} count - The number of values to take.
-- @returns {Observable}
function Observable:take(count)
    local source = self
    return Observable.new(function(observer)
        local taken = 0
        local subscription
        
        subscription = source:subscribe(
            function(value)
                if taken < count then
                    observer:next(value)
                    taken = taken + 1
                    if taken >= count then
                        observer:complete()
                        subscription:unsubscribe()
                    end
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
        
        return subscription
    end)
end