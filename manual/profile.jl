### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 773fe15e-fce6-403f-ba11-dcd2d37911c3
md"""
# Profiling
"""

# ╔═╡ e6179998-a591-45ee-89f3-57b948887762
md"""
The `Profile` module provides tools to help developers improve the performance of their code. When used, it takes measurements on running code, and produces output that helps you understand how much time is spent on individual line(s). The most common usage is to identify \"bottlenecks\" as targets for optimization.
"""

# ╔═╡ 62128071-a264-4518-9797-0bfe621ea34b
md"""
`Profile` implements what is known as a \"sampling\" or [statistical profiler](https://en.wikipedia.org/wiki/Profiling_(computer_programming)).  It works by periodically taking a backtrace during the execution of any task. Each backtrace captures the currently-running function and line number, plus the complete chain of function calls that led to this line, and hence is a \"snapshot\" of the current state of execution.
"""

# ╔═╡ 9f70d963-27a0-488f-99e8-c5380cb89450
md"""
If much of your run time is spent executing a particular line of code, this line will show up frequently in the set of all backtraces. In other words, the \"cost\" of a given line–or really, the cost of the sequence of function calls up to and including this line–is proportional to how often it appears in the set of all backtraces.
"""

# ╔═╡ c80bf459-2259-4df9-a456-19b7bd88f112
md"""
A sampling profiler does not provide complete line-by-line coverage, because the backtraces occur at intervals (by default, 1 ms on Unix systems and 10 ms on Windows, although the actual scheduling is subject to operating system load). Moreover, as discussed further below, because samples are collected at a sparse subset of all execution points, the data collected by a sampling profiler is subject to statistical noise.
"""

# ╔═╡ 90912ece-1368-4017-b6ca-be5ba92df591
md"""
Despite these limitations, sampling profilers have substantial strengths:
"""

# ╔═╡ 1b35cdfb-f552-4fd9-aa5d-368e39a04702
md"""
  * You do not have to make any modifications to your code to take timing measurements.
  * It can profile into Julia's core code and even (optionally) into C and Fortran libraries.
  * By running \"infrequently\" there is very little performance overhead; while profiling, your code can run at nearly native speed.
"""

# ╔═╡ 575e2890-aae9-411f-bf74-a73a86e402ac
md"""
For these reasons, it's recommended that you try using the built-in sampling profiler before considering any alternatives.
"""

# ╔═╡ a8a4f14e-b5b9-4677-ae47-93c60dd6acbb
md"""
## Basic usage
"""

# ╔═╡ f933d439-0d29-4a07-b38e-5c35c407edd0
md"""
Let's work with a simple test case:
"""

# ╔═╡ 3d180acf-2d0f-4867-84a5-6cb853f49940
function myfunc()
     A = rand(200, 200, 400)
     maximum(A)
 end

# ╔═╡ 54d51562-11e7-43cc-ae7d-3364f498ddb8
md"""
It's a good idea to first run the code you intend to profile at least once (unless you want to profile Julia's JIT-compiler):
"""

# ╔═╡ 7c0b8ff8-7fc7-4792-9b57-d4a297126283
myfunc() # run once to force compilation

# ╔═╡ cda7cd17-42ba-430e-b836-b9d743f33d5d
md"""
Now we're ready to profile this function:
"""

# ╔═╡ f68e903a-f63b-4644-85e1-18217bc9aa58
using Profile

# ╔═╡ 81b4d8a2-8621-43e4-9aff-3fb39ee988f4
@profile myfunc()

# ╔═╡ 91bcda73-c3d0-49b8-9016-d707fd75a3cd
md"""
To see the profiling results, there are several graphical browsers. One \"family\" of visualizers is based on [FlameGraphs.jl](https://github.com/timholy/FlameGraphs.jl), with each family member providing a different user interface:
"""

# ╔═╡ 18a7699b-8cd5-487a-9c17-77e51c220797
md"""
  * [Juno](https://junolab.org/) is a full IDE with built-in support for profile visualization
  * [ProfileView.jl](https://github.com/timholy/ProfileView.jl) is a stand-alone visualizer based on GTK
  * [ProfileVega.jl](https://github.com/davidanthoff/ProfileVega.jl) uses VegaLight and integrates well with Jupyter notebooks
  * [StatProfilerHTML](https://github.com/tkluck/StatProfilerHTML.jl) produces HTML and presents some additional summaries, and also integrates well with Jupyter notebooks
  * [ProfileSVG](https://github.com/timholy/ProfileSVG.jl) renders SVG
"""

