local Observable = require('src/Observable')

--- Delays the emission of each value from the source observable based on a duration selector function.
-- @arg {function} duration_selector - A function that takes a value and returns an observable that determines the delay duration.
-- @returns {Observable}
function Observable:delay_when(duration_selector)
    return Observable.new(function(observer)
        local pending = 0
        local count = 0
        local source_completed = false
        
        local function check_complete()
            if source_completed and pending == 0 then
                observer:complete()
            end
        end
        
        return self:subscribe(
            function(value)
                pending = pending + 1
                count = count + 1
                local delay_obs = duration_selector(value)
                delay_obs:subscribe(
                    function(_)
                        observer:next(value)
                        pending = pending - 1
                        check_complete()
                    end,
                    function(err) observer:error(err) end,
                    function()
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
    end)
end