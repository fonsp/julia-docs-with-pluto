### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03d0cb02-9e19-11eb-06f7-a5a74663d2b6
md"""
# [Multi-Threading](@id man-multithreading)
"""

# ╔═╡ 03d0cb34-9e19-11eb-2839-8dc7046ebef4
md"""
Visit this [blog post](https://julialang.org/blog/2019/07/multithreading/) for a presentation of Julia multi-threading features.
"""

# ╔═╡ 03d0cb70-9e19-11eb-0956-0d0a68630eed
md"""
## Starting Julia with multiple threads
"""

# ╔═╡ 03d0cb8e-9e19-11eb-220a-655e70ba678f
md"""
By default, Julia starts up with a single thread of execution. This can be verified by using the command [`Threads.nthreads()`](@ref):
"""

# ╔═╡ 03d0d2fa-9e19-11eb-2718-db5ec698660c
Threads.nthreads()

# ╔═╡ 03d0d354-9e19-11eb-3c69-1b104a34538b
md"""
The number of execution threads is controlled either by using the `-t`/`--threads` command line argument or by using the [`JULIA_NUM_THREADS`](@ref JULIA_NUM_THREADS) environment variable. When both are specified, then `-t`/`--threads` takes precedence.
"""

# ╔═╡ 03d0d44e-9e19-11eb-01a7-5ddaf5c77892
md"""
!!! compat "Julia 1.5"
    The `-t`/`--threads` command line argument requires at least Julia 1.5. In older versions you must use the environment variable instead.
"""

# ╔═╡ 03d0d46c-9e19-11eb-1807-973983df8bce
md"""
Lets start Julia with 4 threads:
"""

# ╔═╡ 03d0d766-9e19-11eb-0862-6fcec83a774b
$ julia -

# ╔═╡ 03d0d798-9e19-11eb-1adc-a99bb37f4948
md"""
Let's verify there are 4 threads at our disposal.
"""

# ╔═╡ 03d0d944-9e19-11eb-24ae-578fe6cfa2f9
Threads.nthreads()

# ╔═╡ 03d0d976-9e19-11eb-2a30-595dd0ab542f
md"""
But we are currently on the master thread. To check, we use the function [`Threads.threadid`](@ref)
"""

# ╔═╡ 03d0da7a-9e19-11eb-0a87-138e4293993e
Threads.threadid()

# ╔═╡ 03d0db9e-9e19-11eb-2a73-412b0c146466
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

# ╔═╡ 03d0dc28-9e19-11eb-2334-811960569295
md"""
!!! note
    The number of threads specified with `-t`/`--threads` is propagated to worker processes that are spawned using the `-p`/`--procs` or `--machine-file` command line options. For example, `julia -p2 -t2` spawns 1 main process with 2 worker processes, and all three processes have 2 threads enabled. For more fine grained control over worker threads use [`addprocs`](@ref) and pass `-t`/`--threads` as `exeflags`.
"""

# ╔═╡ 03d0dc3c-9e19-11eb-0446-1729c62db564
md"""
## Data-race freedom
"""

# ╔═╡ 03d0dc64-9e19-11eb-185e-41be0e08dc2d
md"""
You are entirely responsible for ensuring that your program is data-race free, and nothing promised here can be assumed if you do not observe that requirement. The observed results may be highly unintuitive.
"""

# ╔═╡ 03d0dc6e-9e19-11eb-0d47-9d95bdca459b
md"""
The best way to ensure this is to acquire a lock around any access to data that can be observed from multiple threads. For example, in most cases you should use the following code pattern:
"""

# ╔═╡ 03d0e1dc-9e19-11eb-1c58-374de3486eac
lock(lk) do
           use(a)
       end

# ╔═╡ 03d0e1e6-9e19-11eb-0fe7-d1f465b06360
begin
           lock(lk)
           try
               use(a)
           finally
               unlock(lk)
           end
       end

# ╔═╡ 03d0e218-9e19-11eb-392e-7fd053cb0495
md"""
where `lk` is a lock (e.g. `ReentrantLock()`) and `a` data.
"""

# ╔═╡ 03d0e236-9e19-11eb-2c4d-7377a66efd37
md"""
Additionally, Julia is not memory safe in the presence of a data race. Be very careful about reading *any* data if another thread might write to it! Instead, always use the lock pattern above when changing data (such as assigning to a global or closure variable) accessed by other threads.
"""

# ╔═╡ 03d0e274-9e19-11eb-323e-e13eb2c0a3c0
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

# ╔═╡ 03d0e2b8-9e19-11eb-29a7-658157795315
md"""
## The `@threads` Macro
"""

# ╔═╡ 03d0e2cc-9e19-11eb-3971-11d704a1594d
md"""
Let's work a simple example using our native threads. Let us create an array of zeros:
"""

