### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03c3a238-9e19-11eb-22c3-21dba0a25dd7
md"""
# Environment Variables
"""

# ╔═╡ 03c3a2ce-9e19-11eb-3d92-5fd3ac23ebb8
md"""
Julia can be configured with a number of environment variables, set either in the usual way for each operating system, or in a portable way from within Julia. Supposing that you want to set the environment variable `JULIA_EDITOR` to `vim`, you can type `ENV["JULIA_EDITOR"] = "vim"` (for instance, in the REPL) to make this change on a case by case basis, or add the same to the user configuration file `~/.julia/config/startup.jl` in the user's home directory to have a permanent effect. The current value of the same environment variable can be determined by evaluating `ENV["JULIA_EDITOR"]`.
"""

# ╔═╡ 03c3a31c-9e19-11eb-33cd-877aaa8fe58f
md"""
The environment variables that Julia uses generally start with `JULIA`. If [`InteractiveUtils.versioninfo`](@ref) is called with the keyword `verbose=true`, then the output will list any defined environment variables relevant for Julia, including those which include `JULIA` in their names.
"""

# ╔═╡ 03c3a468-9e19-11eb-31a1-b97b9598467e
md"""
!!! note
    Some variables, such as `JULIA_NUM_THREADS` and `JULIA_PROJECT`, need to be set before Julia starts, therefore adding these to `~/.julia/config/startup.jl` is too late in the startup process. In Bash, environment variables can either be set manually by running, e.g., `export JULIA_NUM_THREADS=4` before starting Julia, or by adding the same command to `~/.bashrc` or `~/.bash_profile` to set the variable each time Bash is started.
"""

# ╔═╡ 03c3a4e0-9e19-11eb-3d46-317fe6b07b80
md"""
## File locations
"""

# ╔═╡ 03c3a508-9e19-11eb-1bb6-0b883b85a02a
md"""
### `JULIA_BINDIR`
"""

# ╔═╡ 03c3a53a-9e19-11eb-2a69-2f6f579c9a3b
md"""
The absolute path of the directory containing the Julia executable, which sets the global variable [`Sys.BINDIR`](@ref). If `$JULIA_BINDIR` is not set, then Julia determines the value `Sys.BINDIR` at run-time.
"""

# ╔═╡ 03c3a55a-9e19-11eb-3c10-df6581a7e972
md"""
The executable itself is one of
"""

# ╔═╡ 03c3a896-9e19-11eb-1fdd-c72ceb2fccf8
$JULIA_BINDIR/julia

# ╔═╡ 03c3a8b4-9e19-11eb-172f-bb8c5bd7e78b
md"""
by default.
"""

# ╔═╡ 03c3a8d2-9e19-11eb-3924-1fb827963b18
md"""
The global variable `Base.DATAROOTDIR` determines a relative path from `Sys.BINDIR` to the data directory associated with Julia. Then the path
"""

# ╔═╡ 03c3aa96-9e19-11eb-0ee6-7ddb911f7918
$JULIA_BINDIR/$DATAROOTDIR/julia/base

# ╔═╡ 03c3aab2-9e19-11eb-3c3e-ddc982997a89
md"""
determines the directory in which Julia initially searches for source files (via `Base.find_source_file()`).
"""

# ╔═╡ 03c3aac8-9e19-11eb-30bd-234e70a9add5
md"""
Likewise, the global variable `Base.SYSCONFDIR` determines a relative path to the configuration file directory. Then Julia searches for a `startup.jl` file at
"""

# ╔═╡ 03c3ac7e-9e19-11eb-293c-3dd4d29b3fe0
$JULIA_BINDIR/$SYSCONFDIR/julia/startup.jl

# ╔═╡ 03c3acb0-9e19-11eb-15a4-871a9d190369
md"""
by default (via `Base.load_julia_startup()`).
"""

# ╔═╡ 03c3acd8-9e19-11eb-317a-699cfbf06f81
md"""
For example, a Linux installation with a Julia executable located at `/bin/julia`, a `DATAROOTDIR` of `../share`, and a `SYSCONFDIR` of `../etc` will have `JULIA_BINDIR` set to `/bin`, a source-file search path of
"""

# ╔═╡ 03c3ad6e-9e19-11eb-1bd9-87a66a92d24b
/share

