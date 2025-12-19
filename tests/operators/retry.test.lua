describe('retry', function()
    it('should retry on error', function()
        local attempts = 0
        local value = nil
        
        Rx.Observable.create(function(observer)
            attempts = attempts + 1
            if attempts < 3 then
                observer:error("fail")
            else
                observer:next("success")
                observer:complete()
            end
        end)
        :retry(3)
        :subscribe(function(x) value = x end)
        
        expect(attempts).to.equal(3)
        expect(value).to.equal("success")
    end)
    
    it('should fail after max retries', function()
        local error_caught = nil
        
        Rx.Observable.create(function(observer)
            observer:error("always fails")
        end)
        :retry(2)
        :subscribe(nil, function(err) error_caught = err end)
        
        expect(error_caught).to_not.equal(nil)
    end)
end)
