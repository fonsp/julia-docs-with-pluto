### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ a6dfa574-17ac-480a-989a-a155183786c7
md"""
# [Multi-Threading](@id man-multithreading)
"""

# ╔═╡ ba657b23-c659-4bc9-b7dd-96f9b076bafa
md"""
Visit this [blog post](https://julialang.org/blog/2019/07/multithreading/) for a presentation of Julia multi-threading features.
"""

# ╔═╡ 01a8e3c9-66cb-49d9-84e6-19670c25ea61
md"""
## Starting Julia with multiple threads
"""

# ╔═╡ 7846f65a-a22e-4c1f-9c8d-fe501af51e46
md"""
By default, Julia starts up with a single thread of execution. This can be verified by using the command [`Threads.nthreads()`](@ref):
"""

# ╔═╡ b5d88ac6-384e-4220-9c8c-45cdc61601d0
Threads.nthreads()

# ╔═╡ f74ba6c4-64fc-4c42-be12-60563d440287
md"""
The number of execution threads is controlled either by using the `-t`/`--threads` command line argument or by using the [`JULIA_NUM_THREADS`](@ref JULIA_NUM_THREADS) environment variable. When both are specified, then `-t`/`--threads` takes precedence.
"""

# ╔═╡ 72eb8416-6575-494d-b328-855cbbcb1a7f
md"""
!!! compat \"Julia 1.5\"
    The `-t`/`--threads` command line argument requires at least Julia 1.5. In older versions you must use the environment variable instead.
"""

# ╔═╡ bed56758-46e8-464d-87e5-8a5214d12992
md"""
Lets start Julia with 4 threads:
"""

# ╔═╡ c10dc4d4-12fb-4f9a-975f-b99573de657c
md"""
```bash
$ julia --threads 4
```
"""

# ╔═╡ 11dfb1ee-2129-468a-b19b-72b8fc07272a
md"""
Let's verify there are 4 threads at our disposal.
"""

# ╔═╡ bbaa4042-08ff-495f-a83b-6e770ca3d361
Threads.nthreads()

# ╔═╡ 8d6046a1-dc61-4d27-8500-be47b31e43ce
md"""
But we are currently on the master thread. To check, we use the function [`Threads.threadid`](@ref)
"""

# ╔═╡ 83d8aff0-34ce-472c-ab57-408656114afe
Threads.threadid()

# ╔═╡ 8a7704f2-07bd-4ee2-835e-202721e1653d
md"""
!!! note
    If you prefer to use the environment variable you can set it as follows in Bash (Linux/macOS):

    ```bash
    export JULIA_NUM_THREADS=4
    ```

    C shell on Linux/macOS, CMD on Windows:

    ```bash
    set JULIA_NUM_THREADS=4
    ```

    Powershell on Windows:

    ```powershell
    $env:JULIA_NUM_THREADS=4
    ```

    Note that this must be done *before* starting Julia.
"""

# ╔═╡ 459fc69d-5307-4bd6-b6c2-c269ec0fc5e7
md"""
!!! note
    The number of threads specified with `-t`/`--threads` is propagated to worker processes that are spawned using the `-p`/`--procs` or `--machine-file` command line options. For example, `julia -p2 -t2` spawns 1 main process with 2 worker processes, and all three processes have 2 threads enabled. For more fine grained control over worker threads use [`addprocs`](@ref) and pass `-t`/`--threads` as `exeflags`.
"""

# ╔═╡ f8f9b7e5-9176-4b6d-a321-4f82864f29bf
md"""
## Data-race freedom
"""

# ╔═╡ 092e9a7d-b12a-4bff-a4c2-bcc1c1e25c3e
md"""
You are entirely responsible for ensuring that your program is data-race free, and nothing promised here can be assumed if you do not observe that requirement. The observed results may be highly unintuitive.
"""

# ╔═╡ bfebf553-4bf4-44c7-b457-22fe410a5c8d
md"""
The best way to ensure this is to acquire a lock around any access to data that can be observed from multiple threads. For example, in most cases you should use the following code pattern:
"""

# ╔═╡ af8f8d7e-fca8-4ab5-93b6-35192c52060b
lock(lk) do
     use(a)
 end

# ╔═╡ 4ea96721-1bdb-4be2-97a2-1962d8873a4e
begin
     lock(lk)
     try
         use(a)
     finally
         unlock(lk)
     end
 end

