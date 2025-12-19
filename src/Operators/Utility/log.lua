local Observable = require('src/observable')

--- Logs each emitted value from the observable to the console.
-- @arg {Observable} observable - The source observable.
-- @arg {string} prefix - A prefix to prepend to each log message (optional).
-- @returns {Observable}
function Observable:log(prefix)
    prefix = prefix or "Value"
    return self:tap( function(value)
        print(prefix .. ":", value)
    end)
end