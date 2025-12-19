describe('some', function()
    it('should test any value', function()
        local result = nil
        Rx.Observable.of(1, 3, 5, 6)
            :some(function(x) return x % 2 == 0 end)
            :subscribe(function(x) result = x end)
        expect(result).to.equal(true)
    end)
    
    it('should return false if none match', function()
        local result = nil
        Rx.Observable.of(1, 3, 5)
            :some(function(x) return x % 2 == 0 end)
            :subscribe(function(x) result = x end)
        expect(result).to.equal(false)
    end)
end)