local Observable = require('src/Observable')
local Subscription = require('src/subscription')

-- Creates an observable that emits sequential numbers every specified interval of time.
-- @arg {number} ms - The interval in milliseconds.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @returns {Observable}
function Observable.interval(ms, scheduler)
    return Observable.new(function(observer)
        local count = 0
        local timer_id
        
        local function tick()
            observer:next(count)
            count = count + 1
        end
        
        if scheduler then
            timer_id = scheduler:schedule_periodic(tick, ms)
        else
            -- Fallback: just emit synchronously for demonstration
            tick()
        end
        
        return Subscription.new(function()
            if scheduler and timer_id then
                scheduler:cancel(timer_id)
            end
        end)
    end)
end