# ╔═╡ 209f7435-ffc4-47eb-a0b9-c6b0d555409e
md"""
An entirely independent approach to profile visualization is [PProf.jl](https://github.com/vchuravy/PProf.jl), which uses the external `pprof` tool.
"""

# ╔═╡ 184576e5-f4ca-4f4d-aab3-f30e99a22e5c
md"""
Here, though, we'll use the text-based display that comes with the standard library:
"""

# ╔═╡ ba4e6682-7425-4e14-8c88-d8a6ebe59ef7
Profile.print()

# ╔═╡ 5dd5addf-b1da-4e11-a1d5-5dab2c2ddf39
md"""
Each line of this display represents a particular spot (line number) in the code. Indentation is used to indicate the nested sequence of function calls, with more-indented lines being deeper in the sequence of calls. In each line, the first \"field\" is the number of backtraces (samples) taken *at this line or in any functions executed by this line*. The second field is the file name and line number and the third field is the function name. Note that the specific line numbers may change as Julia's code changes; if you want to follow along, it's best to run this example yourself.
"""

# ╔═╡ 888446a1-af1e-4fc5-812d-260797677366
md"""
In this example, we can see that the top level function called is in the file `event.jl`. This is the function that runs the REPL when you launch Julia. If you examine line 97 of `REPL.jl`, you'll see this is where the function `eval_user_input()` is called. This is the function that evaluates what you type at the REPL, and since we're working interactively these functions were invoked when we entered `@profile myfunc()`. The next line reflects actions taken in the [`@profile`](@ref) macro.
"""

# ╔═╡ d2e681bc-f912-4336-a4c4-dcb90e6b417f
md"""
The first line shows that 80 backtraces were taken at line 73 of `event.jl`, but it's not that this line was \"expensive\" on its own: the third line reveals that all 80 of these backtraces were actually triggered inside its call to `eval_user_input`, and so on. To find out which operations are actually taking the time, we need to look deeper in the call chain.
"""

# ╔═╡ 82ba1e0f-bd13-415d-bc28-617fca5ed10d
md"""
The first \"important\" line in this output is this one:
"""

# ╔═╡ 6a46e25e-7dd5-4473-8ffa-e823904daaa5
md"""
```
52 ./REPL[1]:2; myfunc()
```
"""

# ╔═╡ 934ee5b0-47cb-42d9-9e47-6e16cb67491f
md"""
`REPL` refers to the fact that we defined `myfunc` in the REPL, rather than putting it in a file; if we had used a file, this would show the file name. The `[1]` shows that the function `myfunc` was the first expression evaluated in this REPL session. Line 2 of `myfunc()` contains the call to `rand`, and there were 52 (out of 80) backtraces that occurred at this line. Below that, you can see a call to `dsfmt_fill_array_close_open!` inside `dSFMT.jl`.
"""

# ╔═╡ cdc61318-9b54-426d-9e73-ae4f5baff470
md"""
A little further down, you see:
"""

# ╔═╡ c52aa9ba-f397-4ae2-b004-4e182f82895e
md"""
```
28 ./REPL[1]:3; myfunc()
```
"""

# ╔═╡ 01d8c6a0-aba5-44a7-8737-5c28611841d8
md"""
Line 3 of `myfunc` contains the call to `maximum`, and there were 28 (out of 80) backtraces taken here. Below that, you can see the specific places in `base/reduce.jl` that carry out the time-consuming operations in the `maximum` function for this type of input data.
"""

# ╔═╡ 53a3d55d-44b3-4a59-b137-5d330aedbe65
md"""
Overall, we can tentatively conclude that generating the random numbers is approximately twice as expensive as finding the maximum element. We could increase our confidence in this result by collecting more samples:
"""

# ╔═╡ f1684378-f05c-4176-8723-fa10127a6260
@profile (for i = 1:100; myfunc(); end)

# ╔═╡ 9a01e2ef-9676-48bc-ba29-badc9e3dc796
Profile.print()

# ╔═╡ 2fe94b1c-babd-4ee6-9511-7294ee0e407e
md"""
In general, if you have `N` samples collected at a line, you can expect an uncertainty on the order of `sqrt(N)` (barring other sources of noise, like how busy the computer is with other tasks). The major exception to this rule is garbage collection, which runs infrequently but tends to be quite expensive. (Since Julia's garbage collector is written in C, such events can be detected using the `C=true` output mode described below, or by using [ProfileView.jl](https://github.com/timholy/ProfileView.jl).)
"""

