local Observable = require('src/Observable')
local Subscription = require('src/subscription')


--- Creates an observable that emits sequential numbers after an initial delay and optionally at a specified period.
-- @arg {number} due_time - The initial delay in milliseconds.
-- @arg {number|nil} period - The period in milliseconds for subsequent emissions. If nil, emits only once after due_time.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @returns {Observable}
function Observable.timer(due_time, period, scheduler)
    return Observable.new(function(observer)
        local count = 0
        local timer_id
        
        if period then
            -- Emit after due_time, then periodically
            timer_id = scheduler:schedule(function()
                observer:next(count)
                count = count + 1
                
                timer_id = scheduler:schedule_periodic(function()
                    observer:next(count)
                    count = count + 1
                end, period)
            end, due_time)
        else
            -- Emit once after due_time and complete
            timer_id = scheduler:schedule(function()
                observer:next(0)
                observer:complete()
            end, due_time)
        end
        
        return Subscription.new(function()
            if timer_id then
                scheduler:cancel(timer_id)
            end
        end)
    end)
end