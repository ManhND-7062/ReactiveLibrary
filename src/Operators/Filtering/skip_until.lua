local Observable = require('src/observable')
local Subscription = require('src/Subscription')

--- Emits values from the source observable only after the notifier observable emits a value.
-- @arg {Observable} notifier - An observable that, when it emits a value, will cause the source observable to start emitting values.
-- @returns {Observable}
function Observable:skip_until(notifier)
    local source = self
    return Observable.new(function(observer)
        local skipping = true
        
        local notifier_sub
        notifier_sub = notifier:subscribe(
            function(_)
                skipping = false
                notifier_sub:unsubscribe()
            end,
            function(err) observer:error(err) end,
            function() end
        )
        
        local source_sub = source:subscribe(
            function(value)
                if not skipping then
                    observer:next(value)
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
        
        return Subscription.new(function()
            source_sub:unsubscribe()
            notifier_sub:unsubscribe()
        end)
    end)
end