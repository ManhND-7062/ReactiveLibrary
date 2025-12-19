local Observable = require('src/observable')
local Subscription = require('src/subscription')

--- Retries the source observable a specified number of times if it errors.
-- @arg {number} count - The number of retry attempts. Defaults to infinite retries.
-- @returns {Observable} An observable that retries the source observable if it errors.
function Observable:retry(count)
    count = count or math.huge
    
    return Observable.new(function(observer)
        local attempts = 0
        local current_subscription
        
        local function attempt()
            attempts = attempts + 1
            current_subscription = self:subscribe(
                function(value) observer:next(value) end,
                function(err)
                    if attempts < count then
                        attempt()
                    else
                        observer:error(err)
                    end
                end,
                function() observer:complete() end
            )
        end
        
        attempt()
        
        return Subscription.new(function()
            if current_subscription then
                current_subscription:unsubscribe()
            end
        end)
    end)
end