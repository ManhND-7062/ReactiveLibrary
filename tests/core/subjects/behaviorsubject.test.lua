describe('BehaviorSubject', function()
    it('should emit initial value to new subscribers', function()
        local subject = Rx.BehaviorSubject.new(42)
        local value = nil
        subject:subscribe(function(x) value = x end)
        expect(value).to.equal(42)
    end)
    
    it('should emit current value to late subscribers', function()
        local subject = Rx.BehaviorSubject.new(1)
        subject:next(2)
        subject:next(3)
        
        local value = nil
        subject:subscribe(function(x) value = x end)
        expect(value).to.equal(3)
    end)
    
    it('should get current value', function()
        local subject = Rx.BehaviorSubject.new(10)
        subject:next(20)
        expect(subject:get_value()).to.equal(20)
    end)
    
    it('should handle nil as initial value', function()
        local subject = Rx.BehaviorSubject.new(nil)
        local value = "not nil"
        subject:subscribe(function(x) value = x end)
        expect(value).to.equal(nil)
    end)
end)