local Observable = require('src/observable')

--- Ignores all items emitted by the source observable and only passes through termination events.
-- @returns {Observable}
function Observable:ignore_elements()
    local source = self
    return Observable.new(function(observer)
        return source:subscribe(
            function(_) end,  -- Ignore all values
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end