# ╔═╡ 9f147960-089b-475c-9d77-76aae42c9610
md"""
where `lk` is a lock (e.g. `ReentrantLock()`) and `a` data.
"""

# ╔═╡ 76cf2c41-3a32-4e27-b8da-9822091ac24f
md"""
Additionally, Julia is not memory safe in the presence of a data race. Be very careful about reading *any* data if another thread might write to it! Instead, always use the lock pattern above when changing data (such as assigning to a global or closure variable) accessed by other threads.
"""

# ╔═╡ 0fed800f-b26b-40fa-9fd8-148a5ba0f9f1
md"""
```julia
Thread 1:
global b = false
global a = rand()
global b = true

Thread 2:
while !b; end
bad_read1(a) # it is NOT safe to access `a` here!

Thread 3:
while !@isdefined(a); end
bad_read2(a) # it is NOT safe to access `a` here
```
"""

# ╔═╡ c188eb85-8a4a-434c-b11b-3a0572fa9edc
md"""
## The `@threads` Macro
"""

# ╔═╡ 58f8f2b2-01f6-4ced-9add-8b03f6157ab9
md"""
Let's work a simple example using our native threads. Let us create an array of zeros:
"""

# ╔═╡ 5bd71cc4-9090-445f-8d3c-e4840da44479
a = zeros(10)

# ╔═╡ 38d7353c-fc90-42c1-800b-accf6e19761f
md"""
Let us operate on this array simultaneously using 4 threads. We'll have each thread write its thread ID into each location.
"""

# ╔═╡ bfbbe4fb-075b-4b76-9c46-04ae0c416031
md"""
Julia supports parallel loops using the [`Threads.@threads`](@ref) macro. This macro is affixed in front of a `for` loop to indicate to Julia that the loop is a multi-threaded region:
"""

# ╔═╡ 8907bfa0-79ce-4bc1-85fe-324a6e3b6d4e
Threads.@threads for i = 1:10
     a[i] = Threads.threadid()
 end

# ╔═╡ 917eeeda-fed2-466f-847d-0971c1fc8935
md"""
The iteration space is split among the threads, after which each thread writes its thread ID to its assigned locations:
"""

# ╔═╡ 132fb3f7-35d4-4c6e-975a-b2f6541e640c
a

# ╔═╡ d2f80dec-16d0-45e8-8b54-83dd8786911f
md"""
Note that [`Threads.@threads`](@ref) does not have an optional reduction parameter like [`@distributed`](@ref).
"""

# ╔═╡ bfeb2bde-82b0-41c9-a5fe-afd2093bdd84
md"""
## Atomic Operations
"""

# ╔═╡ 8381c6e9-4bcd-4d6a-9026-641aaebf4372
md"""
Julia supports accessing and modifying values *atomically*, that is, in a thread-safe way to avoid [race conditions](https://en.wikipedia.org/wiki/Race_condition). A value (which must be of a primitive type) can be wrapped as [`Threads.Atomic`](@ref) to indicate it must be accessed in this way. Here we can see an example:
"""

# ╔═╡ a21b71cf-e870-4dd1-8bc1-501db0dd411b
i = Threads.Atomic{Int}(0);

# ╔═╡ 567fdc5a-a12d-4285-ad12-7ca65e4e0cb7
ids = zeros(4);

# ╔═╡ 53115c5f-2dcb-450b-9351-3876535f50fd
old_is = zeros(4);

# ╔═╡ 482acec0-6eba-473e-92a1-a5902689dfa5
Threads.@threads for id in 1:4
     old_is[id] = Threads.atomic_add!(i, id)
     ids[id] = id
 end

# ╔═╡ daffabaf-af5c-4333-b70f-7cd1197cdc5c
old_is

# ╔═╡ f15f9986-0e27-42e8-88cf-79d08c27b3c2
ids

# ╔═╡ 85854609-bb66-4c74-b0f2-3cd5cfb3f4ad
md"""
Had we tried to do the addition without the atomic tag, we might have gotten the wrong answer due to a race condition. An example of what would happen if we didn't avoid the race:
"""

# ╔═╡ 73b07176-ebe3-402a-b648-f3bd002f7cb2
using Base.Threads

# ╔═╡ 3466902c-cd2f-43d8-ba26-ee70d4612369
nthreads()

