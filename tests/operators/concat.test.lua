describe('concat', function()
    it('should concatenate observables', function()
        local values = {}
        Rx.Observable.concat(
            Rx.Observable.of(1, 2),
            Rx.Observable.of(3, 4)
        ):subscribe(function(x) table.insert(values, x) end)
        expect(values).to.equal({1, 2, 3, 4})
    end)
    
    it('should handle errors', function()
        local error_caught = nil
        Rx.Observable.concat(
            Rx.Observable.of(1),
            Rx.Observable.create(function(obs) obs:error("test") end)
        ):subscribe(nil, function(err) error_caught = err end)
        expect(error_caught).to_not.equal(nil)
    end)
end)