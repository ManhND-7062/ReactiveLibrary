local Observable = require('src/Observable')
local Subscription = require('src/subscription')


--- Buffers values from the source observable until the buffer reaches the specified count and emits them as an array.
-- @arg {number} count - The number of items to buffer.
-- @returns {Observable}
function Observable:buffer_count(count)
    local source = self
    return Observable.new(function(observer)
        local buffer = {}
        
        local source_sub = source:subscribe(
            function(value)
                table.insert(buffer, value)
                if #buffer >= count then
                    observer:next(buffer)
                    buffer = {}
                end
            end,
            function(err) observer:error(err) end,
            function()
                if #buffer > 0 then
                    observer:next(buffer)
                end
                observer:complete()
            end
        )
        
        return source_sub
    end)
end