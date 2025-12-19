describe('first', function()
    it('should take first value', function()
        local value = nil
        Rx.Observable.of(1, 2, 3)
            :first()
            :subscribe(function(x) value = x end)
        expect(value).to.equal(1)
    end)
end)