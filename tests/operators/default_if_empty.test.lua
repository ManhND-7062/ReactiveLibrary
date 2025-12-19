describe('default_if_empty', function()
    it('should emit default if empty', function()
        local value = nil
        Rx.Observable.of()
            :default_if_empty(42)
            :subscribe(function(x) value = x end)
        expect(value).to.equal(42)
    end)
    
    it('should not emit default if not empty', function()
        local values = {}
        Rx.Observable.of(1, 2)
            :default_if_empty(42)
            :subscribe(function(x) table.insert(values, x) end)
        expect(values).to.equal({1, 2})
    end)
end)