local Observable = require('src/Observable')
local Subscription = require('src/subscription')

--- Emits the most recent value from the source observable within periodic time intervals.
-- @arg {number} ms - The delay in milliseconds.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @returns {Observable}
function Observable:audit(ms, scheduler)
    local source = self
    return Observable.new(function(observer)
        local timer_id = nil
        local last_value = nil
        local has_value = false
        
        local source_sub = source:subscribe(
            function(value)
                last_value = value
                
                if not has_value then
                    has_value = true
                    timer_id = scheduler:schedule(function()
                        if has_value then
                            observer:next(last_value)
                            has_value = false
                        end
                    end, ms)
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