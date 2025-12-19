local Observable = require('src/Observable')

--- Counts the number of values emitted by the observable.
-- @returns {Observable}
function Observable:count()
    return self:reduce(function(acc, _) return acc + 1 end, 0)
end