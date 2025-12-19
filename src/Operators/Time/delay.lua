local Observable = require('src/Observable')
local Subscription = require('src/subscription')


--- Delays the emission of items from the source observable by a given timeout.
-- @arg {number} ms - The delay in milliseconds.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @returns {Observable}
function Observable:delay(ms, scheduler)
    local source = self
    return Observable.new(function(observer)
        local queue = {}
        local source_completed = false
        
        local source_sub = source:subscribe(
            function(value)
                local task_id = scheduler:schedule(function()
                    observer:next(value)
                end, ms)
                table.insert(queue, task_id)
            end,
            function(err)
                scheduler:schedule(function()
                    observer:error(err)
                end, ms)
            end,
            function()
                source_completed = true
                scheduler:schedule(function()
                    if source_completed then
                        observer:complete()
                    end
                end, ms)
            end
        )
        
        return Subscription.new(function()
            source_sub:unsubscribe()
            for _, task_id in ipairs(queue) do
                scheduler:cancel(task_id)
            end
        end)
    end)
end