### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 284b62a5-983a-46cb-bccc-5f47a41d8367
md"""
# Parallel Computing
"""

# ╔═╡ 82047111-db86-4ae9-9235-e182cd903848
md"""
Julia supports these four categories of concurrent and parallel programming:
"""

# ╔═╡ 71765e80-b367-4ff5-93a3-22e778de3563
md"""
1. **Asynchronous \"tasks\", or coroutines**:

    Julia Tasks allow suspending and resuming computations  for I/O, event handling, producer-consumer processes, and similar patterns.  Tasks can synchronize through operations like [`wait`](@ref) and [`fetch`](@ref), and  communicate via [`Channel`](@ref)s. While strictly not parallel computing by themselves,  Julia lets you schedule `Task`s on several threads.
2. **Multi-threading**:

    Julia's [multi-threading](@ref man-multithreading) provides the ability to schedule Tasks  simultaneously on more than one thread or CPU core, sharing memory. This is usually the easiest way  to get parallelism on one's PC or on a single large multi-core server. Julia's multi-threading  is composable. When one multi-threaded function calls another multi-threaded function, Julia  will schedule all the threads globally on available resources, without oversubscribing.
3. **Distributed computing**:

    Distributed computing runs multiple Julia processes with separate memory spaces. These can be on the same  computer or multiple computers. The `Distributed` standard library provides the capability for remote execution  of a Julia function. With this basic building block, it is possible to build many different kinds of  distributed computing abstractions. Packages like [`DistributedArrays.jl`](https://github.com/JuliaParallel/DistributedArrays.jl)  are an example of such an abstraction. On the other hand, packages like [`MPI.jl`](https://github.com/JuliaParallel/MPI.jl) and  [`Elemental.jl`](https://github.com/JuliaParallel/Elemental.jl) provide access to the existing MPI ecosystem of libraries.
4. **GPU computing**:

    The Julia GPU compiler provides the ability to run Julia code natively on GPUs. There  is a rich ecosystem of Julia packages that target GPUs. The [JuliaGPU.org](https://juliagpu.org)  website provides a list of capabilities, supported GPUs, related packages and documentation.
"""

# ╔═╡ Cell order:
# ╟─284b62a5-983a-46cb-bccc-5f47a41d8367
# ╟─82047111-db86-4ae9-9235-e182cd903848
# ╟─71765e80-b367-4ff5-93a3-22e778de3563
