local Observable = require('src/observable')
local Subscription = require('src/Subscription')

--- Emits values from the source observable until the notifier observable emits a value.
-- @arg {Observable} notifier - An observable that, when it emits a value, will cause the source observable to complete.
-- @returns {Observable}
function Observable:take_until(notifier)
    local source = self
    return Observable.new(function(observer)
        local source_sub = source:subscribe(
            function(value) observer:next(value) end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
        
        local notifier_sub = notifier:subscribe(
            function(_)
                observer:complete()
                source_sub:unsubscribe()
            end,
            function(err) observer:error(err) end,
            function() end
        )
        
        return Subscription.new(function()
            source_sub:unsubscribe()
            notifier_sub:unsubscribe()
        end)
    end)
end