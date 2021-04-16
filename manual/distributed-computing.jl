### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ c6e5fe1d-ba41-4945-ad7b-4b680456fc23
md"""
# Multi-processing and Distributed Computing
"""

# ╔═╡ f681ce72-b780-4f3c-9222-18487afe7472
md"""
An implementation of distributed memory parallel computing is provided by module `Distributed` as part of the standard library shipped with Julia.
"""

# ╔═╡ 1a9d8e6e-50bb-4206-a8f2-c69161e9d9be
md"""
Most modern computers possess more than one CPU, and several computers can be combined together in a cluster. Harnessing the power of these multiple CPUs allows many computations to be completed more quickly. There are two major factors that influence performance: the speed of the CPUs themselves, and the speed of their access to memory. In a cluster, it's fairly obvious that a given CPU will have fastest access to the RAM within the same computer (node). Perhaps more surprisingly, similar issues are relevant on a typical multicore laptop, due to differences in the speed of main memory and the [cache](https://www.akkadia.org/drepper/cpumemory.pdf). Consequently, a good multiprocessing environment should allow control over the \"ownership\" of a chunk of memory by a particular CPU. Julia provides a multiprocessing environment based on message passing to allow programs to run on multiple processes in separate memory domains at once.
"""

# ╔═╡ 1988621c-f102-4e7c-8f85-dffabc57dfc5
md"""
Julia's implementation of message passing is different from other environments such as MPI[^1]. Communication in Julia is generally \"one-sided\", meaning that the programmer needs to explicitly manage only one process in a two-process operation. Furthermore, these operations typically do not look like \"message send\" and \"message receive\" but rather resemble higher-level operations like calls to user functions.
"""

# ╔═╡ 43f2f59e-4fb7-4339-8030-16ae54c58b50
md"""
Distributed programming in Julia is built on two primitives: *remote references* and *remote calls*. A remote reference is an object that can be used from any process to refer to an object stored on a particular process. A remote call is a request by one process to call a certain function on certain arguments on another (possibly the same) process.
"""

# ╔═╡ 10e7a2b4-6f06-4e1e-92a9-fc0095665ea6
md"""
Remote references come in two flavors: [`Future`](@ref Distributed.Future) and [`RemoteChannel`](@ref).
"""

# ╔═╡ 229d4e58-90af-4343-b6f1-25d30fb36ba5
md"""
A remote call returns a [`Future`](@ref Distributed.Future) to its result. Remote calls return immediately; the process that made the call proceeds to its next operation while the remote call happens somewhere else. You can wait for a remote call to finish by calling [`wait`](@ref) on the returned [`Future`](@ref Distributed.Future), and you can obtain the full value of the result using [`fetch`](@ref).
"""

# ╔═╡ 12a64fbe-6fcb-4892-9d28-bb8cc2546c21
md"""
On the other hand, [`RemoteChannel`](@ref) s are rewritable. For example, multiple processes can co-ordinate their processing by referencing the same remote `Channel`.
"""

# ╔═╡ 31b5a98f-e026-4ed0-9ecb-7a8d90d57750
md"""
Each process has an associated identifier. The process providing the interactive Julia prompt always has an `id` equal to 1. The processes used by default for parallel operations are referred to as \"workers\". When there is only one process, process 1 is considered a worker. Otherwise, workers are considered to be all processes other than process 1. As a result, adding 2 or more processes is required to gain benefits from parallel processing methods like [`pmap`](@ref). Adding a single process is beneficial if you just wish to do other things in the main process while a long computation is running on the worker.
"""

# ╔═╡ 49681d9c-3cf2-4cd1-9a12-f68181987cce
md"""
Let's try this out. Starting with `julia -p n` provides `n` worker processes on the local machine. Generally it makes sense for `n` to equal the number of CPU threads (logical cores) on the machine. Note that the `-p` argument implicitly loads module `Distributed`.
"""

# ╔═╡ 50d1f217-bfd3-4ff6-b292-dd9d372ce115
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

# ╔═╡ 7bbc91dc-2750-4611-a44e-902dc7255a24
md"""
The first argument to [`remotecall`](@ref) is the function to call. Most parallel programming in Julia does not reference specific processes or the number of processes available, but [`remotecall`](@ref) is considered a low-level interface providing finer control. The second argument to [`remotecall`](@ref) is the `id` of the process that will do the work, and the remaining arguments will be passed to the function being called.
"""

# ╔═╡ 481e8894-c644-4c94-88e6-c2afd0fbc8e2
md"""
As you can see, in the first line we asked process 2 to construct a 2-by-2 random matrix, and in the second line we asked it to add 1 to it. The result of both calculations is available in the two futures, `r` and `s`. The [`@spawnat`](@ref) macro evaluates the expression in the second argument on the process specified by the first argument.
"""

# ╔═╡ 690c4343-75bc-4831-b27d-4834b3f2f411
md"""
Occasionally you might want a remotely-computed value immediately. This typically happens when you read from a remote object to obtain data needed by the next local operation. The function [`remotecall_fetch`](@ref) exists for this purpose. It is equivalent to `fetch(remotecall(...))` but is more efficient.
"""

# ╔═╡ 6903f8b8-9df4-4757-99bb-987ec5cb9063
remotecall_fetch(getindex, 2, r, 1, 1)

# ╔═╡ 9ac4a933-702e-459e-bf77-d4012026388f
md"""
Remember that [`getindex(r,1,1)`](@ref) is [equivalent](@ref man-array-indexing) to `r[1,1]`, so this call fetches the first element of the future `r`.
"""

# ╔═╡ 195c24de-b960-4695-b35e-643fc272a26a
md"""
To make things easier, the symbol `:any` can be passed to [`@spawnat`](@ref), which picks where to do the operation for you:
"""

# ╔═╡ 7d8241ec-c8b7-4031-8a64-998a115caaf7
r = @spawnat :any rand(2,2)

# ╔═╡ f1e17ff1-8a05-4cf0-97b3-e152c065585a
s = @spawnat :any 1 .+ fetch(r)

# ╔═╡ d5c95ff8-3971-4c5c-8723-04e35f02a60e
fetch(s)

# ╔═╡ 4ae9f602-5e0e-4193-a579-737a0779f2f6
md"""
Note that we used `1 .+ fetch(r)` instead of `1 .+ r`. This is because we do not know where the code will run, so in general a [`fetch`](@ref) might be required to move `r` to the process doing the addition. In this case, [`@spawnat`](@ref) is smart enough to perform the computation on the process that owns `r`, so the [`fetch`](@ref) will be a no-op (no work is done).
"""

# ╔═╡ 1614b558-e7ad-421c-bb62-6dd8074c97dd
md"""
(It is worth noting that [`@spawnat`](@ref) is not built-in but defined in Julia as a [macro](@ref man-macros). It is possible to define your own such constructs.)
"""

# ╔═╡ 4ef124f3-7157-4c2e-8123-cb0718deb751
md"""
An important thing to remember is that, once fetched, a [`Future`](@ref Distributed.Future) will cache its value locally. Further [`fetch`](@ref) calls do not entail a network hop. Once all referencing [`Future`](@ref Distributed.Future)s have fetched, the remote stored value is deleted.
"""

# ╔═╡ 508ebcd2-a456-459c-9644-1ccf5a89f256
md"""
[`@async`](@ref) is similar to [`@spawnat`](@ref), but only runs tasks on the local process. We use it to create a \"feeder\" task for each process. Each task picks the next index that needs to be computed, then waits for its process to finish, then repeats until we run out of indices. Note that the feeder tasks do not begin to execute until the main task reaches the end of the [`@sync`](@ref) block, at which point it surrenders control and waits for all the local tasks to complete before returning from the function. As for v0.7 and beyond, the feeder tasks are able to share state via `nextidx` because they all run on the same process. Even if `Tasks` are scheduled cooperatively, locking may still be required in some contexts, as in [asynchronous I/O](@ref faq-async-io). This means context switches only occur at well-defined points: in this case, when [`remotecall_fetch`](@ref) is called. This is the current state of implementation and it may change for future Julia versions, as it is intended to make it possible to run up to N `Tasks` on M `Process`, aka [M:N Threading](https://en.wikipedia.org/wiki/Thread_(computing)#Models). Then a lock acquiring\releasing model for `nextidx` will be needed, as it is not safe to let multiple processes read-write a resource at the same time.
"""

# ╔═╡ fd9a618d-916c-4deb-b982-b6de5e44315b
md"""
## [Code Availability and Loading Packages](@id code-availability)
"""

# ╔═╡ 06c19acc-c7a0-4d8f-9768-757385ab20c0
md"""
Your code must be available on any process that runs it. For example, type the following into the Julia prompt:
"""

# ╔═╡ ba6121ca-0f2d-4c99-a915-e636c96718d2
function rand2(dims...)
     return 2*rand(dims...)
 end

# ╔═╡ a9a9d1cc-f7bf-455d-989e-cff2f741c3df
rand2(2,2)

# ╔═╡ 32e40b0d-5588-4309-9925-2a06f1142cc7
fetch(@spawnat :any rand2(2,2))

# ╔═╡ ab9c9f7a-46c9-4d5f-9852-a6bce89fc970
md"""
Process 1 knew about the function `rand2`, but process 2 did not.
"""

# ╔═╡ a10619a2-9966-48a6-b95b-fde2ed110b4a
md"""
Most commonly you'll be loading code from files or packages, and you have a considerable amount of flexibility in controlling which processes load code. Consider a file, `DummyModule.jl`, containing the following code:
"""

# ╔═╡ a847d214-780c-48f0-80eb-19a322f5ab2a
md"""
```julia
module DummyModule

export MyType, f

mutable struct MyType
    a::Int
end

f(x) = x^2+1

println(\"loaded\")

end
```
"""

# ╔═╡ 8c783b0d-1f36-4608-a52c-3ebda0fe20bc
md"""
In order to refer to `MyType` across all processes, `DummyModule.jl` needs to be loaded on every process.  Calling `include(\"DummyModule.jl\")` loads it only on a single process.  To load it on every process, use the [`@everywhere`](@ref) macro (starting Julia with `julia -p 2`):
"""

# ╔═╡ 03bffbeb-7749-4c3b-82ef-9062a938d4a4
@everywhere include("DummyModule.jl")

# ╔═╡ cd2bcec4-10ff-4865-af5f-8ff78babfed9
md"""
As usual, this does not bring `DummyModule` into scope on any of the process, which requires `using` or `import`.  Moreover, when `DummyModule` is brought into scope on one process, it is not on any other:
"""

# ╔═╡ 2256d6b4-2ec8-4dff-9ebe-f7410b6eda8b
using .DummyModule

# ╔═╡ 67037560-35e9-4967-a9e9-59249e03a3f2
MyType(7)

# ╔═╡ ab0ec8bb-5724-4375-8ea8-8d441c77bb80
fetch(@spawnat 2 MyType(7))

# ╔═╡ 19984ede-e45d-4906-b510-263ac53c7d2b
fetch(@spawnat 2 DummyModule.MyType(7))

# ╔═╡ c82b9f57-dd2f-4023-9f5b-921ce823edc8
md"""
However, it's still possible, for instance, to send a `MyType` to a process which has loaded `DummyModule` even if it's not in scope:
"""

# ╔═╡ 895adce3-619f-4b2d-9f03-570e53b660b8
put!(RemoteChannel(2), MyType(7))

# ╔═╡ d842c4a9-f109-489b-b9e2-5c6577e87d31
md"""
A file can also be preloaded on multiple processes at startup with the `-L` flag, and a driver script can be used to drive the computation:
"""

# ╔═╡ 5c04186a-83b0-4fea-b511-58d1f4eaf18e
md"""
```
julia -p <n> -L file1.jl -L file2.jl driver.jl
```
"""

# ╔═╡ 8fff2f5b-1684-41a6-8470-59fdf366ed15
md"""
The Julia process running the driver script in the example above has an `id` equal to 1, just like a process providing an interactive prompt.
"""

# ╔═╡ e5066a21-f492-4906-97cc-3b372f229651
md"""
Finally, if `DummyModule.jl` is not a standalone file but a package, then `using DummyModule` will *load* `DummyModule.jl` on all processes, but only bring it into scope on the process where `using` was called.
"""

# ╔═╡ 27d4abe1-cf24-42d6-91a5-6ecd8c54eb12
md"""
## Starting and managing worker processes
"""

# ╔═╡ e66c670e-5f19-4935-8e27-cf690b57bdc8
md"""
The base Julia installation has in-built support for two types of clusters:
"""

