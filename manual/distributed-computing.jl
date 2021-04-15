### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03c0d3be-9e19-11eb-277f-23638dc88bdc
md"""
# Multi-processing and Distributed Computing
"""

# ╔═╡ 03c0d40e-9e19-11eb-1274-41b61ba04e47
md"""
An implementation of distributed memory parallel computing is provided by module `Distributed` as part of the standard library shipped with Julia.
"""

# ╔═╡ 03c0d49a-9e19-11eb-2543-551bf8f3c2f2
md"""
Most modern computers possess more than one CPU, and several computers can be combined together in a cluster. Harnessing the power of these multiple CPUs allows many computations to be completed more quickly. There are two major factors that influence performance: the speed of the CPUs themselves, and the speed of their access to memory. In a cluster, it's fairly obvious that a given CPU will have fastest access to the RAM within the same computer (node). Perhaps more surprisingly, similar issues are relevant on a typical multicore laptop, due to differences in the speed of main memory and the [cache](https://www.akkadia.org/drepper/cpumemory.pdf). Consequently, a good multiprocessing environment should allow control over the "ownership" of a chunk of memory by a particular CPU. Julia provides a multiprocessing environment based on message passing to allow programs to run on multiple processes in separate memory domains at once.
"""

# ╔═╡ 03c0d4cc-9e19-11eb-1033-c707b249c958
md"""
Julia's implementation of message passing is different from other environments such as MPI[^1]. Communication in Julia is generally "one-sided", meaning that the programmer needs to explicitly manage only one process in a two-process operation. Furthermore, these operations typically do not look like "message send" and "message receive" but rather resemble higher-level operations like calls to user functions.
"""

# ╔═╡ 03c0d4fe-9e19-11eb-14a2-239428cacb7a
md"""
Distributed programming in Julia is built on two primitives: *remote references* and *remote calls*. A remote reference is an object that can be used from any process to refer to an object stored on a particular process. A remote call is a request by one process to call a certain function on certain arguments on another (possibly the same) process.
"""

# ╔═╡ 03c0d558-9e19-11eb-3966-934e2dcfe2cc
md"""
Remote references come in two flavors: [`Future`](@ref Distributed.Future) and [`RemoteChannel`](@ref).
"""

# ╔═╡ 03c0d594-9e19-11eb-17e4-efa009fb709e
md"""
A remote call returns a [`Future`](@ref Distributed.Future) to its result. Remote calls return immediately; the process that made the call proceeds to its next operation while the remote call happens somewhere else. You can wait for a remote call to finish by calling [`wait`](@ref) on the returned [`Future`](@ref Distributed.Future), and you can obtain the full value of the result using [`fetch`](@ref).
"""

# ╔═╡ 03c0d5b2-9e19-11eb-05cb-3388be047656
md"""
On the other hand, [`RemoteChannel`](@ref) s are rewritable. For example, multiple processes can co-ordinate their processing by referencing the same remote `Channel`.
"""

# ╔═╡ 03c0d5e4-9e19-11eb-0775-37da8679be53
md"""
Each process has an associated identifier. The process providing the interactive Julia prompt always has an `id` equal to 1. The processes used by default for parallel operations are referred to as "workers". When there is only one process, process 1 is considered a worker. Otherwise, workers are considered to be all processes other than process 1. As a result, adding 2 or more processes is required to gain benefits from parallel processing methods like [`pmap`](@ref). Adding a single process is beneficial if you just wish to do other things in the main process while a long computation is running on the worker.
"""

# ╔═╡ 03c0d60c-9e19-11eb-0143-d722132f1b50
md"""
Let's try this out. Starting with `julia -p n` provides `n` worker processes on the local machine. Generally it makes sense for `n` to equal the number of CPU threads (logical cores) on the machine. Note that the `-p` argument implicitly loads module `Distributed`.
"""

# ╔═╡ 03c0d648-9e19-11eb-0cd2-d152bfbd7946
md"""
```julia
$ ./julia -p 2

julia> r = remotecall(rand, 2, 2, 2)
Future(2, 1, 4, nothing)

julia> s = @spawnat 2 1 .+ fetch(r)
Future(2, 1, 5, nothing)

julia> fetch(s)
2×2 Array{Float64,2}:
 1.18526  1.50912
 1.16296  1.60607
```
"""

# ╔═╡ 03c0d684-9e19-11eb-1385-554aa5d3d78d
md"""
The first argument to [`remotecall`](@ref) is the function to call. Most parallel programming in Julia does not reference specific processes or the number of processes available, but [`remotecall`](@ref) is considered a low-level interface providing finer control. The second argument to [`remotecall`](@ref) is the `id` of the process that will do the work, and the remaining arguments will be passed to the function being called.
"""

# ╔═╡ 03c0d6a4-9e19-11eb-0603-2d9de95c1097
md"""
As you can see, in the first line we asked process 2 to construct a 2-by-2 random matrix, and in the second line we asked it to add 1 to it. The result of both calculations is available in the two futures, `r` and `s`. The [`@spawnat`](@ref) macro evaluates the expression in the second argument on the process specified by the first argument.
"""

# ╔═╡ 03c0d6b6-9e19-11eb-31f6-5b1d4fac5f66
md"""
Occasionally you might want a remotely-computed value immediately. This typically happens when you read from a remote object to obtain data needed by the next local operation. The function [`remotecall_fetch`](@ref) exists for this purpose. It is equivalent to `fetch(remotecall(...))` but is more efficient.
"""

# ╔═╡ 03c0dad0-9e19-11eb-0903-f1d93d49674d
remotecall_fetch(getindex, 2, r, 1, 1)

# ╔═╡ 03c0db0a-9e19-11eb-221a-cd1c0fcee88a
md"""
Remember that [`getindex(r,1,1)`](@ref) is [equivalent](@ref man-array-indexing) to `r[1,1]`, so this call fetches the first element of the future `r`.
"""

# ╔═╡ 03c0db2a-9e19-11eb-345c-c10cb083cea1
md"""
To make things easier, the symbol `:any` can be passed to [`@spawnat`](@ref), which picks where to do the operation for you:
"""

# ╔═╡ 03c0e192-9e19-11eb-3111-9bfeed71d1dd
r = @spawnat :any rand(2,2)

# ╔═╡ 03c0e1b2-9e19-11eb-3938-01bb746af100
s = @spawnat :any 1 .+ fetch(r)

# ╔═╡ 03c0e1b2-9e19-11eb-0187-8bca4bb59c35
fetch(s)

# ╔═╡ 03c0e1ec-9e19-11eb-0442-3110b1da4a0e
md"""
Note that we used `1 .+ fetch(r)` instead of `1 .+ r`. This is because we do not know where the code will run, so in general a [`fetch`](@ref) might be required to move `r` to the process doing the addition. In this case, [`@spawnat`](@ref) is smart enough to perform the computation on the process that owns `r`, so the [`fetch`](@ref) will be a no-op (no work is done).
"""

# ╔═╡ 03c0e20a-9e19-11eb-353e-ed7e5a1161ef
md"""
(It is worth noting that [`@spawnat`](@ref) is not built-in but defined in Julia as a [macro](@ref man-macros). It is possible to define your own such constructs.)
"""

# ╔═╡ 03c0e23c-9e19-11eb-2874-a90e9f796684
md"""
An important thing to remember is that, once fetched, a [`Future`](@ref Distributed.Future) will cache its value locally. Further [`fetch`](@ref) calls do not entail a network hop. Once all referencing [`Future`](@ref Distributed.Future)s have fetched, the remote stored value is deleted.
"""

# ╔═╡ 03c0e2a0-9e19-11eb-3131-3d08a1c592a0
md"""
[`@async`](@ref) is similar to [`@spawnat`](@ref), but only runs tasks on the local process. We use it to create a "feeder" task for each process. Each task picks the next index that needs to be computed, then waits for its process to finish, then repeats until we run out of indices. Note that the feeder tasks do not begin to execute until the main task reaches the end of the [`@sync`](@ref) block, at which point it surrenders control and waits for all the local tasks to complete before returning from the function. As for v0.7 and beyond, the feeder tasks are able to share state via `nextidx` because they all run on the same process. Even if `Tasks` are scheduled cooperatively, locking may still be required in some contexts, as in [asynchronous I/O](@ref faq-async-io). This means context switches only occur at well-defined points: in this case, when [`remotecall_fetch`](@ref) is called. This is the current state of implementation and it may change for future Julia versions, as it is intended to make it possible to run up to N `Tasks` on M `Process`, aka [M:N Threading](https://en.wikipedia.org/wiki/Thread_(computing)#Models). Then a lock acquiring\releasing model for `nextidx` will be needed, as it is not safe to let multiple processes read-write a resource at the same time.
"""

# ╔═╡ 03c0e2d2-9e19-11eb-07d1-29f99024f450
md"""
## [Code Availability and Loading Packages](@id code-availability)
"""

# ╔═╡ 03c0e2e8-9e19-11eb-207b-dd36366e93c2
md"""
Your code must be available on any process that runs it. For example, type the following into the Julia prompt:
"""

# ╔═╡ 03c0ea02-9e19-11eb-34a7-0f5d6c36aa21
function rand2(dims...)
           return 2*rand(dims...)
       end

# ╔═╡ 03c0ea0c-9e19-11eb-172a-1dcbd9302ab7
rand2(2,2)

# ╔═╡ 03c0ea16-9e19-11eb-3d72-a50808b6a96a
fetch(@spawnat :any rand2(2,2))

# ╔═╡ 03c0ea2a-9e19-11eb-1e93-fbe54de919cd
md"""
Process 1 knew about the function `rand2`, but process 2 did not.
"""

# ╔═╡ 03c0ea48-9e19-11eb-3738-dd2c86081cfb
md"""
Most commonly you'll be loading code from files or packages, and you have a considerable amount of flexibility in controlling which processes load code. Consider a file, `DummyModule.jl`, containing the following code:
"""

# ╔═╡ 03c0ea66-9e19-11eb-0338-45774dadbce8
md"""
```julia
module DummyModule

export MyType, f

mutable struct MyType
    a::Int
end

f(x) = x^2+1

println("loaded")

end
```
"""

# ╔═╡ 03c0ea82-9e19-11eb-3cae-677bdc854901
md"""
In order to refer to `MyType` across all processes, `DummyModule.jl` needs to be loaded on every process.  Calling `include("DummyModule.jl")` loads it only on a single process.  To load it on every process, use the [`@everywhere`](@ref) macro (starting Julia with `julia -p 2`):
"""

# ╔═╡ 03c0ecc8-9e19-11eb-3fc6-1925507bbd82
@everywhere include("DummyModule.jl")

# ╔═╡ 03c0ecee-9e19-11eb-1468-2110833e6c45
md"""
As usual, this does not bring `DummyModule` into scope on any of the process, which requires `using` or `import`.  Moreover, when `DummyModule` is brought into scope on one process, it is not on any other:
"""

# ╔═╡ 03c0f396-9e19-11eb-158b-c9bb4c94835e
using .DummyModule

# ╔═╡ 03c0f396-9e19-11eb-1f27-f94b64c73c1c
MyType(7)

# ╔═╡ 03c0f3a8-9e19-11eb-1567-9d5dda0ba1fe
fetch(@spawnat 2 MyType(7))

# ╔═╡ 03c0f3b2-9e19-11eb-13ad-e989cffa471e
fetch(@spawnat 2 DummyModule.MyType(7))

# ╔═╡ 03c0f3d0-9e19-11eb-27f5-5d6d4ecdfb0f
md"""
However, it's still possible, for instance, to send a `MyType` to a process which has loaded `DummyModule` even if it's not in scope:
"""

# ╔═╡ 03c0f5c4-9e19-11eb-0263-fd68429dea23
put!(RemoteChannel(2), MyType(7))

# ╔═╡ 03c0f5e2-9e19-11eb-29ca-d57fb56fa6e0
md"""
A file can also be preloaded on multiple processes at startup with the `-L` flag, and a driver script can be used to drive the computation:
"""

# ╔═╡ 03c0f7f4-9e19-11eb-0e93-ad6420e27b85
julia -p <n> -L file1

# ╔═╡ 03c0f812-9e19-11eb-1135-fd4a05b95413
md"""
The Julia process running the driver script in the example above has an `id` equal to 1, just like a process providing an interactive prompt.
"""

# ╔═╡ 03c0f83a-9e19-11eb-2832-2bcb526eafd1
md"""
Finally, if `DummyModule.jl` is not a standalone file but a package, then `using DummyModule` will *load* `DummyModule.jl` on all processes, but only bring it into scope on the process where `using` was called.
"""

# ╔═╡ 03c0f84e-9e19-11eb-2567-95a268bd67cf
md"""
## Starting and managing worker processes
"""

# ╔═╡ 03c0f862-9e19-11eb-1227-fda743b4d13a
md"""
The base Julia installation has in-built support for two types of clusters:
"""

