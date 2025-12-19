-- RxLua - Reactive Extensions for lua
--- An object that is used to receive notifications from an Observable.
-- @class Observer
local Observer = {}
Observer.__index = Observer

--- Creates a new Observer.
-- @arg {function} on_next - Function to handle next values.
-- @arg {function} on_error - Function to handle errors.
-- @arg {function} on_complete  - Function to handle completion.
-- @returns {Observer}
function Observer.new(on_next, on_error, on_complete)
    local self = setmetatable({}, Observer)
    self.on_next = on_next or function() end
    self.on_error = on_error or function(err) print("Error:", err) end
    self.on_complete = on_complete or function() end
    self.closed = false
    return self
end

--- Sends a next notification to the observer.
-- @arg {*} value - The next value.
function Observer:next(value)
    if not self.closed then
        local success, err = pcall(self.on_next, value)
        if not success then
            self:error(err)
        end
        return 1
    else
        return 0
    end
    
end

--- Sends an error notification to the observer.
-- @arg {*} err - The error value.
function Observer:error(err)
    if not self.closed then
        self.closed = true
        self.on_error(err)
    end
end

--- Sends a complete notification to the observer.
function Observer:complete()
    if not self.closed then
        self.closed = true
        self.on_complete()
    end
end

--- Represents a disposable resource, such as the execution of an Observable. A Subscription has one important method, `unsubscribe`, that takes no argument and just disposes the resource held by the subscription.
-- @class Subscription
local Subscription = {}
Subscription.__index = Subscription

--- Creates a new Subscription.
-- @arg {function} unsubscribe_fn - A function that will be called when unsubscribe is invoked.
-- @return {Subscription}
function Subscription.new(unsubscribe_fn)
    local self = setmetatable({}, Subscription)
    self.closed = false
    self.unsubscribe_fn = unsubscribe_fn
    return self
end


--- Disposes the resource held by the subscription.
function Subscription:unsubscribe()
    if not self.closed then
        self.closed = true
        if self.unsubscribe_fn then
            local success,err = pcall(self.unsubscribe_fn)
            if not success then
                print("Error during unsubscribe:", err)
            end 
        end
    end
end

--- Adds a teardown to be called during the unsubscribe() of this subscription.
-- @arg {Subscription} subscription - A subscription to add.
function Subscription:add(subscription)
    if self.closed then
        subscription:unsubscribe()
        return
    end
    
    local parent_unsub = self.unsubscribe_fn
    self.unsubscribe_fn = function()
        if parent_unsub then parent_unsub() end
        subscription:unsubscribe()
    end
end

--- @class Scheduler
--- A Scheduler manages the timing of task execution.
local Scheduler = {}
Scheduler.__index = Scheduler

--- Creates a new Scheduler.
-- @returns {Scheduler}
function Scheduler.new()
    local self = setmetatable({}, Scheduler)
    self.tasks = {}
    self.next_id = 1
    self.time = 0
    return self
end

--- Schedules an action to be executed at a specified time.
-- @arg {function} action - The action to schedule.
-- @arg {number} delay - The delay in milliseconds before executing the action.
-- @returns {number}
function Scheduler:schedule(action, delay)
    delay = delay or 0
    local task_id = self.next_id
    self.next_id = self.next_id + 1
    
    self.tasks[task_id] = {
        action = action,
        time = self.time + delay,
        periodic = false
    }
    
    return task_id
end

--- Schedules an action to be executed periodically.
-- @arg {function} action - The action to schedule periodically.
-- @arg {number} period - The period in milliseconds between executions.
-- @returns {number}
function Scheduler:schedule_periodic(action, period)
    local task_id = self.next_id
    self.next_id = self.next_id + 1
    
    self.tasks[task_id] = {
        action = action,
        time = self.time + period,
        period = period,
        periodic = true
    }
    
    return task_id
end

--- Cancels a scheduled task.
-- @arg {number} task_id - The ID of the scheduled task to cancel.
function Scheduler:cancel(task_id)
    self.tasks[task_id] = nil
end

--- Runs all pending tasks that are scheduled to run at or before the current time.
function Scheduler:run_pending()
    local current_tasks = {}
    for id, task in pairs(self.tasks) do
        if task.time <= self.time then
            table.insert(current_tasks, {id = id, task = task})
        end
    end
    local function sort_tasks(a, b) 
        if a.task.time < b.task.time then
            return true
        elseif a.task.time == b.task.time then
            if a.id < b.id then
                return true
            end
        end
        return false
    end
    table.sort(current_tasks, sort_tasks)
    
    for _, item in ipairs(current_tasks) do
        if self.tasks[item.id] then
            item.task.action()
            if item.task.periodic then
                item.task.time = self.time + item.task.period
            else
                self.tasks[item.id] = nil
            end
        end
    end
end

--- Advances the scheduler's time and runs pending tasks.
-- @arg {number} delta - The time in milliseconds to advance the scheduler.
function Scheduler:advance(delta)
    self.time = self.time + delta
    self:run_pending()
end

--- Represents a collection of future values or events.
--- @class Observable
local Observable = {}
Observable.__index = Observable

--- Creates a new Observable.
-- @arg {function} subscribe_fn - A function that is called when an observer subscribes to the observable.
-- @returns {Observable}
function Observable.new(subscribe_fn)
    local self = setmetatable({}, Observable)
    self.subscribe_fn = subscribe_fn
    return self
end

--- Subscribes an observer to the observable.
-- @arg {table|function} observer_or_fn - An observer object or a function to handle next values.
-- @arg {function} on_error - Function to handle errors (if observer_or_fn is a function).
-- @arg {function} on_complete - Function to handle completion (if observer_or_fn is a function).
-- @returns {Subscription}
function Observable:subscribe(observer_or_fn, on_error, on_complete)
    local observer
    if type(observer_or_fn) == "table" then
        observer = observer_or_fn
    else
        observer = Observer.new(observer_or_fn, on_error, on_complete)
    end
    
    local subscription = self.subscribe_fn(observer)
    return subscription or Subscription.new()
end

-- Applies a series of operators to the observable.
-- @arg {functions...} operators - A list of operator functions to apply.
-- @returns {Observable}
function Observable:pipe(...)
    local operators = {...}
    local result = self
    
    for _, operator in ipairs(operators) do
        result = operator(result)
    end
    
    return result
end

--- Creates an Observable from a subscription function.
-- @arg {function} subscribe_fn - A function that defines the subscription behavior.
function Observable.create(subscribe_fn)
  return Observable.new(subscribe_fn)
end

--- Returns an Observable that immediately completes without producing a value.
-- @returns {Observable}
function Observable.empty()
  return Observable.new(function(observer)
    observer:complete()
  end)
end

--- Returns an Observable that never produces values and never completes.
--- @returns {Observable}
function Observable.never()
  return Observable.new(function(observer) end)
end

--- Returns an Observable that immediately produces an error.
--- @arg {*} message - The error message or value.
--- @returns {Observable}
function Observable.throw(message)
  return Observable.new(function(observer)
    observer:error(message)
  end)
end

local Subject = {}
Subject.__index = Subject
setmetatable(Subject, {__index = Observable})

function Subject.new()
    local self = setmetatable({}, Subject)
    self.observers = {}
    self.closed = false
    self.has_error = false
    self.error_value = nil
    self.completed = false
    return self
end

