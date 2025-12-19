local Observable = require('src/observable')
local Subscription = require('src/subscription')

--= Creates an observable that emits the values from the provided table in sequence and then completes.
-- @arg {table} tbl - A table of values to emit.
-- @returns {Observable}
function Observable.from(tbl)
    return Observable.new(function(observer)
        for _, v in ipairs(tbl) do
            observer:next(v)
        end
        observer:complete()
        return Subscription.new()
    end)
end