local Observable = require('src/Observable')

--- Projects each source value to an observable which is merged in the output observable.
-- @arg {function} project_fn - A function that, when applied to an item emitted by the source observable, returns an observable.
-- @returns {Observable}
function Observable:flat_map(project_fn)
    local source = self
    return Observable.new(function(observer)
        local active_count = 0
        local source_completed = false
        local main_subscription
        
        local function check_complete()
            if source_completed and active_count == 0 then
                observer:complete()
            end
        end
        
        main_subscription = source:subscribe(
            function(value)
                active_count = active_count + 1
                local inner_obs = project_fn(value)
                
                inner_obs:subscribe(
                    function(inner_value) observer:next(inner_value) end,
                    function(err) observer:error(err) end,
                    function()
                        active_count = active_count - 1
                        check_complete()
                    end
                )
            end,
            function(err) observer:error(err) end,
            function()
                source_completed = true
                check_complete()
            end
        )
        
        return main_subscription
    end)
end