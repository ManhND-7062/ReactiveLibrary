describe('count', function()
    it('should count emissions', function()
        local result = nil
        Rx.Observable.of(1, 2, 3, 4, 5)
            :count()
            :subscribe(function(x) result = x end)
        expect(result).to.equal(5)
    end)
end)