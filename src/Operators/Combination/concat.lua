local Observable = require('src/observable')
local Subscription = require('src/subscription')

--- Concatenates multiple observables sequentially.
-- @arg {Observable...} observables - The observables to concatenate.
-- @returns {Observable}
function Observable.concat(...)
    local observables = {...}
    return Observable.new(function(observer)
        local index = 1
        local current_subscription
        
        local function subscribe_next()
            if index > #observables then
                observer:complete()
                return
            end
            
            current_subscription = observables[index]:subscribe(
                function(value) observer:next(value) end,
                function(err) observer:error(err) end,
                function()
                    index = index + 1
                    subscribe_next()
                end
            )
        end
        
        subscribe_next()
        
        return Subscription.new(function()
            if current_subscription then
                current_subscription:unsubscribe()
            end
        end)
    end)
end