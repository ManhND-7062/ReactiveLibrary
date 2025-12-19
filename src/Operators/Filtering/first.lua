local Observable = require('src/observable')

--- Emits only the first value from the observable sequence.
-- @returns {Observable} An observable that emits the first value.
function Observable:first()
    return self:take(1)
end