# ╔═╡ 03c3ad98-9e19-11eb-19f9-49912b351e0b
md"""
and a global configuration search path of
"""

# ╔═╡ 03c3adf0-9e19-11eb-1573-89bb66bfc00d
/etc

# ╔═╡ 03c3ae0e-9e19-11eb-0e36-95a7e9f5a500
md"""
### `JULIA_PROJECT`
"""

# ╔═╡ 03c3ae40-9e19-11eb-01ef-2386ed57632c
md"""
A directory path that indicates which project should be the initial active project. Setting this environment variable has the same effect as specifying the `--project` start-up option, but `--project` has higher precedence. If the variable is set to `@.` then Julia tries to find a project directory that contains `Project.toml` or `JuliaProject.toml` file from the current directory and its parents. See also the chapter on [Code Loading](@ref code-loading).
"""

# ╔═╡ 03c3ae9c-9e19-11eb-3c8f-6f295dc6ea63
md"""
!!! note
    `JULIA_PROJECT` must be defined before starting julia; defining it in `startup.jl` is too late in the startup process.
"""

# ╔═╡ 03c3aeae-9e19-11eb-183a-0b189da69519
md"""
### `JULIA_LOAD_PATH`
"""

# ╔═╡ 03c3aed6-9e19-11eb-2afd-f18af67b63bf
md"""
The `JULIA_LOAD_PATH` environment variable is used to populate the global Julia [`LOAD_PATH`](@ref) variable, which determines which packages can be loaded via `import` and `using` (see [Code Loading](@ref code-loading)).
"""

# ╔═╡ 03c3af08-9e19-11eb-3a9b-1d414a50fa09
md"""
Unlike the shell `PATH` variable, empty entries in `JULIA_LOAD_PATH` are expanded to the default value of `LOAD_PATH`, `["@", "@v#.#", "@stdlib"]` when populating `LOAD_PATH`. This allows easy appending, prepending, etc. of the load path value in shell scripts regardless of whether `JULIA_LOAD_PATH` is already set or not. For example, to prepend the directory `/foo/bar` to `LOAD_PATH` just do
"""

# ╔═╡ 03c3b0e8-9e19-11eb-0120-75cb8beb0265
export JULIA_LOAD_PATH="/foo/bar:$JULIA_LOAD_PATH"

# ╔═╡ 03c3b12e-9e19-11eb-0fa9-417f67ede6b2
md"""
If the `JULIA_LOAD_PATH` environment variable is already set, its old value will be prepended with `/foo/bar`. On the other hand, if `JULIA_LOAD_PATH` is not set, then it will be set to `/foo/bar:` which will expand to a `LOAD_PATH` value of `["/foo/bar", "@", "@v#.#", "@stdlib"]`. If `JULIA_LOAD_PATH` is set to the empty string, it expands to an empty `LOAD_PATH` array. In other words, the empty string is interpreted as a zero-element array, not a one-element array of the empty string. This behavior was chosen so that it would be possible to set an empty load path via the environment variable. If you want the default load path, either unset the environment variable or if it must have a value, set it to the string `:`.
"""

# ╔═╡ 03c3b142-9e19-11eb-142f-8d28ca807a17
md"""
### `JULIA_DEPOT_PATH`
"""

# ╔═╡ 03c3b16c-9e19-11eb-287f-2170b9fd4480
md"""
The `JULIA_DEPOT_PATH` environment variable is used to populate the global Julia [`DEPOT_PATH`](@ref) variable, which controls where the package manager, as well as Julia's code loading mechanisms, look for package registries, installed packages, named environments, repo clones, cached compiled package images, configuration files, and the default location of the REPL's history file.
"""

# ╔═╡ 03c3b192-9e19-11eb-2b62-67b619393c8a
md"""
Unlike the shell `PATH` variable but similar to `JULIA_LOAD_PATH`, empty entries in `JULIA_DEPOT_PATH` are expanded to the default value of `DEPOT_PATH`. This allows easy appending, prepending, etc. of the depot path value in shell scripts regardless of whether `JULIA_DEPOT_PATH` is already set or not. For example, to prepend the directory `/foo/bar` to `DEPOT_PATH` just do
"""

# ╔═╡ 03c3b2f0-9e19-11eb-3089-15dcb34f4658
export JULIA_DEPOT_PATH="/foo/bar:$JULIA_DEPOT_PATH"

