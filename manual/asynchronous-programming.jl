### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03b91afc-9e19-11eb-0fdb-4982264d2764
md"""
# [Asynchronous Programming](@id man-asynchronous)
"""

# ╔═╡ 03b91b1a-9e19-11eb-1613-b1395bb8b986
md"""
When a program needs to interact with the outside world, for example communicating with another machine over the internet, operations in the program may need to happen in an unpredictable order. Say your program needs to download a file. We would like to initiate the download operation, perform other operations while we wait for it to complete, and then resume the code that needs the downloaded file when it is available. This sort of scenario falls in the domain of asynchronous programming, sometimes also referred to as concurrent programming (since, conceptually, multiple things are happening at once).
"""

# ╔═╡ 03b91b4c-9e19-11eb-1a8d-89074f06e0e0
md"""
To address these scenarios, Julia provides [`Task`](@ref)s (also known by several other names, such as symmetric coroutines, lightweight threads, cooperative multitasking, or one-shot continuations). When a piece of computing work (in practice, executing a particular function) is designated as a [`Task`](@ref), it becomes possible to interrupt it by switching to another [`Task`](@ref). The original [`Task`](@ref) can later be resumed, at which point it will pick up right where it left off. At first, this may seem similar to a function call. However there are two key differences. First, switching tasks does not use any space, so any number of task switches can occur without consuming the call stack. Second, switching among tasks can occur in any order, unlike function calls, where the called function must finish executing before control returns to the calling function.
"""

# ╔═╡ 03b91b7e-9e19-11eb-11d2-47fe62b0322c
md"""
## Basic `Task` operations
"""

# ╔═╡ 03b91b92-9e19-11eb-24ce-098268802a27
md"""
You can think of a `Task` as a handle to a unit of computational work to be performed. It has a create-start-run-finish lifecycle. Tasks are created by calling the `Task` constructor on a 0-argument function to run, or using the [`@task`](@ref) macro:
"""

# ╔═╡ 03b91fc0-9e19-11eb-09e8-e760e609a7b8
t = @task begin; sleep(5); println("done"); end

# ╔═╡ 03b91fde-9e19-11eb-23cd-49f7a7eae1fb
md"""
`@task x` is equivalent to `Task(()->x)`.
"""

# ╔═╡ 03b92004-9e19-11eb-2305-131ffe4f7e9b
md"""
This task will wait for five seconds, and then print `done`. However, it has not started running yet. We can run it whenever we're ready by calling [`schedule`](@ref):
"""

# ╔═╡ 03b920f6-9e19-11eb-374c-cf6221c06044
schedule(t);

# ╔═╡ 03b92128-9e19-11eb-026f-d131e9c99651
md"""
If you try this in the REPL, you will see that `schedule` returns immediately. That is because it simply adds `t` to an internal queue of tasks to run. Then, the REPL will print the next prompt and wait for more input. Waiting for keyboard input provides an opportunity for other tasks to run, so at that point `t` will start. `t` calls [`sleep`](@ref), which sets a timer and stops execution. If other tasks have been scheduled, they could run then. After five seconds, the timer fires and restarts `t`, and you will see `done` printed. `t` is then finished.
"""

# ╔═╡ 03b9215a-9e19-11eb-232f-3fa409266c23
md"""
The [`wait`](@ref) function blocks the calling task until some other task finishes. So for example if you type
"""

# ╔═╡ 03b922ae-9e19-11eb-2254-e1b3f1a5ea56
schedule(t); wait(t)

# ╔═╡ 03b922cc-9e19-11eb-1afe-81094845d8f2
md"""
instead of only calling `schedule`, you will see a five second pause before the next input prompt appears. That is because the REPL is waiting for `t` to finish before proceeding.
"""

# ╔═╡ 03b922f4-9e19-11eb-0b74-bd84dfeeef52
md"""
It is common to want to create a task and schedule it right away, so the macro [`@async`](@ref) is provided for that purpose –- `@async x` is equivalent to `schedule(@task x)`.
"""

# ╔═╡ 03b922fe-9e19-11eb-185f-9dd32cf3c309
md"""
## Communicating with Channels
"""

