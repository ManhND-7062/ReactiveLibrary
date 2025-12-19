describe('collect', function()
    it('should collect all emitted values', function()
        local results, completed, error = Rx.Observable.collect(
            Rx.Observable.of(1, 2, 3)
        )
        
        expect(results).to.equal({1, 2, 3})
        expect(completed).to.equal(true)
        expect(error).to.equal(nil)
    end)
end)