# ╔═╡ 03c3b34a-9e19-11eb-0636-6b2b30143365
md"""
If the `JULIA_DEPOT_PATH` environment variable is already set, its old value will be prepended with `/foo/bar`. On the other hand, if `JULIA_DEPOT_PATH` is not set, then it will be set to `/foo/bar:` which will have the effect of prepending `/foo/bar` to the default depot path. If `JULIA_DEPOT_PATH` is set to the empty string, it expands to an empty `DEPOT_PATH` array. In other words, the empty string is interpreted as a zero-element array, not a one-element array of the empty string. This behavior was chosen so that it would be possible to set an empty depot path via the environment variable. If you want the default depot path, either unset the environment variable or if it must have a value, set it to the string `:`.
"""

# ╔═╡ 03c3b386-9e19-11eb-2d4d-9b3cdef59b6a
md"""
!!! note
    On Windows, path elements are separated by the `;` character, as is the case with most path lists on Windows.
"""

# ╔═╡ 03c3b398-9e19-11eb-0f8a-053676afff18
md"""
### `JULIA_HISTORY`
"""

# ╔═╡ 03c3b3b8-9e19-11eb-34cf-09c6377639df
md"""
The absolute path `REPL.find_hist_file()` of the REPL's history file. If `$JULIA_HISTORY` is not set, then `REPL.find_hist_file()` defaults to
"""

# ╔═╡ 03c3b636-9e19-11eb-21df-fd375f3007c2
$(DEPOT_PATH[1])/logs/repl_history.jl

# ╔═╡ 03c3b64c-9e19-11eb-02fb-313cdc0bf48d
md"""
## External applications
"""

# ╔═╡ 03c3b660-9e19-11eb-34c1-bf6e85458b0c
md"""
### `JULIA_SHELL`
"""

# ╔═╡ 03c3b692-9e19-11eb-1a87-d3d4b801aaa8
md"""
The absolute path of the shell with which Julia should execute external commands (via `Base.repl_cmd()`). Defaults to the environment variable `$SHELL`, and falls back to `/bin/sh` if `$SHELL` is unset.
"""

# ╔═╡ 03c3b6c4-9e19-11eb-0bde-7986717698fd
md"""
!!! note
    On Windows, this environment variable is ignored, and external commands are executed directly.
"""

# ╔═╡ 03c3b6da-9e19-11eb-32fc-85733c80d692
md"""
### `JULIA_EDITOR`
"""

# ╔═╡ 03c3b700-9e19-11eb-2397-f77520d780fa
md"""
The editor returned by `InteractiveUtils.editor()` and used in, e.g., [`InteractiveUtils.edit`](@ref), referring to the command of the preferred editor, for instance `vim`.
"""

# ╔═╡ 03c3b728-9e19-11eb-0f61-2d9a61f12094
md"""
`$JULIA_EDITOR` takes precedence over `$VISUAL`, which in turn takes precedence over `$EDITOR`. If none of these environment variables is set, then the editor is taken to be `open` on Windows and OS X, or `/etc/alternatives/editor` if it exists, or `emacs` otherwise.
"""

# ╔═╡ 03c3b73e-9e19-11eb-3444-3d0772dcf81f
md"""
## Parallelization
"""

# ╔═╡ 03c3b75a-9e19-11eb-2aee-f39c37003476
md"""
### `JULIA_CPU_THREADS`
"""

# ╔═╡ 03c3b76c-9e19-11eb-260b-452e369cf763
md"""
Overrides the global variable [`Base.Sys.CPU_THREADS`](@ref), the number of logical CPU cores available.
"""

# ╔═╡ 03c3b782-9e19-11eb-3276-2fc102faf382
md"""
### `JULIA_WORKER_TIMEOUT`
"""

# ╔═╡ 03c3b7b4-9e19-11eb-2446-c998af796a76
md"""
A [`Float64`](@ref) that sets the value of `Distributed.worker_timeout()` (default: `60.0`). This function gives the number of seconds a worker process will wait for a master process to establish a connection before dying.
"""

# ╔═╡ 03c3b7c8-9e19-11eb-0a26-7575c5732926
md"""
### [`JULIA_NUM_THREADS`](@id JULIA_NUM_THREADS)
"""