# ╔═╡ 03b9231c-9e19-11eb-30da-dbc8bcc612e1
md"""
In some problems, the various pieces of required work are not naturally related by function calls; there is no obvious "caller" or "callee" among the jobs that need to be done. An example is the producer-consumer problem, where one complex procedure is generating values and another complex procedure is consuming them. The consumer cannot simply call a producer function to get a value, because the producer may have more values to generate and so might not yet be ready to return. With tasks, the producer and consumer can both run as long as they need to, passing values back and forth as necessary.
"""

# ╔═╡ 03b9233a-9e19-11eb-0fa0-9b5bbf8ea3e2
md"""
Julia provides a [`Channel`](@ref) mechanism for solving this problem. A [`Channel`](@ref) is a waitable first-in first-out queue which can have multiple tasks reading from and writing to it.
"""

# ╔═╡ 03b92362-9e19-11eb-2c6e-25355813a33c
md"""
Let's define a producer task, which produces values via the [`put!`](@ref) call. To consume values, we need to schedule the producer to run in a new task. A special [`Channel`](@ref) constructor which accepts a 1-arg function as an argument can be used to run a task bound to a channel. We can then [`take!`](@ref) values repeatedly from the channel object:
"""

# ╔═╡ 03b92e8e-9e19-11eb-0213-2d2d7e8ce9ff
function producer(c::Channel)
           put!(c, "start")
           for n=1:4
               put!(c, 2n)
           end
           put!(c, "stop")
       end;

# ╔═╡ 03b92e8e-9e19-11eb-07c8-c9cb4d9a1ea7
chnl = Channel(producer);

# ╔═╡ 03b92ea2-9e19-11eb-2774-b17bd919c2a3
take!(chnl)

# ╔═╡ 03b92ea2-9e19-11eb-0813-c7c1ad65da20
take!(chnl)

# ╔═╡ 03b92eac-9e19-11eb-0846-ddf69b907684
take!(chnl)

# ╔═╡ 03b92eac-9e19-11eb-36a1-af79162dd56d
take!(chnl)

# ╔═╡ 03b92eb8-9e19-11eb-3ba0-7f33f3f8ac1e
take!(chnl)

# ╔═╡ 03b92eca-9e19-11eb-2f3f-610f7219f31b
take!(chnl)

# ╔═╡ 03b92ef2-9e19-11eb-04a7-0dc85110475e
md"""
One way to think of this behavior is that `producer` was able to return multiple times. Between calls to [`put!`](@ref), the producer's execution is suspended and the consumer has control.
"""

# ╔═╡ 03b92f06-9e19-11eb-00d7-992812c9e35f
md"""
The returned [`Channel`](@ref) can be used as an iterable object in a `for` loop, in which case the loop variable takes on all the produced values. The loop is terminated when the channel is closed.
"""

# ╔═╡ 03b93104-9e19-11eb-0017-8735d2838ac2
for x in Channel(producer)
           println(x)
       end

# ╔═╡ 03b93190-9e19-11eb-12dc-0faaa918caa8
md"""
Note that we did not have to explicitly close the channel in the producer. This is because the act of binding a [`Channel`](@ref) to a [`Task`](@ref) associates the open lifetime of a channel with that of the bound task. The channel object is closed automatically when the task terminates. Multiple channels can be bound to a task, and vice-versa.
"""

# ╔═╡ 03b93208-9e19-11eb-0ed4-09db646e7efb
md"""
While the [`Task`](@ref) constructor expects a 0-argument function, the [`Channel`](@ref) method that creates a task-bound channel expects a function that accepts a single argument of type [`Channel`](@ref). A common pattern is for the producer to be parameterized, in which case a partial function application is needed to create a 0 or 1 argument [anonymous function](@ref man-anonymous-functions).
"""

# ╔═╡ 03b93230-9e19-11eb-1f01-7580f42e7d3e
md"""
For [`Task`](@ref) objects this can be done either directly or by use of a convenience macro:
"""

# ╔═╡ 03b93294-9e19-11eb-07c9-036fe152fd2f
md"""
```julia
function mytask(myarg)
    ...
end

taskHdl = Task(() -> mytask(7))
# or, equivalently
taskHdl = @task mytask(7)
```
"""

# ╔═╡ 03b932c6-9e19-11eb-0010-79329d644636
md"""
To orchestrate more advanced work distribution patterns, [`bind`](@ref) and [`schedule`](@ref) can be used in conjunction with [`Task`](@ref) and [`Channel`](@ref) constructors to explicitly link a set of channels with a set of producer/consumer tasks.
"""

