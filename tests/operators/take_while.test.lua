describe('take_while', function()
    it('should take while condition is true', function()
        local values = {}
        Rx.Observable.of(1, 2, 3, 4, 5)
            :take_while(function(x) return x < 4 end)
            :subscribe(function(x) table.insert(values, x) end)
        expect(values).to.equal({1, 2, 3})
    end)
    
    it('should handle inclusive mode', function()
        local values = {}
        Rx.Observable.of(1, 2, 3, 4, 5)
            :take_while(function(x) return x < 3 end, true)
            :subscribe(function(x) table.insert(values, x) end)
        expect(values).to.equal({1, 2, 3})
    end)
end)