# ╔═╡ e7e74927-27e1-44b7-8f7a-f8781ca42bbc
md"""
This illustrates the default \"tree\" dump; an alternative is the \"flat\" dump, which accumulates counts independent of their nesting:
"""

# ╔═╡ cc9be570-c926-4bca-a5f8-248976bf2ab6
Profile.print(format=:flat)

# ╔═╡ 62bf8193-d809-4111-a694-355f58e5f6d2
md"""
If your code has recursion, one potentially-confusing point is that a line in a \"child\" function can accumulate more counts than there are total backtraces. Consider the following function definitions:
"""

# ╔═╡ 08eeee5a-cb97-490b-bfef-18860d1d5d9b
md"""
```julia
dumbsum(n::Integer) = n == 1 ? 1 : 1 + dumbsum(n-1)
dumbsum3() = dumbsum(3)
```
"""

# ╔═╡ bc31719e-eef7-4457-b236-677c1e3cbfbd
md"""
If you were to profile `dumbsum3`, and a backtrace was taken while it was executing `dumbsum(1)`, the backtrace would look like this:
"""

# ╔═╡ d9144932-5624-4e8f-925d-26d5f97f168d
md"""
```julia
dumbsum3
    dumbsum(3)
        dumbsum(2)
            dumbsum(1)
```
"""

# ╔═╡ 4463f520-18c7-463c-a9ea-918b911c1025
md"""
Consequently, this child function gets 3 counts, even though the parent only gets one. The \"tree\" representation makes this much clearer, and for this reason (among others) is probably the most useful way to view the results.
"""

# ╔═╡ bea582be-a4bb-428f-8825-51f585c3aaee
md"""
## Accumulation and clearing
"""

# ╔═╡ 4bdbbc87-3ea6-490e-b6e2-177661298174
md"""
Results from [`@profile`](@ref) accumulate in a buffer; if you run multiple pieces of code under [`@profile`](@ref), then [`Profile.print()`](@ref) will show you the combined results. This can be very useful, but sometimes you want to start fresh; you can do so with [`Profile.clear()`](@ref).
"""

# ╔═╡ c1ae1d63-c65b-4654-b14a-e6ba77a12449
md"""
## Options for controlling the display of profile results
"""

# ╔═╡ a05eeb04-8fd3-4867-b75a-7af866005b78
md"""
[`Profile.print`](@ref) has more options than we've described so far. Let's see the full declaration:
"""

# ╔═╡ f540ae75-a134-43c1-9e2e-1fe35c103f03
md"""
```julia
function print(io::IO = stdout, data = fetch(); kwargs...)
```
"""

# ╔═╡ f43613ca-aed3-4b50-ba07-37626887c837
md"""
Let's first discuss the two positional arguments, and later the keyword arguments:
"""

# ╔═╡ e42fe256-85f5-48e9-a267-9dc36ed56032
md"""
  * `io` – Allows you to save the results to a buffer, e.g. a file, but the default is to print to `stdout` (the console).
  * `data` – Contains the data you want to analyze; by default that is obtained from [`Profile.fetch()`](@ref), which pulls out the backtraces from a pre-allocated buffer. For example, if you want to profile the profiler, you could say:

    ```julia
    data = copy(Profile.fetch())
    Profile.clear()
    @profile Profile.print(stdout, data) # Prints the previous results
    Profile.print()                      # Prints results from Profile.print()
    ```
"""

# ╔═╡ bf553236-8074-4fec-b371-e16cb24c6cc6
md"""
The keyword arguments can be any combination of:
"""

# ╔═╡ 9d73b0c9-6784-417d-81ea-52890faf572d
md"""
  * `format` – Introduced above, determines whether backtraces are printed  with (default, `:tree`) or without (`:flat`) indentation indicating tree  structure.
  * `C` – If `true`, backtraces from C and Fortran code are shown (normally they are excluded). Try running the introductory example with `Profile.print(C = true)`. This can be extremely helpful in deciding whether it's Julia code or C code that is causing a bottleneck; setting `C = true` also improves the interpretability of the nesting, at the cost of longer profile dumps.
  * `combine` – Some lines of code contain multiple operations; for example, `s += A[i]` contains both an array reference (`A[i]`) and a sum operation. These correspond to different lines in the generated machine code, and hence there may be two or more different addresses captured during backtraces on this line. `combine = true` lumps them together, and is probably what you typically want, but you can generate an output separately for each unique instruction pointer with `combine = false`.
  * `maxdepth` – Limits frames at a depth higher than `maxdepth` in the `:tree` format.
  * `sortedby` – Controls the order in `:flat` format. `:filefuncline` (default) sorts by the source line, whereas `:count` sorts in order of number of collected samples.
  * `noisefloor` – Limits frames that are below the heuristic noise floor of the sample (only applies to format `:tree`). A suggested value to try for this is 2.0 (the default is 0). This parameter hides samples for which `n <= noisefloor * √N`, where `n` is the number of samples on this line, and `N` is the number of samples for the callee.
  * `mincount` – Limits frames with less than `mincount` occurrences.
"""

