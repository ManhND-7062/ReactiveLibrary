describe('last', function()
    it('should take last value', function()
        local value = nil
        Rx.Observable.of(1, 2, 3)
            :last()
            :subscribe(function(x) value = x end)
        expect(value).to.equal(3)
    end)
    
    it('should handle empty observable', function()
        local value = "initial"
        Rx.Observable.of()
            :last()
            :subscribe(function(x) value = x end)
        expect(value).to.equal("initial")
    end)
end)