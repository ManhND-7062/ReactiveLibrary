local Scheduler = require('src/scheduler')

local Utils = {}

--- Advances the scheduler by a specified duration, processing all scheduled tasks.
-- @arg {Scheduler} scheduler - The scheduler to advance.
-- @arg {number} duration - The total time to advance the scheduler.
-- @arg {number} step - The time step for each advancement (default is 1).
function Utils.run_scheduler(scheduler, duration, step)
    step = step or 1
    local elapsed = 0
    
    while elapsed < duration do
        scheduler:advance(step)
        elapsed = elapsed + step
    end
end

--- Runs the scheduler until a specified condition is met or a maximum time is reached.
-- @arg {Scheduler} scheduler - The scheduler to run.
-- @arg {function} condition - A function that returns true when the desired condition is met.
-- @arg {number} max_time - The maximum time to run the scheduler (default is infinity).
-- @arg {number} step - The time step for each advancement (default is 1).
-- @returns {number} The total time the scheduler was run.
function Utils.run_scheduler_until(scheduler, condition, max_time, step)
    step = step or 1
    max_time = max_time or math.huge
    local elapsed = 0
    
    while not condition() and elapsed < max_time do
        scheduler:advance(step)
        elapsed = elapsed + step
    end
    
    return elapsed
end

--- Advances the scheduler by a single step.
-- @arg {Scheduler} scheduler - The scheduler to advance.
-- @arg {number} time - The time to advance the scheduler (default is 1).
function Utils.run_scheduler_once(scheduler, time)
    scheduler:advance(time or 1)
end

return Utils