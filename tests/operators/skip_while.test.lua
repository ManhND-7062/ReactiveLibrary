describe('skip_while', function()
    it('should skip while condition is true', function()
        local values = {}
        Rx.Observable.of(1, 2, 3, 4, 5)
            :skip_while(function(x) return x < 3 end)
            :subscribe(function(x) table.insert(values, x) end)
        expect(values).to.equal({3, 4, 5})
    end)
end)