

--- @class Scheduler
--- A Scheduler manages the timing of task execution.
local Scheduler = {}
Scheduler.__index = Scheduler

--- Creates a new Scheduler.
-- @returns {Scheduler}
function Scheduler.new()
    local self = setmetatable({}, Scheduler)
    self.tasks = {}
    self.next_id = 1
    self.time = 0
    return self
end

--- Schedules an action to be executed at a specified time.
-- @arg {function} action - The action to schedule.
-- @arg {number} delay - The delay in milliseconds before executing the action.
-- @returns {number}
function Scheduler:schedule(action, delay)
    delay = delay or 0
    local task_id = self.next_id
    self.next_id = self.next_id + 1
    
    self.tasks[task_id] = {
        action = action,
        time = self.time + delay,
        periodic = false
    }
    
    return task_id
end

--- Schedules an action to be executed periodically.
-- @arg {function} action - The action to schedule periodically.
-- @arg {number} period - The period in milliseconds between executions.
-- @returns {number}
function Scheduler:schedule_periodic(action, period)
    local task_id = self.next_id
    self.next_id = self.next_id + 1
    
    self.tasks[task_id] = {
        action = action,
        time = self.time + period,
        period = period,
        periodic = true
    }
    
    return task_id
end

--- Cancels a scheduled task.
-- @arg {number} task_id - The ID of the scheduled task to cancel.
function Scheduler:cancel(task_id)
    self.tasks[task_id] = nil
end

--- Runs all pending tasks that are scheduled to run at or before the current time.
function Scheduler:run_pending()
    local current_tasks = {}
    for id, task in pairs(self.tasks) do
        if task.time <= self.time then
            table.insert(current_tasks, {id = id, task = task})
        end
    end
    local function sort_tasks(a, b) 
        if a.task.time < b.task.time then
            return true
        elseif a.task.time == b.task.time then
            if a.id < b.id then
                return true
            end
        end
        return false
    end
    table.sort(current_tasks, sort_tasks)
    
    for _, item in ipairs(current_tasks) do
        if self.tasks[item.id] then
            item.task.action()
            if item.task.periodic then
                item.task.time = self.time + item.task.period
            else
                self.tasks[item.id] = nil
            end
        end
    end
end

--- Advances the scheduler's time and runs pending tasks.
-- @arg {number} delta - The time in milliseconds to advance the scheduler.
function Scheduler:advance(delta)
    self.time = self.time + delta
    self:run_pending()
end