# ╔═╡ 03c3b7e6-9e19-11eb-30f8-ff832efd8099
md"""
An unsigned 64-bit integer (`uint64_t`) that sets the maximum number of threads available to Julia. If `$JULIA_NUM_THREADS` is not positive or is not set, or if the number of CPU threads cannot be determined through system calls, then the number of threads is set to `1`.
"""

# ╔═╡ 03c3b818-9e19-11eb-0380-fd59a301c037
md"""
!!! note
    `JULIA_NUM_THREADS` must be defined before starting julia; defining it in `startup.jl` is too late in the startup process.
"""

# ╔═╡ 03c3b85e-9e19-11eb-0783-03aad20da6e1
md"""
!!! compat "Julia 1.5"
    In Julia 1.5 and above the number of threads can also be specified on startup using the `-t`/`--threads` command line argument.
"""

# ╔═╡ 03c3b874-9e19-11eb-1430-07daa4c5746c
md"""
### `JULIA_THREAD_SLEEP_THRESHOLD`
"""

# ╔═╡ 03c3b886-9e19-11eb-0e5d-53799d4fe636
md"""
If set to a string that starts with the case-insensitive substring `"infinite"`, then spinning threads never sleep. Otherwise, `$JULIA_THREAD_SLEEP_THRESHOLD` is interpreted as an unsigned 64-bit integer (`uint64_t`) and gives, in nanoseconds, the amount of time after which spinning threads should sleep.
"""

# ╔═╡ 03c3b8a6-9e19-11eb-269f-2d6997ad9de1
md"""
### `JULIA_EXCLUSIVE`
"""

# ╔═╡ 03c3b8b8-9e19-11eb-3292-df61686c8e90
md"""
If set to anything besides `0`, then Julia's thread policy is consistent with running on a dedicated machine: the master thread is on proc 0, and threads are affinitized. Otherwise, Julia lets the operating system handle thread policy.
"""

# ╔═╡ 03c3b8cc-9e19-11eb-25a7-15c0d9382efe
md"""
## REPL formatting
"""

# ╔═╡ 03c3b91c-9e19-11eb-3094-5b19b21e65c3
md"""
Environment variables that determine how REPL output should be formatted at the terminal. Generally, these variables should be set to [ANSI terminal escape sequences](http://ascii-table.com/ansi-escape-sequences.php). Julia provides a high-level interface with much of the same functionality; see the section on [The Julia REPL](@ref).
"""

# ╔═╡ 03c3b930-9e19-11eb-17f7-bdaf22b98104
md"""
### `JULIA_ERROR_COLOR`
"""

# ╔═╡ 03c3b944-9e19-11eb-027a-07a7e0dae4b4
md"""
The formatting `Base.error_color()` (default: light red, `"\033[91m"`) that errors should have at the terminal.
"""

# ╔═╡ 03c3b962-9e19-11eb-12aa-dbd6a5f58c3a
md"""
### `JULIA_WARN_COLOR`
"""

# ╔═╡ 03c3b976-9e19-11eb-2b19-e5b1e5e2c3de
md"""
The formatting `Base.warn_color()` (default: yellow, `"\033[93m"`) that warnings should have at the terminal.
"""

# ╔═╡ 03c3b980-9e19-11eb-3336-67e632ec9f56
md"""
### `JULIA_INFO_COLOR`
"""

# ╔═╡ 03c3b99e-9e19-11eb-22e1-5f530652861e
md"""
The formatting `Base.info_color()` (default: cyan, `"\033[36m"`) that info should have at the terminal.
"""

# ╔═╡ 03c3b9aa-9e19-11eb-12e4-b3b73b548574
md"""
### `JULIA_INPUT_COLOR`
"""

# ╔═╡ 03c3b9bc-9e19-11eb-120e-392597e7e63c
md"""
The formatting `Base.input_color()` (default: normal, `"\033[0m"`) that input should have at the terminal.
"""

# ╔═╡ 03c3b9d0-9e19-11eb-1c18-c9b1a8a1b684
md"""
### `JULIA_ANSWER_COLOR`
"""

# ╔═╡ 03c3b9e4-9e19-11eb-096e-c95f18deac7b
md"""
The formatting `Base.answer_color()` (default: normal, `"\033[0m"`) that output should have at the terminal.
"""

# ╔═╡ 03c3b9f8-9e19-11eb-3d64-bd74bcd18b30
md"""
## Debugging and profiling
"""