# ╔═╡ 03c0f984-9e19-11eb-18cd-011806b9b2ab
md"""
  * A local cluster specified with the `-p` option as shown above.
  * A cluster spanning machines using the `--machine-file` option. This uses a passwordless `ssh` login to start Julia worker processes (from the same path as the current host) on the specified machines. Each machine definition takes the form `[count*][user@]host[:port] [bind_addr[:port]]`. `user` defaults to current user, `port` to the standard ssh port. `count` is the number of workers to spawn on the node, and defaults to 1. The optional `bind-to bind_addr[:port]` specifies the IP address and port that other workers should use to connect to this worker.
"""

# ╔═╡ 03c0f9c0-9e19-11eb-3c86-279bd8d3cdc0
md"""
Functions [`addprocs`](@ref), [`rmprocs`](@ref), [`workers`](@ref), and others are available as a programmatic means of adding, removing and querying the processes in a cluster.
"""

# ╔═╡ 03c0fb82-9e19-11eb-19ae-b7dfbbe01510
using Distributed

# ╔═╡ 03c0fb82-9e19-11eb-0260-279edc65dcd7
addprocs(2)

# ╔═╡ 03c0fba2-9e19-11eb-0e65-d134bbe36d1c
md"""
Module `Distributed` must be explicitly loaded on the master process before invoking [`addprocs`](@ref). It is automatically made available on the worker processes.
"""

# ╔═╡ 03c0fbd0-9e19-11eb-32c2-b10c38ad5a5d
md"""
Note that workers do not run a `~/.julia/config/startup.jl` startup script, nor do they synchronize their global state (such as global variables, new method definitions, and loaded modules) with any of the other running processes. You may use `addprocs(exeflags="--project")` to initialize a worker with a particular environment, and then `@everywhere using <modulename>` or `@everywhere include("file.jl")`.
"""

# ╔═╡ 03c0fbf0-9e19-11eb-123f-99d008e8279e
md"""
Other types of clusters can be supported by writing your own custom `ClusterManager`, as described below in the [ClusterManagers](@ref) section.
"""

# ╔═╡ 03c0fbfa-9e19-11eb-0590-5d130e1006aa
md"""
## Data Movement
"""

# ╔═╡ 03c0fc18-9e19-11eb-35ba-c7cdc3b192dd
md"""
Sending messages and moving data constitute most of the overhead in a distributed program. Reducing the number of messages and the amount of data sent is critical to achieving performance and scalability. To this end, it is important to understand the data movement performed by Julia's various distributed programming constructs.
"""

# ╔═╡ 03c0fc40-9e19-11eb-38b3-05aae3bd6b4a
md"""
[`fetch`](@ref) can be considered an explicit data movement operation, since it directly asks that an object be moved to the local machine. [`@spawnat`](@ref) (and a few related constructs) also moves data, but this is not as obvious, hence it can be called an implicit data movement operation. Consider these two approaches to constructing and squaring a random matrix:
"""

# ╔═╡ 03c0fc4a-9e19-11eb-1f25-534669505887
md"""
Method 1:
"""

# ╔═╡ 03c100e6-9e19-11eb-2a99-03e3f5c6e686
A = rand(1000,1000);

# ╔═╡ 03c100f0-9e19-11eb-302a-25d1a75df5f8
Bref = @spawnat :any A^2;

# ╔═╡ 03c100fa-9e19-11eb-01c8-c56627a9f963
fetch(Bref);

# ╔═╡ 03c10104-9e19-11eb-339c-dfa002ee3171
md"""
Method 2:
"""

# ╔═╡ 03c1046a-9e19-11eb-3b91-6d76fc9698fb
Bref = @spawnat :any rand(1000,1000)^2;

# ╔═╡ 03c1047e-9e19-11eb-27c4-c514652126ac
fetch(Bref);

# ╔═╡ 03c104a6-9e19-11eb-1cbc-cd00832137b1
md"""
The difference seems trivial, but in fact is quite significant due to the behavior of [`@spawnat`](@ref). In the first method, a random matrix is constructed locally, then sent to another process where it is squared. In the second method, a random matrix is both constructed and squared on another process. Therefore the second method sends much less data than the first.
"""

# ╔═╡ 03c104ce-9e19-11eb-2f23-4f38a9271141
md"""
In this toy example, the two methods are easy to distinguish and choose from. However, in a real program designing data movement might require more thought and likely some measurement. For example, if the first process needs matrix `A` then the first method might be better. Or, if computing `A` is expensive and only the current process has it, then moving it to another process might be unavoidable. Or, if the current process has very little to do between the [`@spawnat`](@ref) and `fetch(Bref)`, it might be better to eliminate the parallelism altogether. Or imagine `rand(1000,1000)` is replaced with a more expensive operation. Then it might make sense to add another [`@spawnat`](@ref) statement just for this step.
"""

# ╔═╡ 03c104ec-9e19-11eb-2c26-e9b2a042eb2c
md"""
## Global variables
"""

# ╔═╡ 03c1050a-9e19-11eb-14fd-7129416a6164
md"""
Expressions executed remotely via `@spawnat`, or closures specified for remote execution using `remotecall` may refer to global variables. Global bindings under module `Main` are treated a little differently compared to global bindings in other modules. Consider the following code snippet:
"""

# ╔═╡ 03c10672-9e19-11eb-0671-e7c3447366ce
A = rand(10,10)

# ╔═╡ 03c106b0-9e19-11eb-1529-f538510b2ee7
md"""
In this case [`sum`](@ref) MUST be defined in the remote process. Note that `A` is a global variable defined in the local workspace. Worker 2 does not have a variable called `A` under `Main`. The act of shipping the closure `()->sum(A)` to worker 2 results in `Main.A` being defined on 2. `Main.A` continues to exist on worker 2 even after the call `remotecall_fetch` returns. Remote calls with embedded global references (under `Main` module only) manage globals as follows:
"""

# ╔═╡ 03c1079e-9e19-11eb-2c99-2b11f2881668
md"""
  * New global bindings are created on destination workers if they are referenced as part of a remote call.
  * Global constants are declared as constants on remote nodes too.
  * Globals are re-sent to a destination worker only in the context of a remote call, and then only if its value has changed. Also, the cluster does not synchronize global bindings across nodes. For example:

    ```julia
    A = rand(10,10)
    remotecall_fetch(()->sum(A), 2) # worker 2
    A = rand(10,10)
    remotecall_fetch(()->sum(A), 3) # worker 3
    A = nothing
    ```

    Executing the above snippet results in `Main.A` on worker 2 having a different value from `Main.A` on worker 3, while the value of `Main.A` on node 1 is set to `nothing`.
"""

# ╔═╡ 03c107bc-9e19-11eb-35dc-03f9d3fd4fdb
md"""
As you may have realized, while memory associated with globals may be collected when they are reassigned on the master, no such action is taken on the workers as the bindings continue to be valid. [`clear!`](@ref) can be used to manually reassign specific globals on remote nodes to `nothing` once they are no longer required. This will release any memory associated with them as part of a regular garbage collection cycle.
"""

# ╔═╡ 03c107c6-9e19-11eb-219e-8b67895c3c4e
md"""
Thus programs should be careful referencing globals in remote calls. In fact, it is preferable to avoid them altogether if possible. If you must reference globals, consider using `let` blocks to localize global variables.
"""

# ╔═╡ 03c107e6-9e19-11eb-09cd-d5c49ccd8337
md"""
For example:
"""

# ╔═╡ 03c110d6-9e19-11eb-1d86-edcf7b988ef0
A = rand(10,10);

# ╔═╡ 03c110e0-9e19-11eb-26e4-6b0a7820e780
remotecall_fetch(()->A, 2);

# ╔═╡ 03c110e0-9e19-11eb-168a-6387adc92a43
B = rand(10,10);

# ╔═╡ 03c110fe-9e19-11eb-216a-21114bcd974b
let B = B
           remotecall_fetch(()->B, 2)
       end;

# ╔═╡ 03c110fe-9e19-11eb-16bf-5b68ddbc586c
@fetchfrom 2 InteractiveUtils.varinfo()

# ╔═╡ 03c11126-9e19-11eb-231f-991b9182f9a3
md"""
As can be seen, global variable `A` is defined on worker 2, but `B` is captured as a local variable and hence a binding for `B` does not exist on worker 2.
"""

# ╔═╡ 03c1113a-9e19-11eb-13db-475d92af2657
md"""
## Parallel Map and Loops
"""

# ╔═╡ 03c1116c-9e19-11eb-0cd4-f1fd3e4a64ee
md"""
Fortunately, many useful parallel computations do not require data movement. A common example is a Monte Carlo simulation, where multiple processes can handle independent simulation trials simultaneously. We can use [`@spawnat`](@ref) to flip coins on two processes. First, write the following function in `count_heads.jl`:
"""

# ╔═╡ 03c1118c-9e19-11eb-1705-15ea6e6c7dce
md"""
```julia
function count_heads(n)
    c::Int = 0
    for i = 1:n
        c += rand(Bool)
    end
    c
end
```
"""

# ╔═╡ 03c1119e-9e19-11eb-3411-5b30ff72a77e
md"""
The function `count_heads` simply adds together `n` random bits. Here is how we can perform some trials on two machines, and add together the results:
"""

# ╔═╡ 03c11aa4-9e19-11eb-0f39-b9de3aceb668
@everywhere include_string(Main, $(read("count_heads.jl", String)), "count_heads.jl")

# ╔═╡ 03c11aae-9e19-11eb-1d9b-9d078033e06e
a = @spawnat :any count_heads(100000000)

# ╔═╡ 03c11aae-9e19-11eb-1f32-5f446b305306
b = @spawnat :any count_heads(100000000)

# ╔═╡ 03c11ab8-9e19-11eb-2179-b96e7d42e8a6
fetch(a)+fetch(b)

# ╔═╡ 03c11aea-9e19-11eb-17cc-37af38d2e18f
md"""
This example demonstrates a powerful and often-used parallel programming pattern. Many iterations run independently over several processes, and then their results are combined using some function. The combination process is called a *reduction*, since it is generally tensor-rank-reducing: a vector of numbers is reduced to a single number, or a matrix is reduced to a single row or column, etc. In code, this typically looks like the pattern `x = f(x,v[i])`, where `x` is the accumulator, `f` is the reduction function, and the `v[i]` are the elements being reduced. It is desirable for `f` to be associative, so that it does not matter what order the operations are performed in.
"""

# ╔═╡ 03c11b32-9e19-11eb-0c2e-c9cf27f4e4b9
md"""
Notice that our use of this pattern with `count_heads` can be generalized. We used two explicit [`@spawnat`](@ref) statements, which limits the parallelism to two processes. To run on any number of processes, we can use a *parallel for loop*, running in distributed memory, which can be written in Julia using [`@distributed`](@ref) like this:
"""

# ╔═╡ 03c11b44-9e19-11eb-3817-f5d1c4a13dd8
md"""
```julia
nheads = @distributed (+) for i = 1:200000000
    Int(rand(Bool))
end
```
"""

# ╔═╡ 03c11b60-9e19-11eb-2765-b70f7eb2ee80
md"""
This construct implements the pattern of assigning iterations to multiple processes, and combining them with a specified reduction (in this case `(+)`). The result of each iteration is taken as the value of the last expression inside the loop. The whole parallel loop expression itself evaluates to the final answer.
"""

# ╔═╡ 03c11b80-9e19-11eb-12f2-e374bcb614a4
md"""
Note that although parallel for loops look like serial for loops, their behavior is dramatically different. In particular, the iterations do not happen in a specified order, and writes to variables or arrays will not be globally visible since iterations run on different processes. Any variables used inside the parallel loop will be copied and broadcast to each process.
"""

# ╔═╡ 03c11b8a-9e19-11eb-1a59-2ba020798b25
md"""
For example, the following code will not work as intended:
"""

# ╔═╡ 03c11b9e-9e19-11eb-23f4-f90521e42eb9
md"""
```julia
a = zeros(100000)
@distributed for i = 1:100000
    a[i] = i
end
```
"""

# ╔═╡ 03c11bc4-9e19-11eb-1701-2f106d3f8084
md"""
This code will not initialize all of `a`, since each process will have a separate copy of it. Parallel for loops like these must be avoided. Fortunately, [Shared Arrays](@ref man-shared-arrays) can be used to get around this limitation:
"""

# ╔═╡ 03c11bda-9e19-11eb-2159-918f4073d9ac
md"""
```julia
using SharedArrays

a = SharedArray{Float64}(10)
@distributed for i = 1:10
    a[i] = i
end
```
"""

# ╔═╡ 03c11be4-9e19-11eb-07db-fbfac3cd1bad
md"""
Using "outside" variables in parallel loops is perfectly reasonable if the variables are read-only:
"""

# ╔═╡ 03c11bf8-9e19-11eb-1d46-670164452b76
md"""
```julia
a = randn(1000)
@distributed (+) for i = 1:100000
    f(a[rand(1:end)])
end
```
"""

# ╔═╡ 03c11c16-9e19-11eb-228a-27460110ffc4
md"""
Here each iteration applies `f` to a randomly-chosen sample from a vector `a` shared by all processes.
"""

