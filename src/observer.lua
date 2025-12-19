--- An object that is used to receive notifications from an Observable.
-- @class Observer
local Observer = {}
Observer.__index = Observer

--- Creates a new Observer.
-- @arg {function} on_next - Function to handle next values.
-- @arg {function} on_error - Function to handle errors.
-- @arg {function} on_complete  - Function to handle completion.
-- @returns {Observer}
function Observer.new(on_next, on_error, on_complete)
    local self = setmetatable({}, Observer)
    self.on_next = on_next or function() end
    self.on_error = on_error or function(err) print("Error:", err) end
    self.on_complete = on_complete or function() end
    self.closed = false
    return self
end

--- Sends a next notification to the observer.
-- @arg {*} value - The next value.
function Observer:next(value)
    if not self.closed then
        local success, err = pcall(self.on_next, value)
        if not success then
            self:error(err)
        end
        return 1
    else
        return 0
    end
    
end

--- Sends an error notification to the observer.
-- @arg {*} err - The error value.
function Observer:error(err)
    if not self.closed then
        self.closed = true
        self.on_error(err)
    end
end

--- Sends a complete notification to the observer.
function Observer:complete()
    if not self.closed then
        self.closed = true
        self.on_complete()
    end
end

return Observer