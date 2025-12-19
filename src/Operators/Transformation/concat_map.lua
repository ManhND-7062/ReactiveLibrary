local Observable = require('src/Observable')

--- Projects each source value to an observable which is concatenated in the output observable.
-- @arg {function} project_fn - A function that, when applied to an item emitted by the source observable, returns an observable.
-- @returns {Observable}
function Observable:concat_map(project_fn)
    local source = self
    return Observable.new(function(observer)
        local queue = {}
        local active = false
        local source_completed = false
        
        local function process_next()
            if #queue == 0 then
                active = false
                if source_completed then
                    observer:complete()
                end
                return
            end
            
            active = true
            local value = table.remove(queue, 1)
            local inner_obs = project_fn(value)
            
            inner_obs:subscribe(
                function(inner_value) observer:next(inner_value) end,
                function(err) observer:error(err) end,
                function() process_next() end
            )
        end
        
        local main_subscription = source:subscribe(
            function(value)
                table.insert(queue, value)
                if not active then
                    process_next()
                end
            end,
            function(err) observer:error(err) end,
            function()
                source_completed = true
                if not active then
                    observer:complete()
                end
            end
        )
        
        return main_subscription
    end)
end