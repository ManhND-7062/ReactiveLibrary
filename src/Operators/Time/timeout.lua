local Observable = require('src/Observable')
local Subscription = require('src/subscription')

--- Emits an error if the source observable does not emit a value within the specified timeout.
-- @arg {number} ms - The timeout in milliseconds.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @returns {Observable}
function Observable:timeout(ms, scheduler)
    local source = self
    return Observable.new(function(observer)
        local timed_out = false
        local timer_id
        
        local function reset_timer()
            if timer_id then
                scheduler:cancel(timer_id)
            end
            timer_id = scheduler:schedule(function()
                if not timed_out then
                    timed_out = true
                    observer:error("Timeout after " .. ms .. "ms")
                end
            end, ms)
        end
        
        reset_timer()
        
        local source_sub = source:subscribe(
            function(value)
                if not timed_out then
                    reset_timer()
                    observer:next(value)
                end
            end,
            function(err)
                if not timed_out then
                    if timer_id then scheduler:cancel(timer_id) end
                    observer:error(err)
                end
            end,
            function()
                if not timed_out then
                    if timer_id then scheduler:cancel(timer_id) end
                    observer:complete()
                end
            end
        )
        
        return Subscription.new(function()
            if timer_id then scheduler:cancel(timer_id) end
            source_sub:unsubscribe()
        end)
    end)
end