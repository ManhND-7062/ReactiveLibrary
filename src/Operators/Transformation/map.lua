local Observable = require('src/Observable')

-- Applies a transformation function to each emitted value.
-- @arg {function} transform_fn - A function to transform each emitted value.
-- @returns {Observable}
function Observable:map(transform_fn)
    local source = self
    return Observable.new(function(observer)
        return source:subscribe(
            function(value)
                local success, result = pcall(transform_fn, value)
                if success then
                    observer:next(result)
                else
                    observer:error(result)
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end