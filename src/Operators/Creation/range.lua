local Observable = require('src/Observable')
local Subscription = require('src/subscription')

--- Creates an observable that emits a range of sequential numbers.
-- @arg {number} start - The starting number.
-- @arg {number} count - The number of sequential numbers to emit.
-- @returns {Observable}
function Observable.range(start, count)
    return Observable.new(function(observer)
        for i = start, start + count - 1 do
            observer:next(i)
        end
        observer:complete()
        return Subscription.new()
    end)
end