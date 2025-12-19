local Observable = require('src/Observable')
local Subscription = require('src/Subscription')

--- Projects each source value to an observable which is switched to in the output observable.
-- @arg {function} project_fn - A function that, when applied to an item emitted by the source observable, returns an observable.
-- @returns {Subscription}
function Observable:switch_map(project_fn)
    local source = self
    return Observable.new(function(observer)
        local inner_subscription = nil
        
        local main_subscription = source:subscribe(
            function(value)
                -- Unsubscribe from previous inner observable
                if inner_subscription then
                    inner_subscription:unsubscribe()
                end
                
                local inner_obs = project_fn(value)
                inner_subscription = inner_obs:subscribe(
                    function(inner_value) observer:next(inner_value) end,
                    function(err) observer:error(err) end,
                    function() end  -- Don't complete on inner completion
                )
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
        
        return Subscription.new(function()
            if inner_subscription then
                inner_subscription:unsubscribe()
            end
            main_subscription:unsubscribe()
        end)
    end)
end