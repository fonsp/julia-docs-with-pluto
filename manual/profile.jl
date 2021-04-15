### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03d515a4-9e19-11eb-3807-8be4bade1f9e
md"""
# Profiling
"""

# ╔═╡ 03d515ce-9e19-11eb-1f6f-f7c149847b6e
md"""
The `Profile` module provides tools to help developers improve the performance of their code. When used, it takes measurements on running code, and produces output that helps you understand how much time is spent on individual line(s). The most common usage is to identify "bottlenecks" as targets for optimization.
"""

# ╔═╡ 03d515ea-9e19-11eb-1a6f-7f28381721cb
md"""
`Profile` implements what is known as a "sampling" or [statistical profiler](https://en.wikipedia.org/wiki/Profiling_(computer_programming)).  It works by periodically taking a backtrace during the execution of any task. Each backtrace captures the currently-running function and line number, plus the complete chain of function calls that led to this line, and hence is a "snapshot" of the current state of execution.
"""

# ╔═╡ 03d51608-9e19-11eb-1034-075a4a9d0dba
md"""
If much of your run time is spent executing a particular line of code, this line will show up frequently in the set of all backtraces. In other words, the "cost" of a given line–or really, the cost of the sequence of function calls up to and including this line–is proportional to how often it appears in the set of all backtraces.
"""

# ╔═╡ 03d5161c-9e19-11eb-1d69-a3fed7dcc8fa
md"""
A sampling profiler does not provide complete line-by-line coverage, because the backtraces occur at intervals (by default, 1 ms on Unix systems and 10 ms on Windows, although the actual scheduling is subject to operating system load). Moreover, as discussed further below, because samples are collected at a sparse subset of all execution points, the data collected by a sampling profiler is subject to statistical noise.
"""

# ╔═╡ 03d5162e-9e19-11eb-0fd6-51c06245f236
md"""
Despite these limitations, sampling profilers have substantial strengths:
"""

# ╔═╡ 03d51694-9e19-11eb-2cb1-2d7449532ae3
md"""
  * You do not have to make any modifications to your code to take timing measurements.
  * It can profile into Julia's core code and even (optionally) into C and Fortran libraries.
  * By running "infrequently" there is very little performance overhead; while profiling, your code can run at nearly native speed.
"""

# ╔═╡ 03d516bc-9e19-11eb-1b18-37443680c144
md"""
For these reasons, it's recommended that you try using the built-in sampling profiler before considering any alternatives.
"""

# ╔═╡ 03d516da-9e19-11eb-0501-a3d2b7abffc0
md"""
## Basic usage
"""

# ╔═╡ 03d516ee-9e19-11eb-3499-4169a247bce6
md"""
Let's work with a simple test case:
"""

# ╔═╡ 03d51a90-9e19-11eb-373c-412f2a054059
function myfunc()
           A = rand(200, 200, 400)
           maximum(A)
       end

# ╔═╡ 03d51ab8-9e19-11eb-243d-414bec609064
md"""
It's a good idea to first run the code you intend to profile at least once (unless you want to profile Julia's JIT-compiler):
"""

# ╔═╡ 03d51b8a-9e19-11eb-2281-d12a42d72b21
myfunc() # run once to force compilation

# ╔═╡ 03d51b94-9e19-11eb-2044-65cb7ba01e6d
md"""
Now we're ready to profile this function:
"""

# ╔═╡ 03d51d60-9e19-11eb-0730-b1f3a64c8dc1
using Profile

# ╔═╡ 03d51d6a-9e19-11eb-1562-bb5648bc4ed6
@profile myfunc()

# ╔═╡ 03d51d92-9e19-11eb-3fd2-e3401902a09d
md"""
To see the profiling results, there are several graphical browsers. One "family" of visualizers is based on [FlameGraphs.jl](https://github.com/timholy/FlameGraphs.jl), with each family member providing a different user interface:
"""

# ╔═╡ 03d51e6c-9e19-11eb-3c85-97cb120a6a71
md"""
  * [Juno](https://junolab.org/) is a full IDE with built-in support for profile visualization
  * [ProfileView.jl](https://github.com/timholy/ProfileView.jl) is a stand-alone visualizer based on GTK
  * [ProfileVega.jl](https://github.com/davidanthoff/ProfileVega.jl) uses VegaLight and integrates well with Jupyter notebooks
  * [StatProfilerHTML](https://github.com/tkluck/StatProfilerHTML.jl) produces HTML and presents some additional summaries, and also integrates well with Jupyter notebooks
  * [ProfileSVG](https://github.com/timholy/ProfileSVG.jl) renders SVG
"""

