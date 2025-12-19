local Observable = require('src/observable')
local Subscription = require('src/subscription')

--- Emits the item at the specified index from the source observable.
-- @arg {number} index - The zero-based index of the item to emit.
-- @arg {*} default_value - The default value to emit if the index is out of bounds
-- @returns {Observable}
function Observable:element_at(index, default_value)
    local source = self
    return Observable.new(function(observer)
        local current_index = 0
        return source:subscribe(
            function(value)
                if current_index == index then
                    observer:next(value)
                    observer:complete()
                end
                current_index = current_index + 1
            end,
            function(err) observer:error(err) end,
            function()
                if default_value ~= nil then
                    observer:next(default_value)
                    observer:complete()
                else
                    observer:error("Index out of bounds: " .. index)
                end
            end
        )
    end)
end