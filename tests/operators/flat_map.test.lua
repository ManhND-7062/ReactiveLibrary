describe('flat_map', function()
    it('should flatten inner observables', function()
        local values = {}
        Rx.Observable.of(1, 2, 3)
            :flat_map(function(x)
                return Rx.Observable.of(x * 10, x * 100)
            end)
            :subscribe(function(x) table.insert(values, x) end)
        expect(#values).to.equal(6)
    end)
    
    it('should handle errors in project function', function()
        local error_caught = nil
        Rx.Observable.of(1, 2)
            :flat_map(function(x) error("flatmap error") end)
            :subscribe(nil, function(err) error_caught = err end)
        expect(error_caught).to_not.equal(nil)
    end)
end)