### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ c24778e3-c837-406a-8be6-88a27f505efb
md"""
# [Asynchronous Programming](@id man-asynchronous)
"""

# ╔═╡ a9bad818-3d0c-4861-b642-8fbcaab98f71
md"""
When a program needs to interact with the outside world, for example communicating with another machine over the internet, operations in the program may need to happen in an unpredictable order. Say your program needs to download a file. We would like to initiate the download operation, perform other operations while we wait for it to complete, and then resume the code that needs the downloaded file when it is available. This sort of scenario falls in the domain of asynchronous programming, sometimes also referred to as concurrent programming (since, conceptually, multiple things are happening at once).
"""

# ╔═╡ 5446eb35-abf4-44ea-963d-bfb991894110
md"""
To address these scenarios, Julia provides [`Task`](@ref)s (also known by several other names, such as symmetric coroutines, lightweight threads, cooperative multitasking, or one-shot continuations). When a piece of computing work (in practice, executing a particular function) is designated as a [`Task`](@ref), it becomes possible to interrupt it by switching to another [`Task`](@ref). The original [`Task`](@ref) can later be resumed, at which point it will pick up right where it left off. At first, this may seem similar to a function call. However there are two key differences. First, switching tasks does not use any space, so any number of task switches can occur without consuming the call stack. Second, switching among tasks can occur in any order, unlike function calls, where the called function must finish executing before control returns to the calling function.
"""

# ╔═╡ d401c09d-bd62-403b-bd82-8867e0681b06
md"""
## Basic `Task` operations
"""

# ╔═╡ be16c062-7aea-420f-8b96-2ddbc8d2bc3e
md"""
You can think of a `Task` as a handle to a unit of computational work to be performed. It has a create-start-run-finish lifecycle. Tasks are created by calling the `Task` constructor on a 0-argument function to run, or using the [`@task`](@ref) macro:
"""

# ╔═╡ 1b95264f-4930-45cf-a8ca-8d56c2338ebd
t = @task begin; sleep(5); println("done"); end

# ╔═╡ a35ddf90-2998-40d5-a920-4c603ee38bad
md"""
`@task x` is equivalent to `Task(()->x)`.
"""

# ╔═╡ 7e055c8b-bfa5-4198-b589-2d1186b41153
md"""
This task will wait for five seconds, and then print `done`. However, it has not started running yet. We can run it whenever we're ready by calling [`schedule`](@ref):
"""

# ╔═╡ 0017f7bf-67c8-4ef2-b170-ad7da31be757
schedule(t);

# ╔═╡ 5a3c780a-bb82-4a2e-8664-90a2224abbb2
md"""
If you try this in the REPL, you will see that `schedule` returns immediately. That is because it simply adds `t` to an internal queue of tasks to run. Then, the REPL will print the next prompt and wait for more input. Waiting for keyboard input provides an opportunity for other tasks to run, so at that point `t` will start. `t` calls [`sleep`](@ref), which sets a timer and stops execution. If other tasks have been scheduled, they could run then. After five seconds, the timer fires and restarts `t`, and you will see `done` printed. `t` is then finished.
"""

# ╔═╡ e4b47f6c-c554-4d07-a7ab-c01731b9d44f
md"""
The [`wait`](@ref) function blocks the calling task until some other task finishes. So for example if you type
"""

# ╔═╡ 002e6c2a-fe13-410f-add0-7d9870a2f0d2
schedule(t); wait(t)

# ╔═╡ d4ca7720-0760-41a5-8269-13120b29d74e
md"""
instead of only calling `schedule`, you will see a five second pause before the next input prompt appears. That is because the REPL is waiting for `t` to finish before proceeding.
"""

# ╔═╡ f19ba6af-a6c0-4b11-aa96-b4395e6b2a93
md"""
It is common to want to create a task and schedule it right away, so the macro [`@async`](@ref) is provided for that purpose –- `@async x` is equivalent to `schedule(@task x)`.
"""

# ╔═╡ 5f8ef78d-0520-4941-a697-1050f0cfd685
md"""
## Communicating with Channels
"""

# ╔═╡ c22b0a44-f72d-4ea2-8b40-526bbd677ae3
md"""
In some problems, the various pieces of required work are not naturally related by function calls; there is no obvious \"caller\" or \"callee\" among the jobs that need to be done. An example is the producer-consumer problem, where one complex procedure is generating values and another complex procedure is consuming them. The consumer cannot simply call a producer function to get a value, because the producer may have more values to generate and so might not yet be ready to return. With tasks, the producer and consumer can both run as long as they need to, passing values back and forth as necessary.
"""

# ╔═╡ e495c997-a0e3-4387-8a6e-42fcb6dfc231
md"""
Julia provides a [`Channel`](@ref) mechanism for solving this problem. A [`Channel`](@ref) is a waitable first-in first-out queue which can have multiple tasks reading from and writing to it.
"""

