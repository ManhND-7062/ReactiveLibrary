describe('element_at', function()
    it('should get element at index', function()
        local value = nil
        Rx.Observable.of(10, 20, 30)
            :element_at(1)
            :subscribe(function(x) value = x end)
        expect(value).to.equal(20)
    end)
    
    it('should use default if out of bounds', function()
        local value = nil
        Rx.Observable.of(10, 20)
            :element_at(5, 999)
            :subscribe(function(x) value = x end)
        expect(value).to.equal(999)
    end)
    
    it('should error if out of bounds without default', function()
        local error_caught = nil
        Rx.Observable.of(10, 20)
            :element_at(5)
            :subscribe(nil, function(err) error_caught = err end)
        expect(error_caught).to_not.equal(nil)
    end)
end)