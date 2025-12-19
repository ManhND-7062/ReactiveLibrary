describe('every', function()
    it('should test all values', function()
        local result = nil
        Rx.Observable.of(2, 4, 6)
            :every(function(x) return x % 2 == 0 end)
            :subscribe(function(x) result = x end)
        expect(result).to.equal(true)
    end)
    
    it('should return false on first fail', function()
        local result = nil
        Rx.Observable.of(2, 3, 4)
            :every(function(x) return x % 2 == 0 end)
            :subscribe(function(x) result = x end)
        expect(result).to.equal(false)
    end)
end)