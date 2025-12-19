local Observable = require('src/observable')
local Subject = require('src/Subjects/subject')

--- Converts a cold observable into a hot observable by multicasting its emissions through a Subject.
-- @returns {table} A table containing the `observable` and a `connect` function.
function Observable:publish()
    local source = self
    local subject = Subject.new()
    
    return {
        observable = Observable.new(function(observer)
            return subject:subscribe(observer)
        end),
        connect = function()
            return source:subscribe(
                function(value) subject:next(value) end,
                function(err) subject:error(err) end,
                function() subject:complete() end
            )
        end
    }
end