# ╔═╡ 03d51e8c-9e19-11eb-2a1d-a38bfe0504cc
md"""
An entirely independent approach to profile visualization is [PProf.jl](https://github.com/vchuravy/PProf.jl), which uses the external `pprof` tool.
"""

# ╔═╡ 03d51e9e-9e19-11eb-2a09-f3df47c17c95
md"""
Here, though, we'll use the text-based display that comes with the standard library:
"""

# ╔═╡ 03d51f9a-9e19-11eb-38f7-2f0534776a8b
Profile.print()

# ╔═╡ 03d51fb8-9e19-11eb-026b-6d043da114e6
md"""
Each line of this display represents a particular spot (line number) in the code. Indentation is used to indicate the nested sequence of function calls, with more-indented lines being deeper in the sequence of calls. In each line, the first "field" is the number of backtraces (samples) taken *at this line or in any functions executed by this line*. The second field is the file name and line number and the third field is the function name. Note that the specific line numbers may change as Julia's code changes; if you want to follow along, it's best to run this example yourself.
"""

# ╔═╡ 03d51ff4-9e19-11eb-0323-19b0fbc05e02
md"""
In this example, we can see that the top level function called is in the file `event.jl`. This is the function that runs the REPL when you launch Julia. If you examine line 97 of `REPL.jl`, you'll see this is where the function `eval_user_input()` is called. This is the function that evaluates what you type at the REPL, and since we're working interactively these functions were invoked when we entered `@profile myfunc()`. The next line reflects actions taken in the [`@profile`](@ref) macro.
"""

# ╔═╡ 03d52012-9e19-11eb-0c0a-fd50fad6e77e
md"""
The first line shows that 80 backtraces were taken at line 73 of `event.jl`, but it's not that this line was "expensive" on its own: the third line reveals that all 80 of these backtraces were actually triggered inside its call to `eval_user_input`, and so on. To find out which operations are actually taking the time, we need to look deeper in the call chain.
"""

# ╔═╡ 03d5201c-9e19-11eb-1070-b70a42b7fa93
md"""
The first "important" line in this output is this one:
"""

# ╔═╡ 03d52288-9e19-11eb-1d69-e9ccee85630b
52 ./REPL[1]:2; myfunc()

# ╔═╡ 03d522ba-9e19-11eb-0259-995fa48376c5
md"""
`REPL` refers to the fact that we defined `myfunc` in the REPL, rather than putting it in a file; if we had used a file, this would show the file name. The `[1]` shows that the function `myfunc` was the first expression evaluated in this REPL session. Line 2 of `myfunc()` contains the call to `rand`, and there were 52 (out of 80) backtraces that occurred at this line. Below that, you can see a call to `dsfmt_fill_array_close_open!` inside `dSFMT.jl`.
"""

# ╔═╡ 03d522ce-9e19-11eb-0093-79a36c151331
md"""
A little further down, you see:
"""

# ╔═╡ 03d524d6-9e19-11eb-2341-838b37214503
28 ./REPL[1]:3; myfunc()

# ╔═╡ 03d52508-9e19-11eb-238e-81c746b5e415
md"""
Line 3 of `myfunc` contains the call to `maximum`, and there were 28 (out of 80) backtraces taken here. Below that, you can see the specific places in `base/reduce.jl` that carry out the time-consuming operations in the `maximum` function for this type of input data.
"""

# ╔═╡ 03d52510-9e19-11eb-2405-7f828e00fdee
md"""
Overall, we can tentatively conclude that generating the random numbers is approximately twice as expensive as finding the maximum element. We could increase our confidence in this result by collecting more samples:
"""

# ╔═╡ 03d528d2-9e19-11eb-14f3-13c3dac12f39
@profile (for i = 1:100; myfunc(); end)

# ╔═╡ 03d528dc-9e19-11eb-08b7-351532def1e3
Profile.print()