# ╔═╡ 745ce1b1-e9c6-4e4e-86fe-2da2d7db05f8
md"""
File/function names are sometimes truncated (with `...`), and indentation is truncated with a `+n` at the beginning, where `n` is the number of extra spaces that would have been inserted, had there been room. If you want a complete profile of deeply-nested code, often a good idea is to save to a file using a wide `displaysize` in an [`IOContext`](@ref):
"""

# ╔═╡ ac0f42ca-3a4f-4a6d-a472-d2443bd182bc
md"""
```julia
open(\"/tmp/prof.txt\", \"w\") do s
    Profile.print(IOContext(s, :displaysize => (24, 500)))
end
```
"""

# ╔═╡ 1e4b5689-28e5-4a50-a4e8-5ded9296c145
md"""
## Configuration
"""

# ╔═╡ 8dc30252-509e-4855-9bd6-16ab3d311259
md"""
[`@profile`](@ref) just accumulates backtraces, and the analysis happens when you call [`Profile.print()`](@ref). For a long-running computation, it's entirely possible that the pre-allocated buffer for storing backtraces will be filled. If that happens, the backtraces stop but your computation continues. As a consequence, you may miss some important profiling data (you will get a warning when that happens).
"""

# ╔═╡ e5c5ad21-6e83-46ae-bbb4-601e647f62bc
md"""
You can obtain and configure the relevant parameters this way:
"""

# ╔═╡ 3a53a235-77c4-4d19-8dfd-e297f5b7bf7c
md"""
```julia
Profile.init() # returns the current settings
Profile.init(n = 10^7, delay = 0.01)
```
"""

# ╔═╡ 9ae1a5f1-7c61-44fa-88e5-6988051439a2
md"""
`n` is the total number of instruction pointers you can store, with a default value of `10^6`. If your typical backtrace is 20 instruction pointers, then you can collect 50000 backtraces, which suggests a statistical uncertainty of less than 1%. This may be good enough for most applications.
"""

# ╔═╡ 1d0f343b-9e06-4ee7-823a-56beeaa4763f
md"""
Consequently, you are more likely to need to modify `delay`, expressed in seconds, which sets the amount of time that Julia gets between snapshots to perform the requested computations. A very long-running job might not need frequent backtraces. The default setting is `delay = 0.001`. Of course, you can decrease the delay as well as increase it; however, the overhead of profiling grows once the delay becomes similar to the amount of time needed to take a backtrace (~30 microseconds on the author's laptop).
"""

# ╔═╡ cf29de2f-f2ca-4f10-8ce0-9a99a236b9d6
md"""
## Memory allocation analysis
"""

# ╔═╡ c79a4f15-f104-4050-9db4-ca9949651825
md"""
One of the most common techniques to improve performance is to reduce memory allocation. The total amount of allocation can be measured with [`@time`](@ref) and [`@allocated`](@ref), and specific lines triggering allocation can often be inferred from profiling via the cost of garbage collection that these lines incur. However, sometimes it is more efficient to directly measure the amount of memory allocated by each line of code.
"""

# ╔═╡ 4423a121-077b-4bec-8439-a29bc73981fb
md"""
To measure allocation line-by-line, start Julia with the `--track-allocation=<setting>` command-line option, for which you can choose `none` (the default, do not measure allocation), `user` (measure memory allocation everywhere except Julia's core code), or `all` (measure memory allocation at each line of Julia code). Allocation gets measured for each line of compiled code. When you quit Julia, the cumulative results are written to text files with `.mem` appended after the file name, residing in the same directory as the source file. Each line lists the total number of bytes allocated. The [`Coverage` package](https://github.com/JuliaCI/Coverage.jl) contains some elementary analysis tools, for example to sort the lines in order of number of bytes allocated.
"""

