describe('ignore_elements', function()
    it('should ignore all values', function()
        local values = {}
        local completed = false
        Rx.Observable.of(1, 2, 3)
            :ignore_elements()
            :subscribe(
                function(x) table.insert(values, x) end,
                nil,
                function() completed = true end
            )
        expect(#values).to.equal(0)
        expect(completed).to.equal(true)
    end)
end)