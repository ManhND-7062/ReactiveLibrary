describe('to_array', function()
    it('should collect all values into array', function()
        local result = nil
        Rx.Observable.of(1, 2, 3)
            :to_array()
            :subscribe(function(x) result = x end)
        expect(result).to.equal({1, 2, 3})
    end)
end)