# ╔═╡ 03b93302-9e19-11eb-1865-6f78724b6234
md"""
### More on Channels
"""

# ╔═╡ 03b9331e-9e19-11eb-169f-bb2d79dececc
md"""
A channel can be visualized as a pipe, i.e., it has a write end and a read end :
"""

# ╔═╡ 03b93712-9e19-11eb-00a6-eb1439fa07e1
md"""
  * Multiple writers in different tasks can write to the same channel concurrently via [`put!`](@ref) calls.
  * Multiple readers in different tasks can read data concurrently via [`take!`](@ref) calls.
  * As an example:

    ```julia
    # Given Channels c1 and c2,
    c1 = Channel(32)
    c2 = Channel(32)

    # and a function `foo` which reads items from c1, processes the item read
    # and writes a result to c2,
    function foo()
        while true
            data = take!(c1)
            [...]               # process data
            put!(c2, result)    # write out result
        end
    end

    # we can schedule `n` instances of `foo` to be active concurrently.
    for _ in 1:n
        @async foo()
    end
    ```
  * Channels are created via the `Channel{T}(sz)` constructor. The channel will only hold objects of type `T`. If the type is not specified, the channel can hold objects of any type. `sz` refers to the maximum number of elements that can be held in the channel at any time. For example, `Channel(32)` creates a channel that can hold a maximum of 32 objects of any type. A `Channel{MyType}(64)` can hold up to 64 objects of `MyType` at any time.
  * If a [`Channel`](@ref) is empty, readers (on a [`take!`](@ref) call) will block until data is available.
  * If a [`Channel`](@ref) is full, writers (on a [`put!`](@ref) call) will block until space becomes available.
  * [`isready`](@ref) tests for the presence of any object in the channel, while [`wait`](@ref) waits for an object to become available.
  * A [`Channel`](@ref) is in an open state initially. This means that it can be read from and written to freely via [`take!`](@ref) and [`put!`](@ref) calls. [`close`](@ref) closes a [`Channel`](@ref). On a closed [`Channel`](@ref), [`put!`](@ref) will fail. For example:

    ```julia-repl
    julia> c = Channel(2);

    julia> put!(c, 1) # `put!` on an open channel succeeds
    1

    julia> close(c);

    julia> put!(c, 2) # `put!` on a closed channel throws an exception.
    ERROR: InvalidStateException("Channel is closed.",:closed)
    Stacktrace:
    [...]
    ```
  * [`take!`](@ref) and [`fetch`](@ref) (which retrieves but does not remove the value) on a closed channel successfully return any existing values until it is emptied. Continuing the above example:

    ```julia-repl
    julia> fetch(c) # Any number of `fetch` calls succeed.
    1

    julia> fetch(c)
    1

    julia> take!(c) # The first `take!` removes the value.
    1

    julia> take!(c) # No more data available on a closed channel.
    ERROR: InvalidStateException("Channel is closed.",:closed)
    Stacktrace:
    [...]
    ```
"""

# ╔═╡ 03b9373a-9e19-11eb-33b5-ed6143997a85
md"""
Consider a simple example using channels for inter-task communication. We start 4 tasks to process data from a single `jobs` channel. Jobs, identified by an id (`job_id`), are written to the channel. Each task in this simulation reads a `job_id`, waits for a random amount of time and writes back a tuple of `job_id` and the simulated time to the results channel. Finally all the `results` are printed out.
"""

# ╔═╡ 03b95698-9e19-11eb-3f47-ffe2965e21f2
const jobs = Channel{Int}(32);

# ╔═╡ 03b956a2-9e19-11eb-2d00-dbc626f23256
const results = Channel{Tuple}(32);

# ╔═╡ 03b956a2-9e19-11eb-0829-6d51d108a84f
function do_work()
           for job_id in jobs
               exec_time = rand()
               sleep(exec_time)                # simulates elapsed time doing actual work
                                               # typically performed externally.
               put!(results, (job_id, exec_time))
           end
       end;

# ╔═╡ 03b956ac-9e19-11eb-0506-0bb66eadab80
function make_jobs(n)
           for i in 1:n
               put!(jobs, i)
           end
       end;

# ╔═╡ 03b956ac-9e19-11eb-1749-d558079672e9
n = 12;

# ╔═╡ 03b956e6-9e19-11eb-33a4-97c4eff6de0c
@async make_jobs(n); # feed the jobs channel with "n" jobs

