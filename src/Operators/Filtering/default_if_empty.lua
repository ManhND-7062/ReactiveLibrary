local Observable = require('src/observable')
local Subscription = require('src/subscription')

--- Emits a default value if the source observable completes without emitting any values.
-- @arg {*} default_value - The default value to emit if the source is empty.
-- @returns {Observable} An observable that emits the default value if the source is empty.
function Observable:default_if_empty(default_value)
    return Observable.new(function(observer)
        local has_value = false
        
        return self:subscribe(
            function(value)
                has_value = true
                observer:next(value)
            end,
            function(err) observer:error(err) end,
            function()
                if not has_value then
                    observer:next(default_value)
                end
                observer:complete()
            end
        )
    end)
end