# ╔═╡ fa28e560-b29e-45dd-86db-e6ec4eb85972
md"""
Let's define a producer task, which produces values via the [`put!`](@ref) call. To consume values, we need to schedule the producer to run in a new task. A special [`Channel`](@ref) constructor which accepts a 1-arg function as an argument can be used to run a task bound to a channel. We can then [`take!`](@ref) values repeatedly from the channel object:
"""

# ╔═╡ 1fbe497b-c0f8-46e5-a126-251335cace97
function producer(c::Channel)
     put!(c, "start")
     for n=1:4
         put!(c, 2n)
     end
     put!(c, "stop")
 end;

# ╔═╡ a98165c2-fcca-408c-a761-673bbba07d51
chnl = Channel(producer);

# ╔═╡ 82dd34e2-7d41-4c80-87e1-29ea442844fb
take!(chnl)

# ╔═╡ 851195dc-af2f-447d-b7d6-1fef0bdc36a6
take!(chnl)

# ╔═╡ 3b900014-0bf5-4e71-a43b-6b08debf4d2d
take!(chnl)

# ╔═╡ b3e3b8d7-032e-4f01-8b8d-d834db53f1ff
take!(chnl)

# ╔═╡ 6b2ffae3-146c-4663-99ae-033440941436
take!(chnl)

# ╔═╡ 7a64535c-dca8-43eb-a1aa-f599a3f7f912
take!(chnl)

# ╔═╡ 527c3491-7415-4a47-8b72-e8b6c0b0da84
md"""
One way to think of this behavior is that `producer` was able to return multiple times. Between calls to [`put!`](@ref), the producer's execution is suspended and the consumer has control.
"""

# ╔═╡ 78959c2d-2279-42ab-9e8f-0b913bba79c1
md"""
The returned [`Channel`](@ref) can be used as an iterable object in a `for` loop, in which case the loop variable takes on all the produced values. The loop is terminated when the channel is closed.
"""

# ╔═╡ c589b3fb-ba4a-4b3c-95b6-e9bdb5fb832e
for x in Channel(producer)
     println(x)
 end

# ╔═╡ 7fcc021b-b286-4cae-a4f3-f579bf2e8e33
md"""
Note that we did not have to explicitly close the channel in the producer. This is because the act of binding a [`Channel`](@ref) to a [`Task`](@ref) associates the open lifetime of a channel with that of the bound task. The channel object is closed automatically when the task terminates. Multiple channels can be bound to a task, and vice-versa.
"""

# ╔═╡ 131ba9e6-659a-48c5-b006-6eb19c9f46b1
md"""
While the [`Task`](@ref) constructor expects a 0-argument function, the [`Channel`](@ref) method that creates a task-bound channel expects a function that accepts a single argument of type [`Channel`](@ref). A common pattern is for the producer to be parameterized, in which case a partial function application is needed to create a 0 or 1 argument [anonymous function](@ref man-anonymous-functions).
"""

# ╔═╡ b950bcd5-a8d6-4deb-9d53-158a98963424
md"""
For [`Task`](@ref) objects this can be done either directly or by use of a convenience macro:
"""

# ╔═╡ 95c72523-ae8a-4726-bb10-cc5797dbd8b4
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

# ╔═╡ da696a0d-9035-4040-9501-ff13414911a1
md"""
To orchestrate more advanced work distribution patterns, [`bind`](@ref) and [`schedule`](@ref) can be used in conjunction with [`Task`](@ref) and [`Channel`](@ref) constructors to explicitly link a set of channels with a set of producer/consumer tasks.
"""

# ╔═╡ aa69d04f-a31a-42af-9550-ba6412c9b083
md"""
### More on Channels
"""

# ╔═╡ 03e13ad4-ed75-4abf-9c27-00f091b892ad
md"""
A channel can be visualized as a pipe, i.e., it has a write end and a read end :
"""