# ╔═╡ 03c11c48-9e19-11eb-3821-5fdedbee6488
md"""
As you could see, the reduction operator can be omitted if it is not needed. In that case, the loop executes asynchronously, i.e. it spawns independent tasks on all available workers and returns an array of [`Future`](@ref Distributed.Future) immediately without waiting for completion. The caller can wait for the [`Future`](@ref Distributed.Future) completions at a later point by calling [`fetch`](@ref) on them, or wait for completion at the end of the loop by prefixing it with [`@sync`](@ref), like `@sync @distributed for`.
"""

# ╔═╡ 03c11c68-9e19-11eb-2873-e719c38fa52f
md"""
In some cases no reduction operator is needed, and we merely wish to apply a function to all integers in some range (or, more generally, to all elements in some collection). This is another useful operation called *parallel map*, implemented in Julia as the [`pmap`](@ref) function. For example, we could compute the singular values of several large random matrices in parallel as follows:
"""

# ╔═╡ 03c120ee-9e19-11eb-3f0a-8f97ced90f92
M = Matrix{Float64}[rand(1000,1000) for i = 1:10];

# ╔═╡ 03c120f8-9e19-11eb-1584-b3a40cc8b415
pmap(svdvals, M);

# ╔═╡ 03c12120-9e19-11eb-1a7d-7b760c637a41
md"""
Julia's [`pmap`](@ref) is designed for the case where each function call does a large amount of work. In contrast, `@distributed for` can handle situations where each iteration is tiny, perhaps merely summing two numbers. Only worker processes are used by both [`pmap`](@ref) and `@distributed for` for the parallel computation. In case of `@distributed for`, the final reduction is done on the calling process.
"""

# ╔═╡ 03c12132-9e19-11eb-0eca-a1704c914f3b
md"""
## Remote References and AbstractChannels
"""

# ╔═╡ 03c1215c-9e19-11eb-353b-f9918c72cadb
md"""
Remote references always refer to an implementation of an `AbstractChannel`.
"""

# ╔═╡ 03c12198-9e19-11eb-1108-7d7abee637db
md"""
A concrete implementation of an `AbstractChannel` (like `Channel`), is required to implement [`put!`](@ref), [`take!`](@ref), [`fetch`](@ref), [`isready`](@ref) and [`wait`](@ref). The remote object referred to by a [`Future`](@ref Distributed.Future) is stored in a `Channel{Any}(1)`, i.e., a `Channel` of size 1 capable of holding objects of `Any` type.
"""

# ╔═╡ 03c121b6-9e19-11eb-26a9-4f98f1185d25
md"""
[`RemoteChannel`](@ref), which is rewritable, can point to any type and size of channels, or any other implementation of an `AbstractChannel`.
"""

# ╔═╡ 03c121de-9e19-11eb-2e56-7331ca95ed48
md"""
The constructor `RemoteChannel(f::Function, pid)()` allows us to construct references to channels holding more than one value of a specific type. `f` is a function executed on `pid` and it must return an `AbstractChannel`.
"""

# ╔═╡ 03c121fc-9e19-11eb-135a-4797a1ee863f
md"""
For example, `RemoteChannel(()->Channel{Int}(10), pid)`, will return a reference to a channel of type `Int` and size 10. The channel exists on worker `pid`.
"""

# ╔═╡ 03c12236-9e19-11eb-384a-11f83c78ace9
md"""
Methods [`put!`](@ref), [`take!`](@ref), [`fetch`](@ref), [`isready`](@ref) and [`wait`](@ref) on a [`RemoteChannel`](@ref) are proxied onto the backing store on the remote process.
"""

# ╔═╡ 03c12260-9e19-11eb-2ef1-cdc02d0f948e
md"""
[`RemoteChannel`](@ref) can thus be used to refer to user implemented `AbstractChannel` objects. A simple example of this is provided in `dictchannel.jl` in the [Examples repository](https://github.com/JuliaAttic/Examples), which uses a dictionary as its remote store.
"""

# ╔═╡ 03c12274-9e19-11eb-220a-4973c0e1a6f6
md"""
## Channels and RemoteChannels
"""

# ╔═╡ 03c12402-9e19-11eb-1c43-01113a204d1c
md"""
  * A [`Channel`](@ref) is local to a process. Worker 2 cannot directly refer to a [`Channel`](@ref) on worker 3 and vice-versa. A [`RemoteChannel`](@ref), however, can put and take values across workers.
  * A [`RemoteChannel`](@ref) can be thought of as a *handle* to a [`Channel`](@ref).
  * The process id, `pid`, associated with a [`RemoteChannel`](@ref) identifies the process where the backing store, i.e., the backing [`Channel`](@ref) exists.
  * Any process with a reference to a [`RemoteChannel`](@ref) can put and take items from the channel. Data is automatically sent to (or retrieved from) the process a [`RemoteChannel`](@ref) is associated with.
  * Serializing  a [`Channel`](@ref) also serializes any data present in the channel. Deserializing it therefore effectively makes a copy of the original object.
  * On the other hand, serializing a [`RemoteChannel`](@ref) only involves the serialization of an identifier that identifies the location and instance of [`Channel`](@ref) referred to by the handle. A deserialized [`RemoteChannel`](@ref) object (on any worker), therefore also points to the same backing store as the original.
"""

# ╔═╡ 03c12422-9e19-11eb-072b-916c299b8a03
md"""
The channels example from above can be modified for interprocess communication, as shown below.
"""

# ╔═╡ 03c12440-9e19-11eb-2f10-c93ecf897a66
md"""
We start 4 workers to process a single `jobs` remote channel. Jobs, identified by an id (`job_id`), are written to the channel. Each remotely executing task in this simulation reads a `job_id`, waits for a random amount of time and writes back a tuple of `job_id`, time taken and its own `pid` to the results channel. Finally all the `results` are printed out on the master process.
"""

# ╔═╡ 03c14150-9e19-11eb-38d4-1d28b8fcf294
addprocs(4); # add worker processes

# ╔═╡ 03c14150-9e19-11eb-2816-6f6520f01de5
const jobs = RemoteChannel(()->Channel{Int}(32));

# ╔═╡ 03c14166-9e19-11eb-1c12-218c29ef1b78
const results = RemoteChannel(()->Channel{Tuple}(32));

# ╔═╡ 03c1416e-9e19-11eb-1325-7d00ba021b8d
@everywhere function do_work(jobs, results) # define work function everywhere
           while true
               job_id = take!(jobs)
               exec_time = rand()
               sleep(exec_time) # simulates elapsed time doing actual work
               put!(results, (job_id, exec_time, myid()))
           end
       end

# ╔═╡ 03c1416e-9e19-11eb-251e-55bebf3a7469
function make_jobs(n)
           for i in 1:n
               put!(jobs, i)
           end
       end;

# ╔═╡ 03c14178-9e19-11eb-2095-5925c60757e1
n = 12;

# ╔═╡ 03c14178-9e19-11eb-1b7f-9bbea6d0c675
@async make_jobs(n); # feed the jobs channel with "n" jobs

# ╔═╡ 03c1418c-9e19-11eb-14b6-25ca498bc71d
for p in workers() # start tasks on the workers to process requests in parallel
           remote_do(do_work, p, jobs, results)
       end

# ╔═╡ 03c1418c-9e19-11eb-16df-8f9c9b49ec3c
@elapsed while n > 0 # print out results
           job_id, exec_time, where = take!(results)
           println("$job_id finished in $(round(exec_time; digits=2)) seconds on worker $where")
           global n = n - 1
       end

# ╔═╡ 03c141dc-9e19-11eb-247f-670e4e164934
md"""
### Remote References and Distributed Garbage Collection
"""

# ╔═╡ 03c141f0-9e19-11eb-1b30-3b9221949ddf
md"""
Objects referred to by remote references can be freed only when *all* held references in the cluster are deleted.
"""

# ╔═╡ 03c14236-9e19-11eb-1e3e-2d13e3e3e999
md"""
The node where the value is stored keeps track of which of the workers have a reference to it. Every time a [`RemoteChannel`](@ref) or a (unfetched) [`Future`](@ref Distributed.Future) is serialized to a worker, the node pointed to by the reference is notified. And every time a [`RemoteChannel`](@ref) or a (unfetched) [`Future`](@ref Distributed.Future) is garbage collected locally, the node owning the value is again notified. This is implemented in an internal cluster aware serializer. Remote references are only valid in the context of a running cluster. Serializing and deserializing references to and from regular `IO` objects is not supported.
"""

# ╔═╡ 03c1424a-9e19-11eb-0c59-3f655e51017b
md"""
The notifications are done via sending of "tracking" messages–an "add reference" message when a reference is serialized to a different process and a "delete reference" message when a reference is locally garbage collected.
"""

# ╔═╡ 03c14272-9e19-11eb-149c-ff14304758b7
md"""
Since [`Future`](@ref Distributed.Future)s are write-once and cached locally, the act of [`fetch`](@ref)ing a [`Future`](@ref Distributed.Future) also updates reference tracking information on the node owning the value.
"""

# ╔═╡ 03c14286-9e19-11eb-1607-6d083bc852f8
md"""
The node which owns the value frees it once all references to it are cleared.
"""

# ╔═╡ 03c142a4-9e19-11eb-096c-776ced74bd07
md"""
With [`Future`](@ref Distributed.Future)s, serializing an already fetched [`Future`](@ref Distributed.Future) to a different node also sends the value since the original remote store may have collected the value by this time.
"""

# ╔═╡ 03c142b8-9e19-11eb-12af-3d8d981585db
md"""
It is important to note that *when* an object is locally garbage collected depends on the size of the object and the current memory pressure in the system.
"""

# ╔═╡ 03c14308-9e19-11eb-0aad-1d93634f5e5d
md"""
In case of remote references, the size of the local reference object is quite small, while the value stored on the remote node may be quite large. Since the local object may not be collected immediately, it is a good practice to explicitly call [`finalize`](@ref) on local instances of a [`RemoteChannel`](@ref), or on unfetched [`Future`](@ref Distributed.Future)s. Since calling [`fetch`](@ref) on a [`Future`](@ref Distributed.Future) also removes its reference from the remote store, this is not required on fetched [`Future`](@ref Distributed.Future)s. Explicitly calling [`finalize`](@ref) results in an immediate message sent to the remote node to go ahead and remove its reference to the value.
"""

# ╔═╡ 03c14312-9e19-11eb-037f-8ddfa9e3f416
md"""
Once finalized, a reference becomes invalid and cannot be used in any further calls.
"""

# ╔═╡ 03c14326-9e19-11eb-2462-d95170f8cb85
md"""
## Local invocations
"""

# ╔═╡ 03c14358-9e19-11eb-11ee-9d4059b6af18
md"""
Data is necessarily copied over to the remote node for execution. This is the case for both remotecalls and when data is stored to a[`RemoteChannel`](@ref) / [`Future`](@ref Distributed.Future) on a different node. As expected, this results in a copy of the serialized objects on the remote node. However, when the destination node is the local node, i.e. the calling process id is the same as the remote node id, it is executed as a local call. It is usually (not always) executed in a different task - but there is no serialization/deserialization of data. Consequently, the call refers to the same object instances as passed - no copies are created. This behavior is highlighted below:
"""

# ╔═╡ 03c15f82-9e19-11eb-30e4-dd01468754e9
using Distributed;

# ╔═╡ 03c15f8e-9e19-11eb-0701-7733a1011993
rc = RemoteChannel(()->Channel(3));   # RemoteChannel created on local node

# ╔═╡ 03c15f8e-9e19-11eb-09f3-f1cb96f5c137
v = [0];

# ╔═╡ 03c15f96-9e19-11eb-378f-afd43480c6ef
for i in 1:3
           v[1] = i                          # Reusing `v`
           put!(rc, v)
       end;

# ╔═╡ 03c15fa0-9e19-11eb-02ec-c7f75df90abc
result = [take!(rc) for _ in 1:3];

# ╔═╡ 03c15faa-9e19-11eb-24c3-7b6e362163e7
println(result);

# ╔═╡ 03c15faa-9e19-11eb-351e-0393938ecbe2
println("Num Unique objects : ", length(unique(map(objectid, result))));

# ╔═╡ 03c15faa-9e19-11eb-3ee7-993534dca82d
addprocs(1);

# ╔═╡ 03c15fb4-9e19-11eb-12ad-b1737ef99f11
rc = RemoteChannel(()->Channel(3), workers()[1]);   # RemoteChannel created on remote node

# ╔═╡ 03c15fc0-9e19-11eb-385c-b56ad8b2070d
v = [0];

# ╔═╡ 03c15fc8-9e19-11eb-1175-4126d85f646d
for i in 1:3
           v[1] = i
           put!(rc, v)
       end;

# ╔═╡ 03c15fc8-9e19-11eb-17ad-1bb03a945de5
result = [take!(rc) for _ in 1:3];

# ╔═╡ 03c15fd2-9e19-11eb-090f-599d5e7b04a4
println(result);

# ╔═╡ 03c15fd2-9e19-11eb-3fc2-cdd816198bc6
println("Num Unique objects : ", length(unique(map(objectid, result))));

