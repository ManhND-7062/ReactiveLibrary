local Observable = require('src/Observable')
local Subscription = require('src/subscription')

--- Delays the emission of items from the source observable by a given timeout.
-- @arg {number} ms - The delay in milliseconds.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @returns {Observable}
function Observable:debounce(ms, scheduler)
    local source = self
    return Observable.new(function(observer)
        local timer_id = nil
        local last_value = nil
        local has_value = false
        
        local source_sub = source:subscribe(
            function(value)
                has_value = true
                last_value = value
                
                if timer_id then
                    scheduler:cancel(timer_id)
                end
                
                timer_id = scheduler:schedule(function()
                    if has_value then
                        observer:next(last_value)
                        has_value = false
                    end
                end, ms)
            end,
            function(err)
                if timer_id then scheduler:cancel(timer_id) end
                observer:error(err)
            end,
            function()
                if timer_id then scheduler:cancel(timer_id) end
                if has_value then
                    observer:next(last_value)
                end
                observer:complete()
            end
        )
        
        return Subscription.new(function()
            if timer_id then scheduler:cancel(timer_id) end
            source_sub:unsubscribe()
        end)
    end)
end