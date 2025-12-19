local Observable = require('src/observable')


--- Races multiple observables, emitting values from the first one to emit.
-- @arg {Observable...} observables- The observables totally competing.
-- @return {Observable}
function Observable.race(...)
    local observables = {...}
    return Observable.new(function(observer)
        local has_winner = false
        local subscriptions = {}
        
        local function cancel_others()
            for _, sub in ipairs(subscriptions) do
                sub:unsubscribe()
            end
        end
        
        for _, obs in ipairs(observables) do
            local sub = obs:subscribe(
                function(value)
                    if not has_winner then
                        has_winner = true
                        cancel_others()
                        observer:next(value)
                    end
                end,
                function(err)
                    if not has_winner then
                        has_winner = true
                        cancel_others()
                        observer:error(err)
                    end
                end,
                function()
                    if not has_winner then
                        has_winner = true
                        cancel_others()
                        observer:complete()
                    end
                end
            )
            table.insert(subscriptions, sub)
        end
        
        return Subscription.new(function()
            cancel_others()
        end)
    end)
end