# ╔═╡ 03d5290e-9e19-11eb-3bfe-474f0d05e953
md"""
In general, if you have `N` samples collected at a line, you can expect an uncertainty on the order of `sqrt(N)` (barring other sources of noise, like how busy the computer is with other tasks). The major exception to this rule is garbage collection, which runs infrequently but tends to be quite expensive. (Since Julia's garbage collector is written in C, such events can be detected using the `C=true` output mode described below, or by using [ProfileView.jl](https://github.com/timholy/ProfileView.jl).)
"""

# ╔═╡ 03d52922-9e19-11eb-0954-c9506cae07bb
md"""
This illustrates the default "tree" dump; an alternative is the "flat" dump, which accumulates counts independent of their nesting:
"""

# ╔═╡ 03d52ada-9e19-11eb-1364-9b2c2f6d0987
Profile.print(format=:flat)

# ╔═╡ 03d52aee-9e19-11eb-11e0-a195bdf7da81
md"""
If your code has recursion, one potentially-confusing point is that a line in a "child" function can accumulate more counts than there are total backtraces. Consider the following function definitions:
"""

# ╔═╡ 03d52b14-9e19-11eb-18d4-d7bb2936c908
md"""
```julia
dumbsum(n::Integer) = n == 1 ? 1 : 1 + dumbsum(n-1)
dumbsum3() = dumbsum(3)
```
"""

# ╔═╡ 03d52b2a-9e19-11eb-2c83-7f9fbef12c6d
md"""
If you were to profile `dumbsum3`, and a backtrace was taken while it was executing `dumbsum(1)`, the backtrace would look like this:
"""

# ╔═╡ 03d52b3e-9e19-11eb-14b7-79f4859edb60
md"""
```julia
dumbsum3
    dumbsum(3)
        dumbsum(2)
            dumbsum(1)
```
"""

# ╔═╡ 03d52b5c-9e19-11eb-31c2-bbe1ce4ae737
md"""
Consequently, this child function gets 3 counts, even though the parent only gets one. The "tree" representation makes this much clearer, and for this reason (among others) is probably the most useful way to view the results.
"""

# ╔═╡ 03d52b70-9e19-11eb-0d37-677ead5b8b2f
md"""
## Accumulation and clearing
"""

# ╔═╡ 03d52b98-9e19-11eb-1eab-01834c9c5512
md"""
Results from [`@profile`](@ref) accumulate in a buffer; if you run multiple pieces of code under [`@profile`](@ref), then [`Profile.print()`](@ref) will show you the combined results. This can be very useful, but sometimes you want to start fresh; you can do so with [`Profile.clear()`](@ref).
"""

# ╔═╡ 03d52bb8-9e19-11eb-0e3b-2534b5b2649a
md"""
## Options for controlling the display of profile results
"""

# ╔═╡ 03d52bd4-9e19-11eb-063d-b579c6fe2cf9
md"""
[`Profile.print`](@ref) has more options than we've described so far. Let's see the full declaration:
"""

# ╔═╡ 03d52bea-9e19-11eb-096f-b9bbbcaf4e54
md"""
```julia
function print(io::IO = stdout, data = fetch(); kwargs...)
```
"""

# ╔═╡ 03d52c10-9e19-11eb-26a7-eb4706016ff0
md"""
Let's first discuss the two positional arguments, and later the keyword arguments:
"""

# ╔═╡ 03d52cba-9e19-11eb-00b9-cbffaaabc6df
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

# ╔═╡ 03d52cc4-9e19-11eb-246e-67f5a1e80211
md"""
The keyword arguments can be any combination of:
"""

# ╔═╡ 03d52e88-9e19-11eb-0a50-9d7c09842e9e
md"""
  * `format` – Introduced above, determines whether backtraces are printed  with (default, `:tree`) or without (`:flat`) indentation indicating tree  structure.
  * `C` – If `true`, backtraces from C and Fortran code are shown (normally they are excluded). Try running the introductory example with `Profile.print(C = true)`. This can be extremely helpful in deciding whether it's Julia code or C code that is causing a bottleneck; setting `C = true` also improves the interpretability of the nesting, at the cost of longer profile dumps.
  * `combine` – Some lines of code contain multiple operations; for example, `s += A[i]` contains both an array reference (`A[i]`) and a sum operation. These correspond to different lines in the generated machine code, and hence there may be two or more different addresses captured during backtraces on this line. `combine = true` lumps them together, and is probably what you typically want, but you can generate an output separately for each unique instruction pointer with `combine = false`.
  * `maxdepth` – Limits frames at a depth higher than `maxdepth` in the `:tree` format.
  * `sortedby` – Controls the order in `:flat` format. `:filefuncline` (default) sorts by the source line, whereas `:count` sorts in order of number of collected samples.
  * `noisefloor` – Limits frames that are below the heuristic noise floor of the sample (only applies to format `:tree`). A suggested value to try for this is 2.0 (the default is 0). This parameter hides samples for which `n <= noisefloor * √N`, where `n` is the number of samples on this line, and `N` is the number of samples for the callee.
  * `mincount` – Limits frames with less than `mincount` occurrences.
"""