# ╔═╡ 2ef29587-cf3e-4f04-b846-617084f7412a
acc = Ref(0)

# ╔═╡ 9d7b12a7-cdae-4eea-8fe2-c50a4ffd6795
@threads for i in 1:1000
    acc[] += 1
 end

# ╔═╡ c9bdd9b8-6399-4c23-8a21-59af00e2bee4
acc[]

# ╔═╡ 32e0f620-9659-4b99-8fad-1f7341907940
acc = Atomic{Int64}(0)

# ╔═╡ 4ec05c6e-e2cd-49a5-8ed9-98e5123fa61d
@threads for i in 1:1000
    atomic_add!(acc, 1)
 end

# ╔═╡ 319adc7b-af16-4006-903b-e53832ee6d38
acc[]

# ╔═╡ 7b9699e3-cbf9-4e2f-9b4d-db602534800b
md"""
!!! note
    Not *all* primitive types can be wrapped in an `Atomic` tag. Supported types are `Int8`, `Int16`, `Int32`, `Int64`, `Int128`, `UInt8`, `UInt16`, `UInt32`, `UInt64`, `UInt128`, `Float16`, `Float32`, and `Float64`. Additionally, `Int128` and `UInt128` are not supported on AAarch32 and ppc64le.
"""

# ╔═╡ 3bf0c333-43dd-465a-9f37-a7c05d18116f
md"""
## Side effects and mutable function arguments
"""

# ╔═╡ 29238f8e-19eb-4639-9cd1-74349fd285ff
md"""
When using multi-threading we have to be careful when using functions that are not [pure](https://en.wikipedia.org/wiki/Pure_function) as we might get a wrong answer. For instance functions that have a [name ending with `!`](@ref bang-convention) by convention modify their arguments and thus are not pure.
"""

# ╔═╡ 2ceac4a0-9de7-4d87-83ab-38554ccc7d37
md"""
## @threadcall
"""

# ╔═╡ 40536760-b1a2-40a9-b6b1-75d83df53896
md"""
External libraries, such as those called via [`ccall`](@ref), pose a problem for Julia's task-based I/O mechanism. If a C library performs a blocking operation, that prevents the Julia scheduler from executing any other tasks until the call returns. (Exceptions are calls into custom C code that call back into Julia, which may then yield, or C code that calls `jl_yield()`, the C equivalent of [`yield`](@ref).)
"""

# ╔═╡ 4c3c12a5-d449-4747-8f95-a9c26742a844
md"""
The [`@threadcall`](@ref) macro provides a way to avoid stalling execution in such a scenario. It schedules a C function for execution in a separate thread. A threadpool with a default size of 4 is used for this. The size of the threadpool is controlled via environment variable `UV_THREADPOOL_SIZE`. While waiting for a free thread, and during function execution once a thread is available, the requesting task (on the main Julia event loop) yields to other tasks. Note that `@threadcall` does not return until the execution is complete. From a user point of view, it is therefore a blocking call like other Julia APIs.
"""

# ╔═╡ 227b67a4-7cdd-44b2-aeb7-af296d798ade
md"""
It is very important that the called function does not call back into Julia, as it will segfault.
"""

# ╔═╡ 7c8767d9-dfae-4957-8717-d77cbde08136
md"""
`@threadcall` may be removed/changed in future versions of Julia.
"""

# ╔═╡ 5ccbb7dd-fc86-46bc-93bf-b9ab41bb018c
md"""
## Caveats
"""

# ╔═╡ dc5509e2-7dc1-4307-920c-2f6e0eeacf3d
md"""
At this time, most operations in the Julia runtime and standard libraries can be used in a thread-safe manner, if the user code is data-race free. However, in some areas work on stabilizing thread support is ongoing. Multi-threaded programming has many inherent difficulties, and if a program using threads exhibits unusual or undesirable behavior (e.g. crashes or mysterious results), thread interactions should typically be suspected first.
"""

# ╔═╡ f2beabec-9a23-45cc-84ef-ca06957c17ae
md"""
There are a few specific limitations and warnings to be aware of when using threads in Julia:
"""

