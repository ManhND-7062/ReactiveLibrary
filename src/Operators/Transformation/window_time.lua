local Observable = require('src/Observable')
local Subscription = require('src/subscription')
local Subject = require('src/Subject')


--- Splits the source observable into windows (sub-observables) based on a time span.
-- @arg {number} ms - The interval in milliseconds.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @return {Observable}
function Observable:window_time(ms, scheduler)
    local source = self
    return Observable.new(function(observer)
        local current_window = Subject.new()
        observer:next(current_window:as_observable())
        
        local timer_id = scheduler:schedule_periodic(function()
            current_window:complete()
            current_window = Subject.new()
            observer:next(current_window:as_observable())
        end, ms)
        
        local source_sub = source:subscribe(
            function(value)
                current_window:next(value)
            end,
            function(err)
                scheduler:cancel(timer_id)
                current_window:error(err)
                observer:error(err)
            end,
            function()
                scheduler:cancel(timer_id)
                current_window:complete()
                observer:complete()
            end
        )
        
        return Subscription.new(function()
            scheduler:cancel(timer_id)
            current_window:complete()
            source_sub:unsubscribe()
        end)
    end)
end