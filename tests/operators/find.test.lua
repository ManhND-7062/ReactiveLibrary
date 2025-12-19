describe('find', function()
    it('should find first match', function()
        local value = nil
        Rx.Observable.of(1, 2, 3, 4, 5)
            :find(function(x) return x > 3 end)
            :subscribe(function(x) value = x end)
        expect(value).to.equal(4)
    end)
    
    it('should complete without emitting if no match', function()
        local value = "initial"
        Rx.Observable.of(1, 2, 3)
            :find(function(x) return x > 10 end)
            :subscribe(function(x) value = x end)
        expect(value).to.equal("initial")
    end)
end)