# ╔═╡ 03d0e4fc-9e19-11eb-056a-c5430504d66e
a = zeros(10)

# ╔═╡ 03d0e512-9e19-11eb-3eb3-5725faf4a0c9
md"""
Let us operate on this array simultaneously using 4 threads. We'll have each thread write its thread ID into each location.
"""

# ╔═╡ 03d0e54c-9e19-11eb-1bbb-7336020b2425
md"""
Julia supports parallel loops using the [`Threads.@threads`](@ref) macro. This macro is affixed in front of a `for` loop to indicate to Julia that the loop is a multi-threaded region:
"""

# ╔═╡ 03d0e9a2-9e19-11eb-05fa-4555c3774c6e
Threads.@threads for i = 1:10
           a[i] = Threads.threadid()
       end

# ╔═╡ 03d0e9c0-9e19-11eb-349f-4100a7cc4b92
md"""
The iteration space is split among the threads, after which each thread writes its thread ID to its assigned locations:
"""

# ╔═╡ 03d0ea4c-9e19-11eb-0cfe-4dae98a90215
a

# ╔═╡ 03d0ea88-9e19-11eb-1b0c-1351b0c92c2a
md"""
Note that [`Threads.@threads`](@ref) does not have an optional reduction parameter like [`@distributed`](@ref).
"""

# ╔═╡ 03d0ea9c-9e19-11eb-16b8-49d409d65cb3
md"""
## Atomic Operations
"""

# ╔═╡ 03d0eac4-9e19-11eb-31b7-813fd4ee78c6
md"""
Julia supports accessing and modifying values *atomically*, that is, in a thread-safe way to avoid [race conditions](https://en.wikipedia.org/wiki/Race_condition). A value (which must be of a primitive type) can be wrapped as [`Threads.Atomic`](@ref) to indicate it must be accessed in this way. Here we can see an example:
"""

# ╔═╡ 03d0f51e-9e19-11eb-0970-ad92357773cf
i = Threads.Atomic{Int}(0);

# ╔═╡ 03d0f528-9e19-11eb-028a-7363041f6ed2
ids = zeros(4);

# ╔═╡ 03d0f532-9e19-11eb-33f5-f584eb30d55e
old_is = zeros(4);

# ╔═╡ 03d0f532-9e19-11eb-1fdb-cd0e39c703c6
Threads.@threads for id in 1:4
           old_is[id] = Threads.atomic_add!(i, id)
           ids[id] = id
       end

# ╔═╡ 03d0f53c-9e19-11eb-1dea-7900540eb21c
old_is

# ╔═╡ 03d0f55c-9e19-11eb-3340-4b2ef3bae23c
ids

# ╔═╡ 03d0f56e-9e19-11eb-3dd4-35fbe37ee25c
md"""
Had we tried to do the addition without the atomic tag, we might have gotten the wrong answer due to a race condition. An example of what would happen if we didn't avoid the race:
"""

# ╔═╡ 03d10158-9e19-11eb-214f-39ef3f90f22f
using Base.Threads

# ╔═╡ 03d10176-9e19-11eb-200f-ff7e6835315f
nthreads()

# ╔═╡ 03d10180-9e19-11eb-1145-57b15275cdf7
acc = Ref(0)

# ╔═╡ 03d10180-9e19-11eb-10f7-6df89202ee71
@threads for i in 1:1000
          acc[] += 1
       end

# ╔═╡ 03d1018a-9e19-11eb-3372-9bce01596c29
acc[]

# ╔═╡ 03d1018a-9e19-11eb-02f9-511ad2464ed9
acc = Atomic{Int64}(0)

# ╔═╡ 03d10194-9e19-11eb-27ca-f3baaf94811e
@threads for i in 1:1000
          atomic_add!(acc, 1)
       end

# ╔═╡ 03d1019e-9e19-11eb-0e43-a9bf679b3368
acc[]

# ╔═╡ 03d102c0-9e19-11eb-32d3-ef9a5c2a518b
md"""
!!! note
    Not *all* primitive types can be wrapped in an `Atomic` tag. Supported types are `Int8`, `Int16`, `Int32`, `Int64`, `Int128`, `UInt8`, `UInt16`, `UInt32`, `UInt64`, `UInt128`, `Float16`, `Float32`, and `Float64`. Additionally, `Int128` and `UInt128` are not supported on AAarch32 and ppc64le.
"""

# ╔═╡ 03d102d4-9e19-11eb-3a36-371ee0ad9abb
md"""
## Side effects and mutable function arguments
"""

