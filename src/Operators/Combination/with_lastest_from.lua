local Observable = require('src/Observable')
local Subscription = require('src/subscription')

-- When the source observable emits, emit the latest values from the other observables.
-- @arg {Observable...} observables- A variable number of observables to get latest values from.
-- @return {Observable}
function Observable:with_latest_from(...)
    local source = self
    local others = {...}
    
    return Observable.new(function(observer)
        local other_values = {}
        local other_has_value = {}
        local subscriptions = {}
        
        -- Check if all other sources have emitted
        local function has_all_other_values()
            for i = 1, #others do
                if not other_has_value[i] then
                    return false
                end
            end
            return true
        end
        
        -- Subscribe to other sources (only store their latest values)
        for i, other in ipairs(others) do
            subscriptions[i] = other:subscribe(
                function(value)
                    other_values[i] = value
                    other_has_value[i] = true
                end,
                function(err) observer:error(err) end,
                function() end  -- Don't complete when other sources complete
            )
        end
        
        -- Subscribe to main source
        local main_sub = source:subscribe(
            function(value)
                if has_all_other_values() then
                    local combined = {value}
                    for i = 1, #others do
                        table.insert(combined, other_values[i])
                    end
                    observer:next(combined)
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
        
        table.insert(subscriptions, main_sub)
        
        return Subscription.new(function()
            for _, sub in ipairs(subscriptions) do
                sub:unsubscribe()
            end
        end)
    end)
end
