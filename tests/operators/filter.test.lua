describe('filter', function()
    it('should filter values', function()
        local values = {}
        Rx.Observable.of(1, 2, 3, 4, 5)
            :filter(function(x) return x % 2 == 0 end)
            :subscribe(function(x) table.insert(values, x) end)
        expect(values).to.equal({2, 4})
    end)
    
    it('should handle errors in predicate', function()
        local error_caught = nil
        Rx.Observable.of(1, 2, 3)
            :filter(function(x) error("filter error") end)
            :subscribe(nil, function(err) error_caught = err end)
        expect(error_caught).to_not.equal(nil)
    end)
end)