# ╔═╡ 3dfcecf3-a3b6-448b-a24f-1ab9d503072a
md"""
  * A local cluster specified with the `-p` option as shown above.
  * A cluster spanning machines using the `--machine-file` option. This uses a passwordless `ssh` login to start Julia worker processes (from the same path as the current host) on the specified machines. Each machine definition takes the form `[count*][user@]host[:port] [bind_addr[:port]]`. `user` defaults to current user, `port` to the standard ssh port. `count` is the number of workers to spawn on the node, and defaults to 1. The optional `bind-to bind_addr[:port]` specifies the IP address and port that other workers should use to connect to this worker.
"""

# ╔═╡ 5119d425-6c0d-4315-8138-1b853bbfd9a0
md"""
Functions [`addprocs`](@ref), [`rmprocs`](@ref), [`workers`](@ref), and others are available as a programmatic means of adding, removing and querying the processes in a cluster.
"""

# ╔═╡ a06df0c8-3c5f-42cf-9269-404d8ae34c0a
using Distributed

# ╔═╡ cc3e344b-f66e-41b5-a7b5-3d00181d825e
addprocs(2)

# ╔═╡ 67a91643-4609-4ba5-8bfb-236c49562ca3
md"""
Module `Distributed` must be explicitly loaded on the master process before invoking [`addprocs`](@ref). It is automatically made available on the worker processes.
"""

# ╔═╡ 5d144cd9-2095-4b43-bae5-6478f531cc64
md"""
Note that workers do not run a `~/.julia/config/startup.jl` startup script, nor do they synchronize their global state (such as global variables, new method definitions, and loaded modules) with any of the other running processes. You may use `addprocs(exeflags=\"--project\")` to initialize a worker with a particular environment, and then `@everywhere using <modulename>` or `@everywhere include(\"file.jl\")`.
"""

# ╔═╡ b4eae10d-01c4-42ad-93f6-4efed2c08ea8
md"""
Other types of clusters can be supported by writing your own custom `ClusterManager`, as described below in the [ClusterManagers](@ref) section.
"""

# ╔═╡ ecaf392b-c1bd-4adf-9683-bae1ecfd42e4
md"""
## Data Movement
"""

# ╔═╡ 42893e32-8a52-42c7-9c53-4a1d73202207
md"""
Sending messages and moving data constitute most of the overhead in a distributed program. Reducing the number of messages and the amount of data sent is critical to achieving performance and scalability. To this end, it is important to understand the data movement performed by Julia's various distributed programming constructs.
"""

# ╔═╡ 4b8bafa5-a42a-4040-a1d5-38d7a545cabb
md"""
[`fetch`](@ref) can be considered an explicit data movement operation, since it directly asks that an object be moved to the local machine. [`@spawnat`](@ref) (and a few related constructs) also moves data, but this is not as obvious, hence it can be called an implicit data movement operation. Consider these two approaches to constructing and squaring a random matrix:
"""

# ╔═╡ 5849c8e8-a2ff-41c6-b074-a436d9aeeb3a
md"""
Method 1:
"""

# ╔═╡ 0eaf4eca-6099-4fff-9678-562483ea5bc4
A = rand(1000,1000);

# ╔═╡ 54b02098-9187-4141-b3a9-9d4cdaf97d31
Bref = @spawnat :any A^2;

# ╔═╡ ae67e4f5-b879-403c-b8be-d50afb91200f
fetch(Bref);

# ╔═╡ cb9e3760-a3fa-43db-8980-c179457a7499
md"""
Method 2:
"""

# ╔═╡ c49083e9-b165-4db0-a113-b4e4c77873a1
Bref = @spawnat :any rand(1000,1000)^2;

# ╔═╡ 805f4833-c149-41fc-b2b4-f9e3d293217e
fetch(Bref);

# ╔═╡ dbca6584-ffcc-4e08-880a-80dc155458cd
md"""
The difference seems trivial, but in fact is quite significant due to the behavior of [`@spawnat`](@ref). In the first method, a random matrix is constructed locally, then sent to another process where it is squared. In the second method, a random matrix is both constructed and squared on another process. Therefore the second method sends much less data than the first.
"""

# ╔═╡ 45df25b7-de78-44d7-a43d-c94e8788affa
md"""
In this toy example, the two methods are easy to distinguish and choose from. However, in a real program designing data movement might require more thought and likely some measurement. For example, if the first process needs matrix `A` then the first method might be better. Or, if computing `A` is expensive and only the current process has it, then moving it to another process might be unavoidable. Or, if the current process has very little to do between the [`@spawnat`](@ref) and `fetch(Bref)`, it might be better to eliminate the parallelism altogether. Or imagine `rand(1000,1000)` is replaced with a more expensive operation. Then it might make sense to add another [`@spawnat`](@ref) statement just for this step.
"""

# ╔═╡ a8274066-0af6-460c-a9ef-5595ff7854b9
md"""
## Global variables
"""

# ╔═╡ cd48eed6-43d3-4a9a-8ebb-5d84932edd3c
md"""
Expressions executed remotely via `@spawnat`, or closures specified for remote execution using `remotecall` may refer to global variables. Global bindings under module `Main` are treated a little differently compared to global bindings in other modules. Consider the following code snippet:
"""

# ╔═╡ 990375fb-b470-4404-8406-54f29cf08294
A = rand(10,10)

# ╔═╡ a6bc111c-5ed1-4647-9d06-adb6e686157a
md"""
In this case [`sum`](@ref) MUST be defined in the remote process. Note that `A` is a global variable defined in the local workspace. Worker 2 does not have a variable called `A` under `Main`. The act of shipping the closure `()->sum(A)` to worker 2 results in `Main.A` being defined on 2. `Main.A` continues to exist on worker 2 even after the call `remotecall_fetch` returns. Remote calls with embedded global references (under `Main` module only) manage globals as follows:
"""

# ╔═╡ aeec6caa-79f1-4c16-8c5e-cb6e94ef621b
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

# ╔═╡ 30b828e1-520a-4818-a7e5-08c6d54992b3
md"""
As you may have realized, while memory associated with globals may be collected when they are reassigned on the master, no such action is taken on the workers as the bindings continue to be valid. [`clear!`](@ref) can be used to manually reassign specific globals on remote nodes to `nothing` once they are no longer required. This will release any memory associated with them as part of a regular garbage collection cycle.
"""

# ╔═╡ 639cb887-5667-44f2-bf4e-3150f869152f
md"""
Thus programs should be careful referencing globals in remote calls. In fact, it is preferable to avoid them altogether if possible. If you must reference globals, consider using `let` blocks to localize global variables.
"""

# ╔═╡ 5c70a79d-0c77-428e-9d3b-8fec72fb8f18
md"""
For example:
"""

# ╔═╡ 7fb22f26-3143-48ac-8398-15f5ac3373f7
A = rand(10,10);

# ╔═╡ 612324fd-1f7c-48f0-8361-3d79c666dcba
remotecall_fetch(()->A, 2);

# ╔═╡ e5c61d0d-567c-449a-ac88-4b6cc5a5f112
B = rand(10,10);

# ╔═╡ e295b8e9-8f74-4935-91d8-922d6ea96ced
let B = B
     remotecall_fetch(()->B, 2)
 end;

# ╔═╡ ffc6304e-e680-463a-a2e3-d359cd4a2c30
@fetchfrom 2 InteractiveUtils.varinfo()

# ╔═╡ 5e350e78-c961-4f3c-bec4-f3d040b75365
md"""
As can be seen, global variable `A` is defined on worker 2, but `B` is captured as a local variable and hence a binding for `B` does not exist on worker 2.
"""

# ╔═╡ fee6ec57-8bbf-4158-b79a-48595d28f4da
md"""
## Parallel Map and Loops
"""

# ╔═╡ 0c3b88ab-5d08-488a-9c09-4ee66c6d96e0
md"""
Fortunately, many useful parallel computations do not require data movement. A common example is a Monte Carlo simulation, where multiple processes can handle independent simulation trials simultaneously. We can use [`@spawnat`](@ref) to flip coins on two processes. First, write the following function in `count_heads.jl`:
"""

# ╔═╡ d71f7673-7ed5-4037-9f1c-e7aa7c446ad6
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

# ╔═╡ 681a7c56-08a9-42f9-915e-5edb4652433a
md"""
The function `count_heads` simply adds together `n` random bits. Here is how we can perform some trials on two machines, and add together the results:
"""

# ╔═╡ 7fa594a8-1c26-4b87-9c85-bb0f5a5a596a
@everywhere include_string(Main, $(read("count_heads.jl", String)), "count_heads.jl")

# ╔═╡ ee44a442-469d-4965-9e42-b4ea9f698811
a = @spawnat :any count_heads(100000000)

# ╔═╡ 6ca94d87-0903-4814-afef-65d2c2aa234b
b = @spawnat :any count_heads(100000000)

# ╔═╡ fb4ac8fc-ec1b-4380-a384-00b97cd02a79
fetch(a)+fetch(b)

# ╔═╡ 4b0d2e4b-1835-4d91-82d7-3ba657c49363
md"""
This example demonstrates a powerful and often-used parallel programming pattern. Many iterations run independently over several processes, and then their results are combined using some function. The combination process is called a *reduction*, since it is generally tensor-rank-reducing: a vector of numbers is reduced to a single number, or a matrix is reduced to a single row or column, etc. In code, this typically looks like the pattern `x = f(x,v[i])`, where `x` is the accumulator, `f` is the reduction function, and the `v[i]` are the elements being reduced. It is desirable for `f` to be associative, so that it does not matter what order the operations are performed in.
"""

# ╔═╡ 4c07f290-7445-4a5a-8937-67244a562a8c
md"""
Notice that our use of this pattern with `count_heads` can be generalized. We used two explicit [`@spawnat`](@ref) statements, which limits the parallelism to two processes. To run on any number of processes, we can use a *parallel for loop*, running in distributed memory, which can be written in Julia using [`@distributed`](@ref) like this:
"""

# ╔═╡ 3b029245-c1e6-4172-a96a-d67e1c5d5a56
md"""
```julia
nheads = @distributed (+) for i = 1:200000000
    Int(rand(Bool))
end
```
"""

# ╔═╡ 990d89dc-44ae-437a-900d-5e810a738e1b
md"""
This construct implements the pattern of assigning iterations to multiple processes, and combining them with a specified reduction (in this case `(+)`). The result of each iteration is taken as the value of the last expression inside the loop. The whole parallel loop expression itself evaluates to the final answer.
"""

# ╔═╡ ad4c44cb-6cb3-4fd1-a459-dc2d5955ebfe
md"""
Note that although parallel for loops look like serial for loops, their behavior is dramatically different. In particular, the iterations do not happen in a specified order, and writes to variables or arrays will not be globally visible since iterations run on different processes. Any variables used inside the parallel loop will be copied and broadcast to each process.
"""

# ╔═╡ a5942cd9-696c-4acb-8eba-8465c73474be
md"""
For example, the following code will not work as intended:
"""

# ╔═╡ ff5f630d-0879-4de6-873b-6c5305ce9f6d
md"""
```julia
a = zeros(100000)
@distributed for i = 1:100000
    a[i] = i
end
```
"""

# ╔═╡ d9330e11-f960-4455-b725-160e1ac82ca8
md"""
This code will not initialize all of `a`, since each process will have a separate copy of it. Parallel for loops like these must be avoided. Fortunately, [Shared Arrays](@ref man-shared-arrays) can be used to get around this limitation:
"""

# ╔═╡ 90eafebc-8dba-4fcc-ae00-79e740587348
md"""
```julia
using SharedArrays

a = SharedArray{Float64}(10)
@distributed for i = 1:10
    a[i] = i
end
```
"""

# ╔═╡ e1595a2e-e379-48ff-90f1-30adeea2f870
md"""
Using \"outside\" variables in parallel loops is perfectly reasonable if the variables are read-only:
"""

# ╔═╡ e8091183-fc1c-4fdf-8af7-aa25fa317084
md"""
```julia
a = randn(1000)
@distributed (+) for i = 1:100000
    f(a[rand(1:end)])
end
```
"""

# ╔═╡ efa16e76-72a3-4b23-b020-b806dda10983
md"""
Here each iteration applies `f` to a randomly-chosen sample from a vector `a` shared by all processes.
"""

