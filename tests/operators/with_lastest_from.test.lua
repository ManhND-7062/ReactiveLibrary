describe('with_latest_from', function()
    it('should combine on source emission', function()
        local subject1 = Rx.Subject.new()
        local subject2 = Rx.Subject.new()
        local values = {}
        
        subject1:with_latest_from(subject2)
            :subscribe(function(x) table.insert(values, x) end)
        
        subject2:next(10)
        subject1:next(1)
        subject1:next(2)
        
        expect(#values).to.equal(2)
        expect(values[1]).to.equal({1, 10})
        expect(values[2]).to.equal({2, 10})
    end)
    
    it('should wait for other sources', function()
        local subject1 = Rx.Subject.new()
        local subject2 = Rx.Subject.new()
        local values = {}
        
        subject1:with_latest_from(subject2)
            :subscribe(function(x) table.insert(values, x) end)
        
        subject1:next(1)
        expect(#values).to.equal(0)
    end)
end)