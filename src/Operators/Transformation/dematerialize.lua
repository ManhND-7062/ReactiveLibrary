local Observable = require('src/Observable')

--- Converts notification objects back into the emissions they represent.
-- @returns {Observable}
function Observable:dematerialize()
    local source = self
    return Observable.new(function(observer)
        return source:subscribe(
            function(notification)
                if notification.kind == "next" then
                    observer:next(notification.value)
                elseif notification.kind == "error" then
                    observer:error(notification.error)
                elseif notification.kind == "complete" then
                    observer:complete()
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end