# ╔═╡ 7d0d15ca-c3cd-4101-9b29-218395a230eb
md"""
As you could see, the reduction operator can be omitted if it is not needed. In that case, the loop executes asynchronously, i.e. it spawns independent tasks on all available workers and returns an array of [`Future`](@ref Distributed.Future) immediately without waiting for completion. The caller can wait for the [`Future`](@ref Distributed.Future) completions at a later point by calling [`fetch`](@ref) on them, or wait for completion at the end of the loop by prefixing it with [`@sync`](@ref), like `@sync @distributed for`.
"""

# ╔═╡ 4dcdc27e-30aa-45bc-a8a3-2ba6546673bb
md"""
In some cases no reduction operator is needed, and we merely wish to apply a function to all integers in some range (or, more generally, to all elements in some collection). This is another useful operation called *parallel map*, implemented in Julia as the [`pmap`](@ref) function. For example, we could compute the singular values of several large random matrices in parallel as follows:
"""

# ╔═╡ ffa6e99a-8910-4cfc-b0bc-30e510a6bbf3
M = Matrix{Float64}[rand(1000,1000) for i = 1:10];

# ╔═╡ 2a24fadd-9579-4cc5-83de-2348c675b19d
pmap(svdvals, M);

# ╔═╡ 314ad4eb-2db0-4c5a-94b3-22de1f9a4aca
md"""
Julia's [`pmap`](@ref) is designed for the case where each function call does a large amount of work. In contrast, `@distributed for` can handle situations where each iteration is tiny, perhaps merely summing two numbers. Only worker processes are used by both [`pmap`](@ref) and `@distributed for` for the parallel computation. In case of `@distributed for`, the final reduction is done on the calling process.
"""

# ╔═╡ faff58b2-88d8-488b-aff8-5d9bf7e30dee
md"""
## Remote References and AbstractChannels
"""

# ╔═╡ c1a2de39-17bf-4d1f-9fc5-ace00e2f0d4a
md"""
Remote references always refer to an implementation of an `AbstractChannel`.
"""

# ╔═╡ 1bf842aa-70f9-4629-86b3-1b69bb997b5c
md"""
A concrete implementation of an `AbstractChannel` (like `Channel`), is required to implement [`put!`](@ref), [`take!`](@ref), [`fetch`](@ref), [`isready`](@ref) and [`wait`](@ref). The remote object referred to by a [`Future`](@ref Distributed.Future) is stored in a `Channel{Any}(1)`, i.e., a `Channel` of size 1 capable of holding objects of `Any` type.
"""

# ╔═╡ 81cd2bb3-8482-48dc-a74e-d343c50d4e92
md"""
[`RemoteChannel`](@ref), which is rewritable, can point to any type and size of channels, or any other implementation of an `AbstractChannel`.
"""

# ╔═╡ bc8444da-c33b-498c-b84b-99e0830cb33a
md"""
The constructor `RemoteChannel(f::Function, pid)()` allows us to construct references to channels holding more than one value of a specific type. `f` is a function executed on `pid` and it must return an `AbstractChannel`.
"""

# ╔═╡ 9d8abf73-4eff-4d1a-ae99-5cec0359f2e6
md"""
For example, `RemoteChannel(()->Channel{Int}(10), pid)`, will return a reference to a channel of type `Int` and size 10. The channel exists on worker `pid`.
"""

# ╔═╡ b3644b88-e6ae-45e1-ad8c-8ea4e0fd05a4
md"""
Methods [`put!`](@ref), [`take!`](@ref), [`fetch`](@ref), [`isready`](@ref) and [`wait`](@ref) on a [`RemoteChannel`](@ref) are proxied onto the backing store on the remote process.
"""

# ╔═╡ 64ccd5ad-cefd-43a6-85c9-ee63c1adf7b1
md"""
[`RemoteChannel`](@ref) can thus be used to refer to user implemented `AbstractChannel` objects. A simple example of this is provided in `dictchannel.jl` in the [Examples repository](https://github.com/JuliaAttic/Examples), which uses a dictionary as its remote store.
"""

# ╔═╡ daeec496-6476-4680-b815-6b7a8ec48bf1
md"""
## Channels and RemoteChannels
"""

# ╔═╡ 8e796df7-660a-44fc-b677-b68110ddf97c
md"""
  * A [`Channel`](@ref) is local to a process. Worker 2 cannot directly refer to a [`Channel`](@ref) on worker 3 and vice-versa. A [`RemoteChannel`](@ref), however, can put and take values across workers.
  * A [`RemoteChannel`](@ref) can be thought of as a *handle* to a [`Channel`](@ref).
  * The process id, `pid`, associated with a [`RemoteChannel`](@ref) identifies the process where the backing store, i.e., the backing [`Channel`](@ref) exists.
  * Any process with a reference to a [`RemoteChannel`](@ref) can put and take items from the channel. Data is automatically sent to (or retrieved from) the process a [`RemoteChannel`](@ref) is associated with.
  * Serializing  a [`Channel`](@ref) also serializes any data present in the channel. Deserializing it therefore effectively makes a copy of the original object.
  * On the other hand, serializing a [`RemoteChannel`](@ref) only involves the serialization of an identifier that identifies the location and instance of [`Channel`](@ref) referred to by the handle. A deserialized [`RemoteChannel`](@ref) object (on any worker), therefore also points to the same backing store as the original.
"""

# ╔═╡ 5d3ac97e-0969-4eec-ba4b-fef8ceb5a481
md"""
The channels example from above can be modified for interprocess communication, as shown below.
"""

# ╔═╡ 21d7f12e-644a-4736-b2e8-712a6dba96d9
md"""
We start 4 workers to process a single `jobs` remote channel. Jobs, identified by an id (`job_id`), are written to the channel. Each remotely executing task in this simulation reads a `job_id`, waits for a random amount of time and writes back a tuple of `job_id`, time taken and its own `pid` to the results channel. Finally all the `results` are printed out on the master process.
"""

# ╔═╡ 08e6f694-a7a1-4f0a-99ef-5014cf3d7e73
addprocs(4); # add worker processes

# ╔═╡ ab01ab95-10a7-4607-bca3-d866291e4c22
const jobs = RemoteChannel(()->Channel{Int}(32));

# ╔═╡ c0c728dc-d784-4867-af84-77cd7b09e8f3
const results = RemoteChannel(()->Channel{Tuple}(32));

# ╔═╡ 91dace82-62c8-4b2b-81b4-8b85fb6e6071
@everywhere function do_work(jobs, results) # define work function everywhere
     while true
         job_id = take!(jobs)
         exec_time = rand()
         sleep(exec_time) # simulates elapsed time doing actual work
         put!(results, (job_id, exec_time, myid()))
     end
 end

# ╔═╡ e27c8114-cbbd-4ac0-94f4-d3f37c84760f
function make_jobs(n)
     for i in 1:n
         put!(jobs, i)
     end
 end;

# ╔═╡ b64e8abf-0f34-4745-adca-5b1d3106eae9
n = 12;

# ╔═╡ 2e432c3e-19b8-4704-9464-b8769f337b50
@async make_jobs(n); # feed the jobs channel with "n" jobs

# ╔═╡ a731f554-c82d-4bbf-8271-f3875fe2eb92
for p in workers() # start tasks on the workers to process requests in parallel
     remote_do(do_work, p, jobs, results)
 end

# ╔═╡ d0b6502a-2fd7-48f9-94a8-411f7538800d
@elapsed while n > 0 # print out results
     job_id, exec_time, where = take!(results)
     println("$job_id finished in $(round(exec_time; digits=2)) seconds on worker $where")
     global n = n - 1
 end

# ╔═╡ 77428b00-43be-4369-8ec4-afe8f8c27149
md"""
### Remote References and Distributed Garbage Collection
"""

# ╔═╡ 460cd342-975b-48f7-9bad-182bd1791b3d
md"""
Objects referred to by remote references can be freed only when *all* held references in the cluster are deleted.
"""

# ╔═╡ 6e065f0d-7c04-4922-a08d-79b1e276f88c
md"""
The node where the value is stored keeps track of which of the workers have a reference to it. Every time a [`RemoteChannel`](@ref) or a (unfetched) [`Future`](@ref Distributed.Future) is serialized to a worker, the node pointed to by the reference is notified. And every time a [`RemoteChannel`](@ref) or a (unfetched) [`Future`](@ref Distributed.Future) is garbage collected locally, the node owning the value is again notified. This is implemented in an internal cluster aware serializer. Remote references are only valid in the context of a running cluster. Serializing and deserializing references to and from regular `IO` objects is not supported.
"""

# ╔═╡ 9763ba03-51cb-45a6-9d21-bee492434840
md"""
The notifications are done via sending of \"tracking\" messages–an \"add reference\" message when a reference is serialized to a different process and a \"delete reference\" message when a reference is locally garbage collected.
"""

# ╔═╡ d9e93364-82c3-4aac-a5d5-ba5a258a807f
md"""
Since [`Future`](@ref Distributed.Future)s are write-once and cached locally, the act of [`fetch`](@ref)ing a [`Future`](@ref Distributed.Future) also updates reference tracking information on the node owning the value.
"""

# ╔═╡ 61b9f981-7f6c-4e64-917b-10f04913e462
md"""
The node which owns the value frees it once all references to it are cleared.
"""

# ╔═╡ 19bfe3e4-7dfe-487a-97df-138f1605d5be
md"""
With [`Future`](@ref Distributed.Future)s, serializing an already fetched [`Future`](@ref Distributed.Future) to a different node also sends the value since the original remote store may have collected the value by this time.
"""

# ╔═╡ 9bdbfb82-679a-46dc-93c4-17e87305d72c
md"""
It is important to note that *when* an object is locally garbage collected depends on the size of the object and the current memory pressure in the system.
"""

# ╔═╡ abdc3a58-518e-493e-af1f-bdae3ec371de
md"""
In case of remote references, the size of the local reference object is quite small, while the value stored on the remote node may be quite large. Since the local object may not be collected immediately, it is a good practice to explicitly call [`finalize`](@ref) on local instances of a [`RemoteChannel`](@ref), or on unfetched [`Future`](@ref Distributed.Future)s. Since calling [`fetch`](@ref) on a [`Future`](@ref Distributed.Future) also removes its reference from the remote store, this is not required on fetched [`Future`](@ref Distributed.Future)s. Explicitly calling [`finalize`](@ref) results in an immediate message sent to the remote node to go ahead and remove its reference to the value.
"""

# ╔═╡ 7a25e342-6a1c-4706-90d9-876d3252254b
md"""
Once finalized, a reference becomes invalid and cannot be used in any further calls.
"""

# ╔═╡ eecb93d1-eb32-409a-ab0d-d09b0d097e76
md"""
## Local invocations
"""

# ╔═╡ 268e0e57-9f61-4aba-aad2-398a356c882e
md"""
Data is necessarily copied over to the remote node for execution. This is the case for both remotecalls and when data is stored to a[`RemoteChannel`](@ref) / [`Future`](@ref Distributed.Future) on a different node. As expected, this results in a copy of the serialized objects on the remote node. However, when the destination node is the local node, i.e. the calling process id is the same as the remote node id, it is executed as a local call. It is usually (not always) executed in a different task - but there is no serialization/deserialization of data. Consequently, the call refers to the same object instances as passed - no copies are created. This behavior is highlighted below:
"""

# ╔═╡ 16d3b6c2-5703-40ab-ada1-7772bedbdf3d
using Distributed;

# ╔═╡ 5fdca7d5-7895-419e-8027-db3f90638c7e
rc = RemoteChannel(()->Channel(3));   # RemoteChannel created on local node

# ╔═╡ 738bb4af-7290-4246-b846-cb2540fe786e
v = [0];

# ╔═╡ d132ffa5-8e5f-487d-a299-ea486b80aa0a
for i in 1:3
     v[1] = i                          # Reusing `v`
     put!(rc, v)
 end;

# ╔═╡ 72452acc-0226-4268-9520-d80f00a5933c
result = [take!(rc) for _ in 1:3];

# ╔═╡ 5568ff49-12f3-494b-a150-2dd1295cfcb2
println(result);

# ╔═╡ 6d8c0463-f06a-47a4-bfe0-54010e3f4abe
println("Num Unique objects : ", length(unique(map(objectid, result))));

# ╔═╡ 03aa8394-8405-4467-b5d3-253ddc949d20
addprocs(1);

# ╔═╡ 77af7f49-862d-4979-a410-04e53566eaae
rc = RemoteChannel(()->Channel(3), workers()[1]);   # RemoteChannel created on remote node

