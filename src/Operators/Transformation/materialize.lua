local Observable = require('src/Observable')

--- Represents the notification of an event in the source observable.
-- @returns {Observable}
function Observable:materialize()
    local source = self
    return Observable.new(function(observer)
        return source:subscribe(
            function(value)
                observer:next({kind = "next", value = value})
            end,
            function(err)
                observer:next({kind = "error", error = err})
                observer:complete()
            end,
            function()
                observer:next({kind = "complete"})
                observer:complete()
            end
        )
    end)
end