# ╔═╡ 03d52ea4-9e19-11eb-3264-739a28af8b78
md"""
File/function names are sometimes truncated (with `...`), and indentation is truncated with a `+n` at the beginning, where `n` is the number of extra spaces that would have been inserted, had there been room. If you want a complete profile of deeply-nested code, often a good idea is to save to a file using a wide `displaysize` in an [`IOContext`](@ref):
"""

# ╔═╡ 03d52ec2-9e19-11eb-3be7-79f222b0ae7c
md"""
```julia
open("/tmp/prof.txt", "w") do s
    Profile.print(IOContext(s, :displaysize => (24, 500)))
end
```
"""

# ╔═╡ 03d52ed6-9e19-11eb-1081-3d2684c0ff02
md"""
## Configuration
"""

# ╔═╡ 03d52f08-9e19-11eb-18c8-33539244c125
md"""
[`@profile`](@ref) just accumulates backtraces, and the analysis happens when you call [`Profile.print()`](@ref). For a long-running computation, it's entirely possible that the pre-allocated buffer for storing backtraces will be filled. If that happens, the backtraces stop but your computation continues. As a consequence, you may miss some important profiling data (you will get a warning when that happens).
"""

# ╔═╡ 03d52f1a-9e19-11eb-1a69-d145e423179d
md"""
You can obtain and configure the relevant parameters this way:
"""

# ╔═╡ 03d52f30-9e19-11eb-0b66-2d6f7b7320da
md"""
```julia
Profile.init() # returns the current settings
Profile.init(n = 10^7, delay = 0.01)
```
"""

# ╔═╡ 03d52f4e-9e19-11eb-1110-f51226ba9a9a
md"""
`n` is the total number of instruction pointers you can store, with a default value of `10^6`. If your typical backtrace is 20 instruction pointers, then you can collect 50000 backtraces, which suggests a statistical uncertainty of less than 1%. This may be good enough for most applications.
"""

# ╔═╡ 03d52f6c-9e19-11eb-2e39-27fd161056a4
md"""
Consequently, you are more likely to need to modify `delay`, expressed in seconds, which sets the amount of time that Julia gets between snapshots to perform the requested computations. A very long-running job might not need frequent backtraces. The default setting is `delay = 0.001`. Of course, you can decrease the delay as well as increase it; however, the overhead of profiling grows once the delay becomes similar to the amount of time needed to take a backtrace (~30 microseconds on the author's laptop).
"""

# ╔═╡ 03d52f76-9e19-11eb-1c65-5d814d230be4
md"""
## Memory allocation analysis
"""

# ╔═╡ 03d52f9e-9e19-11eb-37c5-17d146912d76
md"""
One of the most common techniques to improve performance is to reduce memory allocation. The total amount of allocation can be measured with [`@time`](@ref) and [`@allocated`](@ref), and specific lines triggering allocation can often be inferred from profiling via the cost of garbage collection that these lines incur. However, sometimes it is more efficient to directly measure the amount of memory allocated by each line of code.
"""

# ╔═╡ 03d52fc6-9e19-11eb-0459-65f03b771496
md"""
To measure allocation line-by-line, start Julia with the `--track-allocation=<setting>` command-line option, for which you can choose `none` (the default, do not measure allocation), `user` (measure memory allocation everywhere except Julia's core code), or `all` (measure memory allocation at each line of Julia code). Allocation gets measured for each line of compiled code. When you quit Julia, the cumulative results are written to text files with `.mem` appended after the file name, residing in the same directory as the source file. Each line lists the total number of bytes allocated. The [`Coverage` package](https://github.com/JuliaCI/Coverage.jl) contains some elementary analysis tools, for example to sort the lines in order of number of bytes allocated.
"""