# ╔═╡ 03d10310-9e19-11eb-03f2-ebb2ad914920
md"""
When using multi-threading we have to be careful when using functions that are not [pure](https://en.wikipedia.org/wiki/Pure_function) as we might get a wrong answer. For instance functions that have a [name ending with `!`](@ref bang-convention) by convention modify their arguments and thus are not pure.
"""

# ╔═╡ 03d10324-9e19-11eb-30f3-8ba066075219
md"""
## @threadcall
"""

# ╔═╡ 03d10356-9e19-11eb-3962-59a0fef0796d
md"""
External libraries, such as those called via [`ccall`](@ref), pose a problem for Julia's task-based I/O mechanism. If a C library performs a blocking operation, that prevents the Julia scheduler from executing any other tasks until the call returns. (Exceptions are calls into custom C code that call back into Julia, which may then yield, or C code that calls `jl_yield()`, the C equivalent of [`yield`](@ref).)
"""

# ╔═╡ 03d1039a-9e19-11eb-3218-dbaff15a6da0
md"""
The [`@threadcall`](@ref) macro provides a way to avoid stalling execution in such a scenario. It schedules a C function for execution in a separate thread. A threadpool with a default size of 4 is used for this. The size of the threadpool is controlled via environment variable `UV_THREADPOOL_SIZE`. While waiting for a free thread, and during function execution once a thread is available, the requesting task (on the main Julia event loop) yields to other tasks. Note that `@threadcall` does not return until the execution is complete. From a user point of view, it is therefore a blocking call like other Julia APIs.
"""

# ╔═╡ 03d103b0-9e19-11eb-0bb8-bd2250946034
md"""
It is very important that the called function does not call back into Julia, as it will segfault.
"""

# ╔═╡ 03d103cc-9e19-11eb-13e1-d3f6ebc5f6fc
md"""
`@threadcall` may be removed/changed in future versions of Julia.
"""

# ╔═╡ 03d103ec-9e19-11eb-175b-1dd1f5dcd8f9
md"""
## Caveats
"""

# ╔═╡ 03d103fe-9e19-11eb-1660-956c51e132fc
md"""
At this time, most operations in the Julia runtime and standard libraries can be used in a thread-safe manner, if the user code is data-race free. However, in some areas work on stabilizing thread support is ongoing. Multi-threaded programming has many inherent difficulties, and if a program using threads exhibits unusual or undesirable behavior (e.g. crashes or mysterious results), thread interactions should typically be suspected first.
"""

# ╔═╡ 03d1040a-9e19-11eb-3ecb-eddd5acba15e
md"""
There are a few specific limitations and warnings to be aware of when using threads in Julia:
"""

# ╔═╡ 03d10612-9e19-11eb-2f41-3ddf4d4fa252
md"""
  * Base collection types require manual locking if used simultaneously by multiple threads where at least one thread modifies the collection (common examples include `push!` on arrays, or inserting items into a `Dict`).
  * After a task starts running on a certain thread (e.g. via `@spawn`), it will always be restarted on the same thread after blocking. In the future this limitation will be removed, and tasks will migrate between threads.
  * `@threads` currently uses a static schedule, using all threads and assigning equal iteration counts to each. In the future the default schedule is likely to change to be dynamic.
  * The schedule used by `@spawn` is nondeterministic and should not be relied on.
  * Compute-bound, non-memory-allocating tasks can prevent garbage collection from running in other threads that are allocating memory. In these cases it may be necessary to insert a manual call to `GC.safepoint()` to allow GC to run. This limitation will be removed in the future.
  * Avoid running top-level operations, e.g. `include`, or `eval` of type, method, and module definitions in parallel.
  * Be aware that finalizers registered by a library may break if threads are enabled. This may require some transitional work across the ecosystem before threading can be widely adopted with confidence. See the next section for further details.
"""

# ╔═╡ 03d10630-9e19-11eb-388e-6df3172ec748
md"""
## Safe use of Finalizers
"""

# ╔═╡ 03d10658-9e19-11eb-0826-5f52956d29e1
md"""
Because finalizers can interrupt any code, they must be very careful in how they interact with any global state. Unfortunately, the main reason that finalizers are used is to update global state (a pure function is generally rather pointless as a finalizer). This leads us to a bit of a conundrum. There are a few approaches to dealing with this problem:
"""

