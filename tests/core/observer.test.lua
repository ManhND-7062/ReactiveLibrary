describe('Observer', function()
    it('should create an observer', function()
        local obs = Rx.Observer.new(
            function(x) end,
            function(err) end,
            function() end
        )
        expect(obs).to.exist()
        expect(obs.closed).to.equal(false)
    end)
    
    it('should call next callback', function()
        local value = nil
        local obs = Rx.Observer.new(function(x) value = x end)
        obs:next(42)
        expect(value).to.equal(42)
    end)
    
    it('should call error callback', function()
        local err = nil
        local obs = Rx.Observer.new(nil, function(e) err = e end)
        obs:error("test error")
        expect(err).to.equal("test error")
    end)
    
    it('should call complete callback', function()
        local completed = false
        local obs = Rx.Observer.new(nil, nil, function() completed = true end)
        obs:complete()
        expect(completed).to.equal(true)
    end)
    
    it('should not emit after complete', function()
        local count = 0
        local obs = Rx.Observer.new(function() count = count + 1 end)
        obs:next(1)
        obs:complete()
        obs:next(2)
        expect(count).to.equal(1)
    end)
    
    it('should not emit after error', function()
        local count = 0
        local obs = Rx.Observer.new(function() count = count + 1 end)
        obs:next(1)
        obs:error("error")
        obs:next(2)
        expect(count).to.equal(1)
    end)
    
    it('should handle error in next callback', function()
        local error_caught = nil
        local obs = Rx.Observer.new(
            function() error("next error") end,
            function(err) error_caught = err end
        )
        obs:next(1)
        expect(error_caught).to_not.equal(nil)
    end)
end)