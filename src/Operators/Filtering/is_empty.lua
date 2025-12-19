local Observable = require('src/observable')

--- Determines whether the observable sequence is empty.
-- @returns {Observable} An observable that emits true if empty, false otherwise.
function Observable:is_empty()
    return Observable.new(function(observer)
        local is_empty = true
        
        return self:subscribe(
            function(_)
                is_empty = false
            end,
            function(err) observer:error(err) end,
            function()
                observer:next(is_empty)
                observer:complete()
            end
        )
    end)
end