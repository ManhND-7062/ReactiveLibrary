local Observable = require('src/Observable')

--- Skips the first `count` values from the source observable.
-- @arg {number} count - The number of values to skip.
-- @return {Observable}
function Observable:skip(count)
    local source = self
    return Observable.new(function(observer)
        local skipped = 0
        return source:subscribe(
            function(value)
                if skipped >= count then
                    observer:next(value)
                else
                    skipped = skipped + 1
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end