# ╔═╡ 03c16018-9e19-11eb-1b58-2f9042843093
md"""
As can be seen, [`put!`](@ref) on a locally owned [`RemoteChannel`](@ref) with the same object `v` modifed between calls results in the same single object instance stored. As opposed to copies of `v` being created when the node owning `rc` is a different node.
"""

# ╔═╡ 03c1602c-9e19-11eb-3799-4d0f5cd43054
md"""
It is to be noted that this is generally not an issue. It is something to be factored in only if the object is both being stored locally and modifed post the call. In such cases it may be appropriate to store a `deepcopy` of the object.
"""

# ╔═╡ 03c16036-9e19-11eb-0f13-391d79d87784
md"""
This is also true for remotecalls on the local node as seen in the following example:
"""

# ╔═╡ 03c17076-9e19-11eb-223e-ff68ba21904f
using Distributed; addprocs(1);

# ╔═╡ 03c17076-9e19-11eb-108b-271b02f208e8
v = [0];

# ╔═╡ 03c17080-9e19-11eb-0a62-a57697b665ee
v2 = remotecall_fetch(x->(x[1] = 1; x), myid(), v);     # Executed on local node

# ╔═╡ 03c17080-9e19-11eb-00fa-cbd1a32867cc
println("v=$v, v2=$v2, ", v === v2);

# ╔═╡ 03c1708a-9e19-11eb-2209-d9ca751a651c
v = [0];

# ╔═╡ 03c17094-9e19-11eb-0bf4-d3c128ddaeda
v2 = remotecall_fetch(x->(x[1] = 1; x), workers()[1], v); # Executed on remote node

# ╔═╡ 03c17094-9e19-11eb-20cb-f1fcd1eb9c2a
println("v=$v, v2=$v2, ", v === v2);

# ╔═╡ 03c170a8-9e19-11eb-1a0e-6375098e3741
md"""
As can be seen once again, a remote call onto the local node behaves just like a direct invocation. The call modifies local objects passed as arguments. In the remote invocation, it operates on a copy of the arguments.
"""

# ╔═╡ 03c170bc-9e19-11eb-2867-ef048ddebd16
md"""
To repeat, in general this is not an issue. If the local node is also being used as a compute node, and the arguments used post the call, this behavior needs to be factored in and if required deep copies of arguments must be passed to the call invoked on the local node. Calls on remote nodes will always operate on copies of arguments.
"""

# ╔═╡ 03c170da-9e19-11eb-0393-4fe6d49eb924
md"""
## [Shared Arrays](@id man-shared-arrays)
"""

# ╔═╡ 03c17116-9e19-11eb-34e1-f97a32c42fa6
md"""
Shared Arrays use system shared memory to map the same array across many processes. While there are some similarities to a [`DArray`](https://github.com/JuliaParallel/DistributedArrays.jl), the behavior of a [`SharedArray`](@ref) is quite different. In a [`DArray`](https://github.com/JuliaParallel/DistributedArrays.jl), each process has local access to just a chunk of the data, and no two processes share the same chunk; in contrast, in a [`SharedArray`](@ref) each "participating" process has access to the entire array.  A [`SharedArray`](@ref) is a good choice when you want to have a large amount of data jointly accessible to two or more processes on the same machine.
"""

# ╔═╡ 03c1712a-9e19-11eb-00a5-c58bb209de6a
md"""
Shared Array support is available via module `SharedArrays` which must be explicitly loaded on all participating workers.
"""

# ╔═╡ 03c17184-9e19-11eb-317c-c91bde57c6f9
md"""
[`SharedArray`](@ref) indexing (assignment and accessing values) works just as with regular arrays, and is efficient because the underlying memory is available to the local process. Therefore, most algorithms work naturally on [`SharedArray`](@ref)s, albeit in single-process mode. In cases where an algorithm insists on an [`Array`](@ref) input, the underlying array can be retrieved from a [`SharedArray`](@ref) by calling [`sdata`](@ref). For other `AbstractArray` types, [`sdata`](@ref) just returns the object itself, so it's safe to use [`sdata`](@ref) on any `Array`-type object.
"""

# ╔═╡ 03c17198-9e19-11eb-3ef2-4b6b24467aab
md"""
The constructor for a shared array is of the form:
"""

# ╔═╡ 03c171ac-9e19-11eb-191a-add741b3f5ff
md"""
```julia
SharedArray{T,N}(dims::NTuple; init=false, pids=Int[])
```
"""

# ╔═╡ 03c171e8-9e19-11eb-3dd2-d329604712e0
md"""
which creates an `N`-dimensional shared array of a bits type `T` and size `dims` across the processes specified by `pids`. Unlike distributed arrays, a shared array is accessible only from those participating workers specified by the `pids` named argument (and the creating process too, if it is on the same host). Note that only elements that are [`isbits`](@ref) are supported in a SharedArray.
"""

# ╔═╡ 03c171fc-9e19-11eb-3215-a795ec645df2
md"""
If an `init` function, of signature `initfn(S::SharedArray)`, is specified, it is called on all the participating workers. You can specify that each worker runs the `init` function on a distinct portion of the array, thereby parallelizing initialization.
"""

# ╔═╡ 03c17210-9e19-11eb-11e5-7d920716cefa
md"""
Here's a brief example:
"""

# ╔═╡ 03c17cd8-9e19-11eb-1f66-6dee2cbe13c4
using Distributed

# ╔═╡ 03c17cd8-9e19-11eb-0e2d-5707884577bd
addprocs(3)

# ╔═╡ 03c17cd8-9e19-11eb-3db4-67eadec97769
@everywhere using SharedArrays

# ╔═╡ 03c17ce0-9e19-11eb-0634-dba0e753956c
S = SharedArray{Int,2}((3,4), init = S -> S[localindices(S)] = repeat([myid()], length(localindices(S))))

# ╔═╡ 03c17ce0-9e19-11eb-3a73-7d89cbe61d04
S[3,2] = 7

# ╔═╡ 03c17cf6-9e19-11eb-36e9-0144db15e584
S

# ╔═╡ 03c17d12-9e19-11eb-34c7-cb548b7ea84b
md"""
[`SharedArrays.localindices`](@ref) provides disjoint one-dimensional ranges of indices, and is sometimes convenient for splitting up tasks among processes. You can, of course, divide the work any way you wish:
"""

# ╔═╡ 03c18570-9e19-11eb-1b6d-a7c27ac80b11
S = SharedArray{Int,2}((3,4), init = S -> S[indexpids(S):length(procs(S)):length(S)] = repeat([myid()], length( indexpids(S):length(procs(S)):length(S))))

# ╔═╡ 03c18582-9e19-11eb-2f6a-9fd6da7413bc
md"""
Since all processes have access to the underlying data, you do have to be careful not to set up conflicts. For example:
"""

# ╔═╡ 03c185ac-9e19-11eb-0d42-370846680ecd
md"""
```julia
@sync begin
    for p in procs(S)
        @async begin
            remotecall_wait(fill!, p, S, p)
        end
    end
end
```
"""

# ╔═╡ 03c185ca-9e19-11eb-308a-936418ae8625
md"""
would result in undefined behavior. Because each process fills the *entire* array with its own `pid`, whichever process is the last to execute (for any particular element of `S`) will have its `pid` retained.
"""

# ╔═╡ 03c185de-9e19-11eb-3fdf-47a7df4f0e69
md"""
As a more extended and complex example, consider running the following "kernel" in parallel:
"""

# ╔═╡ 03c185fc-9e19-11eb-3386-0d9c7182bb17
md"""
```julia
q[i,j,t+1] = q[i,j,t] + u[i,j,t]
```
"""

# ╔═╡ 03c1861a-9e19-11eb-2b4b-b1cc18377e32
md"""
In this case, if we try to split up the work using a one-dimensional index, we are likely to run into trouble: if `q[i,j,t]` is near the end of the block assigned to one worker and `q[i,j,t+1]` is near the beginning of the block assigned to another, it's very likely that `q[i,j,t]` will not be ready at the time it's needed for computing `q[i,j,t+1]`. In such cases, one is better off chunking the array manually. Let's split along the second dimension. Define a function that returns the `(irange, jrange)` indices assigned to this worker:
"""

# ╔═╡ 03c197ae-9e19-11eb-0f92-171b672fee0d
@everywhere function myrange(q::SharedArray)
           idx = indexpids(q)
           if idx == 0 # This worker is not assigned a piece
               return 1:0, 1:0
           end
           nchunks = length(procs(q))
           splits = [round(Int, s) for s in range(0, stop=size(q,2), length=nchunks+1)]
           1:size(q,1), splits[idx]+1:splits[idx+1]
       end

# ╔═╡ 03c197fe-9e19-11eb-1a8f-c1fa69a74538
md"""
Next, define the kernel:
"""

# ╔═╡ 03c1a122-9e19-11eb-2fc9-7fdba6079621
@everywhere function advection_chunk!(q, u, irange, jrange, trange)
           @show (irange, jrange, trange)  # display so we can see what's happening
           for t in trange, j in jrange, i in irange
               q[i,j,t+1] = q[i,j,t] + u[i,j,t]
           end
           q
       end

# ╔═╡ 03c1a154-9e19-11eb-2897-bd09ba3c6d50
md"""
We also define a convenience wrapper for a `SharedArray` implementation
"""

# ╔═╡ 03c1a616-9e19-11eb-1e1b-b72f0e06326c
@everywhere advection_shared_chunk!(q, u) =
           advection_chunk!(q, u, myrange(q)..., 1:size(q,3)-1)

# ╔═╡ 03c1a65e-9e19-11eb-294c-3d3c7c74ca92
md"""
Now let's compare three different versions, one that runs in a single process:
"""

# ╔═╡ 03c1ab9a-9e19-11eb-0a29-2f40bcb524f9
advection_serial!(q, u) = advection_chunk!(q, u, 1:size(q,1), 1:size(q,2), 1:size(q,3)-1);

# ╔═╡ 03c1abcc-9e19-11eb-01af-559bd712e8ec
md"""
one that uses [`@distributed`](@ref):
"""

# ╔═╡ 03c1b676-9e19-11eb-3cef-278cf58619b6
function advection_parallel!(q, u)
           for t = 1:size(q,3)-1
               @sync @distributed for j = 1:size(q,2)
                   for i = 1:size(q,1)
                       q[i,j,t+1]= q[i,j,t] + u[i,j,t]
                   end
               end
           end
           q
       end;

# ╔═╡ 03c1b6b2-9e19-11eb-391e-fb734afe3fd3
md"""
and one that delegates in chunks:
"""

# ╔═╡ 03c1bbc6-9e19-11eb-187f-97faf33675ca
function advection_shared!(q, u)
           @sync begin
               for p in procs(q)
                   @async remotecall_wait(advection_shared_chunk!, p, q, u)
               end
           end
           q
       end;

# ╔═╡ 03c1bbf8-9e19-11eb-28e0-5bdab3a08494
md"""
If we create `SharedArray`s and time these functions, we get the following results (with `julia -p 4`):
"""

# ╔═╡ 03c1c102-9e19-11eb-1ae3-adb0b031af7a
q = SharedArray{Float64,3}((500,500,500));

# ╔═╡ 03c1c120-9e19-11eb-3a67-9be438db2258
u = SharedArray{Float64,3}((500,500,500));

# ╔═╡ 03c1c152-9e19-11eb-1fd6-d5948811f641
md"""
Run the functions once to JIT-compile and [`@time`](@ref) them on the second run:
"""

# ╔═╡ 03c1c53a-9e19-11eb-0868-a3323095e923
@time advection_serial!(q, u);

# ╔═╡ 03c1c546-9e19-11eb-276a-d9cc665eadc9
@time advection_parallel!(q, u);

# ╔═╡ 03c1c546-9e19-11eb-37e7-931178d47559
@time advection_shared!(q,u);

# ╔═╡ 03c1c574-9e19-11eb-0ae9-edc54e4f7a28
md"""
The biggest advantage of `advection_shared!` is that it minimizes traffic among the workers, allowing each to compute for an extended time on the assigned piece.
"""

# ╔═╡ 03c1c5a6-9e19-11eb-196f-e308c1bd1f58
md"""
### Shared Arrays and Distributed Garbage Collection
"""

# ╔═╡ 03c1c5c6-9e19-11eb-0d20-c711343e7086
md"""
Like remote references, shared arrays are also dependent on garbage collection on the creating node to release references from all participating workers. Code which creates many short lived shared array objects would benefit from explicitly finalizing these objects as soon as possible. This results in both memory and file handles mapping the shared segment being released sooner.
"""

# ╔═╡ 03c1c602-9e19-11eb-0b86-134f2ea2be67
md"""
## ClusterManagers
"""

# ╔═╡ 03c1c616-9e19-11eb-36de-91ab54e50d77
md"""
The launching, management and networking of Julia processes into a logical cluster is done via cluster managers. A `ClusterManager` is responsible for
"""

# ╔═╡ 03c1c6e8-9e19-11eb-1e6a-ed5e8676a9b5
md"""
  * launching worker processes in a cluster environment
  * managing events during the lifetime of each worker
  * optionally, providing data transport
"""

# ╔═╡ 03c1c70e-9e19-11eb-139e-b18c84e6a565
md"""
A Julia cluster has the following characteristics:
"""

