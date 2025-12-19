local Observable = require('src/Observable')
local Subscription = require('src/subscription')


-- Emits a value from the source observable, then ignores subsequent source values for the specified duration. Can emit on the leading and/or trailing edge of the timeout.
-- @arg {number} ms - The timeout in milliseconds.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @arg {table} config - Configuration table with `leading` and `trailing` boolean options.
-- @returns {Observable}
function Observable:throttle(ms, scheduler, config)
    local source = self
    config = config or {}
    local leading = config.leading ~= false  -- default true
    local trailing = config.trailing ~= false  -- default true
    
    return Observable.new(function(observer)
        local throttled = false
        local timer_id = nil
        local last_value = nil
        local has_trailing_value = false
        
        local source_sub = source:subscribe(
            function(value)
                if not throttled then
                    -- Leading edge
                    if leading then
                        observer:next(value)
                    end
                    
                    throttled = true
                    has_trailing_value = false
                    
                    timer_id = scheduler:schedule(function()
                        throttled = false
                        
                        -- Trailing edge
                        if trailing and has_trailing_value then
                            observer:next(last_value)
                            has_trailing_value = false
                        end
                    end, ms)
                else
                    -- Store for trailing edge
                    last_value = value
                    has_trailing_value = true
                end
            end,
            function(err)
                if timer_id then scheduler:cancel(timer_id) end
                observer:error(err)
            end,
            function()
                if timer_id then scheduler:cancel(timer_id) end
                observer:complete()
            end
        )
        
        return Subscription.new(function()
            if timer_id then scheduler:cancel(timer_id) end
            source_sub:unsubscribe()
        end)
    end)
end