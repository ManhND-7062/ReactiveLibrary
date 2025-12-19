describe('ReplaySubject', function()
    it('should replay all values by default', function()
        local subject = Rx.ReplaySubject.new()
        subject:next(1)
        subject:next(2)
        subject:next(3)
        
        local values = {}
        subject:subscribe(function(x) table.insert(values, x) end)
        expect(values).to.equal({1, 2, 3})
    end)
    
    it('should replay limited buffer', function()
        local subject = Rx.ReplaySubject.new(2)
        subject:next(1)
        subject:next(2)
        subject:next(3)
        subject:next(4)
        
        local values = {}
        subject:subscribe(function(x) table.insert(values, x) end)
        expect(values).to.equal({3, 4})
    end)
    
    it('should continue emitting to existing subscribers', function()
        local subject = Rx.ReplaySubject.new(2)
        local values = {}
        
        subject:subscribe(function(x) table.insert(values, x) end)
        subject:next(1)
        subject:next(2)
        
        expect(values).to.equal({1, 2})
    end)
    
    it('should handle error after replay', function()
        local subject = Rx.ReplaySubject.new(2)
        subject:next(1)
        subject:error("test error")
        
        local error_caught = nil
        subject:subscribe(nil, function(err) error_caught = err end)
        expect(error_caught).to.equal("test error")
    end)
end)