# ╔═╡ 03c3ba02-9e19-11eb-1ff7-4d66b192e3f4
md"""
### `JULIA_DEBUG`
"""

# ╔═╡ 03c3ba2a-9e19-11eb-03f5-cb0bef878ca3
md"""
Enable debug logging for a file or module, see [`Logging`](@ref Logging) for more information.
"""

# ╔═╡ 03c3ba3c-9e19-11eb-05c4-57f286a292e3
md"""
### `JULIA_GC_ALLOC_POOL`, `JULIA_GC_ALLOC_OTHER`, `JULIA_GC_ALLOC_PRINT`
"""

# ╔═╡ 03c3ba66-9e19-11eb-3e6b-e569e30778e7
md"""
If set, these environment variables take strings that optionally start with the character `'r'`, followed by a string interpolation of a colon-separated list of three signed 64-bit integers (`int64_t`). This triple of integers `a:b:c` represents the arithmetic sequence `a`, `a + b`, `a + 2*b`, ... `c`.
"""

# ╔═╡ 03c3bb60-9e19-11eb-1a46-f1108c7fe149
md"""
  * If it's the `n`th time that `jl_gc_pool_alloc()` has been called, and `n`   belongs to the arithmetic sequence represented by `$JULIA_GC_ALLOC_POOL`,   then garbage collection is forced.
  * If it's the `n`th time that `maybe_collect()` has been called, and `n` belongs   to the arithmetic sequence represented by `$JULIA_GC_ALLOC_OTHER`, then garbage   collection is forced.
  * If it's the `n`th time that `jl_gc_collect()` has been called, and `n` belongs   to the arithmetic sequence represented by `$JULIA_GC_ALLOC_PRINT`, then counts   for the number of calls to `jl_gc_pool_alloc()` and `maybe_collect()` are   printed.
"""

# ╔═╡ 03c3bb72-9e19-11eb-2546-3f058962d6b7
md"""
If the value of the environment variable begins with the character `'r'`, then the interval between garbage collection events is randomized.
"""

# ╔═╡ 03c3bbb0-9e19-11eb-2345-fdcc065d8e43
md"""
!!! note
    These environment variables only have an effect if Julia was compiled with garbage-collection debugging (that is, if `WITH_GC_DEBUG_ENV` is set to `1` in the build configuration).
"""

# ╔═╡ 03c3bbce-9e19-11eb-3614-dfee666c7bdd
md"""
### `JULIA_GC_NO_GENERATIONAL`
"""

# ╔═╡ 03c3bbe2-9e19-11eb-0529-957cc9872db6
md"""
If set to anything besides `0`, then the Julia garbage collector never performs "quick sweeps" of memory.
"""

# ╔═╡ 03c3bc14-9e19-11eb-2748-9b0980de0a7f
md"""
!!! note
    This environment variable only has an effect if Julia was compiled with garbage-collection debugging (that is, if `WITH_GC_DEBUG_ENV` is set to `1` in the build configuration).
"""

# ╔═╡ 03c3bc32-9e19-11eb-315f-21eb101936c9
md"""
### `JULIA_GC_WAIT_FOR_DEBUGGER`
"""

# ╔═╡ 03c3bc48-9e19-11eb-0611-0be7eaf8d240
md"""
If set to anything besides `0`, then the Julia garbage collector will wait for a debugger to attach instead of aborting whenever there's a critical error.
"""

# ╔═╡ 03c3bcac-9e19-11eb-275f-a10479c44346
md"""
!!! note
    This environment variable only has an effect if Julia was compiled with garbage-collection debugging (that is, if `WITH_GC_DEBUG_ENV` is set to `1` in the build configuration).
"""

# ╔═╡ 03c3bcd2-9e19-11eb-3e8e-29c2ca5f0309
md"""
### `ENABLE_JITPROFILING`
"""

# ╔═╡ 03c3bce6-9e19-11eb-0b2c-d1c0e61df5e5
md"""
If set to anything besides `0`, then the compiler will create and register an event listener for just-in-time (JIT) profiling.
"""