# ╔═╡ 4d5a6473-2be5-4c65-aa97-4b4a18fcbd45
v = [0];

# ╔═╡ 345a84f7-0bb2-47e9-a85a-2b8c31578a08
for i in 1:3
     v[1] = i
     put!(rc, v)
 end;

# ╔═╡ acbc3182-e63d-4dda-b7b5-e9db09b7b435
result = [take!(rc) for _ in 1:3];

# ╔═╡ 9b782aca-43cb-469d-adc3-6928bd8ea62b
println(result);

# ╔═╡ 381f30e2-5e2f-40c3-9b96-704165fbc4e2
println("Num Unique objects : ", length(unique(map(objectid, result))));

# ╔═╡ ff526128-3ef0-44d8-b814-bf50324fb117
md"""
As can be seen, [`put!`](@ref) on a locally owned [`RemoteChannel`](@ref) with the same object `v` modifed between calls results in the same single object instance stored. As opposed to copies of `v` being created when the node owning `rc` is a different node.
"""

# ╔═╡ dbc38629-c615-4af6-80d3-ee20ff127e78
md"""
It is to be noted that this is generally not an issue. It is something to be factored in only if the object is both being stored locally and modifed post the call. In such cases it may be appropriate to store a `deepcopy` of the object.
"""

# ╔═╡ 34f2b9c2-57e2-42c4-bf7d-309531f9675b
md"""
This is also true for remotecalls on the local node as seen in the following example:
"""

# ╔═╡ 9029b56f-4ea4-4ff9-9e8a-b95eef06e709
using Distributed; addprocs(1);

# ╔═╡ 71b35f60-3dd8-40a3-b54e-f65df2211df8
v = [0];

# ╔═╡ 075f074b-4cf1-43e2-9fde-58e89188078c
v2 = remotecall_fetch(x->(x[1] = 1; x), myid(), v);     # Executed on local node

# ╔═╡ 068b0859-b779-4e88-abdb-ac9957328a0d
println("v=$v, v2=$v2, ", v === v2);

# ╔═╡ 48ade339-1dc2-4417-ab5f-c09c5d7e36a1
v = [0];

# ╔═╡ 3463e794-fddb-4b8f-a76b-3ad88dd78499
v2 = remotecall_fetch(x->(x[1] = 1; x), workers()[1], v); # Executed on remote node

# ╔═╡ 880c6e40-3504-4ff1-9a50-f8b31d16c90d
println("v=$v, v2=$v2, ", v === v2);

# ╔═╡ 40bcb5ea-7b6e-4adc-b9de-0d7e003bd6fc
md"""
As can be seen once again, a remote call onto the local node behaves just like a direct invocation. The call modifies local objects passed as arguments. In the remote invocation, it operates on a copy of the arguments.
"""

# ╔═╡ cf30b540-85aa-471e-a06b-a7b0106db3ba
md"""
To repeat, in general this is not an issue. If the local node is also being used as a compute node, and the arguments used post the call, this behavior needs to be factored in and if required deep copies of arguments must be passed to the call invoked on the local node. Calls on remote nodes will always operate on copies of arguments.
"""

# ╔═╡ 067a8823-9066-43ed-b8cc-de5bb09b2cd6
md"""
## [Shared Arrays](@id man-shared-arrays)
"""

# ╔═╡ ae1c4d5c-0f10-4370-951d-630dbf88e33a
md"""
Shared Arrays use system shared memory to map the same array across many processes. While there are some similarities to a [`DArray`](https://github.com/JuliaParallel/DistributedArrays.jl), the behavior of a [`SharedArray`](@ref) is quite different. In a [`DArray`](https://github.com/JuliaParallel/DistributedArrays.jl), each process has local access to just a chunk of the data, and no two processes share the same chunk; in contrast, in a [`SharedArray`](@ref) each \"participating\" process has access to the entire array.  A [`SharedArray`](@ref) is a good choice when you want to have a large amount of data jointly accessible to two or more processes on the same machine.
"""

# ╔═╡ c9c3d18a-d7a2-4601-84d8-d738477db177
md"""
Shared Array support is available via module `SharedArrays` which must be explicitly loaded on all participating workers.
"""

# ╔═╡ 7d7bc3f7-ceb1-48d8-8f64-6b589108530b
md"""
[`SharedArray`](@ref) indexing (assignment and accessing values) works just as with regular arrays, and is efficient because the underlying memory is available to the local process. Therefore, most algorithms work naturally on [`SharedArray`](@ref)s, albeit in single-process mode. In cases where an algorithm insists on an [`Array`](@ref) input, the underlying array can be retrieved from a [`SharedArray`](@ref) by calling [`sdata`](@ref). For other `AbstractArray` types, [`sdata`](@ref) just returns the object itself, so it's safe to use [`sdata`](@ref) on any `Array`-type object.
"""

# ╔═╡ 3b4cf984-21f3-4f07-aa83-9441e708dc4e
md"""
The constructor for a shared array is of the form:
"""

# ╔═╡ ae9ae3fa-d438-4c7e-9f91-884c89aabcd6
md"""
```julia
SharedArray{T,N}(dims::NTuple; init=false, pids=Int[])
```
"""

# ╔═╡ c9ba2caa-ce4c-4e14-bc99-e212bc1b3d62
md"""
which creates an `N`-dimensional shared array of a bits type `T` and size `dims` across the processes specified by `pids`. Unlike distributed arrays, a shared array is accessible only from those participating workers specified by the `pids` named argument (and the creating process too, if it is on the same host). Note that only elements that are [`isbits`](@ref) are supported in a SharedArray.
"""

# ╔═╡ 27bc4542-a30e-477e-8eed-2497b1d944c1
md"""
If an `init` function, of signature `initfn(S::SharedArray)`, is specified, it is called on all the participating workers. You can specify that each worker runs the `init` function on a distinct portion of the array, thereby parallelizing initialization.
"""

# ╔═╡ da9fa57a-ba4f-4178-8e74-a5a668f3dd69
md"""
Here's a brief example:
"""

# ╔═╡ fad2930a-706e-4b22-9cc9-49e52d2b72be
using Distributed

# ╔═╡ 2411e053-321b-46e6-80f0-5db19146b936
addprocs(3)

# ╔═╡ da80439c-94e0-454d-9f5a-3af4a42e8d33
@everywhere using SharedArrays

# ╔═╡ f44d18ed-d0b5-4736-a99c-87c86ea26dbd
S = SharedArray{Int,2}((3,4), init = S -> S[localindices(S)] = repeat([myid()], length(localindices(S))))

# ╔═╡ d2bcba03-21b6-4d7c-b26f-22012ed67112
S[3,2] = 7

# ╔═╡ c409391f-1ae2-48fd-8a75-7f4484ddb74b
S

# ╔═╡ bef69002-a4a4-4c00-9f82-04cca6231048
md"""
[`SharedArrays.localindices`](@ref) provides disjoint one-dimensional ranges of indices, and is sometimes convenient for splitting up tasks among processes. You can, of course, divide the work any way you wish:
"""

# ╔═╡ b7f5c0c6-1a61-4724-956f-47a64dba4970
S = SharedArray{Int,2}((3,4), init = S -> S[indexpids(S):length(procs(S)):length(S)] = repeat([myid()], length( indexpids(S):length(procs(S)):length(S))))

# ╔═╡ f77f689d-f983-414c-a8f8-ab9b8546109f
md"""
Since all processes have access to the underlying data, you do have to be careful not to set up conflicts. For example:
"""

# ╔═╡ 7bc8f230-25c7-4ed2-8954-46884dc1052d
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

# ╔═╡ 8a2fdad4-93a4-4554-a50d-16d65058e85b
md"""
would result in undefined behavior. Because each process fills the *entire* array with its own `pid`, whichever process is the last to execute (for any particular element of `S`) will have its `pid` retained.
"""

# ╔═╡ 964ca292-eb6f-43b8-a3d9-249c89c50930
md"""
As a more extended and complex example, consider running the following \"kernel\" in parallel:
"""

# ╔═╡ c31d24c3-ebbd-4624-adcb-68c2212ce222
md"""
```julia
q[i,j,t+1] = q[i,j,t] + u[i,j,t]
```
"""

# ╔═╡ 9897c342-be95-45b8-b6bd-eabdc5aa3853
md"""
In this case, if we try to split up the work using a one-dimensional index, we are likely to run into trouble: if `q[i,j,t]` is near the end of the block assigned to one worker and `q[i,j,t+1]` is near the beginning of the block assigned to another, it's very likely that `q[i,j,t]` will not be ready at the time it's needed for computing `q[i,j,t+1]`. In such cases, one is better off chunking the array manually. Let's split along the second dimension. Define a function that returns the `(irange, jrange)` indices assigned to this worker:
"""

# ╔═╡ cec410a8-ebae-4b21-9355-f05ce1f5630e
@everywhere function myrange(q::SharedArray)
     idx = indexpids(q)
     if idx == 0 # This worker is not assigned a piece
         return 1:0, 1:0
     end
     nchunks = length(procs(q))
     splits = [round(Int, s) for s in range(0, stop=size(q,2), length=nchunks+1)]
     1:size(q,1), splits[idx]+1:splits[idx+1]
 end

# ╔═╡ e65159ce-cb5a-430e-acb2-f94707ff7f0b
md"""
Next, define the kernel:
"""

# ╔═╡ 49d88ccd-6d33-482d-8a68-f3536cf6220e
@everywhere function advection_chunk!(q, u, irange, jrange, trange)
     @show (irange, jrange, trange)  # display so we can see what's happening
     for t in trange, j in jrange, i in irange
         q[i,j,t+1] = q[i,j,t] + u[i,j,t]
     end
     q
 end

# ╔═╡ e8234db9-94fd-4200-afdc-a49ca439b3de
md"""
We also define a convenience wrapper for a `SharedArray` implementation
"""

# ╔═╡ bf671d6f-b05d-4b89-b6ad-f8717e36635d
@everywhere advection_shared_chunk!(q, u) =
     advection_chunk!(q, u, myrange(q)..., 1:size(q,3)-1)

# ╔═╡ 28b28295-2807-4f1a-98d2-18f11c67aa3c
md"""
Now let's compare three different versions, one that runs in a single process:
"""

# ╔═╡ 1924da9a-d6fe-44c5-9873-cbc1036d6984
advection_serial!(q, u) = advection_chunk!(q, u, 1:size(q,1), 1:size(q,2), 1:size(q,3)-1);

# ╔═╡ 2048ba6a-58a0-4a81-b67f-8deedd621328
md"""
one that uses [`@distributed`](@ref):
"""

# ╔═╡ 6ec839e1-9a5e-48c0-8956-1b935c68629b
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

# ╔═╡ 2d891336-86be-4ce6-a5c4-2aaa5f0caba0
md"""
and one that delegates in chunks:
"""

# ╔═╡ da1e89a1-f67e-4afc-8717-773e6080c6b1
function advection_shared!(q, u)
     @sync begin
         for p in procs(q)
             @async remotecall_wait(advection_shared_chunk!, p, q, u)
         end
     end
     q
 end;

# ╔═╡ d605e4cb-7212-4966-a3ad-01774f8b7df3
md"""
If we create `SharedArray`s and time these functions, we get the following results (with `julia -p 4`):
"""

# ╔═╡ 9e198f6e-f9f1-43a7-879d-fe41d2354a38
q = SharedArray{Float64,3}((500,500,500));

# ╔═╡ 38d36d1b-6bc3-4e4e-8f30-fee2a1d9200f
u = SharedArray{Float64,3}((500,500,500));

# ╔═╡ db6dbac0-1020-4819-936d-a2cb73f0a282
md"""
Run the functions once to JIT-compile and [`@time`](@ref) them on the second run:
"""

# ╔═╡ 5aacccc0-d4c3-4d2c-a94a-ea7814c9b60f
@time advection_serial!(q, u);

# ╔═╡ 8024d250-4032-447a-a49d-b99279379862
@time advection_parallel!(q, u);

# ╔═╡ 88624f31-23a7-4f60-8f19-4901e7bcba98
@time advection_shared!(q,u);

# ╔═╡ 9cd17a7b-e9bb-4d65-b564-9eaf74e5a040
md"""
The biggest advantage of `advection_shared!` is that it minimizes traffic among the workers, allowing each to compute for an extended time on the assigned piece.
"""

# ╔═╡ 54d76f79-0225-4096-b3e8-327b2f8024f8
md"""
### Shared Arrays and Distributed Garbage Collection
"""