# ╔═╡ 03d108b0-9e19-11eb-1f6a-858962856eb8
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
# ╟─03d0cb02-9e19-11eb-06f7-a5a74663d2b6
# ╟─03d0cb34-9e19-11eb-2839-8dc7046ebef4
# ╟─03d0cb70-9e19-11eb-0956-0d0a68630eed
# ╟─03d0cb8e-9e19-11eb-220a-655e70ba678f
# ╠═03d0d2fa-9e19-11eb-2718-db5ec698660c
# ╟─03d0d354-9e19-11eb-3c69-1b104a34538b
# ╟─03d0d44e-9e19-11eb-01a7-5ddaf5c77892
# ╟─03d0d46c-9e19-11eb-1807-973983df8bce
# ╠═03d0d766-9e19-11eb-0862-6fcec83a774b
# ╟─03d0d798-9e19-11eb-1adc-a99bb37f4948
# ╠═03d0d944-9e19-11eb-24ae-578fe6cfa2f9
# ╟─03d0d976-9e19-11eb-2a30-595dd0ab542f
# ╠═03d0da7a-9e19-11eb-0a87-138e4293993e
# ╟─03d0db9e-9e19-11eb-2a73-412b0c146466
# ╟─03d0dc28-9e19-11eb-2334-811960569295
# ╟─03d0dc3c-9e19-11eb-0446-1729c62db564
# ╟─03d0dc64-9e19-11eb-185e-41be0e08dc2d
# ╟─03d0dc6e-9e19-11eb-0d47-9d95bdca459b
# ╠═03d0e1dc-9e19-11eb-1c58-374de3486eac
# ╠═03d0e1e6-9e19-11eb-0fe7-d1f465b06360
# ╟─03d0e218-9e19-11eb-392e-7fd053cb0495
# ╟─03d0e236-9e19-11eb-2c4d-7377a66efd37
# ╟─03d0e274-9e19-11eb-323e-e13eb2c0a3c0
# ╟─03d0e2b8-9e19-11eb-29a7-658157795315
# ╟─03d0e2cc-9e19-11eb-3971-11d704a1594d
# ╠═03d0e4fc-9e19-11eb-056a-c5430504d66e
# ╟─03d0e512-9e19-11eb-3eb3-5725faf4a0c9
# ╟─03d0e54c-9e19-11eb-1bbb-7336020b2425
# ╠═03d0e9a2-9e19-11eb-05fa-4555c3774c6e
# ╟─03d0e9c0-9e19-11eb-349f-4100a7cc4b92
# ╠═03d0ea4c-9e19-11eb-0cfe-4dae98a90215
# ╟─03d0ea88-9e19-11eb-1b0c-1351b0c92c2a
# ╟─03d0ea9c-9e19-11eb-16b8-49d409d65cb3
# ╟─03d0eac4-9e19-11eb-31b7-813fd4ee78c6
# ╠═03d0f51e-9e19-11eb-0970-ad92357773cf
# ╠═03d0f528-9e19-11eb-028a-7363041f6ed2
# ╠═03d0f532-9e19-11eb-33f5-f584eb30d55e
# ╠═03d0f532-9e19-11eb-1fdb-cd0e39c703c6
# ╠═03d0f53c-9e19-11eb-1dea-7900540eb21c
# ╠═03d0f55c-9e19-11eb-3340-4b2ef3bae23c
# ╟─03d0f56e-9e19-11eb-3dd4-35fbe37ee25c
# ╠═03d10158-9e19-11eb-214f-39ef3f90f22f
# ╠═03d10176-9e19-11eb-200f-ff7e6835315f
# ╠═03d10180-9e19-11eb-1145-57b15275cdf7
# ╠═03d10180-9e19-11eb-10f7-6df89202ee71
# ╠═03d1018a-9e19-11eb-3372-9bce01596c29
# ╠═03d1018a-9e19-11eb-02f9-511ad2464ed9
# ╠═03d10194-9e19-11eb-27ca-f3baaf94811e
# ╠═03d1019e-9e19-11eb-0e43-a9bf679b3368
# ╟─03d102c0-9e19-11eb-32d3-ef9a5c2a518b
# ╟─03d102d4-9e19-11eb-3a36-371ee0ad9abb
# ╟─03d10310-9e19-11eb-03f2-ebb2ad914920
# ╟─03d10324-9e19-11eb-30f3-8ba066075219
# ╟─03d10356-9e19-11eb-3962-59a0fef0796d
# ╟─03d1039a-9e19-11eb-3218-dbaff15a6da0
# ╟─03d103b0-9e19-11eb-0bb8-bd2250946034
# ╟─03d103cc-9e19-11eb-13e1-d3f6ebc5f6fc
# ╟─03d103ec-9e19-11eb-175b-1dd1f5dcd8f9
# ╟─03d103fe-9e19-11eb-1660-956c51e132fc
# ╟─03d1040a-9e19-11eb-3ecb-eddd5acba15e
# ╟─03d10612-9e19-11eb-2f41-3ddf4d4fa252
# ╟─03d10630-9e19-11eb-388e-6df3172ec748
# ╟─03d10658-9e19-11eb-0826-5f52956d29e1
# ╟─03d108b0-9e19-11eb-1f6a-858962856eb8