# ╔═╡ 03c1c792-9e19-11eb-13a0-433dd1d20e3e
md"""
  * The initial Julia process, also called the `master`, is special and has an `id` of 1.
  * Only the `master` process can add or remove worker processes.
  * All processes can directly communicate with each other.
"""

# ╔═╡ 03c1c79c-9e19-11eb-0ff6-4fccf1a15703
md"""
Connections between workers (using the in-built TCP/IP transport) is established in the following manner:
"""

# ╔═╡ 03c1c8fa-9e19-11eb-1684-6179bcacc6ac
md"""
  * [`addprocs`](@ref) is called on the master process with a `ClusterManager` object.
  * [`addprocs`](@ref) calls the appropriate [`launch`](@ref) method which spawns required number of worker processes on appropriate machines.
  * Each worker starts listening on a free port and writes out its host and port information to [`stdout`](@ref).
  * The cluster manager captures the [`stdout`](@ref) of each worker and makes it available to the master process.
  * The master process parses this information and sets up TCP/IP connections to each worker.
  * Every worker is also notified of other workers in the cluster.
  * Each worker connects to all workers whose `id` is less than the worker's own `id`.
  * In this way a mesh network is established, wherein every worker is directly connected with every other worker.
"""

# ╔═╡ 03c1c91a-9e19-11eb-08b4-f17f2d9f4bac
md"""
While the default transport layer uses plain [`TCPSocket`](@ref), it is possible for a Julia cluster to provide its own transport.
"""

# ╔═╡ 03c1c922-9e19-11eb-20a3-2fe6e0d940fc
md"""
Julia provides two in-built cluster managers:
"""

# ╔═╡ 03c1c9a4-9e19-11eb-355f-3111671c4711
md"""
  * `LocalManager`, used when [`addprocs()`](@ref) or [`addprocs(np::Integer)`](@ref) are called
  * `SSHManager`, used when [`addprocs(hostnames::Array)`](@ref) is called with a list of hostnames
"""

# ╔═╡ 03c1c9b8-9e19-11eb-23d1-b341b04e0d1d
md"""
`LocalManager` is used to launch additional workers on the same host, thereby leveraging multi-core and multi-processor hardware.
"""

# ╔═╡ 03c1c9cc-9e19-11eb-370d-d10ba76c7d90
md"""
Thus, a minimal cluster manager would need to:
"""

# ╔═╡ 03c1ca4e-9e19-11eb-06e6-b1c7c0c5c549
md"""
  * be a subtype of the abstract `ClusterManager`
  * implement [`launch`](@ref), a method responsible for launching new workers
  * implement [`manage`](@ref), which is called at various events during a worker's lifetime (for example, sending an interrupt signal)
"""

# ╔═╡ 03c1ca6c-9e19-11eb-0f92-374103d441dd
md"""
[`addprocs(manager::FooManager)`](@ref addprocs) requires `FooManager` to implement:
"""

# ╔═╡ 03c1caa8-9e19-11eb-38b1-8b834f9b5333
md"""
```julia
function launch(manager::FooManager, params::Dict, launched::Array, c::Condition)
    [...]
end

function manage(manager::FooManager, id::Integer, config::WorkerConfig, op::Symbol)
    [...]
end
```
"""

# ╔═╡ 03c1cada-9e19-11eb-1112-fbba74948d20
md"""
As an example let us see how the `LocalManager`, the manager responsible for starting workers on the same host, is implemented:
"""

# ╔═╡ 03c1cb02-9e19-11eb-2a25-b1959538cfc9
md"""
```julia
struct LocalManager <: ClusterManager
    np::Integer
end

function launch(manager::LocalManager, params::Dict, launched::Array, c::Condition)
    [...]
end

function manage(manager::LocalManager, id::Integer, config::WorkerConfig, op::Symbol)
    [...]
end
```
"""

# ╔═╡ 03c1cb2a-9e19-11eb-1367-9f5502a63366
md"""
The [`launch`](@ref) method takes the following arguments:
"""

# ╔═╡ 03c1cbfc-9e19-11eb-16ac-6ba5177caba6
md"""
  * `manager::ClusterManager`: the cluster manager that [`addprocs`](@ref) is called with
  * `params::Dict`: all the keyword arguments passed to [`addprocs`](@ref)
  * `launched::Array`: the array to append one or more `WorkerConfig` objects to
  * `c::Condition`: the condition variable to be notified as and when workers are launched
"""

# ╔═╡ 03c1cc42-9e19-11eb-2b2b-4d8526701222
md"""
The [`launch`](@ref) method is called asynchronously in a separate task. The termination of this task signals that all requested workers have been launched. Hence the [`launch`](@ref) function MUST exit as soon as all the requested workers have been launched.
"""

# ╔═╡ 03c1cc6a-9e19-11eb-2723-957adae39133
md"""
Newly launched workers are connected to each other and the master process in an all-to-all manner. Specifying the command line argument `--worker[=<cookie>]` results in the launched processes initializing themselves as workers and connections being set up via TCP/IP sockets.
"""

# ╔═╡ 03c1cc9c-9e19-11eb-3344-8166852bdc0a
md"""
All workers in a cluster share the same [cookie](@ref man-cluster-cookie) as the master. When the cookie is unspecified, i.e, with the `--worker` option, the worker tries to read it from its standard input.  `LocalManager` and `SSHManager` both pass the cookie to newly launched workers via their  standard inputs.
"""

# ╔═╡ 03c1ccce-9e19-11eb-094c-3b49edd519cf
md"""
By default a worker will listen on a free port at the address returned by a call to [`getipaddr()`](@ref). A specific address to listen on may be specified by optional argument `--bind-to bind_addr[:port]`. This is useful for multi-homed hosts.
"""

# ╔═╡ 03c1ccec-9e19-11eb-3822-6375994a2548
md"""
As an example of a non-TCP/IP transport, an implementation may choose to use MPI, in which case `--worker` must NOT be specified. Instead, newly launched workers should call `init_worker(cookie)` before using any of the parallel constructs.
"""

# ╔═╡ 03c1cd0a-9e19-11eb-18a7-f71ac8535563
md"""
For every worker launched, the [`launch`](@ref) method must add a `WorkerConfig` object (with appropriate fields initialized) to `launched`
"""

# ╔═╡ 03c1cd32-9e19-11eb-0aaf-07d3c34e4ded
md"""
```julia
mutable struct WorkerConfig
    # Common fields relevant to all cluster managers
    io::Union{IO, Nothing}
    host::Union{AbstractString, Nothing}
    port::Union{Integer, Nothing}

    # Used when launching additional workers at a host
    count::Union{Int, Symbol, Nothing}
    exename::Union{AbstractString, Cmd, Nothing}
    exeflags::Union{Cmd, Nothing}

    # External cluster managers can use this to store information at a per-worker level
    # Can be a dict if multiple fields need to be stored.
    userdata::Any

    # SSHManager / SSH tunnel connections to workers
    tunnel::Union{Bool, Nothing}
    bind_addr::Union{AbstractString, Nothing}
    sshflags::Union{Cmd, Nothing}
    max_parallel::Union{Integer, Nothing}

    # Used by Local/SSH managers
    connect_at::Any

    [...]
end
```
"""

# ╔═╡ 03c1cd5a-9e19-11eb-2ae2-fdaad25d955f
md"""
Most of the fields in `WorkerConfig` are used by the inbuilt managers. Custom cluster managers would typically specify only `io` or `host` / `port`:
"""

# ╔═╡ 03c1cfda-9e19-11eb-3b23-27aaa6481d4b
md"""
  * If `io` is specified, it is used to read host/port information. A Julia worker prints out its bind address and port at startup. This allows Julia workers to listen on any free port available instead of requiring worker ports to be configured manually.
  * If `io` is not specified, `host` and `port` are used to connect.
  * `count`, `exename` and `exeflags` are relevant for launching additional workers from a worker. For example, a cluster manager may launch a single worker per node, and use that to launch additional workers.

      * `count` with an integer value `n` will launch a total of `n` workers.
      * `count` with a value of `:auto` will launch as many workers as the number of CPU threads (logical cores) on that machine.
      * `exename` is the name of the `julia` executable including the full path.
      * `exeflags` should be set to the required command line arguments for new workers.
  * `tunnel`, `bind_addr`, `sshflags` and `max_parallel` are used when a ssh tunnel is required to connect to the workers from the master process.
  * `userdata` is provided for custom cluster managers to store their own worker-specific information.
"""

# ╔═╡ 03c1d00c-9e19-11eb-239b-c91983d8bb67
md"""
`manage(manager::FooManager, id::Integer, config::WorkerConfig, op::Symbol)` is called at different times during the worker's lifetime with appropriate `op` values:
"""

# ╔═╡ 03c1d0ac-9e19-11eb-2078-278572f9c4c7
md"""
  * with `:register`/`:deregister` when a worker is added / removed from the Julia worker pool.
  * with `:interrupt` when `interrupt(workers)` is called. The `ClusterManager` should signal the appropriate worker with an interrupt signal.
  * with `:finalize` for cleanup purposes.
"""

# ╔═╡ 03c1d0ca-9e19-11eb-1c46-95a76f443b32
md"""
### Cluster Managers with Custom Transports
"""

# ╔═╡ 03c1d0e6-9e19-11eb-175a-49d8dc64dc8c
md"""
Replacing the default TCP/IP all-to-all socket connections with a custom transport layer is a little more involved. Each Julia process has as many communication tasks as the workers it is connected to. For example, consider a Julia cluster of 32 processes in an all-to-all mesh network:
"""

# ╔═╡ 03c1d1ce-9e19-11eb-0673-1d9b8fadc7b5
md"""
  * Each Julia process thus has 31 communication tasks.
  * Each task handles all incoming messages from a single remote worker in a message-processing loop.
  * The message-processing loop waits on an `IO` object (for example, a [`TCPSocket`](@ref) in the default implementation), reads an entire message, processes it and waits for the next one.
  * Sending messages to a process is done directly from any Julia task–not just communication tasks–again, via the appropriate `IO` object.
"""

# ╔═╡ 03c1d1f6-9e19-11eb-39e9-dbac43ec74b4
md"""
Replacing the default transport requires the new implementation to set up connections to remote workers and to provide appropriate `IO` objects that the message-processing loops can wait on. The manager-specific callbacks to be implemented are:
"""

# ╔═╡ 03c1d23c-9e19-11eb-3293-e57405956ed8
md"""
```julia
connect(manager::FooManager, pid::Integer, config::WorkerConfig)
kill(manager::FooManager, pid::Int, config::WorkerConfig)
```
"""

# ╔═╡ 03c1d24e-9e19-11eb-08ea-fd333cb9288a
md"""
The default implementation (which uses TCP/IP sockets) is implemented as `connect(manager::ClusterManager, pid::Integer, config::WorkerConfig)`.
"""

# ╔═╡ 03c1d278-9e19-11eb-1b81-e7e9f9d6fbb1
md"""
`connect` should return a pair of `IO` objects, one for reading data sent from worker `pid`, and the other to write data that needs to be sent to worker `pid`. Custom cluster managers can use an in-memory `BufferStream` as the plumbing to proxy data between the custom, possibly non-`IO` transport and Julia's in-built parallel infrastructure.
"""

# ╔═╡ 03c1d2c8-9e19-11eb-03b7-f5b4f9794fd6
md"""
A `BufferStream` is an in-memory [`IOBuffer`](@ref) which behaves like an `IO`–it is a stream which can be handled asynchronously.
"""

# ╔═╡ 03c1d30e-9e19-11eb-2b37-333d074affda
md"""
The folder `clustermanager/0mq` in the [Examples repository](https://github.com/JuliaAttic/Examples) contains an example of using ZeroMQ to connect Julia workers in a star topology with a 0MQ broker in the middle. Note: The Julia processes are still all *logically* connected to each other–any worker can message any other worker directly without any awareness of 0MQ being used as the transport layer.
"""

# ╔═╡ 03c1d318-9e19-11eb-1b2a-efad0b05be2c
md"""
When using custom transports:
"""

# ╔═╡ 03c1d462-9e19-11eb-327d-3d61cbdc3a3c
md"""
  * Julia workers must NOT be started with `--worker`. Starting with `--worker` will result in the newly launched workers defaulting to the TCP/IP socket transport implementation.
  * For every incoming logical connection with a worker, `Base.process_messages(rd::IO, wr::IO)()` must be called. This launches a new task that handles reading and writing of messages from/to the worker represented by the `IO` objects.
  * `init_worker(cookie, manager::FooManager)` *must* be called as part of worker process initialization.
  * Field `connect_at::Any` in `WorkerConfig` can be set by the cluster manager when [`launch`](@ref) is called. The value of this field is passed in all [`connect`](@ref) callbacks. Typically, it carries information on *how to connect* to a worker. For example, the TCP/IP socket transport uses this field to specify the `(host, port)` tuple at which to connect to a worker.
"""

# ╔═╡ 03c1d480-9e19-11eb-3796-2b72881fe079
md"""
`kill(manager, pid, config)` is called to remove a worker from the cluster. On the master process, the corresponding `IO` objects must be closed by the implementation to ensure proper cleanup. The default implementation simply executes an `exit()` call on the specified remote worker.
"""