# ╔═╡ 03b958f2-9e19-11eb-20be-af1fdac48e0d
for i in 1:4 # start 4 tasks to process requests in parallel
           @async do_work()
       end

# ╔═╡ 03b958f2-9e19-11eb-13b9-a73d2d8e8e19
@elapsed while n > 0 # print out results
           job_id, exec_time = take!(results)
           println("$job_id finished in $(round(exec_time; digits=2)) seconds")
           global n = n - 1
       end

# ╔═╡ 03b95940-9e19-11eb-1f37-c9bc9fa26a28
md"""
## More task operations
"""

# ╔═╡ 03b959a4-9e19-11eb-2b60-f91b41d6e018
md"""
Task operations are built on a low-level primitive called [`yieldto`](@ref). `yieldto(task, value)` suspends the current task, switches to the specified `task`, and causes that task's last [`yieldto`](@ref) call to return the specified `value`. Notice that [`yieldto`](@ref) is the only operation required to use task-style control flow; instead of calling and returning we are always just switching to a different task. This is why this feature is also called "symmetric coroutines"; each task is switched to and from using the same mechanism.
"""

# ╔═╡ 03b959e0-9e19-11eb-38c7-111e5b42ba2d
md"""
[`yieldto`](@ref) is powerful, but most uses of tasks do not invoke it directly. Consider why this might be. If you switch away from the current task, you will probably want to switch back to it at some point, but knowing when to switch back, and knowing which task has the responsibility of switching back, can require considerable coordination. For example, [`put!`](@ref) and [`take!`](@ref) are blocking operations, which, when used in the context of channels maintain state to remember who the consumers are. Not needing to manually keep track of the consuming task is what makes [`put!`](@ref) easier to use than the low-level [`yieldto`](@ref).
"""

# ╔═╡ 03b959f4-9e19-11eb-1bb1-a9a271794811
md"""
In addition to [`yieldto`](@ref), a few other basic functions are needed to use tasks effectively.
"""

# ╔═╡ 03b95ad0-9e19-11eb-0acc-292ddbc5617a
md"""
  * [`current_task`](@ref) gets a reference to the currently-running task.
  * [`istaskdone`](@ref) queries whether a task has exited.
  * [`istaskstarted`](@ref) queries whether a task has run yet.
  * [`task_local_storage`](@ref) manipulates a key-value store specific to the current task.
"""

# ╔═╡ 03b95ae4-9e19-11eb-30b3-05aa03ab2965
md"""
## Tasks and events
"""

# ╔═╡ 03b95af8-9e19-11eb-3d53-e5cdd0278852
md"""
Most task switches occur as a result of waiting for events such as I/O requests, and are performed by a scheduler included in Julia Base. The scheduler maintains a queue of runnable tasks, and executes an event loop that restarts tasks based on external events such as message arrival.
"""

# ╔═╡ 03b95b48-9e19-11eb-0496-3b71e55d95ff
md"""
The basic function for waiting for an event is [`wait`](@ref). Several objects implement [`wait`](@ref); for example, given a `Process` object, [`wait`](@ref) will wait for it to exit. [`wait`](@ref) is often implicit; for example, a [`wait`](@ref) can happen inside a call to [`read`](@ref) to wait for data to be available.
"""

# ╔═╡ 03b95b7a-9e19-11eb-31fb-7b1a681c8f71
md"""
In all of these cases, [`wait`](@ref) ultimately operates on a [`Condition`](@ref) object, which is in charge of queueing and restarting tasks. When a task calls [`wait`](@ref) on a [`Condition`](@ref), the task is marked as non-runnable, added to the condition's queue, and switches to the scheduler. The scheduler will then pick another task to run, or block waiting for external events. If all goes well, eventually an event handler will call [`notify`](@ref) on the condition, which causes tasks waiting for that condition to become runnable again.
"""

# ╔═╡ 03b95b98-9e19-11eb-39cb-4bd5e3576f47
md"""
A task created explicitly by calling [`Task`](@ref) is initially not known to the scheduler. This allows you to manage tasks manually using [`yieldto`](@ref) if you wish. However, when such a task waits for an event, it still gets restarted automatically when the event happens, as you would expect.
"""

