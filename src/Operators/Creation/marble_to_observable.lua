local Observable = require('src/observable')
local Subscription = require('src/subscription')

--- Converts a marble diagram string into an observable that emits values according to the diagram.
-- @arg {string} marble_string - The marble diagram string.
-- @arg {Scheduler} scheduler - The scheduler to use for timing the emissions.
-- @arg {number} time_per_char - The time in milliseconds represented by each character in the marble string (default is 10).
-- @returns {Observable} An observable that emits values according to the diagram.
function Observable.marble_to_observable(marble_string, scheduler, time_per_char)
    time_per_char = time_per_char or 10
    
    return Observable.new(function(observer)
        local time = 0
        local tasks = {}
        
        for i = 1, #marble_string do
            local char = marble_string:sub(i, i)
            
            if char == '-' then
                -- Empty frame, do nothing
            elseif char == '|' then
                -- Complete
                table.insert(tasks, scheduler:schedule(function()
                    observer:complete()
                end, time))
            elseif char == '#' then
                -- Error
                table.insert(tasks, scheduler:schedule(function()
                    observer:error("Error at position " .. i)
                end, time))
            elseif char ~= ' ' then
                -- Emit value
                local value = char
                table.insert(tasks, scheduler:schedule(function()
                    observer:next(value)
                end, time))
            end
            
            time = time + time_per_char
        end
        
        return Subscription.new(function()
            for _, task_id in ipairs(tasks) do
                scheduler:cancel(task_id)
            end
        end)
    end)
end