# ╔═╡ f9c5ecc6-0962-4f80-a24c-7e3c8713fcaa
md"""
In interpreting the results, there are a few important details. Under the `user` setting, the first line of any function directly called from the REPL will exhibit allocation due to events that happen in the REPL code itself. More significantly, JIT-compilation also adds to allocation counts, because much of Julia's compiler is written in Julia (and compilation usually requires memory allocation). The recommended procedure is to force compilation by executing all the commands you want to analyze, then call [`Profile.clear_malloc_data()`](@ref) to reset all allocation counters.  Finally, execute the desired commands and quit Julia to trigger the generation of the `.mem` files.
"""

# ╔═╡ c78eed75-0e5e-4b92-a5eb-dfe363accfb1
md"""
## External Profiling
"""

# ╔═╡ 17533291-69d4-4e54-b769-d389b21aeb2c
md"""
Currently Julia supports `Intel VTune`, `OProfile` and `perf` as external profiling tools.
"""

# ╔═╡ 425f5cd7-7f9f-4a44-9221-4b0225d10f1f
md"""
Depending on the tool you choose, compile with `USE_INTEL_JITEVENTS`, `USE_OPROFILE_JITEVENTS` and `USE_PERF_JITEVENTS` set to 1 in `Make.user`. Multiple flags are supported.
"""

# ╔═╡ 612ace2e-008d-4469-899a-162f400a9d9b
md"""
Before running Julia set the environment variable `ENABLE_JITPROFILING` to 1.
"""

# ╔═╡ 57556606-a2cc-4100-bdcb-402790d5ea88
md"""
Now you have a multitude of ways to employ those tools! For example with `OProfile` you can try a simple recording :
"""

# ╔═╡ 9bd61139-35ff-4a1c-b9f9-7045d21cef17
md"""
```
>ENABLE_JITPROFILING=1 sudo operf -Vdebug ./julia test/fastmath.jl
>opreport -l `which ./julia`
```
"""

# ╔═╡ 57686419-6f5e-4141-ac18-946c3b3568bf
md"""
Or similary with `perf` :
"""

# ╔═╡ b2a4357a-d3b9-4414-8b1d-55fa0d2a51a7
md"""
```
$ ENABLE_JITPROFILING=1 perf record -o /tmp/perf.data --call-graph dwarf ./julia /test/fastmath.jl
$ perf inject --jit --input /tmp/perf.data --output /tmp/perf-jit.data
$ perf report --call-graph -G -i /tmp/perf-jit.data
```
"""

# ╔═╡ 880d88dc-482b-4188-a95b-1002942ebe46
md"""
There are many more interesting things that you can measure about your program, to get a comprehensive list please read the [Linux perf examples page](http://www.brendangregg.com/perf.html).
"""

# ╔═╡ a51676cc-521c-46d0-befa-80c690f3d0ab
md"""
Remember that perf saves for each execution a `perf.data` file that, even for small programs, can get quite large. Also the perf LLVM module saves temporarily debug objects in `~/.debug/jit`, remember to clean that folder frequently.
"""

