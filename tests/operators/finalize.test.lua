describe('finalize', function()
    it('should execute on complete', function()
        local finalized = false
        
        Rx.Observable.of(1, 2, 3)
            :finalize(function() finalized = true end)
            :subscribe(function(x) end)
        
        expect(finalized).to.equal(true)
    end)
    
    it('should execute on error', function()
        local finalized = false
        
        Rx.Observable.create(function(observer)
            observer:error("error")
        end)
        :finalize(function() finalized = true end)
        :subscribe(nil, function() end)
        
        expect(finalized).to.equal(true)
    end)
    
    it('should execute on unsubscribe', function()
        local finalized = false
        
        local sub = Rx.Observable.create(function(observer)
            -- Never completes
        end)
        :finalize(function() finalized = true end)
        :subscribe(function(x) end)
        
        sub:unsubscribe()
        expect(finalized).to.equal(true)
    end)
end)