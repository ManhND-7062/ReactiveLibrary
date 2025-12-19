--- Represents a disposable resource, such as the execution of an Observable. A Subscription has one important method, `unsubscribe`, that takes no argument and just disposes the resource held by the subscription.
-- @class Subscription
local Subscription = {}
Subscription.__index = Subscription

--- Creates a new Subscription.
-- @arg {function} unsubscribe_fn - A function that will be called when unsubscribe is invoked.
-- @return {Subscription}
function Subscription.new(unsubscribe_fn)
    local self = setmetatable({}, Subscription)
    self.closed = false
    self.unsubscribe_fn = unsubscribe_fn
    return self
end


--- Disposes the resource held by the subscription.
function Subscription:unsubscribe()
    if not self.closed then
        self.closed = true
        if self.unsubscribe_fn then
            local success,err = pcall(self.unsubscribe_fn)
            if not success then
                print("Error during unsubscribe:", err)
            end 
        end
    end
end

--- Adds a teardown to be called during the unsubscribe() of this subscription.
-- @arg {Subscription} subscription - A subscription to add.
function Subscription:add(subscription)
    if self.closed then
        subscription:unsubscribe()
        return
    end
    
    local parent_unsub = self.unsubscribe_fn
    self.unsubscribe_fn = function()
        if parent_unsub then parent_unsub() end
        subscription:unsubscribe()
    end
end

return Subscription