# ╔═╡ 03c3bde2-9e19-11eb-0e4c-f932453dcd72
md"""
!!! note
    This environment variable only has an effect if Julia was compiled with JIT profiling support, using either

      * Intel's [VTune™ Amplifier](https://software.intel.com/en-us/vtune) (`USE_INTEL_JITEVENTS` set to `1` in the build configuration), or
      * [OProfile](http://oprofile.sourceforge.net/news/) (`USE_OPROFILE_JITEVENTS` set to `1` in the build configuration).
      * [Perf](https://perf.wiki.kernel.org) (`USE_PERF_JITEVENTS` set to `1` in the build configuration). This integration is enabled by default.
"""

# ╔═╡ 03c3bdfe-9e19-11eb-1226-33df92e22fd5
md"""
### `ENABLE_GDBLISTENER`
"""

# ╔═╡ 03c3be14-9e19-11eb-1a23-d7b41b798c20
md"""
If set to anything besides `0` enables GDB registration of Julia code on release builds. On debug builds of Julia this is always enabled. Recommended to use with `-g 2`.
"""

# ╔═╡ 03c3be1c-9e19-11eb-274b-3da7f1d05a19
md"""
### `JULIA_LLVM_ARGS`
"""

# ╔═╡ 03c3be30-9e19-11eb-11ca-4b83ccdcc0e3
md"""
Arguments to be passed to the LLVM backend.
"""

