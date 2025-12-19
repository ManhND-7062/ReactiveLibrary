describe('reduce', function()
    it('should emit single accumulated value', function()
        local value = nil
        Rx.Observable.of(1, 2, 3, 4)
            :reduce(function(acc, x) return acc + x end, 0)
            :subscribe(function(x) value = x end)
        expect(value).to.equal(10)
    end)
    
    it('should handle errors in accumulator', function()
        local error_caught = nil
        Rx.Observable.of(1, 2, 3)
            :reduce(function(acc, x) error("reduce error") end, 0)
            :subscribe(nil, function(err) error_caught = err end)
        expect(error_caught).to_not.equal(nil)
    end)
end)