local Observable = require('src/observable')
local Subscription = require('src/subscription')
local Observer = require('src/observer')

local Subject = {}
Subject.__index = Subject
setmetatable(Subject, {__index = Observable})

function Subject.new()
    local self = setmetatable({}, Subject)
    self.observers = {}
    self.closed = false
    self.has_error = false
    self.error_value = nil
    self.completed = false
    return self
end

--- Subscribes an observer to the subject.
-- @arg {table|function} observer_or_fn - An observer object or a function to handle next values.
-- @arg {function} on_error - Function to handle errors (if observer_or_fn is a function).
-- @arg {function} on_complete  - Function to handle completion (if observer_or_fn is a function).
-- @returns {Subscription}
function Subject:subscribe(observer_or_fn, on_error, on_complete)
    if self.closed then
        return Subscription.new()
    end
    
    local observer
    if type(observer_or_fn) == "table" then
        observer = observer_or_fn
    else
        observer = Observer.new(observer_or_fn, on_error, on_complete)
    end
    
    -- If already completed or errored, notify immediately
    if self.has_error then
        observer:error(self.error_value)
        return Subscription.new()
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

--- Emits a value to all subscribed observers.
-- @arg {*} value - The value to emit to observers.
function Subject:next(value)
    if not self.closed then
        for _, observer in ipairs(self.observers) do
            observer:next(value)
        end
    end
end

--- Emits an error to all subscribed observers and closes the subject.
-- @arg {*} err - The error to emit to observers.
function Subject:error(err)
    if not self.closed then
        self.closed = true
        self.has_error = true
        self.error_value = err
        
        for _, observer in ipairs(self.observers) do
            observer:error(err)
        end
        
        self.observers = {}
    end
end

--- Completes the subject and notifies all subscribed observers.
function Subject:complete()
    if not self.closed then
        self.closed = true
        self.completed = true
        
        for _, observer in ipairs(self.observers) do
            observer:complete()
        end
        
        self.observers = {}
    end
end

--- Returns an observable that is linked to this subject.
-- @return {Observable}
function Subject:as_observable()
    local subject = self
    return Observable.new(function(observer)
        return subject:subscribe(observer)
    end)
end