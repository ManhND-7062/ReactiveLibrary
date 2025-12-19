local Observable = require('src/Observable')
local Subscription = require('src/subscription')

--- Emits the most recent value from the source observable at periodic time intervals.
-- @arg {number} ms - The interval in milliseconds.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @return {Observable}
function Observable:sample(ms, scheduler)
    local source = self
    return Observable.new(function(observer)
        local last_value = nil
        local has_value = false
        local timer_id
        
        timer_id = scheduler:schedule_periodic(function()
            if has_value then
                observer:next(last_value)
                has_value = false
            end
        end, ms)
        
        local source_sub = source:subscribe(
            function(value)
                last_value = value
                has_value = true
            end,
            function(err)
                scheduler:cancel(timer_id)
                observer:error(err)
            end,
            function()
                scheduler:cancel(timer_id)
                observer:complete()
            end
        )
        
        return Subscription.new(function()
            scheduler:cancel(timer_id)
            source_sub:unsubscribe()
        end)
    end)
end