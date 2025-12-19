describe('Subscription', function()
    it('should create a subscription', function()
        local called = false
        local sub = Rx.Subscription.new(function()
            called = true
        end)
        expect(sub).to.exist()
        expect(sub.closed).to.equal(false)
    end)
    
    it('should unsubscribe and call cleanup', function()
        local called = false
        local sub = Rx.Subscription.new(function()
            called = true
        end)
        sub:unsubscribe()
        expect(called).to.equal(true)
        expect(sub.closed).to.equal(true)
    end)
    
    it('should not call cleanup twice', function()
        local count = 0
        local sub = Rx.Subscription.new(function()
            count = count + 1
        end)
        sub:unsubscribe()
        sub:unsubscribe()
        expect(count).to.equal(1)
    end)
    
    it('should add child subscriptions', function()
        local parent_called = false
        local child_called = false
        
        local parent = Rx.Subscription.new(function()
            parent_called = true
        end)
        
        local child = Rx.Subscription.new(function()
            child_called = true
        end)
        
        parent:add(child)
        parent:unsubscribe()
        
        expect(parent_called).to.equal(true)
        expect(child_called).to.equal(true)
    end)
    
    it('should handle error in cleanup function', function()
        local sub = Rx.Subscription.new(function()
            error("cleanup error")
        end)
        -- Should not throw
        expect(function() sub:unsubscribe() end).to_not.fail()
    end)
end)