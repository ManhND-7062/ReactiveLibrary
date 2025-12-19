local Observable = require('src/observable')

--- Combines multiple observables by emitting arrays of their latest values.
-- @arg {Observable...} observables - The observables to combine.
-- @return {Observable}
function Observable.zip(...)
    local observables = {...}
    return Observable.new(function(observer)
        local buffers = {}
        local completed = {}
        local subscriptions = {}
        
        for i = 1, #observables do
            buffers[i] = {}
            completed[i] = false
        end
        
        local function try_emit()
            -- Check if all buffers have at least one value
            local can_emit = true
            for i = 1, #observables do
                if #buffers[i] == 0 then
                    can_emit = false
                    break
                end
            end
            
            if can_emit then
                local values = {}
                for i = 1, #observables do
                    table.insert(values, table.remove(buffers[i], 1))
                end
                observer:next(values)
            end
            
            -- Check if any stream completed with empty buffer
            for i = 1, #observables do
                if completed[i] and #buffers[i] == 0 then
                    observer:complete()
                    return
                end
            end
        end
        
        for i, obs in ipairs(observables) do
            subscriptions[i] = obs:subscribe(
                function(value)
                    table.insert(buffers[i], value)
                    try_emit()
                end,
                function(err) observer:error(err) end,
                function()
                    completed[i] = true
                    try_emit()
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