# ╔═╡ e8eb7495-71fb-47af-91c7-8c1b57a89fa4
md"""
Like remote references, shared arrays are also dependent on garbage collection on the creating node to release references from all participating workers. Code which creates many short lived shared array objects would benefit from explicitly finalizing these objects as soon as possible. This results in both memory and file handles mapping the shared segment being released sooner.
"""

# ╔═╡ 2f4d3b33-1873-4c23-90cf-b54d23777096
md"""
## ClusterManagers
"""

# ╔═╡ ea680a39-99ff-47de-8bcd-97e4bd2eb9f1
md"""
The launching, management and networking of Julia processes into a logical cluster is done via cluster managers. A `ClusterManager` is responsible for
"""

# ╔═╡ c9526cf8-77d0-4b0a-9e6d-903d6ac29efd
md"""
  * launching worker processes in a cluster environment
  * managing events during the lifetime of each worker
  * optionally, providing data transport
"""

# ╔═╡ 80a0c031-bcd3-4024-8168-e47a70ce4b4c
md"""
A Julia cluster has the following characteristics:
"""

# ╔═╡ 276794be-4474-490e-99fb-0d815d724f05
md"""
  * The initial Julia process, also called the `master`, is special and has an `id` of 1.
  * Only the `master` process can add or remove worker processes.
  * All processes can directly communicate with each other.
"""

# ╔═╡ dd85dd42-c37c-4208-b4a9-732d6516a70d
md"""
Connections between workers (using the in-built TCP/IP transport) is established in the following manner:
"""

# ╔═╡ e3dde89c-77ce-41af-90b7-698c4100fb1a
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

# ╔═╡ feb33c42-f6ea-4ebd-920d-525bda4e4576
md"""
While the default transport layer uses plain [`TCPSocket`](@ref), it is possible for a Julia cluster to provide its own transport.
"""

# ╔═╡ 7191d450-1658-4f83-9035-0637a8ac6c88
md"""
Julia provides two in-built cluster managers:
"""

# ╔═╡ 7c7a0b8c-c29c-41e2-aba8-607630a8b1e7
md"""
  * `LocalManager`, used when [`addprocs()`](@ref) or [`addprocs(np::Integer)`](@ref) are called
  * `SSHManager`, used when [`addprocs(hostnames::Array)`](@ref) is called with a list of hostnames
"""

# ╔═╡ 13dac033-127d-4ce6-9df2-b3dd814173c9
md"""
`LocalManager` is used to launch additional workers on the same host, thereby leveraging multi-core and multi-processor hardware.
"""

# ╔═╡ eff4c1f4-ced7-4fd2-8e24-c3bfc59eeb3b
md"""
Thus, a minimal cluster manager would need to:
"""

# ╔═╡ 9e2dc2bc-0e4f-49d2-b6d8-2ef5df650f10
md"""
  * be a subtype of the abstract `ClusterManager`
  * implement [`launch`](@ref), a method responsible for launching new workers
  * implement [`manage`](@ref), which is called at various events during a worker's lifetime (for example, sending an interrupt signal)
"""

# ╔═╡ 02c43911-71d2-4e33-bce4-ea19a3f961ac
md"""
[`addprocs(manager::FooManager)`](@ref addprocs) requires `FooManager` to implement:
"""

# ╔═╡ 1cee731c-e712-4dfd-a8d4-6115c8976ffb
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

# ╔═╡ 59f2b74e-e3af-4f58-a8e9-c2d1e6acc70f
md"""
As an example let us see how the `LocalManager`, the manager responsible for starting workers on the same host, is implemented:
"""

# ╔═╡ 2c81744b-7c26-4f65-8d09-c544a37c72fa
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

# ╔═╡ a9cd1a1f-fe41-40ae-9d71-9a2519dbef8e
md"""
The [`launch`](@ref) method takes the following arguments:
"""

# ╔═╡ a0829de0-ab24-4a99-a7ac-45249a92a113
md"""
  * `manager::ClusterManager`: the cluster manager that [`addprocs`](@ref) is called with
  * `params::Dict`: all the keyword arguments passed to [`addprocs`](@ref)
  * `launched::Array`: the array to append one or more `WorkerConfig` objects to
  * `c::Condition`: the condition variable to be notified as and when workers are launched
"""

# ╔═╡ 691b804f-d950-4c23-9f4f-0076d7b5a0e0
md"""
The [`launch`](@ref) method is called asynchronously in a separate task. The termination of this task signals that all requested workers have been launched. Hence the [`launch`](@ref) function MUST exit as soon as all the requested workers have been launched.
"""

# ╔═╡ 49840359-603d-4ae6-bcd9-2adc9e4f1a50
md"""
Newly launched workers are connected to each other and the master process in an all-to-all manner. Specifying the command line argument `--worker[=<cookie>]` results in the launched processes initializing themselves as workers and connections being set up via TCP/IP sockets.
"""

# ╔═╡ 89de6e62-4c76-4bd7-9996-bcc01f681c1e
md"""
All workers in a cluster share the same [cookie](@ref man-cluster-cookie) as the master. When the cookie is unspecified, i.e, with the `--worker` option, the worker tries to read it from its standard input.  `LocalManager` and `SSHManager` both pass the cookie to newly launched workers via their  standard inputs.
"""

# ╔═╡ 315377f1-c0d6-41b9-bc61-0ddfd82bb9c5
md"""
By default a worker will listen on a free port at the address returned by a call to [`getipaddr()`](@ref). A specific address to listen on may be specified by optional argument `--bind-to bind_addr[:port]`. This is useful for multi-homed hosts.
"""

# ╔═╡ 51af2bcc-9d06-4080-a694-c504c0b274e3
md"""
As an example of a non-TCP/IP transport, an implementation may choose to use MPI, in which case `--worker` must NOT be specified. Instead, newly launched workers should call `init_worker(cookie)` before using any of the parallel constructs.
"""

# ╔═╡ 11f8a797-ab65-4399-b410-2412175333b4
md"""
For every worker launched, the [`launch`](@ref) method must add a `WorkerConfig` object (with appropriate fields initialized) to `launched`
"""

# ╔═╡ 60dbe822-fca8-4992-923a-e23b64711dd8
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

# ╔═╡ fc250748-e3cf-4e9c-873c-12d4d50e2240
md"""
Most of the fields in `WorkerConfig` are used by the inbuilt managers. Custom cluster managers would typically specify only `io` or `host` / `port`:
"""

# ╔═╡ 733278b6-a4ad-4d31-80fc-1cb4862fed1f
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

# ╔═╡ f9e730d5-b2f9-4013-be59-31f732e87c93
md"""
`manage(manager::FooManager, id::Integer, config::WorkerConfig, op::Symbol)` is called at different times during the worker's lifetime with appropriate `op` values:
"""

# ╔═╡ e4e4f785-ebf8-4734-a022-3e630bc2028d
md"""
  * with `:register`/`:deregister` when a worker is added / removed from the Julia worker pool.
  * with `:interrupt` when `interrupt(workers)` is called. The `ClusterManager` should signal the appropriate worker with an interrupt signal.
  * with `:finalize` for cleanup purposes.
"""

# ╔═╡ 39f7ed8d-8196-4355-b703-073cec792136
md"""
### Cluster Managers with Custom Transports
"""

# ╔═╡ 76f7947b-d118-4c54-b9bd-88c507c97392
md"""
Replacing the default TCP/IP all-to-all socket connections with a custom transport layer is a little more involved. Each Julia process has as many communication tasks as the workers it is connected to. For example, consider a Julia cluster of 32 processes in an all-to-all mesh network:
"""

# ╔═╡ b0a71e90-1b7d-47e2-a737-9369c9d78e2b
md"""
  * Each Julia process thus has 31 communication tasks.
  * Each task handles all incoming messages from a single remote worker in a message-processing loop.
  * The message-processing loop waits on an `IO` object (for example, a [`TCPSocket`](@ref) in the default implementation), reads an entire message, processes it and waits for the next one.
  * Sending messages to a process is done directly from any Julia task–not just communication tasks–again, via the appropriate `IO` object.
"""

# ╔═╡ 96d2d7fe-00b4-4bab-a998-beee7f730764
md"""
Replacing the default transport requires the new implementation to set up connections to remote workers and to provide appropriate `IO` objects that the message-processing loops can wait on. The manager-specific callbacks to be implemented are:
"""

# ╔═╡ a166bd57-6d9c-41af-95ee-3a77f01d2859
md"""
```julia
connect(manager::FooManager, pid::Integer, config::WorkerConfig)
kill(manager::FooManager, pid::Int, config::WorkerConfig)
```
"""

# ╔═╡ 2eaba9a5-3526-4baa-be4b-5e2ade0b3037
md"""
The default implementation (which uses TCP/IP sockets) is implemented as `connect(manager::ClusterManager, pid::Integer, config::WorkerConfig)`.
"""

# ╔═╡ ae7f5538-5818-4404-b65a-bd510540c508
md"""
`connect` should return a pair of `IO` objects, one for reading data sent from worker `pid`, and the other to write data that needs to be sent to worker `pid`. Custom cluster managers can use an in-memory `BufferStream` as the plumbing to proxy data between the custom, possibly non-`IO` transport and Julia's in-built parallel infrastructure.
"""

# ╔═╡ 9d970885-e4b4-40ed-9394-290a5e7a280c
md"""
A `BufferStream` is an in-memory [`IOBuffer`](@ref) which behaves like an `IO`–it is a stream which can be handled asynchronously.
"""

# ╔═╡ 8785d2fa-9746-42eb-8ac3-efd9c6b1760c
md"""
The folder `clustermanager/0mq` in the [Examples repository](https://github.com/JuliaAttic/Examples) contains an example of using ZeroMQ to connect Julia workers in a star topology with a 0MQ broker in the middle. Note: The Julia processes are still all *logically* connected to each other–any worker can message any other worker directly without any awareness of 0MQ being used as the transport layer.
"""

# ╔═╡ a9796971-63ef-4ab8-a431-5af4092473ff
md"""
When using custom transports:
"""

# ╔═╡ 3f635c26-82b1-4bb4-a0e1-11e6ee0b80bd
md"""
  * Julia workers must NOT be started with `--worker`. Starting with `--worker` will result in the newly launched workers defaulting to the TCP/IP socket transport implementation.
  * For every incoming logical connection with a worker, `Base.process_messages(rd::IO, wr::IO)()` must be called. This launches a new task that handles reading and writing of messages from/to the worker represented by the `IO` objects.
  * `init_worker(cookie, manager::FooManager)` *must* be called as part of worker process initialization.
  * Field `connect_at::Any` in `WorkerConfig` can be set by the cluster manager when [`launch`](@ref) is called. The value of this field is passed in all [`connect`](@ref) callbacks. Typically, it carries information on *how to connect* to a worker. For example, the TCP/IP socket transport uses this field to specify the `(host, port)` tuple at which to connect to a worker.
"""

# ╔═╡ 7f2f21b3-65c3-4f04-bc8f-47a87130db29
md"""
`kill(manager, pid, config)` is called to remove a worker from the cluster. On the master process, the corresponding `IO` objects must be closed by the implementation to ensure proper cleanup. The default implementation simply executes an `exit()` call on the specified remote worker.
"""

# ╔═╡ b10e3ab8-c7af-4c35-9992-15c604ca1680
md"""
The Examples folder `clustermanager/simple` is an example that shows a simple implementation using UNIX domain sockets for cluster setup.
"""

# ╔═╡ ccd6b3c8-61d5-4123-a117-51fa8ef179fc
md"""
### Network Requirements for LocalManager and SSHManager
"""

# ╔═╡ d2952435-09d4-44ca-a34e-36a397f7abd5
md"""
Julia clusters are designed to be executed on already secured environments on infrastructure such as local laptops, departmental clusters, or even the cloud. This section covers network security requirements for the inbuilt `LocalManager` and `SSHManager`:
"""

