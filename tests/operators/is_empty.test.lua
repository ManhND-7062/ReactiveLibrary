describe('is_empty', function()
    it('should return true for empty', function()
        local result = nil
        Rx.Observable.of()
            :is_empty()
            :subscribe(function(x) result = x end)
        expect(result).to.equal(true)
    end)
    
    it('should return false for non-empty', function()
        local result = nil
        Rx.Observable.of(1)
            :is_empty()
            :subscribe(function(x) result = x end)
        expect(result).to.equal(false)
    end)
end)