# ╔═╡ 03c1d494-9e19-11eb-2994-ad481d192ee5
md"""
The Examples folder `clustermanager/simple` is an example that shows a simple implementation using UNIX domain sockets for cluster setup.
"""

# ╔═╡ 03c1d4a8-9e19-11eb-0107-dbedf5bbf5f6
md"""
### Network Requirements for LocalManager and SSHManager
"""

# ╔═╡ 03c1d4d0-9e19-11eb-2efb-87bbd36f45eb
md"""
Julia clusters are designed to be executed on already secured environments on infrastructure such as local laptops, departmental clusters, or even the cloud. This section covers network security requirements for the inbuilt `LocalManager` and `SSHManager`:
"""

# ╔═╡ 03c1d73c-9e19-11eb-3542-595c744fd543
md"""
  * The master process does not listen on any port. It only connects out to the workers.
  * Each worker binds to only one of the local interfaces and listens on an ephemeral port number assigned by the OS.
  * `LocalManager`, used by `addprocs(N)`, by default binds only to the loopback interface. This means that workers started later on remote hosts (or by anyone with malicious intentions) are unable to connect to the cluster. An `addprocs(4)` followed by an `addprocs(["remote_host"])` will fail. Some users may need to create a cluster comprising their local system and a few remote systems. This can be done by explicitly requesting `LocalManager` to bind to an external network interface via the `restrict` keyword argument: `addprocs(4; restrict=false)`.
  * `SSHManager`, used by `addprocs(list_of_remote_hosts)`, launches workers on remote hosts via SSH. By default SSH is only used to launch Julia workers. Subsequent master-worker and worker-worker connections use plain, unencrypted TCP/IP sockets. The remote hosts must have passwordless login enabled. Additional SSH flags or credentials may be specified via keyword argument `sshflags`.
  * `addprocs(list_of_remote_hosts; tunnel=true, sshflags=<ssh keys and other flags>)` is useful when we wish to use SSH connections for master-worker too. A typical scenario for this is a local laptop running the Julia REPL (i.e., the master) with the rest of the cluster on the cloud, say on Amazon EC2. In this case only port 22 needs to be opened at the remote cluster coupled with SSH client authenticated via public key infrastructure (PKI). Authentication credentials can be supplied via `sshflags`, for example ```sshflags=`-i <keyfile>` ```.

    In an all-to-all topology (the default), all workers connect to each other via plain TCP sockets. The security policy on the cluster nodes must thus ensure free connectivity between workers for the ephemeral port range (varies by OS).

    Securing and encrypting all worker-worker traffic (via SSH) or encrypting individual messages can be done via a custom `ClusterManager`.
  * If you specify `multiplex=true` as an option to `addprocs`, SSH multiplexing is used to create a tunnel between the master and workers. If you have configured SSH multiplexing on your own and the connection has already been established, SSH multiplexing is used regardless of `multiplex` option. If multiplexing is enabled, forwarding is set by using the existing connection (`-O forward` option in ssh). This is beneficial if your servers require password authentication; you can avoid authentication in Julia by logging in to the server ahead of `addprocs`. The control socket will be located at `~/.ssh/julia-%r@%h:%p` during the session unless the existing multiplexing connection is used. Note that bandwidth may be limited if you create multiple processes on a node and enable multiplexing, because in that case processes share a single multiplexing TCP connection.
"""

# ╔═╡ 03c1d750-9e19-11eb-33d3-857b44d13623
md"""
### [Cluster Cookie](@id man-cluster-cookie)
"""

# ╔═╡ 03c1d764-9e19-11eb-0431-5f237ab30564
md"""
All processes in a cluster share the same cookie which, by default, is a randomly generated string on the master process:
"""

# ╔═╡ 03c1d84a-9e19-11eb-05df-8d3459595b15
md"""
  * [`cluster_cookie()`](@ref) returns the cookie, while `cluster_cookie(cookie)()` sets it and returns the new cookie.
  * All connections are authenticated on both sides to ensure that only workers started by the master are allowed to connect to each other.
  * The cookie may be passed to the workers at startup via argument `--worker=<cookie>`. If argument `--worker` is specified without the cookie, the worker tries to read the cookie from its standard input ([`stdin`](@ref)). The `stdin` is closed immediately after the cookie is retrieved.
  * `ClusterManager`s can retrieve the cookie on the master by calling [`cluster_cookie()`](@ref). Cluster managers not using the default TCP/IP transport (and hence not specifying `--worker`) must call `init_worker(cookie, manager)` with the same cookie as on the master.
"""

# ╔═╡ 03c1d868-9e19-11eb-382b-23f029b4a3c3
md"""
Note that environments requiring higher levels of security can implement this via a custom `ClusterManager`. For example, cookies can be pre-shared and hence not specified as a startup argument.
"""

# ╔═╡ 03c1d886-9e19-11eb-3e63-45e5a57cbefe
md"""
## Specifying Network Topology (Experimental)
"""

# ╔═╡ 03c1d8a4-9e19-11eb-106c-6b805d343a7c
md"""
The keyword argument `topology` passed to `addprocs` is used to specify how the workers must be connected to each other:
"""

# ╔═╡ 03c1d944-9e19-11eb-10bd-85e7c4075c5a
md"""
  * `:all_to_all`, the default: all workers are connected to each other.
  * `:master_worker`: only the driver process, i.e. `pid` 1, has connections to the workers.
  * `:custom`: the `launch` method of the cluster manager specifies the connection topology via the fields `ident` and `connect_idents` in `WorkerConfig`. A worker with a cluster-manager-provided identity `ident` will connect to all workers specified in `connect_idents`.
"""

# ╔═╡ 03c1d98a-9e19-11eb-0d6a-8bf934a22d37
md"""
Keyword argument `lazy=true|false` only affects `topology` option `:all_to_all`. If `true`, the cluster starts off with the master connected to all workers. Specific worker-worker connections are established at the first remote invocation between two workers. This helps in reducing initial resources allocated for intra-cluster communication. Connections are setup depending on the runtime requirements of a parallel program. Default value for `lazy` is `true`.
"""

# ╔═╡ 03c1d99e-9e19-11eb-276b-635f29ce2feb
md"""
Currently, sending a message between unconnected workers results in an error. This behaviour, as with the functionality and interface, should be considered experimental in nature and may change in future releases.
"""

# ╔═╡ 03c1d9b2-9e19-11eb-2d7f-7f89853a0f7c
md"""
## Noteworthy external packages
"""

# ╔═╡ 03c1d9ee-9e19-11eb-37eb-474bae9bd176
md"""
Outside of Julia parallelism there are plenty of external packages that should be mentioned. For example [MPI.jl](https://github.com/JuliaParallel/MPI.jl) is a Julia wrapper for the `MPI` protocol, or [DistributedArrays.jl](https://github.com/JuliaParallel/Distributedarrays.jl), as presented in [Shared Arrays](@ref). A mention must be made of Julia's GPU programming ecosystem, which includes:
"""

# ╔═╡ 03c1db38-9e19-11eb-2517-253ea6478682
md"""
1. Low-level (C kernel) based operations [OpenCL.jl](https://github.com/JuliaGPU/OpenCL.jl) and [CUDAdrv.jl](https://github.com/JuliaGPU/CUDAdrv.jl) which are respectively an OpenCL interface and a CUDA wrapper.
2. Low-level (Julia Kernel) interfaces like [CUDAnative.jl](https://github.com/JuliaGPU/CUDAnative.jl) which is a Julia native CUDA implementation.
3. High-level vendor-specific abstractions like [CuArrays.jl](https://github.com/JuliaGPU/CuArrays.jl) and [CLArrays.jl](https://github.com/JuliaGPU/CLArrays.jl)
4. High-level libraries like [ArrayFire.jl](https://github.com/JuliaComputing/ArrayFire.jl) and [GPUArrays.jl](https://github.com/JuliaGPU/GPUArrays.jl)
"""

# ╔═╡ 03c1db56-9e19-11eb-2685-5149f4932dae
md"""
In the following example we will use both `DistributedArrays.jl` and `CuArrays.jl` to distribute an array across multiple processes by first casting it through `distribute()` and `CuArray()`.
"""

# ╔═╡ 03c1db7e-9e19-11eb-0f0f-bba078d07705
md"""
Remember when importing `DistributedArrays.jl` to import it across all processes using [`@everywhere`](@ref)
"""

# ╔═╡ 03c22b92-9e19-11eb-1408-4d5916ea91d0
$ ./julia

# ╔═╡ 03c22ba6-9e19-11eb-3c13-d392fc93bc8d
addprocs()

# ╔═╡ 03c22ba6-9e19-11eb-137e-57a14b4cca55
@everywhere using DistributedArrays

# ╔═╡ 03c22bb0-9e19-11eb-1938-0d7c7ba5f7f2
using CuArrays

# ╔═╡ 03c22bd8-9e19-11eb-1434-f5328dde196e
B = ones(10_000) ./ 2;

# ╔═╡ 03c22bd8-9e19-11eb-13a6-1312e7bf67b7
A = ones(10_000) .* π;

# ╔═╡ 03c22be2-9e19-11eb-05cc-39ad070bfa73
C = 2 .* A ./ B;

# ╔═╡ 03c22be2-9e19-11eb-2048-a1326e156a6d
all(C .≈ 4*π)

# ╔═╡ 03c22be2-9e19-11eb-0512-47fed713a96f
typeof(C)

# ╔═╡ 03c22c0a-9e19-11eb-161c-699ab4d5d9f4
dB = distribute(B);

# ╔═╡ 03c22c14-9e19-11eb-274b-5399c7c6aa5e
dA = distribute(A);

# ╔═╡ 03c22c14-9e19-11eb-2158-f14f85a65597
dC = 2 .* dA ./ dB;

# ╔═╡ 03c22c1e-9e19-11eb-3431-8dc13f4035a4
all(dC .≈ 4*π)

# ╔═╡ 03c22c28-9e19-11eb-2698-e157bd26dc8a
typeof(dC)

# ╔═╡ 03c22c28-9e19-11eb-2b8c-1bc2284ce14f
cuB = CuArray(B);

# ╔═╡ 03c22c34-9e19-11eb-03c5-2b1760e96638
cuA = CuArray(A);

# ╔═╡ 03c22c34-9e19-11eb-3bfc-49266db00617
cuC = 2 .* cuA ./ cuB;

# ╔═╡ 03c22c3c-9e19-11eb-0b01-3f3e556bbba5
all(cuC .≈ 4*π);

# ╔═╡ 03c22c3c-9e19-11eb-124c-d74933c17cd9
typeof(cuC)

# ╔═╡ 03c22d18-9e19-11eb-1c0b-b5ecf150a14c
md"""
Keep in mind that some Julia features are not currently supported by CUDAnative.jl[^2] , especially some functions like `sin` will need to be replaced with `CUDAnative.sin`(cc: @maleadt).
"""

# ╔═╡ 03c22d5e-9e19-11eb-2c72-69e07894faa4
md"""
In the following example we will use both `DistributedArrays.jl` and `CuArrays.jl` to distribute an array across multiple processes and call a generic function on it.
"""

# ╔═╡ 03c22db8-9e19-11eb-3ecd-65dd2351da03
md"""
```julia
function power_method(M, v)
    for i in 1:100
        v = M*v
        v /= norm(v)
    end

    return v, norm(M*v) / norm(v)  # or  (M*v) ./ v
end
```
"""

# ╔═╡ 03c22dd6-9e19-11eb-3154-9ff21c178176
md"""
`power_method` repeatedly creates a new vector and normalizes it. We have not specified any type signature in function declaration, let's see if it works with the aforementioned datatypes:
"""

# ╔═╡ 03c23b3c-9e19-11eb-0837-4da6e7322f8e
M = [2. 1; 1 1];

# ╔═╡ 03c23b3c-9e19-11eb-3232-875595e186b0
v = rand(2)

# ╔═╡ 03c23b5a-9e19-11eb-205a-c1f2f6ab4e16
power_method(M,v)

# ╔═╡ 03c23b5a-9e19-11eb-3950-e97840cc765f
cuM = CuArray(M);

# ╔═╡ 03c23b64-9e19-11eb-05c9-e79e8dab8a60
cuv = CuArray(v);

# ╔═╡ 03c23b64-9e19-11eb-2b66-b186efd7a22a
curesult = power_method(cuM, cuv);

# ╔═╡ 03c23b64-9e19-11eb-3719-0ff913ff01f8
typeof(curesult)

# ╔═╡ 03c23b76-9e19-11eb-3ba5-1f1297fa21f9
dM = distribute(M);

# ╔═╡ 03c23b76-9e19-11eb-0884-f53089dd27c9
dv = distribute(v);

# ╔═╡ 03c23b82-9e19-11eb-0399-a598da97cabe
dC = power_method(dM, dv);

# ╔═╡ 03c23b82-9e19-11eb-140b-ffeef605892f
typeof(dC)

