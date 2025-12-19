local Observable = require('src/observable')
local Subscription = require('src/subscription')

--- Combines multiple observables by emitting an array of the latest values from each source whenever any source emits a new value.
-- @arg {Observable...} sources - A variable number of observables to combine.
-- @returns {Observable}
function Observable:combine_with(...)
    local sources = {self, ...}
    return Observable.new(function(observer)
        local values = {}
        local has_value = {}
        local completed = {}
        local subscriptions = {}
        
        -- Check if all sources have emitted at least once
        local function has_all_values()
            for i = 1, #sources do
                if not has_value[i] then
                    return false
                end
            end
            return true
        end
        
        -- Check if all sources have completed
        local function all_completed()
            for i = 1, #sources do
                if not completed[i] then
                    return false
                end
            end
            return true
        end
        
        -- Emit combined values
        local function emit()
            if has_all_values() then
                local combined_values = {}
                for i = 1, #sources do
                    table.insert(combined_values, values[i])
                end
                observer:next(combined_values)
            end
        end
        
        -- Subscribe to each source
        for i, source in ipairs(sources) do
            subscriptions[i] = source:subscribe(
                function(value)
                    values[i] = value
                    has_value[i] = true
                    emit()
                end,
                function(err)
                    observer:error(err)
                end,
                function()
                    completed[i] = true
                    if all_completed() then
                        observer:complete()
                    end
                end
            )
        end
        
        return Subscription.new(function()
            for _, sub in ipairs(subscriptions) do
                sub:unsubscribe()
            end
        end)
    end)
end