# ╔═╡ a7c13115-e883-442e-82aa-cf04b6cb2e72
md"""
  * Base collection types require manual locking if used simultaneously by multiple threads where at least one thread modifies the collection (common examples include `push!` on arrays, or inserting items into a `Dict`).
  * After a task starts running on a certain thread (e.g. via `@spawn`), it will always be restarted on the same thread after blocking. In the future this limitation will be removed, and tasks will migrate between threads.
  * `@threads` currently uses a static schedule, using all threads and assigning equal iteration counts to each. In the future the default schedule is likely to change to be dynamic.
  * The schedule used by `@spawn` is nondeterministic and should not be relied on.
  * Compute-bound, non-memory-allocating tasks can prevent garbage collection from running in other threads that are allocating memory. In these cases it may be necessary to insert a manual call to `GC.safepoint()` to allow GC to run. This limitation will be removed in the future.
  * Avoid running top-level operations, e.g. `include`, or `eval` of type, method, and module definitions in parallel.
  * Be aware that finalizers registered by a library may break if threads are enabled. This may require some transitional work across the ecosystem before threading can be widely adopted with confidence. See the next section for further details.
"""

# ╔═╡ 0dfd299e-45a1-49f1-b2f7-2e5bf3ca0f9e
md"""
## Safe use of Finalizers
"""

# ╔═╡ e9cbd788-c1bb-462c-9165-d8b72ab2776d
md"""
Because finalizers can interrupt any code, they must be very careful in how they interact with any global state. Unfortunately, the main reason that finalizers are used is to update global state (a pure function is generally rather pointless as a finalizer). This leads us to a bit of a conundrum. There are a few approaches to dealing with this problem:
"""

# ╔═╡ e97d6d4b-6986-4d76-a70b-1a338ef9a95b
md"""
1. When single-threaded, code could call the internal `jl_gc_enable_finalizers` C function to prevent finalizers from being scheduled inside a critical region. Internally, this is used inside some functions (such as our C locks) to prevent recursion when doing certain operations (incremental package loading, codegen, etc.). The combination of a lock and this flag can be used to make finalizers safe.
2. A second strategy, employed by Base in a couple places, is to explicitly delay a finalizer until it may be able to acquire its lock non-recursively. The following example demonstrates how this strategy could be applied to `Distributed.finalize_ref`:

    ```julia
    function finalize_ref(r::AbstractRemoteRef)
        if r.where > 0 # Check if the finalizer is already run
            if islocked(client_refs) || !trylock(client_refs)
                # delay finalizer for later if we aren't free to acquire the lock
                finalizer(finalize_ref, r)
                return nothing
            end
            try # `lock` should always be followed by `try`
                if r.where > 0 # Must check again here
                    # Do actual cleanup here
                    r.where = 0
                end
            finally
                unlock(client_refs)
            end
        end
        nothing
    end
    ```
3. A related third strategy is to use a yield-free queue. We don't currently have a lock-free queue implemented in Base, but `Base.InvasiveLinkedListSynchronized{T}` is suitable. This can frequently be a good strategy to use for code with event loops. For example, this strategy is employed by `Gtk.jl` to manage lifetime ref-counting. In this approach, we don't do any explicit work inside the `finalizer`, and instead add it to a queue to run at a safer time. In fact, Julia's task scheduler already uses this, so defining the finalizer as `x -> @spawn do_cleanup(x)` is one example of this approach. Note however that this doesn't control which thread `do_cleanup` runs on, so `do_cleanup` would still need to acquire a lock. That doesn't need to be true if you implement your own queue, as you can explicitly only drain that queue from your thread.
"""