# ╔═╡ 3e84064d-a39e-410a-9bad-12b658423749
md"""
  * The master process does not listen on any port. It only connects out to the workers.
  * Each worker binds to only one of the local interfaces and listens on an ephemeral port number assigned by the OS.
  * `LocalManager`, used by `addprocs(N)`, by default binds only to the loopback interface. This means that workers started later on remote hosts (or by anyone with malicious intentions) are unable to connect to the cluster. An `addprocs(4)` followed by an `addprocs([\"remote_host\"])` will fail. Some users may need to create a cluster comprising their local system and a few remote systems. This can be done by explicitly requesting `LocalManager` to bind to an external network interface via the `restrict` keyword argument: `addprocs(4; restrict=false)`.
  * `SSHManager`, used by `addprocs(list_of_remote_hosts)`, launches workers on remote hosts via SSH. By default SSH is only used to launch Julia workers. Subsequent master-worker and worker-worker connections use plain, unencrypted TCP/IP sockets. The remote hosts must have passwordless login enabled. Additional SSH flags or credentials may be specified via keyword argument `sshflags`.
  * `addprocs(list_of_remote_hosts; tunnel=true, sshflags=<ssh keys and other flags>)` is useful when we wish to use SSH connections for master-worker too. A typical scenario for this is a local laptop running the Julia REPL (i.e., the master) with the rest of the cluster on the cloud, say on Amazon EC2. In this case only port 22 needs to be opened at the remote cluster coupled with SSH client authenticated via public key infrastructure (PKI). Authentication credentials can be supplied via `sshflags`, for example ```sshflags=`-i <keyfile>` ```.

    In an all-to-all topology (the default), all workers connect to each other via plain TCP sockets. The security policy on the cluster nodes must thus ensure free connectivity between workers for the ephemeral port range (varies by OS).

    Securing and encrypting all worker-worker traffic (via SSH) or encrypting individual messages can be done via a custom `ClusterManager`.
  * If you specify `multiplex=true` as an option to `addprocs`, SSH multiplexing is used to create a tunnel between the master and workers. If you have configured SSH multiplexing on your own and the connection has already been established, SSH multiplexing is used regardless of `multiplex` option. If multiplexing is enabled, forwarding is set by using the existing connection (`-O forward` option in ssh). This is beneficial if your servers require password authentication; you can avoid authentication in Julia by logging in to the server ahead of `addprocs`. The control socket will be located at `~/.ssh/julia-%r@%h:%p` during the session unless the existing multiplexing connection is used. Note that bandwidth may be limited if you create multiple processes on a node and enable multiplexing, because in that case processes share a single multiplexing TCP connection.
"""

# ╔═╡ 2671d504-ddd2-43fd-a976-b8f1d4acf954
md"""
### [Cluster Cookie](@id man-cluster-cookie)
"""

# ╔═╡ 5afbe858-a1eb-422a-966e-709fe4357274
md"""
All processes in a cluster share the same cookie which, by default, is a randomly generated string on the master process:
"""

# ╔═╡ f26cc18a-0532-4076-9c9f-a394b6a92e4f
md"""
  * [`cluster_cookie()`](@ref) returns the cookie, while `cluster_cookie(cookie)()` sets it and returns the new cookie.
  * All connections are authenticated on both sides to ensure that only workers started by the master are allowed to connect to each other.
  * The cookie may be passed to the workers at startup via argument `--worker=<cookie>`. If argument `--worker` is specified without the cookie, the worker tries to read the cookie from its standard input ([`stdin`](@ref)). The `stdin` is closed immediately after the cookie is retrieved.
  * `ClusterManager`s can retrieve the cookie on the master by calling [`cluster_cookie()`](@ref). Cluster managers not using the default TCP/IP transport (and hence not specifying `--worker`) must call `init_worker(cookie, manager)` with the same cookie as on the master.
"""

# ╔═╡ 586cff51-6f98-4a71-976d-c7619d324020
md"""
Note that environments requiring higher levels of security can implement this via a custom `ClusterManager`. For example, cookies can be pre-shared and hence not specified as a startup argument.
"""

# ╔═╡ cf7bc277-41c5-4a40-be20-4ba7341bb146
md"""
## Specifying Network Topology (Experimental)
"""

# ╔═╡ ddd06016-2782-44f0-8ebc-b457a5dbf726
md"""
The keyword argument `topology` passed to `addprocs` is used to specify how the workers must be connected to each other:
"""

# ╔═╡ 7d8a52f6-2ea7-49ca-8e08-89ffa08097cb
md"""
  * `:all_to_all`, the default: all workers are connected to each other.
  * `:master_worker`: only the driver process, i.e. `pid` 1, has connections to the workers.
  * `:custom`: the `launch` method of the cluster manager specifies the connection topology via the fields `ident` and `connect_idents` in `WorkerConfig`. A worker with a cluster-manager-provided identity `ident` will connect to all workers specified in `connect_idents`.
"""

# ╔═╡ 52f9d7ec-75a4-4a40-9c9a-916973349359
md"""
Keyword argument `lazy=true|false` only affects `topology` option `:all_to_all`. If `true`, the cluster starts off with the master connected to all workers. Specific worker-worker connections are established at the first remote invocation between two workers. This helps in reducing initial resources allocated for intra-cluster communication. Connections are setup depending on the runtime requirements of a parallel program. Default value for `lazy` is `true`.
"""

# ╔═╡ 658f7519-33a7-4b15-b8c7-42606ad3f965
md"""
Currently, sending a message between unconnected workers results in an error. This behaviour, as with the functionality and interface, should be considered experimental in nature and may change in future releases.
"""

# ╔═╡ 6960c763-ef20-4b30-9013-b5bec36b998b
md"""
## Noteworthy external packages
"""

# ╔═╡ 5c19cf55-f975-45b9-b2dc-979876a0ef1d
md"""
Outside of Julia parallelism there are plenty of external packages that should be mentioned. For example [MPI.jl](https://github.com/JuliaParallel/MPI.jl) is a Julia wrapper for the `MPI` protocol, or [DistributedArrays.jl](https://github.com/JuliaParallel/Distributedarrays.jl), as presented in [Shared Arrays](@ref). A mention must be made of Julia's GPU programming ecosystem, which includes:
"""

# ╔═╡ ab719c1e-fce3-41c0-9b4f-12abc5480bea
md"""
1. Low-level (C kernel) based operations [OpenCL.jl](https://github.com/JuliaGPU/OpenCL.jl) and [CUDAdrv.jl](https://github.com/JuliaGPU/CUDAdrv.jl) which are respectively an OpenCL interface and a CUDA wrapper.
2. Low-level (Julia Kernel) interfaces like [CUDAnative.jl](https://github.com/JuliaGPU/CUDAnative.jl) which is a Julia native CUDA implementation.
3. High-level vendor-specific abstractions like [CuArrays.jl](https://github.com/JuliaGPU/CuArrays.jl) and [CLArrays.jl](https://github.com/JuliaGPU/CLArrays.jl)
4. High-level libraries like [ArrayFire.jl](https://github.com/JuliaComputing/ArrayFire.jl) and [GPUArrays.jl](https://github.com/JuliaGPU/GPUArrays.jl)
"""

# ╔═╡ bd9f23ce-322b-4460-a86a-08ec64791a2e
md"""
In the following example we will use both `DistributedArrays.jl` and `CuArrays.jl` to distribute an array across multiple processes by first casting it through `distribute()` and `CuArray()`.
"""

# ╔═╡ 569a36b5-74fc-43d0-ab71-ff8139e3acdb
md"""
Remember when importing `DistributedArrays.jl` to import it across all processes using [`@everywhere`](@ref)
"""

# ╔═╡ 720db8ba-8dc5-4931-922d-ef0199a9b718
$ ./julia

# ╔═╡ 25d89d32-57b6-4398-8687-6cafa49711f9
addprocs()

# ╔═╡ b8267df5-d936-4207-98b4-3e0c09fed4b1
@everywhere using DistributedArrays

# ╔═╡ e9f6b771-4fd3-4c27-adee-87680dd55a58
using CuArrays

# ╔═╡ 741a0104-5662-4174-ae48-d7f8e35a8fd4
B = ones(10_000) ./ 2;

# ╔═╡ 5ab0df8a-07b1-405f-aad3-fc675b114bdb
A = ones(10_000) .* π;

# ╔═╡ 6fade9e3-8f86-4c16-b00a-3dcbc9e1a46e
C = 2 .* A ./ B;

# ╔═╡ d5af1755-ce2a-49b1-b446-73ed72f5e88b
all(C .≈ 4*π)

# ╔═╡ 7d04277f-34d8-4d78-8443-9636ae8a4da2
typeof(C)

# ╔═╡ 38d3293b-32ac-430f-8a59-b7766b9e2afe
dB = distribute(B);

# ╔═╡ 915467f5-9366-46d8-90f7-e2d45ed57fbf
dA = distribute(A);

# ╔═╡ 4667db56-0ac0-4682-8467-5538a005d2b3
dC = 2 .* dA ./ dB;

# ╔═╡ 3168bf18-c48c-4a2a-a57a-e3fbceb52268
all(dC .≈ 4*π)

# ╔═╡ b1564786-7880-46a0-8f7d-ffeab6eca571
typeof(dC)

# ╔═╡ 91831fef-d367-4918-b637-15c765b6a32d
cuB = CuArray(B);

# ╔═╡ 2b2ab2e9-0ba7-4817-8f65-c488b31864fe
cuA = CuArray(A);

# ╔═╡ 5c77ade4-dfd8-4e80-b5ad-4d7bf28cf0f2
cuC = 2 .* cuA ./ cuB;

# ╔═╡ 7380a9f4-7fc6-4a8c-84c7-3463efd6adc9
all(cuC .≈ 4*π);

# ╔═╡ c3728b36-d82f-4b2b-b616-52b2b1113408
typeof(cuC)

# ╔═╡ eb5ac7ea-be90-4a19-baa4-108d98d0d310
md"""
Keep in mind that some Julia features are not currently supported by CUDAnative.jl[^2] , especially some functions like `sin` will need to be replaced with `CUDAnative.sin`(cc: @maleadt).
"""

# ╔═╡ 7c2eb8c4-7d0b-45bb-9091-e9000e98c5e2
md"""
In the following example we will use both `DistributedArrays.jl` and `CuArrays.jl` to distribute an array across multiple processes and call a generic function on it.
"""

# ╔═╡ 93c96713-12ae-4835-a45c-7b9a89d6859c
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

# ╔═╡ 929e250d-8b1a-4d81-a6ab-57090757050f
md"""
`power_method` repeatedly creates a new vector and normalizes it. We have not specified any type signature in function declaration, let's see if it works with the aforementioned datatypes:
"""

# ╔═╡ 2a43175a-0cfd-4e65-ab0c-da9341dade03
M = [2. 1; 1 1];

# ╔═╡ 8bd73c67-f7a4-44ba-89d7-2ac78ea2157b
v = rand(2)

# ╔═╡ 8dd47c07-3148-4b3f-9db3-9395e656ba1f
power_method(M,v)

# ╔═╡ 645f76f6-b0fa-4c0f-811a-2d1f91fcb3fe
cuM = CuArray(M);

# ╔═╡ 37193a29-b3a4-41ba-9480-fbcd27c59f2c
cuv = CuArray(v);

# ╔═╡ 705f1f5e-18ce-4456-9e5e-f416ad428f7d
curesult = power_method(cuM, cuv);

# ╔═╡ 508f0dbf-a9bf-4232-a58a-7c92100a1c80
typeof(curesult)

# ╔═╡ 030e9f35-1b7e-47b6-a4f3-62362950cf1b
dM = distribute(M);

# ╔═╡ 6d009e1c-b534-42cd-8124-ca10b1f8d889
dv = distribute(v);

# ╔═╡ 9d405545-6d84-4989-86a7-396eea6afa11
dC = power_method(dM, dv);

# ╔═╡ 6b70a137-51da-43fb-8302-f94b6c7a697a
typeof(dC)

# ╔═╡ ca057c15-b7f7-4fb4-b8fb-4a69e4cf9f85
md"""
To end this short exposure to external packages, we can consider `MPI.jl`, a Julia wrapper of the MPI protocol. As it would take too long to consider every inner function, it would be better to simply appreciate the approach used to implement the protocol.
"""

# ╔═╡ de87be03-9369-440c-b41b-7cea816e408d
md"""
Consider this toy script which simply calls each subprocess, instantiate its rank and when the master process is reached, performs the ranks' sum
"""

