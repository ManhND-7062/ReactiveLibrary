local Observable = require('src/Observable')

--- Projects each source value to an observable which is merged in the output observable only if the previous inner observable has completed.
-- @arg {function} project_fn - A function that, when applied to an item emitted by the source observable, returns an observable.
-- @returns {Observable}
function Observable:exhaust_map(project_fn)
    local source = self
    return Observable.new(function(observer)
        local inner_active = false
        
        local main_subscription = source:subscribe(
            function(value)
                if not inner_active then
                    inner_active = true
                    local inner_obs = project_fn(value)
                    
                    inner_obs:subscribe(
                        function(inner_value) observer:next(inner_value) end,
                        function(err) observer:error(err) end,
                        function() inner_active = false end
                    )
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
        
        return main_subscription
    end)
end