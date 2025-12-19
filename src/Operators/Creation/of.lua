local Observable = require('src/Observable')
local Subscription = require('src/subscription')

--- Creates an observable that emits the provided values in sequence and then completes.
-- @arg {*...} any - A variable number of values to emit.
-- @returns {Observable}
function Observable.of(...)
    local values = {...}
    return Observable.new(function(observer)
        for _, v in ipairs(values) do
            observer:next(v)
        end
        observer:complete()
        return Subscription.new()
    end)
end