describe('zip', function()
    it('should zip values by index', function()
        local values = {}
        Rx.Observable.zip(
            Rx.Observable.of(1, 2, 3),
            Rx.Observable.of('a', 'b', 'c')
        ):subscribe(function(x) table.insert(values, x) end)
        expect(#values).to.equal(3)
        expect(values[1]).to.equal({1, 'a'})
    end)
    
    it('should complete when shortest completes', function()
        local values = {}
        Rx.Observable.zip(
            Rx.Observable.of(1, 2),
            Rx.Observable.of('a', 'b', 'c')
        ):subscribe(function(x) table.insert(values, x) end)
        expect(#values).to.equal(2)
    end)
    
    it('should handle errors', function()
        local error_caught = nil
        Rx.Observable.zip(
            Rx.Observable.create(function(obs) obs:error("test") end),
            Rx.Observable.of(1, 2)
        ):subscribe(nil, function(err) error_caught = err end)
        expect(error_caught).to_not.equal(nil)
    end)
end)
