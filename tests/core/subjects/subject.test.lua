describe('Subject', function()
    it('should create a subject', function()
        local subject = Rx.Subject.new()
        expect(subject).to.exist()
    end)
    
    it('should multicast to multiple subscribers', function()
        local subject = Rx.Subject.new()
        local values1 = {}
        local values2 = {}
        
        subject:subscribe(function(x) table.insert(values1, x) end)
        subject:subscribe(function(x) table.insert(values2, x) end)
        
        subject:next(1)
        subject:next(2)
        
        expect(values1).to.equal({1, 2})
        expect(values2).to.equal({1, 2})
    end)
    
    it('should complete all subscribers', function()
        local subject = Rx.Subject.new()
        local completed1 = false
        local completed2 = false
        
        subject:subscribe(nil, nil, function() completed1 = true end)
        subject:subscribe(nil, nil, function() completed2 = true end)
        
        subject:complete()
        
        expect(completed1).to.equal(true)
        expect(completed2).to.equal(true)
    end)
    
    it('should not emit after complete', function()
        local subject = Rx.Subject.new()
        local count = 0
        subject:subscribe(function() count = count + 1 end)
        subject:next(1)
        subject:complete()
        subject:next(2)
        expect(count).to.equal(1)
    end)
    
    it('should propagate errors to all subscribers', function()
        local subject = Rx.Subject.new()
        local errors = {}
        subject:subscribe(nil, function(err) table.insert(errors, err) end)
        subject:subscribe(nil, function(err) table.insert(errors, err) end)
        subject:error("test error")
        expect(#errors).to.equal(2)
    end)
    
    it('should convert to observable', function()
        local subject = Rx.Subject.new()
        local obs = subject:as_observable()
        expect(obs).to.exist()
    end)
end)