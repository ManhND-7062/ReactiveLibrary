describe('distinct_until_changed', function()
    it('should remove consecutive duplicates', function()
        local values = {}
        Rx.Observable.of(1, 1, 2, 2, 3, 3, 2)
            :distinct_until_changed()
            :subscribe(function(x) table.insert(values, x) end)
        expect(values).to.equal({1, 2, 3, 2})
    end)
end)