# ╔═╡ Cell order:
# ╟─773fe15e-fce6-403f-ba11-dcd2d37911c3
# ╟─e6179998-a591-45ee-89f3-57b948887762
# ╟─62128071-a264-4518-9797-0bfe621ea34b
# ╟─9f70d963-27a0-488f-99e8-c5380cb89450
# ╟─c80bf459-2259-4df9-a456-19b7bd88f112
# ╟─90912ece-1368-4017-b6ca-be5ba92df591
# ╟─1b35cdfb-f552-4fd9-aa5d-368e39a04702
# ╟─575e2890-aae9-411f-bf74-a73a86e402ac
# ╟─a8a4f14e-b5b9-4677-ae47-93c60dd6acbb
# ╟─f933d439-0d29-4a07-b38e-5c35c407edd0
# ╠═3d180acf-2d0f-4867-84a5-6cb853f49940
# ╟─54d51562-11e7-43cc-ae7d-3364f498ddb8
# ╠═7c0b8ff8-7fc7-4792-9b57-d4a297126283
# ╟─cda7cd17-42ba-430e-b836-b9d743f33d5d
# ╠═f68e903a-f63b-4644-85e1-18217bc9aa58
# ╠═81b4d8a2-8621-43e4-9aff-3fb39ee988f4
# ╟─91bcda73-c3d0-49b8-9016-d707fd75a3cd
# ╟─18a7699b-8cd5-487a-9c17-77e51c220797
# ╟─209f7435-ffc4-47eb-a0b9-c6b0d555409e
# ╟─184576e5-f4ca-4f4d-aab3-f30e99a22e5c
# ╠═ba4e6682-7425-4e14-8c88-d8a6ebe59ef7
# ╟─5dd5addf-b1da-4e11-a1d5-5dab2c2ddf39
# ╟─888446a1-af1e-4fc5-812d-260797677366
# ╟─d2e681bc-f912-4336-a4c4-dcb90e6b417f
# ╟─82ba1e0f-bd13-415d-bc28-617fca5ed10d
# ╟─6a46e25e-7dd5-4473-8ffa-e823904daaa5
# ╟─934ee5b0-47cb-42d9-9e47-6e16cb67491f
# ╟─cdc61318-9b54-426d-9e73-ae4f5baff470
# ╟─c52aa9ba-f397-4ae2-b004-4e182f82895e
# ╟─01d8c6a0-aba5-44a7-8737-5c28611841d8
# ╟─53a3d55d-44b3-4a59-b137-5d330aedbe65
# ╠═f1684378-f05c-4176-8723-fa10127a6260
# ╠═9a01e2ef-9676-48bc-ba29-badc9e3dc796
# ╟─2fe94b1c-babd-4ee6-9511-7294ee0e407e
# ╟─e7e74927-27e1-44b7-8f7a-f8781ca42bbc
# ╠═cc9be570-c926-4bca-a5f8-248976bf2ab6
# ╟─62bf8193-d809-4111-a694-355f58e5f6d2
# ╟─08eeee5a-cb97-490b-bfef-18860d1d5d9b
# ╟─bc31719e-eef7-4457-b236-677c1e3cbfbd
# ╟─d9144932-5624-4e8f-925d-26d5f97f168d
# ╟─4463f520-18c7-463c-a9ea-918b911c1025
# ╟─bea582be-a4bb-428f-8825-51f585c3aaee
# ╟─4bdbbc87-3ea6-490e-b6e2-177661298174
# ╟─c1ae1d63-c65b-4654-b14a-e6ba77a12449
# ╟─a05eeb04-8fd3-4867-b75a-7af866005b78
# ╟─f540ae75-a134-43c1-9e2e-1fe35c103f03
# ╟─f43613ca-aed3-4b50-ba07-37626887c837
# ╟─e42fe256-85f5-48e9-a267-9dc36ed56032
# ╟─bf553236-8074-4fec-b371-e16cb24c6cc6
# ╟─9d73b0c9-6784-417d-81ea-52890faf572d
# ╟─745ce1b1-e9c6-4e4e-86fe-2da2d7db05f8
# ╟─ac0f42ca-3a4f-4a6d-a472-d2443bd182bc
# ╟─1e4b5689-28e5-4a50-a4e8-5ded9296c145
# ╟─8dc30252-509e-4855-9bd6-16ab3d311259
# ╟─e5c5ad21-6e83-46ae-bbb4-601e647f62bc
# ╟─3a53a235-77c4-4d19-8dfd-e297f5b7bf7c
# ╟─9ae1a5f1-7c61-44fa-88e5-6988051439a2
# ╟─1d0f343b-9e06-4ee7-823a-56beeaa4763f
# ╟─cf29de2f-f2ca-4f10-8ce0-9a99a236b9d6
# ╟─c79a4f15-f104-4050-9db4-ca9949651825
# ╟─4423a121-077b-4bec-8439-a29bc73981fb
# ╟─f9c5ecc6-0962-4f80-a24c-7e3c8713fcaa
# ╟─c78eed75-0e5e-4b92-a5eb-dfe363accfb1
# ╟─17533291-69d4-4e54-b769-d389b21aeb2c
# ╟─425f5cd7-7f9f-4a44-9221-4b0225d10f1f
# ╟─612ace2e-008d-4469-899a-162f400a9d9b
# ╟─57556606-a2cc-4100-bdcb-402790d5ea88
# ╟─9bd61139-35ff-4a1c-b9f9-7045d21cef17
# ╟─57686419-6f5e-4141-ac18-946c3b3568bf
# ╟─b2a4357a-d3b9-4414-8b1d-55fa0d2a51a7
# ╟─880d88dc-482b-4188-a95b-1002942ebe46
# ╟─a51676cc-521c-46d0-befa-80c690f3d0ab