# ╔═╡ Cell order:
# ╟─03c3a238-9e19-11eb-22c3-21dba0a25dd7
# ╟─03c3a2ce-9e19-11eb-3d92-5fd3ac23ebb8
# ╟─03c3a31c-9e19-11eb-33cd-877aaa8fe58f
# ╟─03c3a468-9e19-11eb-31a1-b97b9598467e
# ╟─03c3a4e0-9e19-11eb-3d46-317fe6b07b80
# ╟─03c3a508-9e19-11eb-1bb6-0b883b85a02a
# ╟─03c3a53a-9e19-11eb-2a69-2f6f579c9a3b
# ╟─03c3a55a-9e19-11eb-3c10-df6581a7e972
# ╠═03c3a896-9e19-11eb-1fdd-c72ceb2fccf8
# ╟─03c3a8b4-9e19-11eb-172f-bb8c5bd7e78b
# ╟─03c3a8d2-9e19-11eb-3924-1fb827963b18
# ╠═03c3aa96-9e19-11eb-0ee6-7ddb911f7918
# ╟─03c3aab2-9e19-11eb-3c3e-ddc982997a89
# ╟─03c3aac8-9e19-11eb-30bd-234e70a9add5
# ╠═03c3ac7e-9e19-11eb-293c-3dd4d29b3fe0
# ╟─03c3acb0-9e19-11eb-15a4-871a9d190369
# ╟─03c3acd8-9e19-11eb-317a-699cfbf06f81
# ╠═03c3ad6e-9e19-11eb-1bd9-87a66a92d24b
# ╟─03c3ad98-9e19-11eb-19f9-49912b351e0b
# ╠═03c3adf0-9e19-11eb-1573-89bb66bfc00d
# ╟─03c3ae0e-9e19-11eb-0e36-95a7e9f5a500
# ╟─03c3ae40-9e19-11eb-01ef-2386ed57632c
# ╟─03c3ae9c-9e19-11eb-3c8f-6f295dc6ea63
# ╟─03c3aeae-9e19-11eb-183a-0b189da69519
# ╟─03c3aed6-9e19-11eb-2afd-f18af67b63bf
# ╟─03c3af08-9e19-11eb-3a9b-1d414a50fa09
# ╠═03c3b0e8-9e19-11eb-0120-75cb8beb0265
# ╟─03c3b12e-9e19-11eb-0fa9-417f67ede6b2
# ╟─03c3b142-9e19-11eb-142f-8d28ca807a17
# ╟─03c3b16c-9e19-11eb-287f-2170b9fd4480
# ╟─03c3b192-9e19-11eb-2b62-67b619393c8a
# ╠═03c3b2f0-9e19-11eb-3089-15dcb34f4658
# ╟─03c3b34a-9e19-11eb-0636-6b2b30143365
# ╟─03c3b386-9e19-11eb-2d4d-9b3cdef59b6a
# ╟─03c3b398-9e19-11eb-0f8a-053676afff18
# ╟─03c3b3b8-9e19-11eb-34cf-09c6377639df
# ╠═03c3b636-9e19-11eb-21df-fd375f3007c2
# ╟─03c3b64c-9e19-11eb-02fb-313cdc0bf48d
# ╟─03c3b660-9e19-11eb-34c1-bf6e85458b0c
# ╟─03c3b692-9e19-11eb-1a87-d3d4b801aaa8
# ╟─03c3b6c4-9e19-11eb-0bde-7986717698fd
# ╟─03c3b6da-9e19-11eb-32fc-85733c80d692
# ╟─03c3b700-9e19-11eb-2397-f77520d780fa
# ╟─03c3b728-9e19-11eb-0f61-2d9a61f12094
# ╟─03c3b73e-9e19-11eb-3444-3d0772dcf81f
# ╟─03c3b75a-9e19-11eb-2aee-f39c37003476
# ╟─03c3b76c-9e19-11eb-260b-452e369cf763
# ╟─03c3b782-9e19-11eb-3276-2fc102faf382
# ╟─03c3b7b4-9e19-11eb-2446-c998af796a76
# ╟─03c3b7c8-9e19-11eb-0a26-7575c5732926
# ╟─03c3b7e6-9e19-11eb-30f8-ff832efd8099
# ╟─03c3b818-9e19-11eb-0380-fd59a301c037
# ╟─03c3b85e-9e19-11eb-0783-03aad20da6e1
# ╟─03c3b874-9e19-11eb-1430-07daa4c5746c
# ╟─03c3b886-9e19-11eb-0e5d-53799d4fe636
# ╟─03c3b8a6-9e19-11eb-269f-2d6997ad9de1
# ╟─03c3b8b8-9e19-11eb-3292-df61686c8e90
# ╟─03c3b8cc-9e19-11eb-25a7-15c0d9382efe
# ╟─03c3b91c-9e19-11eb-3094-5b19b21e65c3
# ╟─03c3b930-9e19-11eb-17f7-bdaf22b98104
# ╟─03c3b944-9e19-11eb-027a-07a7e0dae4b4
# ╟─03c3b962-9e19-11eb-12aa-dbd6a5f58c3a
# ╟─03c3b976-9e19-11eb-2b19-e5b1e5e2c3de
# ╟─03c3b980-9e19-11eb-3336-67e632ec9f56
# ╟─03c3b99e-9e19-11eb-22e1-5f530652861e
# ╟─03c3b9aa-9e19-11eb-12e4-b3b73b548574
# ╟─03c3b9bc-9e19-11eb-120e-392597e7e63c
# ╟─03c3b9d0-9e19-11eb-1c18-c9b1a8a1b684
# ╟─03c3b9e4-9e19-11eb-096e-c95f18deac7b
# ╟─03c3b9f8-9e19-11eb-3d64-bd74bcd18b30
# ╟─03c3ba02-9e19-11eb-1ff7-4d66b192e3f4
# ╟─03c3ba2a-9e19-11eb-03f5-cb0bef878ca3
# ╟─03c3ba3c-9e19-11eb-05c4-57f286a292e3
# ╟─03c3ba66-9e19-11eb-3e6b-e569e30778e7
# ╟─03c3bb60-9e19-11eb-1a46-f1108c7fe149
# ╟─03c3bb72-9e19-11eb-2546-3f058962d6b7
# ╟─03c3bbb0-9e19-11eb-2345-fdcc065d8e43
# ╟─03c3bbce-9e19-11eb-3614-dfee666c7bdd
# ╟─03c3bbe2-9e19-11eb-0529-957cc9872db6
# ╟─03c3bc14-9e19-11eb-2748-9b0980de0a7f
# ╟─03c3bc32-9e19-11eb-315f-21eb101936c9
# ╟─03c3bc48-9e19-11eb-0611-0be7eaf8d240
# ╟─03c3bcac-9e19-11eb-275f-a10479c44346
# ╟─03c3bcd2-9e19-11eb-3e8e-29c2ca5f0309
# ╟─03c3bce6-9e19-11eb-0b2c-d1c0e61df5e5
# ╟─03c3bde2-9e19-11eb-0e4c-f932453dcd72
# ╟─03c3bdfe-9e19-11eb-1226-33df92e22fd5
# ╟─03c3be14-9e19-11eb-1a23-d7b41b798c20
# ╟─03c3be1c-9e19-11eb-274b-3da7f1d05a19
# ╟─03c3be30-9e19-11eb-11ca-4b83ccdcc0e3
