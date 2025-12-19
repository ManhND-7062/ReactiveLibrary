local Observable = require('src/observable')
local Subscription = require('src/subscription')

--- Invokes a callback function when the observable terminates (completes, errors, or is unsubscribed).
-- @arg {function} callback - A function to invoke on termination.
-- @returns {Observable} An observable that invokes the callback on termination.
function Observable:finalize(callback)
    return Observable.new(function(observer)
        local subscription = self:subscribe(
            function(value) observer:next(value) end,
            function(err)
                pcall(callback)
                observer:error(err)
            end,
            function()
                pcall(callback)
                observer:complete()
            end
        )
        
        local original_unsub = subscription.unsubscribe_fn
        subscription.unsubscribe_fn = function()
            pcall(callback)
            if original_unsub then original_unsub() end
        end
        
        return subscription
    end)
end