# ╔═╡ 1d497483-1f18-46c4-b1ff-f8393df2e572
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
   @printf(\"sum of ranks: %s\n\", sr)
end

MPI.Finalize()
```
"""

# ╔═╡ 3185f42d-56a2-4d62-b327-91c46e11f396
md"""
```
mpirun -np 4 ./julia example.jl
```
"""

# ╔═╡ 7114c307-165c-4f70-995c-3a8484a26034
md"""
[^1]: In this context, MPI refers to the MPI-1 standard. Beginning with MPI-2, the MPI standards committee introduced a new set of communication mechanisms, collectively referred to as Remote Memory Access (RMA). The motivation for adding rma to the MPI standard was to facilitate one-sided communication patterns. For additional information on the latest MPI standard, see [https://mpi-forum.org/docs](https://mpi-forum.org/docs).
"""

# ╔═╡ 206dd224-ea71-471f-8ff7-d412e3b0337a
md"""
[^2]: [Julia GPU man pages](http://juliagpu.github.io/CUDAnative.jl/stable/man/usage.html#Julia-support-1)
"""

# ╔═╡ Cell order:
# ╟─c6e5fe1d-ba41-4945-ad7b-4b680456fc23
# ╟─f681ce72-b780-4f3c-9222-18487afe7472
# ╟─1a9d8e6e-50bb-4206-a8f2-c69161e9d9be
# ╟─1988621c-f102-4e7c-8f85-dffabc57dfc5
# ╟─43f2f59e-4fb7-4339-8030-16ae54c58b50
# ╟─10e7a2b4-6f06-4e1e-92a9-fc0095665ea6
# ╟─229d4e58-90af-4343-b6f1-25d30fb36ba5
# ╟─12a64fbe-6fcb-4892-9d28-bb8cc2546c21
# ╟─31b5a98f-e026-4ed0-9ecb-7a8d90d57750
# ╟─49681d9c-3cf2-4cd1-9a12-f68181987cce
# ╟─50d1f217-bfd3-4ff6-b292-dd9d372ce115
# ╟─7bbc91dc-2750-4611-a44e-902dc7255a24
# ╟─481e8894-c644-4c94-88e6-c2afd0fbc8e2
# ╟─690c4343-75bc-4831-b27d-4834b3f2f411
# ╠═6903f8b8-9df4-4757-99bb-987ec5cb9063
# ╟─9ac4a933-702e-459e-bf77-d4012026388f
# ╟─195c24de-b960-4695-b35e-643fc272a26a
# ╠═7d8241ec-c8b7-4031-8a64-998a115caaf7
# ╠═f1e17ff1-8a05-4cf0-97b3-e152c065585a
# ╠═d5c95ff8-3971-4c5c-8723-04e35f02a60e
# ╟─4ae9f602-5e0e-4193-a579-737a0779f2f6
# ╟─1614b558-e7ad-421c-bb62-6dd8074c97dd
# ╟─4ef124f3-7157-4c2e-8123-cb0718deb751
# ╟─508ebcd2-a456-459c-9644-1ccf5a89f256
# ╟─fd9a618d-916c-4deb-b982-b6de5e44315b
# ╟─06c19acc-c7a0-4d8f-9768-757385ab20c0
# ╠═ba6121ca-0f2d-4c99-a915-e636c96718d2
# ╠═a9a9d1cc-f7bf-455d-989e-cff2f741c3df
# ╠═32e40b0d-5588-4309-9925-2a06f1142cc7
# ╟─ab9c9f7a-46c9-4d5f-9852-a6bce89fc970
# ╟─a10619a2-9966-48a6-b95b-fde2ed110b4a
# ╟─a847d214-780c-48f0-80eb-19a322f5ab2a
# ╟─8c783b0d-1f36-4608-a52c-3ebda0fe20bc
# ╠═03bffbeb-7749-4c3b-82ef-9062a938d4a4
# ╟─cd2bcec4-10ff-4865-af5f-8ff78babfed9
# ╠═2256d6b4-2ec8-4dff-9ebe-f7410b6eda8b
# ╠═67037560-35e9-4967-a9e9-59249e03a3f2
# ╠═ab0ec8bb-5724-4375-8ea8-8d441c77bb80
# ╠═19984ede-e45d-4906-b510-263ac53c7d2b
# ╟─c82b9f57-dd2f-4023-9f5b-921ce823edc8
# ╠═895adce3-619f-4b2d-9f03-570e53b660b8
# ╟─d842c4a9-f109-489b-b9e2-5c6577e87d31
# ╟─5c04186a-83b0-4fea-b511-58d1f4eaf18e
# ╟─8fff2f5b-1684-41a6-8470-59fdf366ed15
# ╟─e5066a21-f492-4906-97cc-3b372f229651
# ╟─27d4abe1-cf24-42d6-91a5-6ecd8c54eb12
# ╟─e66c670e-5f19-4935-8e27-cf690b57bdc8
# ╟─3dfcecf3-a3b6-448b-a24f-1ab9d503072a
# ╟─5119d425-6c0d-4315-8138-1b853bbfd9a0
# ╠═a06df0c8-3c5f-42cf-9269-404d8ae34c0a
# ╠═cc3e344b-f66e-41b5-a7b5-3d00181d825e
# ╟─67a91643-4609-4ba5-8bfb-236c49562ca3
# ╟─5d144cd9-2095-4b43-bae5-6478f531cc64
# ╟─b4eae10d-01c4-42ad-93f6-4efed2c08ea8
# ╟─ecaf392b-c1bd-4adf-9683-bae1ecfd42e4
# ╟─42893e32-8a52-42c7-9c53-4a1d73202207
# ╟─4b8bafa5-a42a-4040-a1d5-38d7a545cabb
# ╟─5849c8e8-a2ff-41c6-b074-a436d9aeeb3a
# ╠═0eaf4eca-6099-4fff-9678-562483ea5bc4
# ╠═54b02098-9187-4141-b3a9-9d4cdaf97d31
# ╠═ae67e4f5-b879-403c-b8be-d50afb91200f
# ╟─cb9e3760-a3fa-43db-8980-c179457a7499
# ╠═c49083e9-b165-4db0-a113-b4e4c77873a1
# ╠═805f4833-c149-41fc-b2b4-f9e3d293217e
# ╟─dbca6584-ffcc-4e08-880a-80dc155458cd
# ╟─45df25b7-de78-44d7-a43d-c94e8788affa
# ╟─a8274066-0af6-460c-a9ef-5595ff7854b9
# ╟─cd48eed6-43d3-4a9a-8ebb-5d84932edd3c
# ╠═990375fb-b470-4404-8406-54f29cf08294
# ╟─a6bc111c-5ed1-4647-9d06-adb6e686157a
# ╟─aeec6caa-79f1-4c16-8c5e-cb6e94ef621b
# ╟─30b828e1-520a-4818-a7e5-08c6d54992b3
# ╟─639cb887-5667-44f2-bf4e-3150f869152f
# ╟─5c70a79d-0c77-428e-9d3b-8fec72fb8f18
# ╠═7fb22f26-3143-48ac-8398-15f5ac3373f7
# ╠═612324fd-1f7c-48f0-8361-3d79c666dcba
# ╠═e5c61d0d-567c-449a-ac88-4b6cc5a5f112
# ╠═e295b8e9-8f74-4935-91d8-922d6ea96ced
# ╠═ffc6304e-e680-463a-a2e3-d359cd4a2c30
# ╟─5e350e78-c961-4f3c-bec4-f3d040b75365
# ╟─fee6ec57-8bbf-4158-b79a-48595d28f4da
# ╟─0c3b88ab-5d08-488a-9c09-4ee66c6d96e0
# ╟─d71f7673-7ed5-4037-9f1c-e7aa7c446ad6
# ╟─681a7c56-08a9-42f9-915e-5edb4652433a
# ╠═7fa594a8-1c26-4b87-9c85-bb0f5a5a596a
# ╠═ee44a442-469d-4965-9e42-b4ea9f698811
# ╠═6ca94d87-0903-4814-afef-65d2c2aa234b
# ╠═fb4ac8fc-ec1b-4380-a384-00b97cd02a79
# ╟─4b0d2e4b-1835-4d91-82d7-3ba657c49363
# ╟─4c07f290-7445-4a5a-8937-67244a562a8c
# ╟─3b029245-c1e6-4172-a96a-d67e1c5d5a56
# ╟─990d89dc-44ae-437a-900d-5e810a738e1b
# ╟─ad4c44cb-6cb3-4fd1-a459-dc2d5955ebfe
# ╟─a5942cd9-696c-4acb-8eba-8465c73474be
# ╟─ff5f630d-0879-4de6-873b-6c5305ce9f6d
# ╟─d9330e11-f960-4455-b725-160e1ac82ca8
# ╟─90eafebc-8dba-4fcc-ae00-79e740587348
# ╟─e1595a2e-e379-48ff-90f1-30adeea2f870
# ╟─e8091183-fc1c-4fdf-8af7-aa25fa317084
# ╟─efa16e76-72a3-4b23-b020-b806dda10983
# ╟─7d0d15ca-c3cd-4101-9b29-218395a230eb
# ╟─4dcdc27e-30aa-45bc-a8a3-2ba6546673bb
# ╠═ffa6e99a-8910-4cfc-b0bc-30e510a6bbf3
# ╠═2a24fadd-9579-4cc5-83de-2348c675b19d
# ╟─314ad4eb-2db0-4c5a-94b3-22de1f9a4aca
# ╟─faff58b2-88d8-488b-aff8-5d9bf7e30dee
# ╟─c1a2de39-17bf-4d1f-9fc5-ace00e2f0d4a
# ╟─1bf842aa-70f9-4629-86b3-1b69bb997b5c
# ╟─81cd2bb3-8482-48dc-a74e-d343c50d4e92
# ╟─bc8444da-c33b-498c-b84b-99e0830cb33a
# ╟─9d8abf73-4eff-4d1a-ae99-5cec0359f2e6
# ╟─b3644b88-e6ae-45e1-ad8c-8ea4e0fd05a4
# ╟─64ccd5ad-cefd-43a6-85c9-ee63c1adf7b1
# ╟─daeec496-6476-4680-b815-6b7a8ec48bf1
# ╟─8e796df7-660a-44fc-b677-b68110ddf97c
# ╟─5d3ac97e-0969-4eec-ba4b-fef8ceb5a481
# ╟─21d7f12e-644a-4736-b2e8-712a6dba96d9
# ╠═08e6f694-a7a1-4f0a-99ef-5014cf3d7e73
# ╠═ab01ab95-10a7-4607-bca3-d866291e4c22
# ╠═c0c728dc-d784-4867-af84-77cd7b09e8f3
# ╠═91dace82-62c8-4b2b-81b4-8b85fb6e6071
# ╠═e27c8114-cbbd-4ac0-94f4-d3f37c84760f
# ╠═b64e8abf-0f34-4745-adca-5b1d3106eae9
# ╠═2e432c3e-19b8-4704-9464-b8769f337b50
# ╠═a731f554-c82d-4bbf-8271-f3875fe2eb92
# ╠═d0b6502a-2fd7-48f9-94a8-411f7538800d
# ╟─77428b00-43be-4369-8ec4-afe8f8c27149
# ╟─460cd342-975b-48f7-9bad-182bd1791b3d
# ╟─6e065f0d-7c04-4922-a08d-79b1e276f88c
# ╟─9763ba03-51cb-45a6-9d21-bee492434840
# ╟─d9e93364-82c3-4aac-a5d5-ba5a258a807f
# ╟─61b9f981-7f6c-4e64-917b-10f04913e462
# ╟─19bfe3e4-7dfe-487a-97df-138f1605d5be
# ╟─9bdbfb82-679a-46dc-93c4-17e87305d72c
# ╟─abdc3a58-518e-493e-af1f-bdae3ec371de
# ╟─7a25e342-6a1c-4706-90d9-876d3252254b
# ╟─eecb93d1-eb32-409a-ab0d-d09b0d097e76
# ╟─268e0e57-9f61-4aba-aad2-398a356c882e
# ╠═16d3b6c2-5703-40ab-ada1-7772bedbdf3d
# ╠═5fdca7d5-7895-419e-8027-db3f90638c7e
# ╠═738bb4af-7290-4246-b846-cb2540fe786e
# ╠═d132ffa5-8e5f-487d-a299-ea486b80aa0a
# ╠═72452acc-0226-4268-9520-d80f00a5933c
# ╠═5568ff49-12f3-494b-a150-2dd1295cfcb2
# ╠═6d8c0463-f06a-47a4-bfe0-54010e3f4abe
# ╠═03aa8394-8405-4467-b5d3-253ddc949d20
# ╠═77af7f49-862d-4979-a410-04e53566eaae
# ╠═4d5a6473-2be5-4c65-aa97-4b4a18fcbd45
# ╠═345a84f7-0bb2-47e9-a85a-2b8c31578a08
# ╠═acbc3182-e63d-4dda-b7b5-e9db09b7b435
# ╠═9b782aca-43cb-469d-adc3-6928bd8ea62b
# ╠═381f30e2-5e2f-40c3-9b96-704165fbc4e2
# ╟─ff526128-3ef0-44d8-b814-bf50324fb117
# ╟─dbc38629-c615-4af6-80d3-ee20ff127e78
# ╟─34f2b9c2-57e2-42c4-bf7d-309531f9675b
# ╠═9029b56f-4ea4-4ff9-9e8a-b95eef06e709
# ╠═71b35f60-3dd8-40a3-b54e-f65df2211df8
# ╠═075f074b-4cf1-43e2-9fde-58e89188078c
# ╠═068b0859-b779-4e88-abdb-ac9957328a0d
# ╠═48ade339-1dc2-4417-ab5f-c09c5d7e36a1
# ╠═3463e794-fddb-4b8f-a76b-3ad88dd78499
# ╠═880c6e40-3504-4ff1-9a50-f8b31d16c90d
# ╟─40bcb5ea-7b6e-4adc-b9de-0d7e003bd6fc
# ╟─cf30b540-85aa-471e-a06b-a7b0106db3ba
# ╟─067a8823-9066-43ed-b8cc-de5bb09b2cd6
# ╟─ae1c4d5c-0f10-4370-951d-630dbf88e33a
# ╟─c9c3d18a-d7a2-4601-84d8-d738477db177
# ╟─7d7bc3f7-ceb1-48d8-8f64-6b589108530b
# ╟─3b4cf984-21f3-4f07-aa83-9441e708dc4e
# ╟─ae9ae3fa-d438-4c7e-9f91-884c89aabcd6
# ╟─c9ba2caa-ce4c-4e14-bc99-e212bc1b3d62
# ╟─27bc4542-a30e-477e-8eed-2497b1d944c1
# ╟─da9fa57a-ba4f-4178-8e74-a5a668f3dd69
# ╠═fad2930a-706e-4b22-9cc9-49e52d2b72be
# ╠═2411e053-321b-46e6-80f0-5db19146b936
# ╠═da80439c-94e0-454d-9f5a-3af4a42e8d33
# ╠═f44d18ed-d0b5-4736-a99c-87c86ea26dbd
# ╠═d2bcba03-21b6-4d7c-b26f-22012ed67112
# ╠═c409391f-1ae2-48fd-8a75-7f4484ddb74b
# ╟─bef69002-a4a4-4c00-9f82-04cca6231048
# ╠═b7f5c0c6-1a61-4724-956f-47a64dba4970
# ╟─f77f689d-f983-414c-a8f8-ab9b8546109f
# ╟─7bc8f230-25c7-4ed2-8954-46884dc1052d
# ╟─8a2fdad4-93a4-4554-a50d-16d65058e85b
# ╟─964ca292-eb6f-43b8-a3d9-249c89c50930
# ╟─c31d24c3-ebbd-4624-adcb-68c2212ce222
# ╟─9897c342-be95-45b8-b6bd-eabdc5aa3853
# ╠═cec410a8-ebae-4b21-9355-f05ce1f5630e
# ╟─e65159ce-cb5a-430e-acb2-f94707ff7f0b
# ╠═49d88ccd-6d33-482d-8a68-f3536cf6220e
# ╟─e8234db9-94fd-4200-afdc-a49ca439b3de
# ╠═bf671d6f-b05d-4b89-b6ad-f8717e36635d
# ╟─28b28295-2807-4f1a-98d2-18f11c67aa3c
# ╠═1924da9a-d6fe-44c5-9873-cbc1036d6984
# ╟─2048ba6a-58a0-4a81-b67f-8deedd621328
# ╠═6ec839e1-9a5e-48c0-8956-1b935c68629b
# ╟─2d891336-86be-4ce6-a5c4-2aaa5f0caba0
# ╠═da1e89a1-f67e-4afc-8717-773e6080c6b1
# ╟─d605e4cb-7212-4966-a3ad-01774f8b7df3
# ╠═9e198f6e-f9f1-43a7-879d-fe41d2354a38
# ╠═38d36d1b-6bc3-4e4e-8f30-fee2a1d9200f
# ╟─db6dbac0-1020-4819-936d-a2cb73f0a282
# ╠═5aacccc0-d4c3-4d2c-a94a-ea7814c9b60f
# ╠═8024d250-4032-447a-a49d-b99279379862
# ╠═88624f31-23a7-4f60-8f19-4901e7bcba98
# ╟─9cd17a7b-e9bb-4d65-b564-9eaf74e5a040
# ╟─54d76f79-0225-4096-b3e8-327b2f8024f8
# ╟─e8eb7495-71fb-47af-91c7-8c1b57a89fa4
# ╟─2f4d3b33-1873-4c23-90cf-b54d23777096
# ╟─ea680a39-99ff-47de-8bcd-97e4bd2eb9f1
# ╟─c9526cf8-77d0-4b0a-9e6d-903d6ac29efd
# ╟─80a0c031-bcd3-4024-8168-e47a70ce4b4c
# ╟─276794be-4474-490e-99fb-0d815d724f05
# ╟─dd85dd42-c37c-4208-b4a9-732d6516a70d
# ╟─e3dde89c-77ce-41af-90b7-698c4100fb1a
# ╟─feb33c42-f6ea-4ebd-920d-525bda4e4576
# ╟─7191d450-1658-4f83-9035-0637a8ac6c88
# ╟─7c7a0b8c-c29c-41e2-aba8-607630a8b1e7
# ╟─13dac033-127d-4ce6-9df2-b3dd814173c9
# ╟─eff4c1f4-ced7-4fd2-8e24-c3bfc59eeb3b
# ╟─9e2dc2bc-0e4f-49d2-b6d8-2ef5df650f10
# ╟─02c43911-71d2-4e33-bce4-ea19a3f961ac
# ╟─1cee731c-e712-4dfd-a8d4-6115c8976ffb
# ╟─59f2b74e-e3af-4f58-a8e9-c2d1e6acc70f
# ╟─2c81744b-7c26-4f65-8d09-c544a37c72fa
# ╟─a9cd1a1f-fe41-40ae-9d71-9a2519dbef8e
# ╟─a0829de0-ab24-4a99-a7ac-45249a92a113
# ╟─691b804f-d950-4c23-9f4f-0076d7b5a0e0
# ╟─49840359-603d-4ae6-bcd9-2adc9e4f1a50
# ╟─89de6e62-4c76-4bd7-9996-bcc01f681c1e
# ╟─315377f1-c0d6-41b9-bc61-0ddfd82bb9c5
# ╟─51af2bcc-9d06-4080-a694-c504c0b274e3
# ╟─11f8a797-ab65-4399-b410-2412175333b4
# ╟─60dbe822-fca8-4992-923a-e23b64711dd8
# ╟─fc250748-e3cf-4e9c-873c-12d4d50e2240
# ╟─733278b6-a4ad-4d31-80fc-1cb4862fed1f
# ╟─f9e730d5-b2f9-4013-be59-31f732e87c93
# ╟─e4e4f785-ebf8-4734-a022-3e630bc2028d
# ╟─39f7ed8d-8196-4355-b703-073cec792136
# ╟─76f7947b-d118-4c54-b9bd-88c507c97392
# ╟─b0a71e90-1b7d-47e2-a737-9369c9d78e2b
# ╟─96d2d7fe-00b4-4bab-a998-beee7f730764
# ╟─a166bd57-6d9c-41af-95ee-3a77f01d2859
# ╟─2eaba9a5-3526-4baa-be4b-5e2ade0b3037
# ╟─ae7f5538-5818-4404-b65a-bd510540c508
# ╟─9d970885-e4b4-40ed-9394-290a5e7a280c
# ╟─8785d2fa-9746-42eb-8ac3-efd9c6b1760c
# ╟─a9796971-63ef-4ab8-a431-5af4092473ff
# ╟─3f635c26-82b1-4bb4-a0e1-11e6ee0b80bd
# ╟─7f2f21b3-65c3-4f04-bc8f-47a87130db29
# ╟─b10e3ab8-c7af-4c35-9992-15c604ca1680
# ╟─ccd6b3c8-61d5-4123-a117-51fa8ef179fc
# ╟─d2952435-09d4-44ca-a34e-36a397f7abd5
# ╟─3e84064d-a39e-410a-9bad-12b658423749
# ╟─2671d504-ddd2-43fd-a976-b8f1d4acf954
# ╟─5afbe858-a1eb-422a-966e-709fe4357274
# ╟─f26cc18a-0532-4076-9c9f-a394b6a92e4f
# ╟─586cff51-6f98-4a71-976d-c7619d324020
# ╟─cf7bc277-41c5-4a40-be20-4ba7341bb146
# ╟─ddd06016-2782-44f0-8ebc-b457a5dbf726
# ╟─7d8a52f6-2ea7-49ca-8e08-89ffa08097cb
# ╟─52f9d7ec-75a4-4a40-9c9a-916973349359
# ╟─658f7519-33a7-4b15-b8c7-42606ad3f965
# ╟─6960c763-ef20-4b30-9013-b5bec36b998b
# ╟─5c19cf55-f975-45b9-b2dc-979876a0ef1d
# ╟─ab719c1e-fce3-41c0-9b4f-12abc5480bea
# ╟─bd9f23ce-322b-4460-a86a-08ec64791a2e
# ╟─569a36b5-74fc-43d0-ab71-ff8139e3acdb
# ╠═720db8ba-8dc5-4931-922d-ef0199a9b718
# ╠═25d89d32-57b6-4398-8687-6cafa49711f9
# ╠═b8267df5-d936-4207-98b4-3e0c09fed4b1
# ╠═e9f6b771-4fd3-4c27-adee-87680dd55a58
# ╠═741a0104-5662-4174-ae48-d7f8e35a8fd4
# ╠═5ab0df8a-07b1-405f-aad3-fc675b114bdb
# ╠═6fade9e3-8f86-4c16-b00a-3dcbc9e1a46e
# ╠═d5af1755-ce2a-49b1-b446-73ed72f5e88b
# ╠═7d04277f-34d8-4d78-8443-9636ae8a4da2
# ╠═38d3293b-32ac-430f-8a59-b7766b9e2afe
# ╠═915467f5-9366-46d8-90f7-e2d45ed57fbf
# ╠═4667db56-0ac0-4682-8467-5538a005d2b3
# ╠═3168bf18-c48c-4a2a-a57a-e3fbceb52268
# ╠═b1564786-7880-46a0-8f7d-ffeab6eca571
# ╠═91831fef-d367-4918-b637-15c765b6a32d
# ╠═2b2ab2e9-0ba7-4817-8f65-c488b31864fe
# ╠═5c77ade4-dfd8-4e80-b5ad-4d7bf28cf0f2
# ╠═7380a9f4-7fc6-4a8c-84c7-3463efd6adc9
# ╠═c3728b36-d82f-4b2b-b616-52b2b1113408
# ╟─eb5ac7ea-be90-4a19-baa4-108d98d0d310
# ╟─7c2eb8c4-7d0b-45bb-9091-e9000e98c5e2
# ╟─93c96713-12ae-4835-a45c-7b9a89d6859c
# ╟─929e250d-8b1a-4d81-a6ab-57090757050f
# ╠═2a43175a-0cfd-4e65-ab0c-da9341dade03
# ╠═8bd73c67-f7a4-44ba-89d7-2ac78ea2157b
# ╠═8dd47c07-3148-4b3f-9db3-9395e656ba1f
# ╠═645f76f6-b0fa-4c0f-811a-2d1f91fcb3fe
# ╠═37193a29-b3a4-41ba-9480-fbcd27c59f2c
# ╠═705f1f5e-18ce-4456-9e5e-f416ad428f7d
# ╠═508f0dbf-a9bf-4232-a58a-7c92100a1c80
# ╠═030e9f35-1b7e-47b6-a4f3-62362950cf1b
# ╠═6d009e1c-b534-42cd-8124-ca10b1f8d889
# ╠═9d405545-6d84-4989-86a7-396eea6afa11
# ╠═6b70a137-51da-43fb-8302-f94b6c7a697a
# ╟─ca057c15-b7f7-4fb4-b8fb-4a69e4cf9f85
# ╟─de87be03-9369-440c-b41b-7cea816e408d
# ╟─1d497483-1f18-46c4-b1ff-f8393df2e572
# ╟─3185f42d-56a2-4d62-b327-91c46e11f396
# ╟─7114c307-165c-4f70-995c-3a8484a26034
# ╟─206dd224-ea71-471f-8ff7-d412e3b0337a
