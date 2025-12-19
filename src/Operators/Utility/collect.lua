local Observable = require('src/Observable')

--- Collects all emitted values from an observable into a table.
-- @arg {Observable} observable - The observable to collect values from.
-- @arg {number} timeout - The maximum time to wait for completion (optional).
-- @return {table}
function Observable:collect(timeout)
    local results = {}
    local completed = false
    local error_value = nil
    
    self:subscribe(
        function(value) table.insert(results, value) end,
        function(err) error_value = err end,
        function() completed = true end
    )
    
    return results, completed, error_value
end