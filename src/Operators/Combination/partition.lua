local Observable = require('src/observable')

--- Splits the source observable into two observables based on a predicate function.
-- @arg {function} predicate_fn - A function to test each emitted value.
-- @returns {Observable}
-- @returns {Observable}
function Observable:partition(predicate_fn)
    local source = self
    local pass = source:filter(predicate_fn)
    local fail = source:filter(function(x) return not predicate_fn(x) end)
    return pass, fail
end