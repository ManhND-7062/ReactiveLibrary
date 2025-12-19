describe('start_with', function()
    it('should prepend values', function()
        local values = {}
        Rx.Observable.of(2, 3)
            :start_with(1)
            :subscribe(function(x) table.insert(values, x) end)
        expect(values).to.equal({1, 2, 3})
    end)
    
    it('should prepend multiple values', function()
        local values = {}
        Rx.Observable.of(3, 4)
            :start_with(1, 2)
            :subscribe(function(x) table.insert(values, x) end)
        expect(values).to.equal({1, 2, 3, 4})
    end)
end)