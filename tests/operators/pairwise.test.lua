describe('pairwise', function()
    it('should emit pairs', function()
        local values = {}
        Rx.Observable.of(1, 2, 3, 4)
            :pairwise()
            :subscribe(function(pair) table.insert(values, pair) end)
        expect(#values).to.equal(3)
        expect(values[1]).to.equal({1, 2})
    end)
    
    it('should handle single value', function()
        local values = {}
        Rx.Observable.of(1)
            :pairwise()
            :subscribe(function(pair) table.insert(values, pair) end)
        expect(#values).to.equal(0)
    end)
end)