--- Subscribes an observer to the subject.
-- @arg {table|function} observer_or_fn - An observer object or a function to handle next values.
-- @arg {function} on_error - Function to handle errors (if observer_or_fn is a function).
-- @arg {function} on_complete  - Function to handle completion (if observer_or_fn is a function).
-- @returns {Subscription}
function Subject:subscribe(observer_or_fn, on_error, on_complete)
    if self.closed then
        return Subscription.new()
    end
    
    local observer
    if type(observer_or_fn) == "table" then
        observer = observer_or_fn
    else
        observer = Observer.new(observer_or_fn, on_error, on_complete)
    end
    
    -- If already completed or errored, notify immediately
    if self.has_error then
        observer:error(self.error_value)
        return Subscription.new()
    end
    
    if self.completed then
        observer:complete()
        return Subscription.new()
    end
    
    table.insert(self.observers, observer)
    
    local subscription = Subscription.new(function()
        for i, obs in ipairs(self.observers) do
            if obs == observer then
                table.remove(self.observers, i)
                break
            end
        end
    end)
    
    return subscription
end

--- Emits a value to all subscribed observers.
-- @arg {*} value - The value to emit to observers.
function Subject:next(value)
    if not self.closed then
        for _, observer in ipairs(self.observers) do
            observer:next(value)
        end
    end
end

--- Emits an error to all subscribed observers and closes the subject.
-- @arg {*} err - The error to emit to observers.
function Subject:error(err)
    if not self.closed then
        self.closed = true
        self.has_error = true
        self.error_value = err
        
        for _, observer in ipairs(self.observers) do
            observer:error(err)
        end
        
        self.observers = {}
    end
end

--- Completes the subject and notifies all subscribed observers.
function Subject:complete()
    if not self.closed then
        self.closed = true
        self.completed = true
        
        for _, observer in ipairs(self.observers) do
            observer:complete()
        end
        
        self.observers = {}
    end
end

--- Returns an observable that is linked to this subject.
-- @return {Observable}
function Subject:as_observable()
    local subject = self
    return Observable.new(function(observer)
        return subject:subscribe(observer)
    end)
end

--- @class BehaviorSubject
-- @description A BehaviorSubject is a type of Subject that requires an initial value and emits its current value to new subscribers.
local BehaviorSubject = {}
BehaviorSubject.__index = BehaviorSubject
setmetatable(BehaviorSubject, {__index = Subject})

--- Creates a new BehaviorSubject with the specified initial value.
-- @arg {*} initial_value - The initial value for the BehaviorSubject.
-- @returns {BehaviorSubject}
function BehaviorSubject.new(initial_value)
    local self = setmetatable(Subject.new(), BehaviorSubject)
    self.current_value = initial_value
    return self
end

