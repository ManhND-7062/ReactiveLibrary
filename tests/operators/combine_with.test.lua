describe('combine_with', function()
    it('should combine latest values', function()
        local subject1 = Rx.Subject.new()
        local subject2 = Rx.Subject.new()
        local values = {}
        
        subject1:combine_with(subject2)
            :subscribe(function(x) table.insert(values, x) end)
        
        subject1:next(1)
        subject2:next(2)
        subject1:next(3)
        
        expect(#values).to.equal(2)
        expect(values[1]).to.equal({1, 2})
        expect(values[2]).to.equal({3, 2})
    end)
    
    it('should wait for all sources to emit', function()
        local subject1 = Rx.Subject.new()
        local subject2 = Rx.Subject.new()
        local values = {}
        
        subject1:combine_with(subject2)
            :subscribe(function(x) table.insert(values, x) end)
        
        subject1:next(1)
        expect(#values).to.equal(0)
        subject2:next(2)
        expect(#values).to.equal(1)
    end)
    
    it('should handle errors from any source', function()
        local subject1 = Rx.Subject.new()
        local subject2 = Rx.Subject.new()
        local error_caught = nil
        
        subject1:combine_with(subject2)
            :subscribe(nil, function(err) error_caught = err end)
        
        subject1:error("test error")
        expect(error_caught).to_not.equal(nil)
    end)
end)