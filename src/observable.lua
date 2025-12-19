local Observer = require('src/observer')
local Subscription = require('src/subscription')

--- Represents a collection of future values or events.
--- @class Observable
local Observable = {}
Observable.__index = Observable

--- Creates a new Observable.
-- @arg {function} subscribe_fn - A function that is called when an observer subscribes to the observable.
-- @returns {Observable}
function Observable.new(subscribe_fn)
    local self = setmetatable({}, Observable)
    self.subscribe_fn = subscribe_fn
    return self
end

--- Subscribes an observer to the observable.
-- @arg {table|function} observer_or_fn - An observer object or a function to handle next values.
-- @arg {function} on_error - Function to handle errors (if observer_or_fn is a function).
-- @arg {function} on_complete - Function to handle completion (if observer_or_fn is a function).
-- @returns {Subscription}
function Observable:subscribe(observer_or_fn, on_error, on_complete)
    local observer
    if type(observer_or_fn) == "table" then
        observer = observer_or_fn
    else
        observer = Observer.new(observer_or_fn, on_error, on_complete)
    end
    
    local subscription = self.subscribe_fn(observer)
    return subscription or Subscription.new()
end

-- Applies a series of operators to the observable.
-- @arg {functions...} operators - A list of operator functions to apply.
-- @returns {Observable}
function Observable:pipe(...)
    local operators = {...}
    local result = self
    
    for _, operator in ipairs(operators) do
        result = operator(result)
    end
    
    return result
end

--- Creates an Observable from a subscription function.
-- @arg {function} subscribe_fn - A function that defines the subscription behavior.
function Observable.create(subscribe_fn)
  return Observable.new(subscribe_fn)
end

--- Returns an Observable that immediately completes without producing a value.
-- @returns {Observable}
function Observable.empty()
  return Observable.new(function(observer)
    observer:complete()
  end)
end

--- Returns an Observable that never produces values and never completes.
--- @returns {Observable}
function Observable.never()
  return Observable.new(function(observer) end)
end

--- Returns an Observable that immediately produces an error.
--- @arg {*} message - The error message or value.
--- @returns {Observable}
function Observable.throw(message)
  return Observable.new(function(observer)
    observer:error(message)
  end)
end