# ╔═╡ 03d52ff0-9e19-11eb-2353-1f08a9b7bf62
md"""
In interpreting the results, there are a few important details. Under the `user` setting, the first line of any function directly called from the REPL will exhibit allocation due to events that happen in the REPL code itself. More significantly, JIT-compilation also adds to allocation counts, because much of Julia's compiler is written in Julia (and compilation usually requires memory allocation). The recommended procedure is to force compilation by executing all the commands you want to analyze, then call [`Profile.clear_malloc_data()`](@ref) to reset all allocation counters.  Finally, execute the desired commands and quit Julia to trigger the generation of the `.mem` files.
"""

# ╔═╡ 03d5300c-9e19-11eb-09aa-194d65277dbd
md"""
## External Profiling
"""

# ╔═╡ 03d53034-9e19-11eb-33ac-67a8fb925bb1
md"""
Currently Julia supports `Intel VTune`, `OProfile` and `perf` as external profiling tools.
"""

# ╔═╡ 03d53050-9e19-11eb-0cce-776100abfb25
md"""
Depending on the tool you choose, compile with `USE_INTEL_JITEVENTS`, `USE_OPROFILE_JITEVENTS` and `USE_PERF_JITEVENTS` set to 1 in `Make.user`. Multiple flags are supported.
"""

# ╔═╡ 03d53070-9e19-11eb-0910-2d9cebd13fe5
md"""
Before running Julia set the environment variable `ENABLE_JITPROFILING` to 1.
"""

# ╔═╡ 03d53082-9e19-11eb-2da0-174b7cd81393
md"""
Now you have a multitude of ways to employ those tools! For example with `OProfile` you can try a simple recording :
"""

# ╔═╡ 03d53110-9e19-11eb-1a53-bbd81e3bfc61
>ENABLE_JITPROFILING

# ╔═╡ 03d5312e-9e19-11eb-09d2-d7c35821d830
md"""
Or similary with `perf` :
"""

# ╔═╡ 03d5328e-9e19-11eb-1ed1-89cb126ca30b
$ ENABLE_JITPROFILING=1 perf

# ╔═╡ 03d532a0-9e19-11eb-2e7e-153c80402fc9
md"""
There are many more interesting things that you can measure about your program, to get a comprehensive list please read the [Linux perf examples page](http://www.brendangregg.com/perf.html).
"""

# ╔═╡ 03d532c0-9e19-11eb-17dd-f304417fa93d
md"""
Remember that perf saves for each execution a `perf.data` file that, even for small programs, can get quite large. Also the perf LLVM module saves temporarily debug objects in `~/.debug/jit`, remember to clean that folder frequently.
"""

