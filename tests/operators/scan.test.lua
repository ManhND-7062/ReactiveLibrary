describe('scan', function()
    it('should accumulate values', function()
        local values = {}
        Rx.Observable.of(1, 2, 3, 4)
            :scan(function(acc, x) return acc + x end, 0)
            :subscribe(function(x) table.insert(values, x) end)
        expect(values).to.equal({1, 3, 6, 10})
    end)
    
    it('should work without seed', function()
        local values = {}
        Rx.Observable.of(1, 2, 3)
            :scan(function(acc, x) return acc + x end)
            :subscribe(function(x) table.insert(values, x) end)
        expect(values[1]).to.equal(1)
    end)
    
    it('should handle errors in accumulator', function()
        local error_caught = nil
        Rx.Observable.of(1, 2, 3)
            :scan(function(acc, x) error("scan error") end, 0)
            :subscribe(nil, function(err) error_caught = err end)
        expect(error_caught).to_not.equal(nil)
    end)
end)