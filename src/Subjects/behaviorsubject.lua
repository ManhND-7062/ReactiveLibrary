local Subject = require("src/Subjects/subject")

--- @class BehaviorSubject
-- @description A BehaviorSubject is a type of Subject that requires an initial value and emits its current value to new subscribers.
local BehaviorSubject = {}
BehaviorSubject.__index = BehaviorSubject
setmetatable(BehaviorSubject, {__index = Subject})

--- Creates a new BehaviorSubject with the specified initial value.
-- @arg {*} initial_value - The initial value for the BehaviorSubject.
-- @returns {BehaviorSubject}
function BehaviorSubject.new(initial_value)
    local self = setmetatable(Subject.new(), BehaviorSubject)
    self.current_value = initial_value
    return self
end

--- Subscribes an observer to the BehaviorSubject and immediately emits the current value.  
-- @arg {table|function} observer_or_fn - An observer object or a function to handle next values.
-- @arg {function} on_error - Function to handle errors (if observer_or_fn is a function
-- @arg {function} on_complete  - Function to handle completion (if observer_or_fn is a function).
-- @returns {Subscription}
function BehaviorSubject:subscribe(observer_or_fn, on_error, on_complete)
    local observer
    if type(observer_or_fn) == "table" then
        observer = observer_or_fn
    else
        observer = Observer.new(observer_or_fn, on_error, on_complete)
    end
    
    -- Emit current value immediately
    if not self.closed and not self.has_error then
        observer:next(self.current_value)
    end
    
    return Subject.subscribe(self, observer)
end

--- Emits a value to all subscribed observers and updates the current value.
-- @arg {*} value - The value to emit to observers.
function BehaviorSubject:next(value)
    self.current_value = value
    Subject.next(self, value)
end

--- Gets the current value of the BehaviorSubject.
-- @return {*} - The current value.
function BehaviorSubject:get_value()
    return self.current_value
end