# ╔═╡ 03c23ba8-9e19-11eb-2a61-a76cd6070684
md"""
To end this short exposure to external packages, we can consider `MPI.jl`, a Julia wrapper of the MPI protocol. As it would take too long to consider every inner function, it would be better to simply appreciate the approach used to implement the protocol.
"""

# ╔═╡ 03c23bc8-9e19-11eb-1860-73d41462714e
md"""
Consider this toy script which simply calls each subprocess, instantiate its rank and when the master process is reached, performs the ranks' sum
"""

# ╔═╡ 03c23be6-9e19-11eb-13b4-f7b7ce193646
md"""
```julia
import MPI

MPI.Init()

comm = MPI.COMM_WORLD
MPI.Barrier(comm)

root = 0
r = MPI.Comm_rank(comm)

sr = MPI.Reduce(r, MPI.SUM, root, comm)

if(MPI.Comm_rank(comm) == root)
   @printf("sum of ranks: %s\n", sr)
end

MPI.Finalize()
```
"""

# ╔═╡ 03c23d26-9e19-11eb-2b84-8ffc98200143
mpirun -np 4

# ╔═╡ 03c23e5c-9e19-11eb-253a-b3811d4bc07e
md"""
[^1]: In this context, MPI refers to the MPI-1 standard. Beginning with MPI-2, the MPI standards committee introduced a new set of communication mechanisms, collectively referred to as Remote Memory Access (RMA). The motivation for adding rma to the MPI standard was to facilitate one-sided communication patterns. For additional information on the latest MPI standard, see [https://mpi-forum.org/docs](https://mpi-forum.org/docs).
"""

# ╔═╡ 03c23eaa-9e19-11eb-3214-1522f21491c6
md"""
[^2]: [Julia GPU man pages](http://juliagpu.github.io/CUDAnative.jl/stable/man/usage.html#Julia-support-1)
"""

