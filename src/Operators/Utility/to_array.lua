local Observable = require('src/Observable')

--- Converts the observable sequence to an array.
-- @returns {Observable}
function Observable:to_array()
    return self:reduce(function(acc, value)
        table.insert(acc, value)
        return acc
    end, {})
end