# ╔═╡ Cell order:
# ╟─03d515a4-9e19-11eb-3807-8be4bade1f9e
# ╟─03d515ce-9e19-11eb-1f6f-f7c149847b6e
# ╟─03d515ea-9e19-11eb-1a6f-7f28381721cb
# ╟─03d51608-9e19-11eb-1034-075a4a9d0dba
# ╟─03d5161c-9e19-11eb-1d69-a3fed7dcc8fa
# ╟─03d5162e-9e19-11eb-0fd6-51c06245f236
# ╟─03d51694-9e19-11eb-2cb1-2d7449532ae3
# ╟─03d516bc-9e19-11eb-1b18-37443680c144
# ╟─03d516da-9e19-11eb-0501-a3d2b7abffc0
# ╟─03d516ee-9e19-11eb-3499-4169a247bce6
# ╠═03d51a90-9e19-11eb-373c-412f2a054059
# ╟─03d51ab8-9e19-11eb-243d-414bec609064
# ╠═03d51b8a-9e19-11eb-2281-d12a42d72b21
# ╟─03d51b94-9e19-11eb-2044-65cb7ba01e6d
# ╠═03d51d60-9e19-11eb-0730-b1f3a64c8dc1
# ╠═03d51d6a-9e19-11eb-1562-bb5648bc4ed6
# ╟─03d51d92-9e19-11eb-3fd2-e3401902a09d
# ╟─03d51e6c-9e19-11eb-3c85-97cb120a6a71
# ╟─03d51e8c-9e19-11eb-2a1d-a38bfe0504cc
# ╟─03d51e9e-9e19-11eb-2a09-f3df47c17c95
# ╠═03d51f9a-9e19-11eb-38f7-2f0534776a8b
# ╟─03d51fb8-9e19-11eb-026b-6d043da114e6
# ╟─03d51ff4-9e19-11eb-0323-19b0fbc05e02
# ╟─03d52012-9e19-11eb-0c0a-fd50fad6e77e
# ╟─03d5201c-9e19-11eb-1070-b70a42b7fa93
# ╠═03d52288-9e19-11eb-1d69-e9ccee85630b
# ╟─03d522ba-9e19-11eb-0259-995fa48376c5
# ╟─03d522ce-9e19-11eb-0093-79a36c151331
# ╠═03d524d6-9e19-11eb-2341-838b37214503
# ╟─03d52508-9e19-11eb-238e-81c746b5e415
# ╟─03d52510-9e19-11eb-2405-7f828e00fdee
# ╠═03d528d2-9e19-11eb-14f3-13c3dac12f39
# ╠═03d528dc-9e19-11eb-08b7-351532def1e3
# ╟─03d5290e-9e19-11eb-3bfe-474f0d05e953
# ╟─03d52922-9e19-11eb-0954-c9506cae07bb
# ╠═03d52ada-9e19-11eb-1364-9b2c2f6d0987
# ╟─03d52aee-9e19-11eb-11e0-a195bdf7da81
# ╟─03d52b14-9e19-11eb-18d4-d7bb2936c908
# ╟─03d52b2a-9e19-11eb-2c83-7f9fbef12c6d
# ╟─03d52b3e-9e19-11eb-14b7-79f4859edb60
# ╟─03d52b5c-9e19-11eb-31c2-bbe1ce4ae737
# ╟─03d52b70-9e19-11eb-0d37-677ead5b8b2f
# ╟─03d52b98-9e19-11eb-1eab-01834c9c5512
# ╟─03d52bb8-9e19-11eb-0e3b-2534b5b2649a
# ╟─03d52bd4-9e19-11eb-063d-b579c6fe2cf9
# ╟─03d52bea-9e19-11eb-096f-b9bbbcaf4e54
# ╟─03d52c10-9e19-11eb-26a7-eb4706016ff0
# ╟─03d52cba-9e19-11eb-00b9-cbffaaabc6df
# ╟─03d52cc4-9e19-11eb-246e-67f5a1e80211
# ╟─03d52e88-9e19-11eb-0a50-9d7c09842e9e
# ╟─03d52ea4-9e19-11eb-3264-739a28af8b78
# ╟─03d52ec2-9e19-11eb-3be7-79f222b0ae7c
# ╟─03d52ed6-9e19-11eb-1081-3d2684c0ff02
# ╟─03d52f08-9e19-11eb-18c8-33539244c125
# ╟─03d52f1a-9e19-11eb-1a69-d145e423179d
# ╟─03d52f30-9e19-11eb-0b66-2d6f7b7320da
# ╟─03d52f4e-9e19-11eb-1110-f51226ba9a9a
# ╟─03d52f6c-9e19-11eb-2e39-27fd161056a4
# ╟─03d52f76-9e19-11eb-1c65-5d814d230be4
# ╟─03d52f9e-9e19-11eb-37c5-17d146912d76
# ╟─03d52fc6-9e19-11eb-0459-65f03b771496
# ╟─03d52ff0-9e19-11eb-2353-1f08a9b7bf62
# ╟─03d5300c-9e19-11eb-09aa-194d65277dbd
# ╟─03d53034-9e19-11eb-33ac-67a8fb925bb1
# ╟─03d53050-9e19-11eb-0cce-776100abfb25
# ╟─03d53070-9e19-11eb-0910-2d9cebd13fe5
# ╟─03d53082-9e19-11eb-2da0-174b7cd81393
# ╠═03d53110-9e19-11eb-1a53-bbd81e3bfc61
# ╟─03d5312e-9e19-11eb-09d2-d7c35821d830
# ╠═03d5328e-9e19-11eb-1ed1-89cb126ca30b
# ╟─03d532a0-9e19-11eb-2e7e-153c80402fc9
# ╟─03d532c0-9e19-11eb-17dd-f304417fa93d
