local Observable = require('src/Observable')
local Subscription = require('src/subscription')


-- Buffers values from the source observable for a specified time span and emits them as an array.
-- @arg {number} ms - The interval in milliseconds.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @returns {Observable}
function Observable:buffer_time(ms, scheduler)
    local source = self
    return Observable.new(function(observer)
        local buffer = {}
        local timer_id
        
        local function emit_buffer()
            if #buffer > 0 then
                observer:next(buffer)
                buffer = {}
            end
        end
        
        timer_id = scheduler:schedule_periodic(function()
            emit_buffer()
        end, ms)
        
        local source_sub = source:subscribe(
            function(value)
                table.insert(buffer, value)
            end,
            function(err)
                scheduler:cancel(timer_id)
                observer:error(err)
            end,
            function()
                scheduler:cancel(timer_id)
                emit_buffer()
                observer:complete()
            end
        )
        
        return Subscription.new(function()
            scheduler:cancel(timer_id)
            source_sub:unsubscribe()
        end)
    end)
end