# ╔═╡ Cell order:
# ╟─a6dfa574-17ac-480a-989a-a155183786c7
# ╟─ba657b23-c659-4bc9-b7dd-96f9b076bafa
# ╟─01a8e3c9-66cb-49d9-84e6-19670c25ea61
# ╟─7846f65a-a22e-4c1f-9c8d-fe501af51e46
# ╠═b5d88ac6-384e-4220-9c8c-45cdc61601d0
# ╟─f74ba6c4-64fc-4c42-be12-60563d440287
# ╟─72eb8416-6575-494d-b328-855cbbcb1a7f
# ╟─bed56758-46e8-464d-87e5-8a5214d12992
# ╟─c10dc4d4-12fb-4f9a-975f-b99573de657c
# ╟─11dfb1ee-2129-468a-b19b-72b8fc07272a
# ╠═bbaa4042-08ff-495f-a83b-6e770ca3d361
# ╟─8d6046a1-dc61-4d27-8500-be47b31e43ce
# ╠═83d8aff0-34ce-472c-ab57-408656114afe
# ╟─8a7704f2-07bd-4ee2-835e-202721e1653d
# ╟─459fc69d-5307-4bd6-b6c2-c269ec0fc5e7
# ╟─f8f9b7e5-9176-4b6d-a321-4f82864f29bf
# ╟─092e9a7d-b12a-4bff-a4c2-bcc1c1e25c3e
# ╟─bfebf553-4bf4-44c7-b457-22fe410a5c8d
# ╠═af8f8d7e-fca8-4ab5-93b6-35192c52060b
# ╠═4ea96721-1bdb-4be2-97a2-1962d8873a4e
# ╟─9f147960-089b-475c-9d77-76aae42c9610
# ╟─76cf2c41-3a32-4e27-b8da-9822091ac24f
# ╟─0fed800f-b26b-40fa-9fd8-148a5ba0f9f1
# ╟─c188eb85-8a4a-434c-b11b-3a0572fa9edc
# ╟─58f8f2b2-01f6-4ced-9add-8b03f6157ab9
# ╠═5bd71cc4-9090-445f-8d3c-e4840da44479
# ╟─38d7353c-fc90-42c1-800b-accf6e19761f
# ╟─bfbbe4fb-075b-4b76-9c46-04ae0c416031
# ╠═8907bfa0-79ce-4bc1-85fe-324a6e3b6d4e
# ╟─917eeeda-fed2-466f-847d-0971c1fc8935
# ╠═132fb3f7-35d4-4c6e-975a-b2f6541e640c
# ╟─d2f80dec-16d0-45e8-8b54-83dd8786911f
# ╟─bfeb2bde-82b0-41c9-a5fe-afd2093bdd84
# ╟─8381c6e9-4bcd-4d6a-9026-641aaebf4372
# ╠═a21b71cf-e870-4dd1-8bc1-501db0dd411b
# ╠═567fdc5a-a12d-4285-ad12-7ca65e4e0cb7
# ╠═53115c5f-2dcb-450b-9351-3876535f50fd
# ╠═482acec0-6eba-473e-92a1-a5902689dfa5
# ╠═daffabaf-af5c-4333-b70f-7cd1197cdc5c
# ╠═f15f9986-0e27-42e8-88cf-79d08c27b3c2
# ╟─85854609-bb66-4c74-b0f2-3cd5cfb3f4ad
# ╠═73b07176-ebe3-402a-b648-f3bd002f7cb2
# ╠═3466902c-cd2f-43d8-ba26-ee70d4612369
# ╠═2ef29587-cf3e-4f04-b846-617084f7412a
# ╠═9d7b12a7-cdae-4eea-8fe2-c50a4ffd6795
# ╠═c9bdd9b8-6399-4c23-8a21-59af00e2bee4
# ╠═32e0f620-9659-4b99-8fad-1f7341907940
# ╠═4ec05c6e-e2cd-49a5-8ed9-98e5123fa61d
# ╠═319adc7b-af16-4006-903b-e53832ee6d38
# ╟─7b9699e3-cbf9-4e2f-9b4d-db602534800b
# ╟─3bf0c333-43dd-465a-9f37-a7c05d18116f
# ╟─29238f8e-19eb-4639-9cd1-74349fd285ff
# ╟─2ceac4a0-9de7-4d87-83ab-38554ccc7d37
# ╟─40536760-b1a2-40a9-b6b1-75d83df53896
# ╟─4c3c12a5-d449-4747-8f95-a9c26742a844
# ╟─227b67a4-7cdd-44b2-aeb7-af296d798ade
# ╟─7c8767d9-dfae-4957-8717-d77cbde08136
# ╟─5ccbb7dd-fc86-46bc-93bf-b9ab41bb018c
# ╟─dc5509e2-7dc1-4307-920c-2f6e0eeacf3d
# ╟─f2beabec-9a23-45cc-84ef-ca06957c17ae
# ╟─a7c13115-e883-442e-82aa-cf04b6cb2e72
# ╟─0dfd299e-45a1-49f1-b2f7-2e5bf3ca0f9e
# ╟─e9cbd788-c1bb-462c-9165-d8b72ab2776d
# ╟─e97d6d4b-6986-4d76-a70b-1a338ef9a95b
