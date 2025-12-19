describe('distinct', function()
    it('should remove duplicates', function()
        local values = {}
        Rx.Observable.of(1, 2, 2, 3, 1, 4)
            :distinct()
            :subscribe(function(x) table.insert(values, x) end)
        expect(values).to.equal({1, 2, 3, 4})
    end)
    
    it('should use key selector', function()
        local values = {}
        Rx.Observable.of({id=1}, {id=2}, {id=1})
            :distinct(function(x) return x.id end)
            :subscribe(function(x) table.insert(values, x) end)
        expect(#values).to.equal(2)
    end)
end)