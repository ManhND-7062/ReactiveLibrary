describe('catch_error', function()
    it('should catch and recover', function()
        local value = nil
        
        Rx.Observable.create(function(observer)
            observer:error("error")
        end)
        :catch_error(function(err)
            return Rx.Observable.of("recovered")
        end)
        :subscribe(function(x) value = x end)
        
        expect(value).to.equal("recovered")
    end)
    
    it('should pass through non-error emissions', function()
        local values = {}
        
        Rx.Observable.of(1, 2, 3)
            :catch_error(function(err)
                return Rx.Observable.of(999)
            end)
            :subscribe(function(x) table.insert(values, x) end)
        
        expect(values).to.equal({1, 2, 3})
    end)
end)