local Observable = require('src/Observable')

--- Emits the previous and current values as a pair for each emission from the source observable.
-- @returns {Observable}
function Observable:pairwise()
    local source = self
    return Observable.new(function(observer)
        local has_prev = false
        local prev_value = nil
        
        return source:subscribe(
            function(value)
                if has_prev then
                    observer:next({prev_value, value})
                end
                prev_value = value
                has_prev = true
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end