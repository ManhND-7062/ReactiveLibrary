local Observable = require('src/observable')
local Subscription = require('src/subscription')

--- Removes duplicate values from the source observable.
-- @arg {function} key_selector - An optional function to select the key for comparison.
-- @returns {Observable} An observable that emits only distinct values.
function Observable:distinct(key_selector)
    key_selector = key_selector or function(x) return x end
    
    return Observable.new(function(observer)
        local seen = {}
        
        return self:subscribe(
            function(value)
                local key = key_selector(value)
                if not seen[key] then
                    seen[key] = true
                    observer:next(value)
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end