# ╔═╡ Cell order:
# ╟─03b91afc-9e19-11eb-0fdb-4982264d2764
# ╟─03b91b1a-9e19-11eb-1613-b1395bb8b986
# ╟─03b91b4c-9e19-11eb-1a8d-89074f06e0e0
# ╟─03b91b7e-9e19-11eb-11d2-47fe62b0322c
# ╟─03b91b92-9e19-11eb-24ce-098268802a27
# ╠═03b91fc0-9e19-11eb-09e8-e760e609a7b8
# ╟─03b91fde-9e19-11eb-23cd-49f7a7eae1fb
# ╟─03b92004-9e19-11eb-2305-131ffe4f7e9b
# ╠═03b920f6-9e19-11eb-374c-cf6221c06044
# ╟─03b92128-9e19-11eb-026f-d131e9c99651
# ╟─03b9215a-9e19-11eb-232f-3fa409266c23
# ╠═03b922ae-9e19-11eb-2254-e1b3f1a5ea56
# ╟─03b922cc-9e19-11eb-1afe-81094845d8f2
# ╟─03b922f4-9e19-11eb-0b74-bd84dfeeef52
# ╟─03b922fe-9e19-11eb-185f-9dd32cf3c309
# ╟─03b9231c-9e19-11eb-30da-dbc8bcc612e1
# ╟─03b9233a-9e19-11eb-0fa0-9b5bbf8ea3e2
# ╟─03b92362-9e19-11eb-2c6e-25355813a33c
# ╠═03b92e8e-9e19-11eb-0213-2d2d7e8ce9ff
# ╠═03b92e8e-9e19-11eb-07c8-c9cb4d9a1ea7
# ╠═03b92ea2-9e19-11eb-2774-b17bd919c2a3
# ╠═03b92ea2-9e19-11eb-0813-c7c1ad65da20
# ╠═03b92eac-9e19-11eb-0846-ddf69b907684
# ╠═03b92eac-9e19-11eb-36a1-af79162dd56d
# ╠═03b92eb8-9e19-11eb-3ba0-7f33f3f8ac1e
# ╠═03b92eca-9e19-11eb-2f3f-610f7219f31b
# ╟─03b92ef2-9e19-11eb-04a7-0dc85110475e
# ╟─03b92f06-9e19-11eb-00d7-992812c9e35f
# ╠═03b93104-9e19-11eb-0017-8735d2838ac2
# ╟─03b93190-9e19-11eb-12dc-0faaa918caa8
# ╟─03b93208-9e19-11eb-0ed4-09db646e7efb
# ╟─03b93230-9e19-11eb-1f01-7580f42e7d3e
# ╟─03b93294-9e19-11eb-07c9-036fe152fd2f
# ╟─03b932c6-9e19-11eb-0010-79329d644636
# ╟─03b93302-9e19-11eb-1865-6f78724b6234
# ╟─03b9331e-9e19-11eb-169f-bb2d79dececc
# ╟─03b93712-9e19-11eb-00a6-eb1439fa07e1
# ╟─03b9373a-9e19-11eb-33b5-ed6143997a85
# ╠═03b95698-9e19-11eb-3f47-ffe2965e21f2
# ╠═03b956a2-9e19-11eb-2d00-dbc626f23256
# ╠═03b956a2-9e19-11eb-0829-6d51d108a84f
# ╠═03b956ac-9e19-11eb-0506-0bb66eadab80
# ╠═03b956ac-9e19-11eb-1749-d558079672e9
# ╠═03b956e6-9e19-11eb-33a4-97c4eff6de0c
# ╠═03b958f2-9e19-11eb-20be-af1fdac48e0d
# ╠═03b958f2-9e19-11eb-13b9-a73d2d8e8e19
# ╟─03b95940-9e19-11eb-1f37-c9bc9fa26a28
# ╟─03b959a4-9e19-11eb-2b60-f91b41d6e018
# ╟─03b959e0-9e19-11eb-38c7-111e5b42ba2d
# ╟─03b959f4-9e19-11eb-1bb1-a9a271794811
# ╟─03b95ad0-9e19-11eb-0acc-292ddbc5617a
# ╟─03b95ae4-9e19-11eb-30b3-05aa03ab2965
# ╟─03b95af8-9e19-11eb-3d53-e5cdd0278852
# ╟─03b95b48-9e19-11eb-0496-3b71e55d95ff
# ╟─03b95b7a-9e19-11eb-31fb-7b1a681c8f71
# ╟─03b95b98-9e19-11eb-39cb-4bd5e3576f47
