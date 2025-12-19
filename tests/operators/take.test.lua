describe('take', function()
    it('should take N values', function()
        local values = {}
        Rx.Observable.of(1, 2, 3, 4, 5)
            :take(3)
            :subscribe(function(x) table.insert(values, x) end)
        expect(values).to.equal({1, 2, 3})
    end)
    
    it('should complete after N values', function()
        local completed = false
        Rx.Observable.of(1, 2, 3)
            :take(2)
            :subscribe(nil, nil, function() completed = true end)
        expect(completed).to.equal(true)
    end)
end)