--- Subscribes an observer to the BehaviorSubject and immediately emits the current value.  
-- @arg {table|function} observer_or_fn - An observer object or a function to handle next values.
-- @arg {function} on_error - Function to handle errors (if observer_or_fn is a function
-- @arg {function} on_complete  - Function to handle completion (if observer_or_fn is a function).
-- @returns {Subscription}
function BehaviorSubject:subscribe(observer_or_fn, on_error, on_complete)
    local observer
    if type(observer_or_fn) == "table" then
        observer = observer_or_fn
    else
        observer = Observer.new(observer_or_fn, on_error, on_complete)
    end
    
    -- Emit current value immediately
    if not self.closed and not self.has_error then
        observer:next(self.current_value)
    end
    
    return Subject.subscribe(self, observer)
end

--- Emits a value to all subscribed observers and updates the current value.
-- @arg {*} value - The value to emit to observers.
function BehaviorSubject:next(value)
    self.current_value = value
    Subject.next(self, value)
end

--- Gets the current value of the BehaviorSubject.
-- @return {*} - The current value.
function BehaviorSubject:get_value()
    return self.current_value
end

--- @class ReplaySubject
--- A ReplaySubject is a type of Subject that records multiple values and replays them to new subscribers.
local ReplaySubject = {}
ReplaySubject.__index = ReplaySubject
setmetatable(ReplaySubject, {__index = Subject})

--- Creates a new ReplaySubject with the specified buffer size and window time.
-- @arg {number} buffer_size - The maximum number of values to store in the buffer.
-- @arg {number} window_time - The maximum age of values to store in the buffer (in seconds).
-- @return {ReplaySubject}
function ReplaySubject.new(buffer_size, window_time)

    local self = setmetatable(Subject.new(), ReplaySubject)
    self.buffer_size = buffer_size or math.huge
    self.window_time = window_time
    self.buffer = {}
    self.timestamps = {}

    return self
end

--- Trims the buffer based on buffer_size and window_time.
function ReplaySubject:_trim_buffer()
    local current_time = os.time()
    
    -- Remove old values based on window_time
    if self.window_time and type(self.window_time) == "number" then
        local i = 1
        while i <= #self.buffer do
            if current_time - self.timestamps[i] > self.window_time then
                table.remove(self.buffer, i)
                table.remove(self.timestamps, i)
            else
                break
            end
        end
    end
    
    -- Remove excess values based on buffer_size
    while #self.buffer > self.buffer_size do
        table.remove(self.buffer, 1)
        table.remove(self.timestamps, 1)
    end
end

--- @description Emits a value to all subscribed observers and stores it in the buffer.
-- @arg {*} value - The value to emit to observers.
function ReplaySubject:next(value)
    if not self.closed then
        -- Store value in buffer
        table.insert(self.buffer, value)
        table.insert(self.timestamps, os.time())

        self:_trim_buffer()
        -- Emit to current observers
        for _, observer in ipairs(self.observers) do
            observer:next(value)
        end
    end
end

--- @description Subscribes an observer to the ReplaySubject and replays buffered values.
-- @arg {table|function} observer_or_fn - An observer object or a function to handle next values.
-- @arg {function} on_error  - Function to handle errors (if observer_or_fn is a function).
-- @arg {function} on_complete - Function to handle completion (if observer_or_fn is a function).
-- @returns {Subscription}
function ReplaySubject:subscribe(observer_or_fn, on_error, on_complete)

    local observer
    if type(observer_or_fn) == "table" then
        observer = observer_or_fn
    else
        observer = Observer.new(observer_or_fn, on_error, on_complete)
    end

    if self.has_error then
        print("Replaying error to new subscriber")
        observer:error(self.error_value)
        return Subscription.new()
    end
    
    if self.closed then
        return Subscription.new()
    end
    
    -- If already completed or errored, handle accordingly
    
    -- Replay buffered values to new subscriber
    self:_trim_buffer()

    for _, value in ipairs(self.buffer) do
        observer:next(value)
    end
    
    if self.completed then
        observer:complete()
        return Subscription.new()
    end
    
    table.insert(self.observers, observer)
    
    local subscription = Subscription.new(function()
        for i, obs in ipairs(self.observers) do
            if obs == observer then
                table.remove(self.observers, i)
                break
            end
        end
    end)
    
    return subscription
end

--- Creates an observable that emits the provided values in sequence and then completes.
-- @arg {*...} any - A variable number of values to emit.
-- @returns {Observable}
function Observable.of(...)
    local values = {...}
    return Observable.new(function(observer)
        for _, v in ipairs(values) do
            observer:next(v)
        end
        observer:complete()
        return Subscription.new()
    end)
end

--= Creates an observable that emits the values from the provided table in sequence and then completes.
-- @arg {table} tbl - A table of values to emit.
-- @returns {Observable}
function Observable.from(tbl)
    return Observable.new(function(observer)
        for _, v in ipairs(tbl) do
            observer:next(v)
        end
        observer:complete()
        return Subscription.new()
    end)
end

-- Creates an observable that emits sequential numbers every specified interval of time.
-- @arg {number} ms - The interval in milliseconds.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @returns {Observable}
function Observable.interval(ms, scheduler)
    return Observable.new(function(observer)
        local count = 0
        local timer_id
        
        local function tick()
            observer:next(count)
            count = count + 1
        end
        
        if scheduler then
            timer_id = scheduler:schedule_periodic(tick, ms)
        else
            -- Fallback: just emit synchronously for demonstration
            tick()
        end
        
        return Subscription.new(function()
            if scheduler and timer_id then
                scheduler:cancel(timer_id)
            end
        end)
    end)
end

--- Creates an observable that emits sequential numbers after an initial delay and optionally at a specified period.
-- @arg {number} due_time - The initial delay in milliseconds.
-- @arg {number|nil} period - The period in milliseconds for subsequent emissions. If nil, emits only once after due_time.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @returns {Observable}
function Observable.timer(due_time, period, scheduler)
    return Observable.new(function(observer)
        local count = 0
        local timer_id
        
        if period then
            -- Emit after due_time, then periodically
            timer_id = scheduler:schedule(function()
                observer:next(count)
                count = count + 1
                
                timer_id = scheduler:schedule_periodic(function()
                    observer:next(count)
                    count = count + 1
                end, period)
            end, due_time)
        else
            -- Emit once after due_time and complete
            timer_id = scheduler:schedule(function()
                observer:next(0)
                observer:complete()
            end, due_time)
        end
        
        return Subscription.new(function()
            if timer_id then
                scheduler:cancel(timer_id)
            end
        end)
    end)
end

--- Creates an observable that emits a range of sequential numbers.
-- @arg {number} start - The starting number.
-- @arg {number} count - The number of sequential numbers to emit.
-- @returns {Observable}
function Observable.range(start, count)
    return Observable.new(function(observer)
        for i = start, start + count - 1 do
            observer:next(i)
        end
        observer:complete()
        return Subscription.new()
    end)
end

--- Converts a marble diagram string into an observable that emits values according to the diagram.
-- @arg {string} marble_string - The marble diagram string.
-- @arg {Scheduler} scheduler - The scheduler to use for timing the emissions.
-- @arg {number} time_per_char - The time in milliseconds represented by each character in the marble string (default is 10).
-- @returns {Observable} An observable that emits values according to the diagram.
function Observable.marble_to_observable(marble_string, scheduler, time_per_char)
    time_per_char = time_per_char or 10
    
    return Observable.new(function(observer)
        local time = 0
        local tasks = {}
        
        for i = 1, #marble_string do
            local char = marble_string:sub(i, i)
            
            if char == '-' then
                -- Empty frame, do nothing
            elseif char == '|' then
                -- Complete
                table.insert(tasks, scheduler:schedule(function()
                    observer:complete()
                end, time))
            elseif char == '#' then
                -- Error
                table.insert(tasks, scheduler:schedule(function()
                    observer:error("Error at position " .. i)
                end, time))
            elseif char ~= ' ' then
                -- Emit value
                local value = char
                table.insert(tasks, scheduler:schedule(function()
                    observer:next(value)
                end, time))
            end
            
            time = time + time_per_char
        end
        
        return Subscription.new(function()
            for _, task_id in ipairs(tasks) do
                scheduler:cancel(task_id)
            end
        end)
    end)
end

--- Combines multiple observables by emitting an array of the latest values from each source whenever any source emits a new value.
-- @arg {Observable...} sources - A variable number of observables to combine.
-- @returns {Observable}
function Observable:combine_with(...)
    local sources = {self, ...}
    return Observable.new(function(observer)
        local values = {}
        local has_value = {}
        local completed = {}
        local subscriptions = {}
        
        -- Check if all sources have emitted at least once
        local function has_all_values()
            for i = 1, #sources do
                if not has_value[i] then
                    return false
                end
            end
            return true
        end
        
        -- Check if all sources have completed
        local function all_completed()
            for i = 1, #sources do
                if not completed[i] then
                    return false
                end
            end
            return true
        end
        
        -- Emit combined values
        local function emit()
            if has_all_values() then
                local combined_values = {}
                for i = 1, #sources do
                    table.insert(combined_values, values[i])
                end
                observer:next(combined_values)
            end
        end
        
        -- Subscribe to each source
        for i, source in ipairs(sources) do
            subscriptions[i] = source:subscribe(
                function(value)
                    values[i] = value
                    has_value[i] = true
                    emit()
                end,
                function(err)
                    observer:error(err)
                end,
                function()
                    completed[i] = true
                    if all_completed() then
                        observer:complete()
                    end
                end
            )
        end
        
        return Subscription.new(function()
            for _, sub in ipairs(subscriptions) do
                sub:unsubscribe()
            end
        end)
    end)
end

--- Concatenates multiple observables sequentially.
-- @arg {Observable...} observables - The observables to concatenate.
-- @returns {Observable}
function Observable.concat(...)
    local observables = {...}
    return Observable.new(function(observer)
        local index = 1
        local current_subscription
        
        local function subscribe_next()
            if index > #observables then
                observer:complete()
                return
            end
            
            current_subscription = observables[index]:subscribe(
                function(value) observer:next(value) end,
                function(err) observer:error(err) end,
                function()
                    index = index + 1
                    subscribe_next()
                end
            )
        end
        
        subscribe_next()
        
        return Subscription.new(function()
            if current_subscription then
                current_subscription:unsubscribe()
            end
        end)
    end)
end

--- Merges values from the source observable and another observable.
-- @arg {Observable} other - Another observable to merge with.
-- @returns {Observable}
function Observable:merge_with(other)
    local source = self
    return Observable.new(function(observer)
        local completed_count = 0
        local subscription1 = source:subscribe(
            function(value) observer:next(value) end,
            function(err) observer:error(err) end,
            function()
                completed_count = completed_count + 1
                if completed_count == 2 then
                    observer:complete()
                end
            end
        )
        
        local subscription2 = other:subscribe(
            function(value) observer:next(value) end,
            function(err) observer:error(err) end,
            function()
                completed_count = completed_count + 1
                if completed_count == 2 then
                    observer:complete()
                end
            end
        )
        
        local combined = Subscription.new(function()
            subscription1:unsubscribe()
            subscription2:unsubscribe()
        end)
        
        return combined
    end)
end

--- Splits the source observable into two observables based on a predicate function.
-- @arg {function} predicate_fn - A function to test each emitted value.
-- @returns {Observable}
-- @returns {Observable}
function Observable:partition(predicate_fn)
    local source = self
    local pass = source:filter(predicate_fn)
    local fail = source:filter(function(x) return not predicate_fn(x) end)
    return pass, fail
end

--- Converts a cold observable into a hot observable by multicasting its emissions through a Subject.
-- @returns {table} A table containing the `observable` and a `connect` function.
function Observable:publish()
    local source = self
    local subject = Subject.new()
    
    return {
        observable = Observable.new(function(observer)
            return subject:subscribe(observer)
        end),
        connect = function()
            return source:subscribe(
                function(value) subject:next(value) end,
                function(err) subject:error(err) end,
                function() subject:complete() end
            )
        end
    }
end

--- Races multiple observables, emitting values from the first one to emit.
-- @arg {Observable...} observables- The observables totally competing.
-- @return {Observable}
function Observable.race(...)
    local observables = {...}
    return Observable.new(function(observer)
        local has_winner = false
        local subscriptions = {}
        
        local function cancel_others()
            for _, sub in ipairs(subscriptions) do
                sub:unsubscribe()
            end
        end
        
        for _, obs in ipairs(observables) do
            local sub = obs:subscribe(
                function(value)
                    if not has_winner then
                        has_winner = true
                        cancel_others()
                        observer:next(value)
                    end
                end,
                function(err)
                    if not has_winner then
                        has_winner = true
                        cancel_others()
                        observer:error(err)
                    end
                end,
                function()
                    if not has_winner then
                        has_winner = true
                        cancel_others()
                        observer:complete()
                    end
                end
            )
            table.insert(subscriptions, sub)
        end
        
        return Subscription.new(function()
            cancel_others()
        end)
    end)
end

--- Shares a single subscription to the source observable among multiple subscribers.
-- @returns {Observable}
function Observable:share()
    local source = self
    local subject = nil
    local subscription = nil
    local ref_count = 0
    
    return Observable.new(function(observer)
        ref_count = ref_count + 1
        
        if not subject then
            subject = Subject.new()
            subscription = source:subscribe(
                function(value) subject:next(value) end,
                function(err) subject:error(err) end,
                function() subject:complete() end
            )
        end
        
        local sub = subject:subscribe(observer)
        
        return Subscription.new(function()
            ref_count = ref_count - 1
            sub:unsubscribe()
            
            if ref_count == 0 and subscription then
                subscription:unsubscribe()
                subject = nil
                subscription = nil
            end
        end)
    end)
end

--- Shares a single subscription to the source observable among multiple subscribers and replays a specified number of previous emissions to new subscribers.
-- @arg {number} buffer_size - The maximum number of previous emissions to replay to new subscribers.
-- @arg {number} window_time - The maximum time in milliseconds to replay previous emissions to new subscribers.
-- @returns {Observable}
function Observable:share_replay(buffer_size, window_time)
    local source = self
    local subject = nil
    local subscription = nil
    local ref_count = 0
    return Observable.new(function(observer)
        ref_count = ref_count + 1
        
        if not subject then
            subject = ReplaySubject.new(buffer_size, window_time)
            subscription = source:subscribe(
                function(value) 
                    subject:next(value) end,
                function(err) subject:error(err) end,
                function() end
            )
        end
        
        local sub = subject:subscribe(observer)
        
        return Subscription.new(function()
            ref_count = ref_count - 1
            sub:unsubscribe()
            
            if ref_count == 0 and subscription then
                subscription:unsubscribe()
                subject = nil
                subscription = nil
            end
        end)
    end)
end

--- Prepends initial values to the source observable.
-- @arg {*...} values - The initial values to prepend.
-- @returns {Observable} An observable that emits the initial values followed by the source values.
function Observable:start_with(...)
    local initial_values = {...}
    return Observable.new(function(observer)
        for _, value in ipairs(initial_values) do
            observer:next(value)
        end
        
        return self:subscribe(
            function(value) observer:next(value) end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end

-- When the source observable emits, emit the latest values from the other observables.
-- @arg {Observable...} observables- A variable number of observables to get latest values from.
-- @return {Observable}
function Observable:with_latest_from(...)
    local source = self
    local others = {...}
    
    return Observable.new(function(observer)
        local other_values = {}
        local other_has_value = {}
        local subscriptions = {}
        
        -- Check if all other sources have emitted
        local function has_all_other_values()
            for i = 1, #others do
                if not other_has_value[i] then
                    return false
                end
            end
            return true
        end
        
        -- Subscribe to other sources (only store their latest values)
        for i, other in ipairs(others) do
            subscriptions[i] = other:subscribe(
                function(value)
                    other_values[i] = value
                    other_has_value[i] = true
                end,
                function(err) observer:error(err) end,
                function() end  -- Don't complete when other sources complete
            )
        end
        
        -- Subscribe to main source
        local main_sub = source:subscribe(
            function(value)
                if has_all_other_values() then
                    local combined = {value}
                    for i = 1, #others do
                        table.insert(combined, other_values[i])
                    end
                    observer:next(combined)
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
        
        table.insert(subscriptions, main_sub)
        
        return Subscription.new(function()
            for _, sub in ipairs(subscriptions) do
                sub:unsubscribe()
            end
        end)
    end)
end

--- Combines multiple observables by emitting arrays of their latest values.
-- @arg {Observable...} observables - The observables to combine.
-- @return {Observable}
function Observable.zip(...)
    local observables = {...}
    return Observable.new(function(observer)
        local buffers = {}
        local completed = {}
        local subscriptions = {}
        
        for i = 1, #observables do
            buffers[i] = {}
            completed[i] = false
        end
        
        local function try_emit()
            -- Check if all buffers have at least one value
            local can_emit = true
            for i = 1, #observables do
                if #buffers[i] == 0 then
                    can_emit = false
                    break
                end
            end
            
            if can_emit then
                local values = {}
                for i = 1, #observables do
                    table.insert(values, table.remove(buffers[i], 1))
                end
                observer:next(values)
            end
            
            -- Check if any stream completed with empty buffer
            for i = 1, #observables do
                if completed[i] and #buffers[i] == 0 then
                    observer:complete()
                    return
                end
            end
        end
        
        for i, obs in ipairs(observables) do
            subscriptions[i] = obs:subscribe(
                function(value)
                    table.insert(buffers[i], value)
                    try_emit()
                end,
                function(err) observer:error(err) end,
                function()
                    completed[i] = true
                    try_emit()
                end
            )
        end
        
        return Subscription.new(function()
            for _, sub in ipairs(subscriptions) do
                sub:unsubscribe()
            end
        end)
    end)
end

--- Buffers values from the source observable until the buffer reaches the specified count and emits them as an array.
-- @arg {number} count - The number of items to buffer.
-- @returns {Observable}
function Observable:buffer_count(count)
    local source = self
    return Observable.new(function(observer)
        local buffer = {}
        
        local source_sub = source:subscribe(
            function(value)
                table.insert(buffer, value)
                if #buffer >= count then
                    observer:next(buffer)
                    buffer = {}
                end
            end,
            function(err) observer:error(err) end,
            function()
                if #buffer > 0 then
                    observer:next(buffer)
                end
                observer:complete()
            end
        )
        
        return source_sub
    end)
end

-- Buffers values from the source observable for a specified time span and emits them as an array.
-- @arg {number} ms - The interval in milliseconds.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @returns {Observable}
function Observable:buffer_time(ms, scheduler)
    local source = self
    return Observable.new(function(observer)
        local buffer = {}
        local timer_id
        
        local function emit_buffer()
            if #buffer > 0 then
                observer:next(buffer)
                buffer = {}
            end
        end
        
        timer_id = scheduler:schedule_periodic(function()
            emit_buffer()
        end, ms)
        
        local source_sub = source:subscribe(
            function(value)
                table.insert(buffer, value)
            end,
            function(err)
                scheduler:cancel(timer_id)
                observer:error(err)
            end,
            function()
                scheduler:cancel(timer_id)
                emit_buffer()
                observer:complete()
            end
        )
        
        return Subscription.new(function()
            scheduler:cancel(timer_id)
            source_sub:unsubscribe()
        end)
    end)
end

--- Projects each source value to an observable which is concatenated in the output observable.
-- @arg {function} project_fn - A function that, when applied to an item emitted by the source observable, returns an observable.
-- @returns {Observable}
function Observable:concat_map(project_fn)
    local source = self
    return Observable.new(function(observer)
        local queue = {}
        local active = false
        local source_completed = false
        
        local function process_next()
            if #queue == 0 then
                active = false
                if source_completed then
                    observer:complete()
                end
                return
            end
            
            active = true
            local value = table.remove(queue, 1)
            local inner_obs = project_fn(value)
            
            inner_obs:subscribe(
                function(inner_value) observer:next(inner_value) end,
                function(err) observer:error(err) end,
                function() process_next() end
            )
        end
        
        local main_subscription = source:subscribe(
            function(value)
                table.insert(queue, value)
                if not active then
                    process_next()
                end
            end,
            function(err) observer:error(err) end,
            function()
                source_completed = true
                if not active then
                    observer:complete()
                end
            end
        )
        
        return main_subscription
    end)
end

--- Converts notification objects back into the emissions they represent.
-- @returns {Observable}
function Observable:dematerialize()
    local source = self
    return Observable.new(function(observer)
        return source:subscribe(
            function(notification)
                if notification.kind == "next" then
                    observer:next(notification.value)
                elseif notification.kind == "error" then
                    observer:error(notification.error)
                elseif notification.kind == "complete" then
                    observer:complete()
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end

--- Projects each source value to an observable which is merged in the output observable only if the previous inner observable has completed.
-- @arg {function} project_fn - A function that, when applied to an item emitted by the source observable, returns an observable.
-- @returns {Observable}
function Observable:exhaust_map(project_fn)
    local source = self
    return Observable.new(function(observer)
        local inner_active = false
        
        local main_subscription = source:subscribe(
            function(value)
                if not inner_active then
                    inner_active = true
                    local inner_obs = project_fn(value)
                    
                    inner_obs:subscribe(
                        function(inner_value) observer:next(inner_value) end,
                        function(err) observer:error(err) end,
                        function() inner_active = false end
                    )
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
        
        return main_subscription
    end)
end

--- Projects each source value to an observable which is merged in the output observable.
-- @arg {function} project_fn - A function that, when applied to an item emitted by the source observable, returns an observable.
-- @returns {Observable}
function Observable:flat_map(project_fn)
    local source = self
    return Observable.new(function(observer)
        local active_count = 0
        local source_completed = false
        local main_subscription
        
        local function check_complete()
            if source_completed and active_count == 0 then
                observer:complete()
            end
        end
        
        main_subscription = source:subscribe(
            function(value)
                active_count = active_count + 1
                local inner_obs = project_fn(value)
                
                inner_obs:subscribe(
                    function(inner_value) observer:next(inner_value) end,
                    function(err) observer:error(err) end,
                    function()
                        active_count = active_count - 1
                        check_complete()
                    end
                )
            end,
            function(err) observer:error(err) end,
            function()
                source_completed = true
                check_complete()
            end
        )
        
        return main_subscription
    end)
end

--- Groups the items emitted by the source observable according to a specified key selector function.
-- @arg {function} key_selector  - A function that extracts the key for each item.
-- @arg {function} element_selector - A function that extracts the element for each item.
-- @returns {Observable}
function Observable:group_by(key_selector, element_selector)
    element_selector = element_selector or function(x) return x end
    local source = self
    
    return Observable.new(function(observer)
        local groups = {}
        
        return source:subscribe(
            function(value)
                local key = key_selector(value)
                local element = element_selector(value)
                
                if not groups[key] then
                    local group_subject = Subject.new()
                    groups[key] = group_subject
                    
                    observer:next({
                        key = key,
                        observable = group_subject:as_observable()
                    })
                end
                
                groups[key]:next(element)
            end,
            function(err)
                for _, group in pairs(groups) do
                    group:error(err)
                end
                observer:error(err)
            end,
            function()
                for _, group in pairs(groups) do
                    group:complete()
                end
                observer:complete()
            end
        )
    end)
end

-- Applies a transformation function to each emitted value.
-- @arg {function} transform_fn - A function to transform each emitted value.
-- @returns {Observable}
function Observable:map(transform_fn)
    local source = self
    return Observable.new(function(observer)
        return source:subscribe(
            function(value)
                local success, result = pcall(transform_fn, value)
                if success then
                    observer:next(result)
                else
                    observer:error(result)
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end

--- Represents the notification of an event in the source observable.
-- @returns {Observable}
function Observable:materialize()
    local source = self
    return Observable.new(function(observer)
        return source:subscribe(
            function(value)
                observer:next({kind = "next", value = value})
            end,
            function(err)
                observer:next({kind = "error", error = err})
                observer:complete()
            end,
            function()
                observer:next({kind = "complete"})
                observer:complete()
            end
        )
    end)
end

--- Emits the previous and current values as a pair for each emission from the source observable.
-- @returns {Observable}
function Observable:pairwise()
    local source = self
    return Observable.new(function(observer)
        local has_prev = false
        local prev_value = nil
        
        return source:subscribe(
            function(value)
                if has_prev then
                    observer:next({prev_value, value})
                end
                prev_value = value
                has_prev = true
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end

--- Applies an accumulator function to each emitted value.
-- @arg {function} accumulator_fn - A function to accumulate values.
-- @arg {*} seed - The initial value for the accumulator.
-- @returns {Observable}
function Observable:reduce(accumulator_fn, seed)
    local source = self
    return Observable.new(function(observer)
        local acc = seed
        return source:subscribe(
            function(value)
                local success, result = pcall(accumulator_fn, acc, value)
                if success then
                    acc = result
                else
                    observer:error(result)
                end
            end,
            function(err) observer:error(err) end,
            function()
                observer:next(acc)
                observer:complete()
            end
        )
    end)
end

-- Accumulates values from the source observable using an accumulator function.
-- @arg {function} accumulator_fn - A function that takes the accumulated value and the current value, and returns the new accumulated value.
-- @arg {*} seed  - An optional initial value for the accumulator.
-- @returns {Observable}
function Observable:scan(accumulator_fn, seed)
    return Observable.new(function(observer)
        local acc = seed
        local has_seed = seed ~= nil
        
        return self:subscribe(
            function(value)
                if has_seed then
                    acc = accumulator_fn(acc, value)
                else
                    acc = value
                    has_seed = true
                end
                observer:next(acc)
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end

--- Projects each source value to an observable which is switched to in the output observable.
-- @arg {function} project_fn - A function that, when applied to an item emitted by the source observable, returns an observable.
-- @returns {Subscription}
function Observable:switch_map(project_fn)
    local source = self
    return Observable.new(function(observer)
        local inner_subscription = nil
        
        local main_subscription = source:subscribe(
            function(value)
                -- Unsubscribe from previous inner observable
                if inner_subscription then
                    inner_subscription:unsubscribe()
                end
                
                local inner_obs = project_fn(value)
                inner_subscription = inner_obs:subscribe(
                    function(inner_value) observer:next(inner_value) end,
                    function(err) observer:error(err) end,
                    function() end  -- Don't complete on inner completion
                )
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
        
        return Subscription.new(function()
            if inner_subscription then
                inner_subscription:unsubscribe()
            end
            main_subscription:unsubscribe()
        end)
    end)
end

--- Splits the source observable into windows (sub-observables) based on a time span.
-- @arg {number} ms - The interval in milliseconds.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @return {Observable}
function Observable:window_time(ms, scheduler)
    local source = self
    return Observable.new(function(observer)
        local current_window = Subject.new()
        observer:next(current_window:as_observable())
        
        local timer_id = scheduler:schedule_periodic(function()
            current_window:complete()
            current_window = Subject.new()
            observer:next(current_window:as_observable())
        end, ms)
        
        local source_sub = source:subscribe(
            function(value)
                current_window:next(value)
            end,
            function(err)
                scheduler:cancel(timer_id)
                current_window:error(err)
                observer:error(err)
            end,
            function()
                scheduler:cancel(timer_id)
                current_window:complete()
                observer:complete()
            end
        )
        
        return Subscription.new(function()
            scheduler:cancel(timer_id)
            current_window:complete()
            source_sub:unsubscribe()
        end)
    end)
end

--- Emits a default value if the source observable completes without emitting any values.
-- @arg {*} default_value - The default value to emit if the source is empty.
-- @returns {Observable} An observable that emits the default value if the source is empty.
function Observable:default_if_empty(default_value)
    return Observable.new(function(observer)
        local has_value = false
        
        return self:subscribe(
            function(value)
                has_value = true
                observer:next(value)
            end,
            function(err) observer:error(err) end,
            function()
                if not has_value then
                    observer:next(default_value)
                end
                observer:complete()
            end
        )
    end)
end

--- Emits values from the source observable only when they are different from the previous value.
-- @arg {function} compare_fn - An optional function to compare the previous and current values.
-- @returns {Observable} An observable that emits only distinct consecutive values.
function Observable:distinct_until_changed( compare_fn)
    compare_fn = compare_fn or function(a, b) return a == b end
    
    return Observable.new(function(observer)
        local has_prev = false
        local prev_value = nil
        
        return self:subscribe(
            function(value)
                if not has_prev or not compare_fn(prev_value, value) then
                    observer:next(value)
                    prev_value = value
                    has_prev = true
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end

--- Removes duplicate values from the source observable.
-- @arg {function} key_selector - An optional function to select the key for comparison.
-- @returns {Observable} An observable that emits only distinct values.
function Observable:distinct(key_selector)
    key_selector = key_selector or function(x) return x end
    
    return Observable.new(function(observer)
        local seen = {}
        
        return self:subscribe(
            function(value)
                local key = key_selector(value)
                if not seen[key] then
                    seen[key] = true
                    observer:next(value)
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end

--- Emits the item at the specified index from the source observable.
-- @arg {number} index - The zero-based index of the item to emit.
-- @arg {*} default_value - The default value to emit if the index is out of bounds
-- @returns {Observable}
function Observable:element_at(index, default_value)
    local source = self
    return Observable.new(function(observer)
        local current_index = 0
        return source:subscribe(
            function(value)
                if current_index == index then
                    observer:next(value)
                    observer:complete()
                end
                current_index = current_index + 1
            end,
            function(err) observer:error(err) end,
            function()
                if default_value ~= nil then
                    observer:next(default_value)
                    observer:complete()
                else
                    observer:error("Index out of bounds: " .. index)
                end
            end
        )
    end)
end

--- Determines whether all items emitted by the source observable satisfy the specified predicate.
-- @arg {function} predicate_fn - A function to test each emitted value.
-- @returns {Observable}
function Observable:every(predicate_fn)
    local source = self
    return Observable.new(function(observer)
        return source:subscribe(
            function(value)
                if not predicate_fn(value) then
                    observer:next(false)
                    observer:complete()
                end
            end,
            function(err) observer:error(err) end,
            function()
                observer:next(true)
                observer:complete()
            end
        )
    end)
end

-- Emits only those values that pass the predicate function test.
-- @arg {function} predicate_fn - A function to test each emitted value.
-- @returns {Observable}
function Observable:filter(predicate_fn)
    local source = self
    return Observable.new(function(observer)
        return source:subscribe(
            function(value)
                local success, result = pcall(predicate_fn, value)
                if success and result then
                    observer:next(value)
                elseif not success then
                    observer:error(result)
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end

--- Finds the index of the first item emitted by the source observable that satisfies the specified predicate.
-- @arg {function} predicate_fn - A function to test each emitted value.
-- @returns {Observable}
function Observable:find_index(predicate_fn)
    local source = self
    return Observable.new(function(observer)
        local index = 0
        return source:subscribe(
            function(value)
                if predicate_fn(value) then
                    observer:next(index)
                    observer:complete()
                else
                    index = index + 1
                end
            end,
            function(err) observer:error(err) end,
            function()
                observer:next(-1)
                observer:complete()
            end
        )
    end)
end

--- Determines whether any item emitted by the source observable satisfies the specified predicate.
-- @arg {function} predicate_fn - A function to test each emitted value.
-- @returns {Observable}
function Observable:find(predicate_fn)
    local source = self
    return Observable.new(function(observer)
        return source:subscribe(
            function(value)
                if predicate_fn(value) then
                    observer:next(value)
                    observer:complete()
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end

--- Emits only the first value from the observable sequence.
-- @returns {Observable} An observable that emits the first value.
function Observable:first()
    return self:take(1)
end

--- Ignores all items emitted by the source observable and only passes through termination events.
-- @returns {Observable}
function Observable:ignore_elements()
    local source = self
    return Observable.new(function(observer)
        return source:subscribe(
            function(_) end,  -- Ignore all values
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end

--- Determines whether the observable sequence is empty.
-- @returns {Observable} An observable that emits true if empty, false otherwise.
function Observable:is_empty()
    return Observable.new(function(observer)
        local is_empty = true
        
        return self:subscribe(
            function(_)
                is_empty = false
            end,
            function(err) observer:error(err) end,
            function()
                observer:next(is_empty)
                observer:complete()
            end
        )
    end)
end

--- Emits only the last value from the observable sequence.
-- @returns {Observable} An observable that emits the last value.
function Observable:last()
    return Observable.new(function(observer)
        local last_value = nil
        local has_value = false
        
        return self:subscribe(
            function(value)
                last_value = value
                has_value = true
            end,
            function(err) observer:error(err) end,
            function()
                if has_value then
                    observer:next(last_value)
                end
                observer:complete()
            end
        )
    end)
end

--- Emits values from the source observable only after the notifier observable emits a value.
-- @arg {Observable} notifier - An observable that, when it emits a value, will cause the source observable to start emitting values.
-- @returns {Observable}
function Observable:skip_until(notifier)
    local source = self
    return Observable.new(function(observer)
        local skipping = true
        
        local notifier_sub
        notifier_sub = notifier:subscribe(
            function(_)
                skipping = false
                notifier_sub:unsubscribe()
            end,
            function(err) observer:error(err) end,
            function() end
        )
        
        local source_sub = source:subscribe(
            function(value)
                if not skipping then
                    observer:next(value)
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
        
        return Subscription.new(function()
            source_sub:unsubscribe()
            notifier_sub:unsubscribe()
        end)
    end)
end

--- Emits values from the source observable while the predicate function returns true.
-- @arg {function} predicate_fn - A function to test each emitted value.
-- @returns {Observable}
function Observable:skip_while(predicate_fn)
    local source = self
    return Observable.new(function(observer)
        local skipping = true
        
        return source:subscribe(
            function(value)
                if skipping then
                    skipping = predicate_fn(value)
                end
                if not skipping then
                    observer:next(value)
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end

--- Skips the first `count` values from the source observable.
-- @arg {number} count - The number of values to skip.
-- @return {Observable}
function Observable:skip(count)
    local source = self
    return Observable.new(function(observer)
        local skipped = 0
        return source:subscribe(
            function(value)
                if skipped >= count then
                    observer:next(value)
                else
                    skipped = skipped + 1
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end

--- Determines whether any item emitted by the source observable satisfies the specified predicate.
-- @arg {function} predicate_fn  - A function to test each emitted value.
-- @return {Observable}
function Observable:some(predicate_fn)
    local source = self
    return Observable.new(function(observer)
        return source:subscribe(
            function(value)
                if predicate_fn(value) then
                    observer:next(true)
                    observer:complete()
                end
            end,
            function(err) observer:error(err) end,
            function()
                observer:next(false)
                observer:complete()
            end
        )
    end)
end

--- Emits values from the source observable until the notifier observable emits a value.
-- @arg {Observable} notifier - An observable that, when it emits a value, will cause the source observable to complete.
-- @returns {Observable}
function Observable:take_until(notifier)
    local source = self
    return Observable.new(function(observer)
        local source_sub = source:subscribe(
            function(value) observer:next(value) end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
        
        local notifier_sub = notifier:subscribe(
            function(_)
                observer:complete()
                source_sub:unsubscribe()
            end,
            function(err) observer:error(err) end,
            function() end
        )
        
        return Subscription.new(function()
            source_sub:unsubscribe()
            notifier_sub:unsubscribe()
        end)
    end)
end

--- Emits values from the source observable while the predicate function returns true.
-- @arg {function} predicate_fn - A function to test each emitted value.
-- @arg {boolean} inclusive - If true, includes the first value that causes the predicate to return false.
-- @return {Observable}
function Observable:take_while(predicate_fn, inclusive)
    local source = self
    return Observable.new(function(observer)
        return source:subscribe(
            function(value)
                local should_take = predicate_fn(value)
                if should_take then
                    observer:next(value)
                else
                    if inclusive then
                        observer:next(value)
                    end
                    observer:complete()
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end

--- Emits only the first `count` values from the source observable.
-- @arg {number} count - The number of values to take.
-- @returns {Observable}
function Observable:take(count)
    local source = self
    return Observable.new(function(observer)
        local taken = 0
        local subscription
        
        subscription = source:subscribe(
            function(value)
                if taken < count then
                    observer:next(value)
                    taken = taken + 1
                    if taken >= count then
                        observer:complete()
                        subscription:unsubscribe()
                    end
                end
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
        
        return subscription
    end)
end

--- Catches errors from the source observable and switches to a fallback observable.
-- @arg {function} selector_fn - A function that takes an error and returns a new observable.
-- @returns {Observable} An observable that switches to the fallback observable on error.
function Observable:catch_error(selector_fn)
    return Observable.new(function(observer)
        return self:subscribe(
            function(value) observer:next(value) end,
            function(err)
                local fallback = selector_fn(err)
                fallback:subscribe(
                    function(value) observer:next(value) end,
                    function(err2) observer:error(err2) end,
                    function() observer:complete() end
                )
            end,
            function() observer:complete() end
        )
    end)
end

--- Invokes a callback function when the observable terminates (completes, errors, or is unsubscribed).
-- @arg {function} callback - A function to invoke on termination.
-- @returns {Observable} An observable that invokes the callback on termination.
function Observable:finalize(callback)
    return Observable.new(function(observer)
        local subscription = self:subscribe(
            function(value) observer:next(value) end,
            function(err)
                pcall(callback)
                observer:error(err)
            end,
            function()
                pcall(callback)
                observer:complete()
            end
        )
        
        local original_unsub = subscription.unsubscribe_fn
        subscription.unsubscribe_fn = function()
            pcall(callback)
            if original_unsub then original_unsub() end
        end
        
        return subscription
    end)
end

--- Retries the source observable a specified number of times if it errors.
-- @arg {number} count - The number of retry attempts. Defaults to infinite retries.
-- @returns {Observable} An observable that retries the source observable if it errors.
function Observable:retry(count)
    count = count or math.huge
    
    return Observable.new(function(observer)
        local attempts = 0
        local current_subscription
        
        local function attempt()
            attempts = attempts + 1
            current_subscription = self:subscribe(
                function(value) observer:next(value) end,
                function(err)
                    if attempts < count then
                        attempt()
                    else
                        observer:error(err)
                    end
                end,
                function() observer:complete() end
            )
        end
        
        attempt()
        
        return Subscription.new(function()
            if current_subscription then
                current_subscription:unsubscribe()
            end
        end)
    end)
end

--- Emits the most recent value from the source observable within periodic time intervals.
-- @arg {number} ms - The delay in milliseconds.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @returns {Observable}
function Observable:audit(ms, scheduler)
    local source = self
    return Observable.new(function(observer)
        local timer_id = nil
        local last_value = nil
        local has_value = false
        
        local source_sub = source:subscribe(
            function(value)
                last_value = value
                
                if not has_value then
                    has_value = true
                    timer_id = scheduler:schedule(function()
                        if has_value then
                            observer:next(last_value)
                            has_value = false
                        end
                    end, ms)
                end
            end,
            function(err)
                if timer_id then scheduler:cancel(timer_id) end
                observer:error(err)
            end,
            function()
                if timer_id then scheduler:cancel(timer_id) end
                observer:complete()
            end
        )
        
        return Subscription.new(function()
            if timer_id then scheduler:cancel(timer_id) end
            source_sub:unsubscribe()
        end)
    end)
end

--- Delays the emission of items from the source observable by a given timeout.
-- @arg {number} ms - The delay in milliseconds.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @returns {Observable}
function Observable:debounce(ms, scheduler)
    local source = self
    return Observable.new(function(observer)
        local timer_id = nil
        local last_value = nil
        local has_value = false
        
        local source_sub = source:subscribe(
            function(value)
                has_value = true
                last_value = value
                
                if timer_id then
                    scheduler:cancel(timer_id)
                end
                
                timer_id = scheduler:schedule(function()
                    if has_value then
                        observer:next(last_value)
                        has_value = false
                    end
                end, ms)
            end,
            function(err)
                if timer_id then scheduler:cancel(timer_id) end
                observer:error(err)
            end,
            function()
                if timer_id then scheduler:cancel(timer_id) end
                if has_value then
                    observer:next(last_value)
                end
                observer:complete()
            end
        )
        
        return Subscription.new(function()
            if timer_id then scheduler:cancel(timer_id) end
            source_sub:unsubscribe()
        end)
    end)
end

--- Delays the emission of each value from the source observable based on a duration selector function.
-- @arg {function} duration_selector - A function that takes a value and returns an observable that determines the delay duration.
-- @returns {Observable}
function Observable:delay_when(duration_selector)
    return Observable.new(function(observer)
        local pending = 0
        local count = 0
        local source_completed = false
        
        local function check_complete()
            if source_completed and pending == 0 then
                observer:complete()
            end
        end
        
        return self:subscribe(
            function(value)
                pending = pending + 1
                count = count + 1
                local delay_obs = duration_selector(value)
                delay_obs:subscribe(
                    function(_)
                        observer:next(value)
                        pending = pending - 1
                        check_complete()
                    end,
                    function(err) observer:error(err) end,
                    function()
                        check_complete()
                    end
                )
            end,
            function(err) observer:error(err) end,
            function()
                source_completed = true
                check_complete()
            end
        )
    end)
end

--- Delays the emission of items from the source observable by a given timeout.
-- @arg {number} ms - The delay in milliseconds.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @returns {Observable}
function Observable:delay(ms, scheduler)
    local source = self
    return Observable.new(function(observer)
        local queue = {}
        local source_completed = false
        
        local source_sub = source:subscribe(
            function(value)
                local task_id = scheduler:schedule(function()
                    observer:next(value)
                end, ms)
                table.insert(queue, task_id)
            end,
            function(err)
                scheduler:schedule(function()
                    observer:error(err)
                end, ms)
            end,
            function()
                source_completed = true
                scheduler:schedule(function()
                    if source_completed then
                        observer:complete()
                    end
                end, ms)
            end
        )
        
        return Subscription.new(function()
            source_sub:unsubscribe()
            for _, task_id in ipairs(queue) do
                scheduler:cancel(task_id)
            end
        end)
    end)
end

--- Emits the most recent value from the source observable at periodic time intervals.
-- @arg {number} ms - The interval in milliseconds.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @return {Observable}
function Observable:sample(ms, scheduler)
    local source = self
    return Observable.new(function(observer)
        local last_value = nil
        local has_value = false
        local timer_id
        
        timer_id = scheduler:schedule_periodic(function()
            if has_value then
                observer:next(last_value)
                has_value = false
            end
        end, ms)
        
        local source_sub = source:subscribe(
            function(value)
                last_value = value
                has_value = true
            end,
            function(err)
                scheduler:cancel(timer_id)
                observer:error(err)
            end,
            function()
                scheduler:cancel(timer_id)
                observer:complete()
            end
        )
        
        return Subscription.new(function()
            scheduler:cancel(timer_id)
            source_sub:unsubscribe()
        end)
    end)
end

-- Emits a value from the source observable, then ignores subsequent source values for the specified duration. Can emit on the leading and/or trailing edge of the timeout.
-- @arg {number} ms - The timeout in milliseconds.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @arg {table} config - Configuration table with `leading` and `trailing` boolean options.
-- @returns {Observable}
function Observable:throttle(ms, scheduler, config)
    local source = self
    config = config or {}
    local leading = config.leading ~= false  -- default true
    local trailing = config.trailing ~= false  -- default true
    
    return Observable.new(function(observer)
        local throttled = false
        local timer_id = nil
        local last_value = nil
        local has_trailing_value = false
        
        local source_sub = source:subscribe(
            function(value)
                if not throttled then
                    -- Leading edge
                    if leading then
                        observer:next(value)
                    end
                    
                    throttled = true
                    has_trailing_value = false
                    
                    timer_id = scheduler:schedule(function()
                        throttled = false
                        
                        -- Trailing edge
                        if trailing and has_trailing_value then
                            observer:next(last_value)
                            has_trailing_value = false
                        end
                    end, ms)
                else
                    -- Store for trailing edge
                    last_value = value
                    has_trailing_value = true
                end
            end,
            function(err)
                if timer_id then scheduler:cancel(timer_id) end
                observer:error(err)
            end,
            function()
                if timer_id then scheduler:cancel(timer_id) end
                observer:complete()
            end
        )
        
        return Subscription.new(function()
            if timer_id then scheduler:cancel(timer_id) end
            source_sub:unsubscribe()
        end)
    end)
end

--- Emits an error if the source observable does not emit a value within the specified timeout.
-- @arg {number} ms - The timeout in milliseconds.
-- @arg {Scheduler} scheduler - The scheduler to use for managing the timers.
-- @returns {Observable}
function Observable:timeout(ms, scheduler)
    local source = self
    return Observable.new(function(observer)
        local timed_out = false
        local timer_id
        
        local function reset_timer()
            if timer_id then
                scheduler:cancel(timer_id)
            end
            timer_id = scheduler:schedule(function()
                if not timed_out then
                    timed_out = true
                    observer:error("Timeout after " .. ms .. "ms")
                end
            end, ms)
        end
        
        reset_timer()
        
        local source_sub = source:subscribe(
            function(value)
                if not timed_out then
                    reset_timer()
                    observer:next(value)
                end
            end,
            function(err)
                if not timed_out then
                    if timer_id then scheduler:cancel(timer_id) end
                    observer:error(err)
                end
            end,
            function()
                if not timed_out then
                    if timer_id then scheduler:cancel(timer_id) end
                    observer:complete()
                end
            end
        )
        
        return Subscription.new(function()
            if timer_id then scheduler:cancel(timer_id) end
            source_sub:unsubscribe()
        end)
    end)
end

--- Collects all emitted values from an observable into a table.
-- @arg {Observable} observable - The observable to collect values from.
-- @arg {number} timeout - The maximum time to wait for completion (optional).
-- @return {table}
function Observable:collect(timeout)
    local results = {}
    local completed = false
    local error_value = nil
    
    self:subscribe(
        function(value) table.insert(results, value) end,
        function(err) error_value = err end,
        function() completed = true end
    )
    
    return results, completed, error_value
end

--- Counts the number of values emitted by the observable.
-- @returns {Observable}
function Observable:count()
    return self:reduce(function(acc, _) return acc + 1 end, 0)
end

--- Logs each emitted value from the observable to the console.
-- @arg {Observable} observable - The source observable.
-- @arg {string} prefix - A prefix to prepend to each log message (optional).
-- @returns {Observable}
function Observable:log(prefix)
    prefix = prefix or "Value"
    return self:tap( function(value)
        print(prefix .. ":", value)
    end)
end

--- Invokes a side-effect function for each value emitted by the source observable.
-- @arg {function} side_effect_fn - A function to invoke for each emitted value.
-- @returns {Observable}
function Observable:tap(side_effect_fn)
    return Observable.new(function(observer)
        return self:subscribe(
            function(value)
                pcall(side_effect_fn, value)
                observer:next(value)
            end,
            function(err) observer:error(err) end,
            function() observer:complete() end
        )
    end)
end

--- Converts the observable sequence to an array.
-- @returns {Observable}
function Observable:to_array()
    return self:reduce(function(acc, value)
        table.insert(acc, value)
        return acc
    end, {})
end

local Utils = {}

--- Advances the scheduler by a specified duration, processing all scheduled tasks.
-- @arg {Scheduler} scheduler - The scheduler to advance.
-- @arg {number} duration - The total time to advance the scheduler.
-- @arg {number} step - The time step for each advancement (default is 1).
function Utils.run_scheduler(scheduler, duration, step)
    step = step or 1
    local elapsed = 0
    
    while elapsed < duration do
        scheduler:advance(step)
        elapsed = elapsed + step
    end
end

--- Runs the scheduler until a specified condition is met or a maximum time is reached.
-- @arg {Scheduler} scheduler - The scheduler to run.
-- @arg {function} condition - A function that returns true when the desired condition is met.
-- @arg {number} max_time - The maximum time to run the scheduler (default is infinity).
-- @arg {number} step - The time step for each advancement (default is 1).
-- @returns {number} The total time the scheduler was run.
function Utils.run_scheduler_until(scheduler, condition, max_time, step)
    step = step or 1
    max_time = max_time or math.huge
    local elapsed = 0
    
    while not condition() and elapsed < max_time do
        scheduler:advance(step)
        elapsed = elapsed + step
    end
    
    return elapsed
end

--- Advances the scheduler by a single step.
-- @arg {Scheduler} scheduler - The scheduler to advance.
-- @arg {number} time - The time to advance the scheduler (default is 1).
function Utils.run_scheduler_once(scheduler, time)
    scheduler:advance(time or 1)
end

return {
  Utils = Utils,
  Subscription = Subscription,
  Observer = Observer,
  Observable = Observable,
  Scheduler = Scheduler,
  Subject = Subject,
  BehaviorSubject = BehaviorSubject,
  ReplaySubject = ReplaySubject
}