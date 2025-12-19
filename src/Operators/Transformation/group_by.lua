local Observable = require('src/Observable')
local Subject = require('src/Subject')

--- Groups the items emitted by the source observable according to a specified key selector function.
-- @arg {function} key_selector  - A function that extracts the key for each item.
-- @arg {function} element_selector - A function that extracts the element for each item.
-- @returns {Observable}
function Observable:group_by(key_selector, element_selector)
    element_selector = element_selector or function(x) return x end
    local source = self
    
    return Observable.new(function(observer)
        local groups = {}
        
        return source:subscribe(
            function(value)
                local key = key_selector(value)
                local element = element_selector(value)
                
                if not groups[key] then
                    local group_subject = Subject.new()
                    groups[key] = group_subject
                    
                    observer:next({
                        key = key,
                        observable = group_subject:as_observable()
                    })
                end
                
                groups[key]:next(element)
            end,
            function(err)
                for _, group in pairs(groups) do
                    group:error(err)
                end
                observer:error(err)
            end,
            function()
                for _, group in pairs(groups) do
                    group:complete()
                end
                observer:complete()
            end
        )
    end)
end