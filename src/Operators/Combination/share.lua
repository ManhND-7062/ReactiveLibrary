local Observable = require('src/observable')
local Subject = require('src/Subjects/subject')

--- Shares a single subscription to the source observable among multiple subscribers.
-- @returns {Observable}
function Observable:share()
    local source = self
    local subject = nil
    local subscription = nil
    local ref_count = 0
    
    return Observable.new(function(observer)
        ref_count = ref_count + 1
        
        if not subject then
            subject = Subject.new()
            subscription = source:subscribe(
                function(value) subject:next(value) end,
                function(err) subject:error(err) end,
                function() subject:complete() end
            )
        end
        
        local sub = subject:subscribe(observer)
        
        return Subscription.new(function()
            ref_count = ref_count - 1
            sub:unsubscribe()
            
            if ref_count == 0 and subscription then
                subscription:unsubscribe()
                subject = nil
                subscription = nil
            end
        end)
    end)
end