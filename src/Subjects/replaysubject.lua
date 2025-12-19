local Subject = require("src/Subjects/subject")

--- @class ReplaySubject
--- A ReplaySubject is a type of Subject that records multiple values and replays them to new subscribers.
local ReplaySubject = {}
ReplaySubject.__index = ReplaySubject
setmetatable(ReplaySubject, {__index = Subject})

--- Creates a new ReplaySubject with the specified buffer size and window time.
-- @arg {number} buffer_size - The maximum number of values to store in the buffer.
-- @arg {number} window_time - The maximum age of values to store in the buffer (in seconds).
-- @return {ReplaySubject}
function ReplaySubject.new(buffer_size, window_time)

    local self = setmetatable(Subject.new(), ReplaySubject)
    self.buffer_size = buffer_size or math.huge
    self.window_time = window_time
    self.buffer = {}
    self.timestamps = {}

    return self
end

--- Trims the buffer based on buffer_size and window_time.
function ReplaySubject:_trim_buffer()
    local current_time = os.time()
    
    -- Remove old values based on window_time
    if self.window_time and type(self.window_time) == "number" then
        local i = 1
        while i <= #self.buffer do
            if current_time - self.timestamps[i] > self.window_time then
                table.remove(self.buffer, i)
                table.remove(self.timestamps, i)
            else
                break
            end
        end
    end
    
    -- Remove excess values based on buffer_size
    while #self.buffer > self.buffer_size do
        table.remove(self.buffer, 1)
        table.remove(self.timestamps, 1)
    end
end

--- @description Emits a value to all subscribed observers and stores it in the buffer.
-- @arg {*} value - The value to emit to observers.
function ReplaySubject:next(value)
    if not self.closed then
        -- Store value in buffer
        table.insert(self.buffer, value)
        table.insert(self.timestamps, os.time())

        self:_trim_buffer()
        -- Emit to current observers
        for _, observer in ipairs(self.observers) do
            observer:next(value)
        end
    end
end

--- @description Subscribes an observer to the ReplaySubject and replays buffered values.
-- @arg {table|function} observer_or_fn - An observer object or a function to handle next values.
-- @arg {function} on_error  - Function to handle errors (if observer_or_fn is a function).
-- @arg {function} on_complete - Function to handle completion (if observer_or_fn is a function).
-- @returns {Subscription}
function ReplaySubject:subscribe(observer_or_fn, on_error, on_complete)

    local observer
    if type(observer_or_fn) == "table" then
        observer = observer_or_fn
    else
        observer = Observer.new(observer_or_fn, on_error, on_complete)
    end

    if self.has_error then
        print("Replaying error to new subscriber")
        observer:error(self.error_value)
        return Subscription.new()
    end
    
    if self.closed then
        return Subscription.new()
    end
    
    -- If already completed or errored, handle accordingly
    
    -- Replay buffered values to new subscriber
    self:_trim_buffer()

    for _, value in ipairs(self.buffer) do
        observer:next(value)
    end
    
    if self.completed then
        observer:complete()
        return Subscription.new()
    end
    
    table.insert(self.observers, observer)
    
    local subscription = Subscription.new(function()
        for i, obs in ipairs(self.observers) do
            if obs == observer then
                table.remove(self.observers, i)
                break
            end
        end
    end)
    
    return subscription
end