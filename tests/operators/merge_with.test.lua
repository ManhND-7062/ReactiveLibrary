describe('merge_with', function()
    it('should merge emissions', function()
        local values = {}
        Rx.Observable.of(1, 2)
            :merge_with(Rx.Observable.of(3, 4))
            :subscribe(function(x) table.insert(values, x) end)
        expect(#values).to.equal(4)
    end)
    
    it('should propagate errors', function()
        local error_caught = nil
        Rx.Observable.of(1)
            :merge_with(Rx.Observable.create(function(obs) obs:error("test") end))
            :subscribe(nil, function(err) error_caught = err end)
        expect(error_caught).to_not.equal(nil)
    end)
end)