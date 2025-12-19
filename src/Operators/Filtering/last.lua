local Observable = require('src/observable')

--- Emits only the last value from the observable sequence.
-- @returns {Observable} An observable that emits the last value.
function Observable:last()
    return Observable.new(function(observer)
        local last_value = nil
        local has_value = false
        
        return self:subscribe(
            function(value)
                last_value = value
                has_value = true
            end,
            function(err) observer:error(err) end,
            function()
                if has_value then
                    observer:next(last_value)
                end
                observer:complete()
            end
        )
    end)
end