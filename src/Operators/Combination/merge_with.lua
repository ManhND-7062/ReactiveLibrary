local Observable = require('src/Observable')
local Subscription = require('src/subscription')

--- Merges values from the source observable and another observable.
-- @arg {Observable} other - Another observable to merge with.
-- @returns {Observable}
function Observable:merge_with(other)
    local source = self
    return Observable.new(function(observer)
        local completed_count = 0
        local subscription1 = source:subscribe(
            function(value) observer:next(value) end,
            function(err) observer:error(err) end,
            function()
                completed_count = completed_count + 1
                if completed_count == 2 then
                    observer:complete()
                end
            end
        )
        
        local subscription2 = other:subscribe(
            function(value) observer:next(value) end,
            function(err) observer:error(err) end,
            function()
                completed_count = completed_count + 1
                if completed_count == 2 then
                    observer:complete()
                end
            end
        )
        
        local combined = Subscription.new(function()
            subscription1:unsubscribe()
            subscription2:unsubscribe()
        end)
        
        return combined
    end)
end