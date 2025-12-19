RxLua
===

- [Observer](#observer)
  - [new](#newonnext-onerror-oncomplete)
  - [next](#nextvalue)
  - [error](#errorerr)
  - [complete](#complete)
- [Subscription](#subscription)
  - [new](#newunsubscribefn)
  - [unsubscribe](#unsubscribe)
  - [add](#addsubscription)
- [Scheduler A Scheduler manages the timing of task execution.](#scheduler a scheduler manages the timing of task execution.)
  - [new](#new)
  - [schedule](#scheduleaction-delay)
  - [schedule_periodic](#scheduleperiodicaction-period)
  - [cancel](#canceltaskid)
  - [run_pending](#runpending)
  - [advance](#advancedelta)
- [Observable](#observable)
  - [new](#newsubscribefn)
  - [subscribe](#subscribeobserverorfn-onerror-oncomplete)
  - [empty](#empty)
  - [never](#never)
  - [throw](#throwmessage)
  - [subscribe](#subscribeobserverorfn-onerror-oncomplete)
  - [next](#nextvalue)
  - [error](#errorerr)
  - [complete](#complete)
  - [as_observable](#asobservable)
- [BehaviorSubject](#behaviorsubject)
  - [new](#newinitialvalue)
  - [subscribe](#subscribeobserverorfn-onerror-oncomplete)
  - [next](#nextvalue)
  - [get_value](#getvalue)
- [ReplaySubject A ReplaySubject is a type of Subject that records multiple values and replays them to new subscribers.](#replaysubject a replaysubject is a type of subject that records multiple values and replays them to new subscribers.)
  - [new](#newbuffersize-windowtime)
  - [_trim_buffer](#trimbuffer)
  - [next](#nextvalue)
  - [subscribe](#subscribeobserverorfn-onerror-oncomplete)
  - [of](#ofany)
  - [timer](#timerduetime-period-scheduler)
  - [range](#rangestart-count)
  - [marble_to_observable](#marbletoobservablemarblestring-scheduler-timeperchar)
  - [combine_with](#combinewithsources)
  - [concat](#concatobservables)
  - [merge_with](#mergewithother)
  - [partition](#partitionpredicatefn)
  - [publish](#publish)
  - [race](#raceobservables)
  - [share](#share)
  - [share_replay](#sharereplaybuffersize-windowtime)
  - [start_with](#startwithvalues)
  - [zip](#zipobservables)
  - [buffer_count](#buffercountcount)
  - [concat_map](#concatmapprojectfn)
  - [dematerialize](#dematerialize)
  - [exhaust_map](#exhaustmapprojectfn)
  - [flat_map](#flatmapprojectfn)
  - [group_by](#groupbykeyselector-elementselector)
  - [materialize](#materialize)
  - [pairwise](#pairwise)
  - [reduce](#reduceaccumulatorfn-seed)
  - [switch_map](#switchmapprojectfn)
  - [window_time](#windowtimems-scheduler)
  - [default_if_empty](#defaultifemptydefaultvalue)
  - [distinct_until_changed](#distinctuntilchangedcomparefn)
  - [distinct](#distinctkeyselector)
  - [element_at](#elementatindex-defaultvalue)
  - [every](#everypredicatefn)
  - [find_index](#findindexpredicatefn)
  - [find](#findpredicatefn)
  - [first](#first)
  - [ignore_elements](#ignoreelements)
  - [is_empty](#isempty)
  - [last](#last)
  - [skip_until](#skipuntilnotifier)
  - [skip_while](#skipwhilepredicatefn)
  - [skip](#skipcount)
  - [some](#somepredicatefn)
  - [take_until](#takeuntilnotifier)
  - [take_while](#takewhilepredicatefn-inclusive)
  - [take](#takecount)
  - [catch_error](#catcherrorselectorfn)
  - [finalize](#finalizecallback)
  - [retry](#retrycount)
  - [audit](#auditms-scheduler)
  - [debounce](#debouncems-scheduler)
  - [delay_when](#delaywhendurationselector)
  - [delay](#delayms-scheduler)
  - [sample](#samplems-scheduler)
  - [timeout](#timeoutms-scheduler)
  - [collect](#collectobservable-timeout)
  - [count](#count)
  - [log](#logobservable-prefix)
  - [tap](#tapsideeffectfn)
  - [to_array](#toarray)
  - [run_scheduler](#runschedulerscheduler-duration-step)
  - [run_scheduler_until](#runscheduleruntilscheduler-condition-maxtime-step)
  - [run_scheduler_once](#runscheduleroncescheduler-time)

# Observer

An object that is used to receive notifications from an Observable.

---

#### `.new(on_next, on_error, on_complete)`

Creates a new Observer.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `on_next` | function |  | Function to handle next values. |
| `on_error` | function |  | Function to handle errors. |
| `on_complete` | function |  | Function to handle completion. |

---

#### `:next(value)`

Sends a next notification to the observer.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | * |  | The next value. |

---

#### `:error(err)`

Sends an error notification to the observer.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `err` | * |  | The error value. |

---

#### `:complete()`

Sends a complete notification to the observer.

# Subscription

Represents a disposable resource, such as the execution of an Observable. A Subscription has one important method, `unsubscribe`, that takes no argument and just disposes the resource held by the subscription.

---

#### `.new(unsubscribe_fn)`

Creates a new Subscription.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `unsubscribe_fn` | function |  | A function that will be called when unsubscribe is invoked. |

---

#### `:unsubscribe()`

Disposes the resource held by the subscription.

---

#### `:add(subscription)`

Adds a teardown to be called during the unsubscribe() of this subscription.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `subscription` | Subscription |  | A subscription to add. |

# Scheduler A Scheduler manages the timing of task execution.

---

#### `.new()`

Creates a new Scheduler.

---

#### `:schedule(action, delay)`

Schedules an action to be executed at a specified time.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `action` | function |  | The action to schedule. |
| `delay` | number |  | The delay in milliseconds before executing the action. |

---

#### `:schedule_periodic(action, period)`

Schedules an action to be executed periodically.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `action` | function |  | The action to schedule periodically. |
| `period` | number |  | The period in milliseconds between executions. |

---

#### `:cancel(task_id)`

Cancels a scheduled task.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `task_id` | number |  | The ID of the scheduled task to cancel. |

---

#### `:run_pending()`

Runs all pending tasks that are scheduled to run at or before the current time.

---

#### `:advance(delta)`

Advances the scheduler's time and runs pending tasks.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `delta` | number |  | The time in milliseconds to advance the scheduler. |

# Observable

Represents a collection of future values or events.

---

#### `.new(subscribe_fn)`

Creates a new Observable.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `subscribe_fn` | function |  | A function that is called when an observer subscribes to the observable. |

---

#### `:subscribe(observer_or_fn, on_error, on_complete)`

Subscribes an observer to the observable.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `observer_or_fn` | table or function |  | An observer object or a function to handle next values. |
| `on_error` | function |  | Function to handle errors (if observer_or_fn is a function). |
| `on_complete` | function |  | Function to handle completion (if observer_or_fn is a function). |

---

#### `.empty()`

Returns an Observable that immediately completes without producing a value.

---

#### `.never()`

Returns an Observable that never produces values and never completes.

---

#### `.throw(message)`

Returns an Observable that immediately produces an error.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `message` | * |  | The error message or value. |

---

#### `:subscribe(observer_or_fn, on_error, on_complete)`

Subscribes an observer to the subject.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `observer_or_fn` | table or function |  | An observer object or a function to handle next values. |
| `on_error` | function |  | Function to handle errors (if observer_or_fn is a function). |
| `on_complete` | function |  | Function to handle completion (if observer_or_fn is a function). |

---

#### `:next(value)`

Emits a value to all subscribed observers.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | * |  | The value to emit to observers. |

---

#### `:error(err)`

Emits an error to all subscribed observers and closes the subject.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `err` | * |  | The error to emit to observers. |

---

#### `:complete()`

Completes the subject and notifies all subscribed observers.

---

#### `:as_observable()`

Returns an observable that is linked to this subject.

# BehaviorSubject

A BehaviorSubject is a type of Subject that requires an initial value and emits its current value to new subscribers.

---

#### `.new(initial_value)`

Creates a new BehaviorSubject with the specified initial value.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `initial_value` | * |  | The initial value for the BehaviorSubject. |

---

#### `:subscribe(observer_or_fn, on_error, on_complete)`

Subscribes an observer to the BehaviorSubject and immediately emits the current value.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `observer_or_fn` | table or function |  | An observer object or a function to handle next values. |
| `on_error` | function |  | Function to handle errors (if observer_or_fn is a function |
| `on_complete` | function |  | Function to handle completion (if observer_or_fn is a function). |

---

#### `:next(value)`

Emits a value to all subscribed observers and updates the current value.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | * |  | The value to emit to observers. |

---

#### `:get_value()`

Gets the current value of the BehaviorSubject.

# ReplaySubject A ReplaySubject is a type of Subject that records multiple values and replays them to new subscribers.

---

#### `.new(buffer_size, window_time)`

Creates a new ReplaySubject with the specified buffer size and window time.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `buffer_size` | number |  | The maximum number of values to store in the buffer. |
| `window_time` | number |  | The maximum age of values to store in the buffer (in seconds). |

---

#### `:_trim_buffer()`

Trims the buffer based on buffer_size and window_time.

---

#### `:next(value)`

Emits a value to all subscribed observers and stores it in the buffer.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `value` | * |  | The value to emit to observers. |

---

#### `:subscribe(observer_or_fn, on_error, on_complete)`

Subscribes an observer to the ReplaySubject and replays buffered values.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `observer_or_fn` | table or function |  | An observer object or a function to handle next values. |
| `on_error` | function |  | Function to handle errors (if observer_or_fn is a function). |
| `on_complete` | function |  | Function to handle completion (if observer_or_fn is a function). |

---

#### `.of(any)`

Creates an observable that emits the provided values in sequence and then completes.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `any` | *... |  | A variable number of values to emit. |

---

#### `.timer(due_time, period, scheduler)`

Creates an observable that emits sequential numbers after an initial delay and optionally at a specified period.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `due_time` | number |  | The initial delay in milliseconds. |
| `period` | number or nil |  | The period in milliseconds for subsequent emissions. If nil, emits only once after due_time. |
| `scheduler` | Scheduler |  | The scheduler to use for managing the timers. |

---

#### `.range(start, count)`

Creates an observable that emits a range of sequential numbers.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `start` | number |  | The starting number. |
| `count` | number |  | The number of sequential numbers to emit. |

---

#### `.marble_to_observable(marble_string, scheduler, time_per_char)`

Converts a marble diagram string into an observable that emits values according to the diagram.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `marble_string` | string |  | The marble diagram string. |
| `scheduler` | Scheduler |  | The scheduler to use for timing the emissions. |
| `time_per_char` | number |  | The time in milliseconds represented by each character in the marble string (default is 10). |

---

#### `:combine_with(sources)`

Combines multiple observables by emitting an array of the latest values from each source whenever any source emits a new value.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `sources` | Observable... |  | A variable number of observables to combine. |

---

#### `.concat(observables)`

Concatenates multiple observables sequentially.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `observables` | Observable... |  | The observables to concatenate. |

---

#### `:merge_with(other)`

Merges values from the source observable and another observable.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `other` | Observable |  | Another observable to merge with. |

---

#### `:partition(predicate_fn)`

Splits the source observable into two observables based on a predicate function.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `predicate_fn` | function |  | A function to test each emitted value. |

---

#### `:publish()`

Converts a cold observable into a hot observable by multicasting its emissions through a Subject.

---

#### `.race(observables)`

Races multiple observables, emitting values from the first one to emit.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `observables` | Observable... |  | The observables totally competing. |

---

#### `:share()`

Shares a single subscription to the source observable among multiple subscribers.

---

#### `:share_replay(buffer_size, window_time)`

Shares a single subscription to the source observable among multiple subscribers and replays a specified number of previous emissions to new subscribers.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `buffer_size` | number |  | The maximum number of previous emissions to replay to new subscribers. |
| `window_time` | number |  | The maximum time in milliseconds to replay previous emissions to new subscribers. |

---

#### `:start_with(values)`

Prepends initial values to the source observable.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `values` | *... |  | The initial values to prepend. |

---

#### `.zip(observables)`

Combines multiple observables by emitting arrays of their latest values.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `observables` | Observable... |  | The observables to combine. |

---

#### `:buffer_count(count)`

Buffers values from the source observable until the buffer reaches the specified count and emits them as an array.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `count` | number |  | The number of items to buffer. |

---

#### `:concat_map(project_fn)`

Projects each source value to an observable which is concatenated in the output observable.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_fn` | function |  | A function that, when applied to an item emitted by the source observable, returns an observable. |

---

#### `:dematerialize()`

Converts notification objects back into the emissions they represent.

---

#### `:exhaust_map(project_fn)`

Projects each source value to an observable which is merged in the output observable only if the previous inner observable has completed.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_fn` | function |  | A function that, when applied to an item emitted by the source observable, returns an observable. |

---

#### `:flat_map(project_fn)`

Projects each source value to an observable which is merged in the output observable.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_fn` | function |  | A function that, when applied to an item emitted by the source observable, returns an observable. |

---

#### `:group_by(key_selector, element_selector)`

Groups the items emitted by the source observable according to a specified key selector function.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `key_selector` | function |  | A function that extracts the key for each item. |
| `element_selector` | function |  | A function that extracts the element for each item. |

---

#### `:materialize()`

Represents the notification of an event in the source observable.

---

#### `:pairwise()`

Emits the previous and current values as a pair for each emission from the source observable.

---

#### `:reduce(accumulator_fn, seed)`

Applies an accumulator function to each emitted value.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `accumulator_fn` | function |  | A function to accumulate values. |
| `seed` | * |  | The initial value for the accumulator. |

---

#### `:switch_map(project_fn)`

Projects each source value to an observable which is switched to in the output observable.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_fn` | function |  | A function that, when applied to an item emitted by the source observable, returns an observable. |

---

#### `:window_time(ms, scheduler)`

Splits the source observable into windows (sub-observables) based on a time span.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `ms` | number |  | The interval in milliseconds. |
| `scheduler` | Scheduler |  | The scheduler to use for managing the timers. |

---

#### `:default_if_empty(default_value)`

Emits a default value if the source observable completes without emitting any values.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `default_value` | * |  | The default value to emit if the source is empty. |

---

#### `:distinct_until_changed(compare_fn)`

Emits values from the source observable only when they are different from the previous value.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `compare_fn` | function |  | An optional function to compare the previous and current values. |

---

#### `:distinct(key_selector)`

Removes duplicate values from the source observable.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `key_selector` | function |  | An optional function to select the key for comparison. |

---

#### `:element_at(index, default_value)`

Emits the item at the specified index from the source observable.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `index` | number |  | The zero-based index of the item to emit. |
| `default_value` | * |  | The default value to emit if the index is out of bounds |

---

#### `:every(predicate_fn)`

Determines whether all items emitted by the source observable satisfy the specified predicate.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `predicate_fn` | function |  | A function to test each emitted value. |

---

#### `:find_index(predicate_fn)`

Finds the index of the first item emitted by the source observable that satisfies the specified predicate.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `predicate_fn` | function |  | A function to test each emitted value. |

---

#### `:find(predicate_fn)`

Determines whether any item emitted by the source observable satisfies the specified predicate.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `predicate_fn` | function |  | A function to test each emitted value. |

---

#### `:first()`

Emits only the first value from the observable sequence.

---

#### `:ignore_elements()`

Ignores all items emitted by the source observable and only passes through termination events.

---

#### `:is_empty()`

Determines whether the observable sequence is empty.

---

#### `:last()`

Emits only the last value from the observable sequence.

---

#### `:skip_until(notifier)`

Emits values from the source observable only after the notifier observable emits a value.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `notifier` | Observable |  | An observable that, when it emits a value, will cause the source observable to start emitting values. |

---

#### `:skip_while(predicate_fn)`

Emits values from the source observable while the predicate function returns true.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `predicate_fn` | function |  | A function to test each emitted value. |

---

#### `:skip(count)`

Skips the first `count` values from the source observable.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `count` | number |  | The number of values to skip. |

---

#### `:some(predicate_fn)`

Determines whether any item emitted by the source observable satisfies the specified predicate.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `predicate_fn` | function |  | A function to test each emitted value. |

---

#### `:take_until(notifier)`

Emits values from the source observable until the notifier observable emits a value.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `notifier` | Observable |  | An observable that, when it emits a value, will cause the source observable to complete. |

---

#### `:take_while(predicate_fn, inclusive)`

Emits values from the source observable while the predicate function returns true.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `predicate_fn` | function |  | A function to test each emitted value. |
| `inclusive` | boolean |  | If true, includes the first value that causes the predicate to return false. |

---

#### `:take(count)`

Emits only the first `count` values from the source observable.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `count` | number |  | The number of values to take. |

---

#### `:catch_error(selector_fn)`

Catches errors from the source observable and switches to a fallback observable.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `selector_fn` | function |  | A function that takes an error and returns a new observable. |

---

#### `:finalize(callback)`

Invokes a callback function when the observable terminates (completes, errors, or is unsubscribed).

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `callback` | function |  | A function to invoke on termination. |

---

#### `:retry(count)`

Retries the source observable a specified number of times if it errors.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `count` | number |  | The number of retry attempts. Defaults to infinite retries. |

---

#### `:audit(ms, scheduler)`

Emits the most recent value from the source observable within periodic time intervals.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `ms` | number |  | The delay in milliseconds. |
| `scheduler` | Scheduler |  | The scheduler to use for managing the timers. |

---

#### `:debounce(ms, scheduler)`

Delays the emission of items from the source observable by a given timeout.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `ms` | number |  | The delay in milliseconds. |
| `scheduler` | Scheduler |  | The scheduler to use for managing the timers. |

---

#### `:delay_when(duration_selector)`

Delays the emission of each value from the source observable based on a duration selector function.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `duration_selector` | function |  | A function that takes a value and returns an observable that determines the delay duration. |

---

#### `:delay(ms, scheduler)`

Delays the emission of items from the source observable by a given timeout.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `ms` | number |  | The delay in milliseconds. |
| `scheduler` | Scheduler |  | The scheduler to use for managing the timers. |

---

#### `:sample(ms, scheduler)`

Emits the most recent value from the source observable at periodic time intervals.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `ms` | number |  | The interval in milliseconds. |
| `scheduler` | Scheduler |  | The scheduler to use for managing the timers. |

---

#### `:timeout(ms, scheduler)`

Emits an error if the source observable does not emit a value within the specified timeout.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `ms` | number |  | The timeout in milliseconds. |
| `scheduler` | Scheduler |  | The scheduler to use for managing the timers. |

---

#### `:collect(observable, timeout)`

Collects all emitted values from an observable into a table.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `observable` | Observable |  | The observable to collect values from. |
| `timeout` | number |  | The maximum time to wait for completion (optional). |

---

#### `:count()`

Counts the number of values emitted by the observable.

---

#### `:log(observable, prefix)`

Logs each emitted value from the observable to the console.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `observable` | Observable |  | The source observable. |
| `prefix` | string |  | A prefix to prepend to each log message (optional). |

---

#### `:tap(side_effect_fn)`

Invokes a side-effect function for each value emitted by the source observable.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `side_effect_fn` | function |  | A function to invoke for each emitted value. |

---

#### `:to_array()`

Converts the observable sequence to an array.

---

#### `.run_scheduler(scheduler, duration, step)`

Advances the scheduler by a specified duration, processing all scheduled tasks.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `scheduler` | Scheduler |  | The scheduler to advance. |
| `duration` | number |  | The total time to advance the scheduler. |
| `step` | number |  | The time step for each advancement (default is 1). |

---

#### `.run_scheduler_until(scheduler, condition, max_time, step)`

Runs the scheduler until a specified condition is met or a maximum time is reached.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `scheduler` | Scheduler |  | The scheduler to run. |
| `condition` | function |  | A function that returns true when the desired condition is met. |
| `max_time` | number |  | The maximum time to run the scheduler (default is infinity). |
| `step` | number |  | The time step for each advancement (default is 1). |

---

#### `.run_scheduler_once(scheduler, time)`

Advances the scheduler by a single step.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `scheduler` | Scheduler |  | The scheduler to advance. |
| `time` | number |  | The time to advance the scheduler (default is 1). |

