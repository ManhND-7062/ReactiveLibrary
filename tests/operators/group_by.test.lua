describe('exhaust_map', function()
    it('should ignore while busy', function()
        local subject = Rx.Subject.new()
        local inner = Rx.Subject.new()
        local values = {}
        
        subject:exhaust_map(function(x)
            return inner:as_observable()
        end)
        :subscribe(function(x) table.insert(values, x) end)
        
        subject:next(1)
        subject:next(2) -- Should be ignored
        inner:next(10)
        inner:complete()
        
        expect(values).to.equal({10})
    end)
end)