# ╔═╡ Cell order:
# ╟─03c0d3be-9e19-11eb-277f-23638dc88bdc
# ╟─03c0d40e-9e19-11eb-1274-41b61ba04e47
# ╟─03c0d49a-9e19-11eb-2543-551bf8f3c2f2
# ╟─03c0d4cc-9e19-11eb-1033-c707b249c958
# ╟─03c0d4fe-9e19-11eb-14a2-239428cacb7a
# ╟─03c0d558-9e19-11eb-3966-934e2dcfe2cc
# ╟─03c0d594-9e19-11eb-17e4-efa009fb709e
# ╟─03c0d5b2-9e19-11eb-05cb-3388be047656
# ╟─03c0d5e4-9e19-11eb-0775-37da8679be53
# ╟─03c0d60c-9e19-11eb-0143-d722132f1b50
# ╟─03c0d648-9e19-11eb-0cd2-d152bfbd7946
# ╟─03c0d684-9e19-11eb-1385-554aa5d3d78d
# ╟─03c0d6a4-9e19-11eb-0603-2d9de95c1097
# ╟─03c0d6b6-9e19-11eb-31f6-5b1d4fac5f66
# ╠═03c0dad0-9e19-11eb-0903-f1d93d49674d
# ╟─03c0db0a-9e19-11eb-221a-cd1c0fcee88a
# ╟─03c0db2a-9e19-11eb-345c-c10cb083cea1
# ╠═03c0e192-9e19-11eb-3111-9bfeed71d1dd
# ╠═03c0e1b2-9e19-11eb-3938-01bb746af100
# ╠═03c0e1b2-9e19-11eb-0187-8bca4bb59c35
# ╟─03c0e1ec-9e19-11eb-0442-3110b1da4a0e
# ╟─03c0e20a-9e19-11eb-353e-ed7e5a1161ef
# ╟─03c0e23c-9e19-11eb-2874-a90e9f796684
# ╟─03c0e2a0-9e19-11eb-3131-3d08a1c592a0
# ╟─03c0e2d2-9e19-11eb-07d1-29f99024f450
# ╟─03c0e2e8-9e19-11eb-207b-dd36366e93c2
# ╠═03c0ea02-9e19-11eb-34a7-0f5d6c36aa21
# ╠═03c0ea0c-9e19-11eb-172a-1dcbd9302ab7
# ╠═03c0ea16-9e19-11eb-3d72-a50808b6a96a
# ╟─03c0ea2a-9e19-11eb-1e93-fbe54de919cd
# ╟─03c0ea48-9e19-11eb-3738-dd2c86081cfb
# ╟─03c0ea66-9e19-11eb-0338-45774dadbce8
# ╟─03c0ea82-9e19-11eb-3cae-677bdc854901
# ╠═03c0ecc8-9e19-11eb-3fc6-1925507bbd82
# ╟─03c0ecee-9e19-11eb-1468-2110833e6c45
# ╠═03c0f396-9e19-11eb-158b-c9bb4c94835e
# ╠═03c0f396-9e19-11eb-1f27-f94b64c73c1c
# ╠═03c0f3a8-9e19-11eb-1567-9d5dda0ba1fe
# ╠═03c0f3b2-9e19-11eb-13ad-e989cffa471e
# ╟─03c0f3d0-9e19-11eb-27f5-5d6d4ecdfb0f
# ╠═03c0f5c4-9e19-11eb-0263-fd68429dea23
# ╟─03c0f5e2-9e19-11eb-29ca-d57fb56fa6e0
# ╠═03c0f7f4-9e19-11eb-0e93-ad6420e27b85
# ╟─03c0f812-9e19-11eb-1135-fd4a05b95413
# ╟─03c0f83a-9e19-11eb-2832-2bcb526eafd1
# ╟─03c0f84e-9e19-11eb-2567-95a268bd67cf
# ╟─03c0f862-9e19-11eb-1227-fda743b4d13a
# ╟─03c0f984-9e19-11eb-18cd-011806b9b2ab
# ╟─03c0f9c0-9e19-11eb-3c86-279bd8d3cdc0
# ╠═03c0fb82-9e19-11eb-19ae-b7dfbbe01510
# ╠═03c0fb82-9e19-11eb-0260-279edc65dcd7
# ╟─03c0fba2-9e19-11eb-0e65-d134bbe36d1c
# ╟─03c0fbd0-9e19-11eb-32c2-b10c38ad5a5d
# ╟─03c0fbf0-9e19-11eb-123f-99d008e8279e
# ╟─03c0fbfa-9e19-11eb-0590-5d130e1006aa
# ╟─03c0fc18-9e19-11eb-35ba-c7cdc3b192dd
# ╟─03c0fc40-9e19-11eb-38b3-05aae3bd6b4a
# ╟─03c0fc4a-9e19-11eb-1f25-534669505887
# ╠═03c100e6-9e19-11eb-2a99-03e3f5c6e686
# ╠═03c100f0-9e19-11eb-302a-25d1a75df5f8
# ╠═03c100fa-9e19-11eb-01c8-c56627a9f963
# ╟─03c10104-9e19-11eb-339c-dfa002ee3171
# ╠═03c1046a-9e19-11eb-3b91-6d76fc9698fb
# ╠═03c1047e-9e19-11eb-27c4-c514652126ac
# ╟─03c104a6-9e19-11eb-1cbc-cd00832137b1
# ╟─03c104ce-9e19-11eb-2f23-4f38a9271141
# ╟─03c104ec-9e19-11eb-2c26-e9b2a042eb2c
# ╟─03c1050a-9e19-11eb-14fd-7129416a6164
# ╠═03c10672-9e19-11eb-0671-e7c3447366ce
# ╟─03c106b0-9e19-11eb-1529-f538510b2ee7
# ╟─03c1079e-9e19-11eb-2c99-2b11f2881668
# ╟─03c107bc-9e19-11eb-35dc-03f9d3fd4fdb
# ╟─03c107c6-9e19-11eb-219e-8b67895c3c4e
# ╟─03c107e6-9e19-11eb-09cd-d5c49ccd8337
# ╠═03c110d6-9e19-11eb-1d86-edcf7b988ef0
# ╠═03c110e0-9e19-11eb-26e4-6b0a7820e780
# ╠═03c110e0-9e19-11eb-168a-6387adc92a43
# ╠═03c110fe-9e19-11eb-216a-21114bcd974b
# ╠═03c110fe-9e19-11eb-16bf-5b68ddbc586c
# ╟─03c11126-9e19-11eb-231f-991b9182f9a3
# ╟─03c1113a-9e19-11eb-13db-475d92af2657
# ╟─03c1116c-9e19-11eb-0cd4-f1fd3e4a64ee
# ╟─03c1118c-9e19-11eb-1705-15ea6e6c7dce
# ╟─03c1119e-9e19-11eb-3411-5b30ff72a77e
# ╠═03c11aa4-9e19-11eb-0f39-b9de3aceb668
# ╠═03c11aae-9e19-11eb-1d9b-9d078033e06e
# ╠═03c11aae-9e19-11eb-1f32-5f446b305306
# ╠═03c11ab8-9e19-11eb-2179-b96e7d42e8a6
# ╟─03c11aea-9e19-11eb-17cc-37af38d2e18f
# ╟─03c11b32-9e19-11eb-0c2e-c9cf27f4e4b9
# ╟─03c11b44-9e19-11eb-3817-f5d1c4a13dd8
# ╟─03c11b60-9e19-11eb-2765-b70f7eb2ee80
# ╟─03c11b80-9e19-11eb-12f2-e374bcb614a4
# ╟─03c11b8a-9e19-11eb-1a59-2ba020798b25
# ╟─03c11b9e-9e19-11eb-23f4-f90521e42eb9
# ╟─03c11bc4-9e19-11eb-1701-2f106d3f8084
# ╟─03c11bda-9e19-11eb-2159-918f4073d9ac
# ╟─03c11be4-9e19-11eb-07db-fbfac3cd1bad
# ╟─03c11bf8-9e19-11eb-1d46-670164452b76
# ╟─03c11c16-9e19-11eb-228a-27460110ffc4
# ╟─03c11c48-9e19-11eb-3821-5fdedbee6488
# ╟─03c11c68-9e19-11eb-2873-e719c38fa52f
# ╠═03c120ee-9e19-11eb-3f0a-8f97ced90f92
# ╠═03c120f8-9e19-11eb-1584-b3a40cc8b415
# ╟─03c12120-9e19-11eb-1a7d-7b760c637a41
# ╟─03c12132-9e19-11eb-0eca-a1704c914f3b
# ╟─03c1215c-9e19-11eb-353b-f9918c72cadb
# ╟─03c12198-9e19-11eb-1108-7d7abee637db
# ╟─03c121b6-9e19-11eb-26a9-4f98f1185d25
# ╟─03c121de-9e19-11eb-2e56-7331ca95ed48
# ╟─03c121fc-9e19-11eb-135a-4797a1ee863f
# ╟─03c12236-9e19-11eb-384a-11f83c78ace9
# ╟─03c12260-9e19-11eb-2ef1-cdc02d0f948e
# ╟─03c12274-9e19-11eb-220a-4973c0e1a6f6
# ╟─03c12402-9e19-11eb-1c43-01113a204d1c
# ╟─03c12422-9e19-11eb-072b-916c299b8a03
# ╟─03c12440-9e19-11eb-2f10-c93ecf897a66
# ╠═03c14150-9e19-11eb-38d4-1d28b8fcf294
# ╠═03c14150-9e19-11eb-2816-6f6520f01de5
# ╠═03c14166-9e19-11eb-1c12-218c29ef1b78
# ╠═03c1416e-9e19-11eb-1325-7d00ba021b8d
# ╠═03c1416e-9e19-11eb-251e-55bebf3a7469
# ╠═03c14178-9e19-11eb-2095-5925c60757e1
# ╠═03c14178-9e19-11eb-1b7f-9bbea6d0c675
# ╠═03c1418c-9e19-11eb-14b6-25ca498bc71d
# ╠═03c1418c-9e19-11eb-16df-8f9c9b49ec3c
# ╟─03c141dc-9e19-11eb-247f-670e4e164934
# ╟─03c141f0-9e19-11eb-1b30-3b9221949ddf
# ╟─03c14236-9e19-11eb-1e3e-2d13e3e3e999
# ╟─03c1424a-9e19-11eb-0c59-3f655e51017b
# ╟─03c14272-9e19-11eb-149c-ff14304758b7
# ╟─03c14286-9e19-11eb-1607-6d083bc852f8
# ╟─03c142a4-9e19-11eb-096c-776ced74bd07
# ╟─03c142b8-9e19-11eb-12af-3d8d981585db
# ╟─03c14308-9e19-11eb-0aad-1d93634f5e5d
# ╟─03c14312-9e19-11eb-037f-8ddfa9e3f416
# ╟─03c14326-9e19-11eb-2462-d95170f8cb85
# ╟─03c14358-9e19-11eb-11ee-9d4059b6af18
# ╠═03c15f82-9e19-11eb-30e4-dd01468754e9
# ╠═03c15f8e-9e19-11eb-0701-7733a1011993
# ╠═03c15f8e-9e19-11eb-09f3-f1cb96f5c137
# ╠═03c15f96-9e19-11eb-378f-afd43480c6ef
# ╠═03c15fa0-9e19-11eb-02ec-c7f75df90abc
# ╠═03c15faa-9e19-11eb-24c3-7b6e362163e7
# ╠═03c15faa-9e19-11eb-351e-0393938ecbe2
# ╠═03c15faa-9e19-11eb-3ee7-993534dca82d
# ╠═03c15fb4-9e19-11eb-12ad-b1737ef99f11
# ╠═03c15fc0-9e19-11eb-385c-b56ad8b2070d
# ╠═03c15fc8-9e19-11eb-1175-4126d85f646d
# ╠═03c15fc8-9e19-11eb-17ad-1bb03a945de5
# ╠═03c15fd2-9e19-11eb-090f-599d5e7b04a4
# ╠═03c15fd2-9e19-11eb-3fc2-cdd816198bc6
# ╟─03c16018-9e19-11eb-1b58-2f9042843093
# ╟─03c1602c-9e19-11eb-3799-4d0f5cd43054
# ╟─03c16036-9e19-11eb-0f13-391d79d87784
# ╠═03c17076-9e19-11eb-223e-ff68ba21904f
# ╠═03c17076-9e19-11eb-108b-271b02f208e8
# ╠═03c17080-9e19-11eb-0a62-a57697b665ee
# ╠═03c17080-9e19-11eb-00fa-cbd1a32867cc
# ╠═03c1708a-9e19-11eb-2209-d9ca751a651c
# ╠═03c17094-9e19-11eb-0bf4-d3c128ddaeda
# ╠═03c17094-9e19-11eb-20cb-f1fcd1eb9c2a
# ╟─03c170a8-9e19-11eb-1a0e-6375098e3741
# ╟─03c170bc-9e19-11eb-2867-ef048ddebd16
# ╟─03c170da-9e19-11eb-0393-4fe6d49eb924
# ╟─03c17116-9e19-11eb-34e1-f97a32c42fa6
# ╟─03c1712a-9e19-11eb-00a5-c58bb209de6a
# ╟─03c17184-9e19-11eb-317c-c91bde57c6f9
# ╟─03c17198-9e19-11eb-3ef2-4b6b24467aab
# ╟─03c171ac-9e19-11eb-191a-add741b3f5ff
# ╟─03c171e8-9e19-11eb-3dd2-d329604712e0
# ╟─03c171fc-9e19-11eb-3215-a795ec645df2
# ╟─03c17210-9e19-11eb-11e5-7d920716cefa
# ╠═03c17cd8-9e19-11eb-1f66-6dee2cbe13c4
# ╠═03c17cd8-9e19-11eb-0e2d-5707884577bd
# ╠═03c17cd8-9e19-11eb-3db4-67eadec97769
# ╠═03c17ce0-9e19-11eb-0634-dba0e753956c
# ╠═03c17ce0-9e19-11eb-3a73-7d89cbe61d04
# ╠═03c17cf6-9e19-11eb-36e9-0144db15e584
# ╟─03c17d12-9e19-11eb-34c7-cb548b7ea84b
# ╠═03c18570-9e19-11eb-1b6d-a7c27ac80b11
# ╟─03c18582-9e19-11eb-2f6a-9fd6da7413bc
# ╟─03c185ac-9e19-11eb-0d42-370846680ecd
# ╟─03c185ca-9e19-11eb-308a-936418ae8625
# ╟─03c185de-9e19-11eb-3fdf-47a7df4f0e69
# ╟─03c185fc-9e19-11eb-3386-0d9c7182bb17
# ╟─03c1861a-9e19-11eb-2b4b-b1cc18377e32
# ╠═03c197ae-9e19-11eb-0f92-171b672fee0d
# ╟─03c197fe-9e19-11eb-1a8f-c1fa69a74538
# ╠═03c1a122-9e19-11eb-2fc9-7fdba6079621
# ╟─03c1a154-9e19-11eb-2897-bd09ba3c6d50
# ╠═03c1a616-9e19-11eb-1e1b-b72f0e06326c
# ╟─03c1a65e-9e19-11eb-294c-3d3c7c74ca92
# ╠═03c1ab9a-9e19-11eb-0a29-2f40bcb524f9
# ╟─03c1abcc-9e19-11eb-01af-559bd712e8ec
# ╠═03c1b676-9e19-11eb-3cef-278cf58619b6
# ╟─03c1b6b2-9e19-11eb-391e-fb734afe3fd3
# ╠═03c1bbc6-9e19-11eb-187f-97faf33675ca
# ╟─03c1bbf8-9e19-11eb-28e0-5bdab3a08494
# ╠═03c1c102-9e19-11eb-1ae3-adb0b031af7a
# ╠═03c1c120-9e19-11eb-3a67-9be438db2258
# ╟─03c1c152-9e19-11eb-1fd6-d5948811f641
# ╠═03c1c53a-9e19-11eb-0868-a3323095e923
# ╠═03c1c546-9e19-11eb-276a-d9cc665eadc9
# ╠═03c1c546-9e19-11eb-37e7-931178d47559
# ╟─03c1c574-9e19-11eb-0ae9-edc54e4f7a28
# ╟─03c1c5a6-9e19-11eb-196f-e308c1bd1f58
# ╟─03c1c5c6-9e19-11eb-0d20-c711343e7086
# ╟─03c1c602-9e19-11eb-0b86-134f2ea2be67
# ╟─03c1c616-9e19-11eb-36de-91ab54e50d77
# ╟─03c1c6e8-9e19-11eb-1e6a-ed5e8676a9b5
# ╟─03c1c70e-9e19-11eb-139e-b18c84e6a565
# ╟─03c1c792-9e19-11eb-13a0-433dd1d20e3e
# ╟─03c1c79c-9e19-11eb-0ff6-4fccf1a15703
# ╟─03c1c8fa-9e19-11eb-1684-6179bcacc6ac
# ╟─03c1c91a-9e19-11eb-08b4-f17f2d9f4bac
# ╟─03c1c922-9e19-11eb-20a3-2fe6e0d940fc
# ╟─03c1c9a4-9e19-11eb-355f-3111671c4711
# ╟─03c1c9b8-9e19-11eb-23d1-b341b04e0d1d
# ╟─03c1c9cc-9e19-11eb-370d-d10ba76c7d90
# ╟─03c1ca4e-9e19-11eb-06e6-b1c7c0c5c549
# ╟─03c1ca6c-9e19-11eb-0f92-374103d441dd
# ╟─03c1caa8-9e19-11eb-38b1-8b834f9b5333
# ╟─03c1cada-9e19-11eb-1112-fbba74948d20
# ╟─03c1cb02-9e19-11eb-2a25-b1959538cfc9
# ╟─03c1cb2a-9e19-11eb-1367-9f5502a63366
# ╟─03c1cbfc-9e19-11eb-16ac-6ba5177caba6
# ╟─03c1cc42-9e19-11eb-2b2b-4d8526701222
# ╟─03c1cc6a-9e19-11eb-2723-957adae39133
# ╟─03c1cc9c-9e19-11eb-3344-8166852bdc0a
# ╟─03c1ccce-9e19-11eb-094c-3b49edd519cf
# ╟─03c1ccec-9e19-11eb-3822-6375994a2548
# ╟─03c1cd0a-9e19-11eb-18a7-f71ac8535563
# ╟─03c1cd32-9e19-11eb-0aaf-07d3c34e4ded
# ╟─03c1cd5a-9e19-11eb-2ae2-fdaad25d955f
# ╟─03c1cfda-9e19-11eb-3b23-27aaa6481d4b
# ╟─03c1d00c-9e19-11eb-239b-c91983d8bb67
# ╟─03c1d0ac-9e19-11eb-2078-278572f9c4c7
# ╟─03c1d0ca-9e19-11eb-1c46-95a76f443b32
# ╟─03c1d0e6-9e19-11eb-175a-49d8dc64dc8c
# ╟─03c1d1ce-9e19-11eb-0673-1d9b8fadc7b5
# ╟─03c1d1f6-9e19-11eb-39e9-dbac43ec74b4
# ╟─03c1d23c-9e19-11eb-3293-e57405956ed8
# ╟─03c1d24e-9e19-11eb-08ea-fd333cb9288a
# ╟─03c1d278-9e19-11eb-1b81-e7e9f9d6fbb1
# ╟─03c1d2c8-9e19-11eb-03b7-f5b4f9794fd6
# ╟─03c1d30e-9e19-11eb-2b37-333d074affda
# ╟─03c1d318-9e19-11eb-1b2a-efad0b05be2c
# ╟─03c1d462-9e19-11eb-327d-3d61cbdc3a3c
# ╟─03c1d480-9e19-11eb-3796-2b72881fe079
# ╟─03c1d494-9e19-11eb-2994-ad481d192ee5
# ╟─03c1d4a8-9e19-11eb-0107-dbedf5bbf5f6
# ╟─03c1d4d0-9e19-11eb-2efb-87bbd36f45eb
# ╟─03c1d73c-9e19-11eb-3542-595c744fd543
# ╟─03c1d750-9e19-11eb-33d3-857b44d13623
# ╟─03c1d764-9e19-11eb-0431-5f237ab30564
# ╟─03c1d84a-9e19-11eb-05df-8d3459595b15
# ╟─03c1d868-9e19-11eb-382b-23f029b4a3c3
# ╟─03c1d886-9e19-11eb-3e63-45e5a57cbefe
# ╟─03c1d8a4-9e19-11eb-106c-6b805d343a7c
# ╟─03c1d944-9e19-11eb-10bd-85e7c4075c5a
# ╟─03c1d98a-9e19-11eb-0d6a-8bf934a22d37
# ╟─03c1d99e-9e19-11eb-276b-635f29ce2feb
# ╟─03c1d9b2-9e19-11eb-2d7f-7f89853a0f7c
# ╟─03c1d9ee-9e19-11eb-37eb-474bae9bd176
# ╟─03c1db38-9e19-11eb-2517-253ea6478682
# ╟─03c1db56-9e19-11eb-2685-5149f4932dae
# ╟─03c1db7e-9e19-11eb-0f0f-bba078d07705
# ╠═03c22b92-9e19-11eb-1408-4d5916ea91d0
# ╠═03c22ba6-9e19-11eb-3c13-d392fc93bc8d
# ╠═03c22ba6-9e19-11eb-137e-57a14b4cca55
# ╠═03c22bb0-9e19-11eb-1938-0d7c7ba5f7f2
# ╠═03c22bd8-9e19-11eb-1434-f5328dde196e
# ╠═03c22bd8-9e19-11eb-13a6-1312e7bf67b7
# ╠═03c22be2-9e19-11eb-05cc-39ad070bfa73
# ╠═03c22be2-9e19-11eb-2048-a1326e156a6d
# ╠═03c22be2-9e19-11eb-0512-47fed713a96f
# ╠═03c22c0a-9e19-11eb-161c-699ab4d5d9f4
# ╠═03c22c14-9e19-11eb-274b-5399c7c6aa5e
# ╠═03c22c14-9e19-11eb-2158-f14f85a65597
# ╠═03c22c1e-9e19-11eb-3431-8dc13f4035a4
# ╠═03c22c28-9e19-11eb-2698-e157bd26dc8a
# ╠═03c22c28-9e19-11eb-2b8c-1bc2284ce14f
# ╠═03c22c34-9e19-11eb-03c5-2b1760e96638
# ╠═03c22c34-9e19-11eb-3bfc-49266db00617
# ╠═03c22c3c-9e19-11eb-0b01-3f3e556bbba5
# ╠═03c22c3c-9e19-11eb-124c-d74933c17cd9
# ╟─03c22d18-9e19-11eb-1c0b-b5ecf150a14c
# ╟─03c22d5e-9e19-11eb-2c72-69e07894faa4
# ╟─03c22db8-9e19-11eb-3ecd-65dd2351da03
# ╟─03c22dd6-9e19-11eb-3154-9ff21c178176
# ╠═03c23b3c-9e19-11eb-0837-4da6e7322f8e
# ╠═03c23b3c-9e19-11eb-3232-875595e186b0
# ╠═03c23b5a-9e19-11eb-205a-c1f2f6ab4e16
# ╠═03c23b5a-9e19-11eb-3950-e97840cc765f
# ╠═03c23b64-9e19-11eb-05c9-e79e8dab8a60
# ╠═03c23b64-9e19-11eb-2b66-b186efd7a22a
# ╠═03c23b64-9e19-11eb-3719-0ff913ff01f8
# ╠═03c23b76-9e19-11eb-3ba5-1f1297fa21f9
# ╠═03c23b76-9e19-11eb-0884-f53089dd27c9
# ╠═03c23b82-9e19-11eb-0399-a598da97cabe
# ╠═03c23b82-9e19-11eb-140b-ffeef605892f
# ╟─03c23ba8-9e19-11eb-2a61-a76cd6070684
# ╟─03c23bc8-9e19-11eb-1860-73d41462714e
# ╟─03c23be6-9e19-11eb-13b4-f7b7ce193646
# ╠═03c23d26-9e19-11eb-2b84-8ffc98200143
# ╟─03c23e5c-9e19-11eb-253a-b3811d4bc07e
# ╟─03c23eaa-9e19-11eb-3214-1522f21491c6
