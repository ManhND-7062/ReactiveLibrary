local Observable = require('src/observable')
local Subscription = require('src/subscription')
local ReplaySubject = require('src/Subjects/replay_subject')

--- Shares a single subscription to the source observable among multiple subscribers and replays a specified number of previous emissions to new subscribers.
-- @arg {number} buffer_size - The maximum number of previous emissions to replay to new subscribers.
-- @arg {number} window_time - The maximum time in milliseconds to replay previous emissions to new subscribers.
-- @returns {Observable}
function Observable:share_replay(buffer_size, window_time)
    local source = self
    local subject = nil
    local subscription = nil
    local ref_count = 0
    return Observable.new(function(observer)
        ref_count = ref_count + 1
        
        if not subject then
            subject = ReplaySubject.new(buffer_size, window_time)
            subscription = source:subscribe(
                function(value) 
                    subject:next(value) end,
                function(err) subject:error(err) end,
                function() end
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