# ╔═╡ 206ff827-609e-4956-9724-80f9f4d3521d
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
    ERROR: InvalidStateException(\"Channel is closed.\",:closed)
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
    ERROR: InvalidStateException(\"Channel is closed.\",:closed)
    Stacktrace:
    [...]
    ```
"""

# ╔═╡ ceda4e61-2fcf-4124-85e2-14ebb98c791e
md"""
Consider a simple example using channels for inter-task communication. We start 4 tasks to process data from a single `jobs` channel. Jobs, identified by an id (`job_id`), are written to the channel. Each task in this simulation reads a `job_id`, waits for a random amount of time and writes back a tuple of `job_id` and the simulated time to the results channel. Finally all the `results` are printed out.
"""

# ╔═╡ 98e4b6cb-4b5d-47f2-8095-68ebd1372676
const jobs = Channel{Int}(32);

# ╔═╡ 2eaa4ca1-9acb-451a-af58-bcf2c76addba
const results = Channel{Tuple}(32);

# ╔═╡ d529c981-7f26-42b1-aa30-2f6df662eda3
function do_work()
     for job_id in jobs
         exec_time = rand()
         sleep(exec_time)                # simulates elapsed time doing actual work
                                         # typically performed externally.
         put!(results, (job_id, exec_time))
     end
 end;

# ╔═╡ 4acd60fe-3a0e-4e9f-92f1-cee54c541e59
function make_jobs(n)
     for i in 1:n
         put!(jobs, i)
     end
 end;

# ╔═╡ 35844b6b-7425-4395-bda2-38ebd8c871e9
n = 12;

# ╔═╡ a28c392f-363f-4d49-b6de-a345c6dc4ee6
@async make_jobs(n); # feed the jobs channel with "n" jobs

# ╔═╡ e5314213-d67c-4270-a889-5ee358177cb3
for i in 1:4 # start 4 tasks to process requests in parallel
     @async do_work()
 end

# ╔═╡ 137046f1-6d80-411f-815e-9822cc4a4b9f
@elapsed while n > 0 # print out results
     job_id, exec_time = take!(results)
     println("$job_id finished in $(round(exec_time; digits=2)) seconds")
     global n = n - 1
 end

# ╔═╡ 9b5230d6-5455-4d81-95a1-34024a0d6340
md"""
## More task operations
"""

# ╔═╡ 03d4bdd8-3ec3-41f3-96e6-2dec2f85ace0
md"""
Task operations are built on a low-level primitive called [`yieldto`](@ref). `yieldto(task, value)` suspends the current task, switches to the specified `task`, and causes that task's last [`yieldto`](@ref) call to return the specified `value`. Notice that [`yieldto`](@ref) is the only operation required to use task-style control flow; instead of calling and returning we are always just switching to a different task. This is why this feature is also called \"symmetric coroutines\"; each task is switched to and from using the same mechanism.
"""

# ╔═╡ d33621eb-f298-4a42-8c5a-70e7d8a3c933
md"""
[`yieldto`](@ref) is powerful, but most uses of tasks do not invoke it directly. Consider why this might be. If you switch away from the current task, you will probably want to switch back to it at some point, but knowing when to switch back, and knowing which task has the responsibility of switching back, can require considerable coordination. For example, [`put!`](@ref) and [`take!`](@ref) are blocking operations, which, when used in the context of channels maintain state to remember who the consumers are. Not needing to manually keep track of the consuming task is what makes [`put!`](@ref) easier to use than the low-level [`yieldto`](@ref).
"""

# ╔═╡ a16d071a-9f37-4d71-9660-1d597308ce14
md"""
In addition to [`yieldto`](@ref), a few other basic functions are needed to use tasks effectively.
"""

# ╔═╡ fb38021c-a6fc-4a59-9716-5605f948e99d
md"""
  * [`current_task`](@ref) gets a reference to the currently-running task.
  * [`istaskdone`](@ref) queries whether a task has exited.
  * [`istaskstarted`](@ref) queries whether a task has run yet.
  * [`task_local_storage`](@ref) manipulates a key-value store specific to the current task.
"""

# ╔═╡ 9da975d0-d518-4059-bb5b-318127ee701c
md"""
## Tasks and events
"""

# ╔═╡ c306dedf-bbb8-43b1-9ee9-c46b7d93da84
md"""
Most task switches occur as a result of waiting for events such as I/O requests, and are performed by a scheduler included in Julia Base. The scheduler maintains a queue of runnable tasks, and executes an event loop that restarts tasks based on external events such as message arrival.
"""

# ╔═╡ 9fdb6d28-c60b-420c-8991-05c38524f95b
md"""
The basic function for waiting for an event is [`wait`](@ref). Several objects implement [`wait`](@ref); for example, given a `Process` object, [`wait`](@ref) will wait for it to exit. [`wait`](@ref) is often implicit; for example, a [`wait`](@ref) can happen inside a call to [`read`](@ref) to wait for data to be available.
"""

# ╔═╡ 1081bf5f-6d5a-4f4c-827a-1326f0477ef0
md"""
In all of these cases, [`wait`](@ref) ultimately operates on a [`Condition`](@ref) object, which is in charge of queueing and restarting tasks. When a task calls [`wait`](@ref) on a [`Condition`](@ref), the task is marked as non-runnable, added to the condition's queue, and switches to the scheduler. The scheduler will then pick another task to run, or block waiting for external events. If all goes well, eventually an event handler will call [`notify`](@ref) on the condition, which causes tasks waiting for that condition to become runnable again.
"""

# ╔═╡ 3a62dacd-9090-4e01-bab8-cc68306f53a6
md"""
A task created explicitly by calling [`Task`](@ref) is initially not known to the scheduler. This allows you to manage tasks manually using [`yieldto`](@ref) if you wish. However, when such a task waits for an event, it still gets restarted automatically when the event happens, as you would expect.
"""

# ╔═╡ Cell order:
# ╟─c24778e3-c837-406a-8be6-88a27f505efb
# ╟─a9bad818-3d0c-4861-b642-8fbcaab98f71
# ╟─5446eb35-abf4-44ea-963d-bfb991894110
# ╟─d401c09d-bd62-403b-bd82-8867e0681b06
# ╟─be16c062-7aea-420f-8b96-2ddbc8d2bc3e
# ╠═1b95264f-4930-45cf-a8ca-8d56c2338ebd
# ╟─a35ddf90-2998-40d5-a920-4c603ee38bad
# ╟─7e055c8b-bfa5-4198-b589-2d1186b41153
# ╠═0017f7bf-67c8-4ef2-b170-ad7da31be757
# ╟─5a3c780a-bb82-4a2e-8664-90a2224abbb2
# ╟─e4b47f6c-c554-4d07-a7ab-c01731b9d44f
# ╠═002e6c2a-fe13-410f-add0-7d9870a2f0d2
# ╟─d4ca7720-0760-41a5-8269-13120b29d74e
# ╟─f19ba6af-a6c0-4b11-aa96-b4395e6b2a93
# ╟─5f8ef78d-0520-4941-a697-1050f0cfd685
# ╟─c22b0a44-f72d-4ea2-8b40-526bbd677ae3
# ╟─e495c997-a0e3-4387-8a6e-42fcb6dfc231
# ╟─fa28e560-b29e-45dd-86db-e6ec4eb85972
# ╠═1fbe497b-c0f8-46e5-a126-251335cace97
# ╠═a98165c2-fcca-408c-a761-673bbba07d51
# ╠═82dd34e2-7d41-4c80-87e1-29ea442844fb
# ╠═851195dc-af2f-447d-b7d6-1fef0bdc36a6
# ╠═3b900014-0bf5-4e71-a43b-6b08debf4d2d
# ╠═b3e3b8d7-032e-4f01-8b8d-d834db53f1ff
# ╠═6b2ffae3-146c-4663-99ae-033440941436
# ╠═7a64535c-dca8-43eb-a1aa-f599a3f7f912
# ╟─527c3491-7415-4a47-8b72-e8b6c0b0da84
# ╟─78959c2d-2279-42ab-9e8f-0b913bba79c1
# ╠═c589b3fb-ba4a-4b3c-95b6-e9bdb5fb832e
# ╟─7fcc021b-b286-4cae-a4f3-f579bf2e8e33
# ╟─131ba9e6-659a-48c5-b006-6eb19c9f46b1
# ╟─b950bcd5-a8d6-4deb-9d53-158a98963424
# ╟─95c72523-ae8a-4726-bb10-cc5797dbd8b4
# ╟─da696a0d-9035-4040-9501-ff13414911a1
# ╟─aa69d04f-a31a-42af-9550-ba6412c9b083
# ╟─03e13ad4-ed75-4abf-9c27-00f091b892ad
# ╟─206ff827-609e-4956-9724-80f9f4d3521d
# ╟─ceda4e61-2fcf-4124-85e2-14ebb98c791e
# ╠═98e4b6cb-4b5d-47f2-8095-68ebd1372676
# ╠═2eaa4ca1-9acb-451a-af58-bcf2c76addba
# ╠═d529c981-7f26-42b1-aa30-2f6df662eda3
# ╠═4acd60fe-3a0e-4e9f-92f1-cee54c541e59
# ╠═35844b6b-7425-4395-bda2-38ebd8c871e9
# ╠═a28c392f-363f-4d49-b6de-a345c6dc4ee6
# ╠═e5314213-d67c-4270-a889-5ee358177cb3
# ╠═137046f1-6d80-411f-815e-9822cc4a4b9f
# ╟─9b5230d6-5455-4d81-95a1-34024a0d6340
# ╟─03d4bdd8-3ec3-41f3-96e6-2dec2f85ace0
# ╟─d33621eb-f298-4a42-8c5a-70e7d8a3c933
# ╟─a16d071a-9f37-4d71-9660-1d597308ce14
# ╟─fb38021c-a6fc-4a59-9716-5605f948e99d
# ╟─9da975d0-d518-4059-bb5b-318127ee701c
# ╟─c306dedf-bbb8-43b1-9ee9-c46b7d93da84
# ╟─9fdb6d28-c60b-420c-8991-05c38524f95b
# ╟─1081bf5f-6d5a-4f4c-827a-1326f0477ef0
# ╟─3a62dacd-9090-4e01-bab8-cc68306f53a6
