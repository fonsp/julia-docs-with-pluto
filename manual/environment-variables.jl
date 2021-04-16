### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 30cb5dd4-a069-481b-8ce4-103a7ea8d11a
md"""
# Environment Variables
"""

# ╔═╡ ef367eeb-f952-456f-9b24-32f63cd0f05a
md"""
Julia can be configured with a number of environment variables, set either in the usual way for each operating system, or in a portable way from within Julia. Supposing that you want to set the environment variable `JULIA_EDITOR` to `vim`, you can type `ENV[\"JULIA_EDITOR\"] = \"vim\"` (for instance, in the REPL) to make this change on a case by case basis, or add the same to the user configuration file `~/.julia/config/startup.jl` in the user's home directory to have a permanent effect. The current value of the same environment variable can be determined by evaluating `ENV[\"JULIA_EDITOR\"]`.
"""

# ╔═╡ bd6a045d-64bc-425a-abb5-e287d425d5a0
md"""
The environment variables that Julia uses generally start with `JULIA`. If [`InteractiveUtils.versioninfo`](@ref) is called with the keyword `verbose=true`, then the output will list any defined environment variables relevant for Julia, including those which include `JULIA` in their names.
"""

# ╔═╡ bfba6dd6-5a7b-4b7c-9277-e24298219757
md"""
!!! note
    Some variables, such as `JULIA_NUM_THREADS` and `JULIA_PROJECT`, need to be set before Julia starts, therefore adding these to `~/.julia/config/startup.jl` is too late in the startup process. In Bash, environment variables can either be set manually by running, e.g., `export JULIA_NUM_THREADS=4` before starting Julia, or by adding the same command to `~/.bashrc` or `~/.bash_profile` to set the variable each time Bash is started.
"""

# ╔═╡ d80cdcd4-7c16-47cf-a93f-4d63766d87d1
md"""
## File locations
"""

# ╔═╡ 2b24b669-5655-4c34-8ac8-51dfacd9d1b2
md"""
### `JULIA_BINDIR`
"""

# ╔═╡ a8a22556-3c12-42db-befc-4133a0676b01
md"""
The absolute path of the directory containing the Julia executable, which sets the global variable [`Sys.BINDIR`](@ref). If `$JULIA_BINDIR` is not set, then Julia determines the value `Sys.BINDIR` at run-time.
"""

# ╔═╡ 30ce49ec-c623-4896-8fae-803ee2d1b7bb
md"""
The executable itself is one of
"""

# ╔═╡ 176839c9-6ce6-414b-bca6-cffa21ea5615
md"""
```
$JULIA_BINDIR/julia
$JULIA_BINDIR/julia-debug
```
"""

# ╔═╡ 98a41ee2-a4ed-44c8-ad7e-ce40df987e63
md"""
by default.
"""

# ╔═╡ 11d72f31-00dc-4b22-929e-e6d9d4d72784
md"""
The global variable `Base.DATAROOTDIR` determines a relative path from `Sys.BINDIR` to the data directory associated with Julia. Then the path
"""

# ╔═╡ 87f46747-ebc8-41fc-b3a4-17675184d6a7
md"""
```
$JULIA_BINDIR/$DATAROOTDIR/julia/base
```
"""

# ╔═╡ ad09678c-f3b4-4da7-a175-80ab9cc1d19d
md"""
determines the directory in which Julia initially searches for source files (via `Base.find_source_file()`).
"""

# ╔═╡ a5f6c1e4-555f-457d-bfbe-7b3a025d4dc1
md"""
Likewise, the global variable `Base.SYSCONFDIR` determines a relative path to the configuration file directory. Then Julia searches for a `startup.jl` file at
"""

# ╔═╡ 406f4b43-7338-4d15-ba09-851dd8c3db45
md"""
```
$JULIA_BINDIR/$SYSCONFDIR/julia/startup.jl
$JULIA_BINDIR/../etc/julia/startup.jl
```
"""

# ╔═╡ eed1bbc8-f799-4bca-9ba0-1fb591631506
md"""
by default (via `Base.load_julia_startup()`).
"""

# ╔═╡ c0f70c04-d3b9-44a7-a63f-d656d8c18930
md"""
For example, a Linux installation with a Julia executable located at `/bin/julia`, a `DATAROOTDIR` of `../share`, and a `SYSCONFDIR` of `../etc` will have `JULIA_BINDIR` set to `/bin`, a source-file search path of
"""

# ╔═╡ b9fc2596-bbbc-425f-ba51-1e6796c7a971
md"""
```
/share/julia/base
```
"""

# ╔═╡ 65b8966b-079b-4ffa-ac7e-2cd0e3a0d381
md"""
and a global configuration search path of
"""

# ╔═╡ 28b9d77b-d96c-42fd-a522-ad74ef72d910
md"""
```
/etc/julia/startup.jl
```
"""

# ╔═╡ 1941b484-b90b-43bf-8a49-c4edfe8a76ec
md"""
### `JULIA_PROJECT`
"""

# ╔═╡ 9323bd90-db28-4e87-9df1-d4aeacf237f1
md"""
A directory path that indicates which project should be the initial active project. Setting this environment variable has the same effect as specifying the `--project` start-up option, but `--project` has higher precedence. If the variable is set to `@.` then Julia tries to find a project directory that contains `Project.toml` or `JuliaProject.toml` file from the current directory and its parents. See also the chapter on [Code Loading](@ref code-loading).
"""

# ╔═╡ 9058971a-88f1-474a-83a8-148508cc96ce
md"""
!!! note
    `JULIA_PROJECT` must be defined before starting julia; defining it in `startup.jl` is too late in the startup process.
"""

# ╔═╡ 4ae43b45-acec-4882-a31e-a6a406ca1bfb
md"""
### `JULIA_LOAD_PATH`
"""

# ╔═╡ d7d26ea6-c602-40a1-a140-5696f94e291a
md"""
The `JULIA_LOAD_PATH` environment variable is used to populate the global Julia [`LOAD_PATH`](@ref) variable, which determines which packages can be loaded via `import` and `using` (see [Code Loading](@ref code-loading)).
"""

# ╔═╡ 01d91619-1736-49b3-a6e6-aaed65d6112d
md"""
Unlike the shell `PATH` variable, empty entries in `JULIA_LOAD_PATH` are expanded to the default value of `LOAD_PATH`, `[\"@\", \"@v#.#\", \"@stdlib\"]` when populating `LOAD_PATH`. This allows easy appending, prepending, etc. of the load path value in shell scripts regardless of whether `JULIA_LOAD_PATH` is already set or not. For example, to prepend the directory `/foo/bar` to `LOAD_PATH` just do
"""

# ╔═╡ 7be17832-a982-4e79-a7d4-73cd860bd1e0
md"""
```sh
export JULIA_LOAD_PATH=\"/foo/bar:$JULIA_LOAD_PATH\"
```
"""

# ╔═╡ 0e65cee8-758d-406a-9849-b3c9591f2823
md"""
If the `JULIA_LOAD_PATH` environment variable is already set, its old value will be prepended with `/foo/bar`. On the other hand, if `JULIA_LOAD_PATH` is not set, then it will be set to `/foo/bar:` which will expand to a `LOAD_PATH` value of `[\"/foo/bar\", \"@\", \"@v#.#\", \"@stdlib\"]`. If `JULIA_LOAD_PATH` is set to the empty string, it expands to an empty `LOAD_PATH` array. In other words, the empty string is interpreted as a zero-element array, not a one-element array of the empty string. This behavior was chosen so that it would be possible to set an empty load path via the environment variable. If you want the default load path, either unset the environment variable or if it must have a value, set it to the string `:`.
"""

# ╔═╡ 91ae5249-7e37-4ac5-89a7-c13234863ec0
md"""
### `JULIA_DEPOT_PATH`
"""

# ╔═╡ 221401f7-379d-4dfa-9a08-27371fa59732
md"""
The `JULIA_DEPOT_PATH` environment variable is used to populate the global Julia [`DEPOT_PATH`](@ref) variable, which controls where the package manager, as well as Julia's code loading mechanisms, look for package registries, installed packages, named environments, repo clones, cached compiled package images, configuration files, and the default location of the REPL's history file.
"""

# ╔═╡ e15942c1-8078-43d4-b7d7-a4ebc6d1d46b
md"""
Unlike the shell `PATH` variable but similar to `JULIA_LOAD_PATH`, empty entries in `JULIA_DEPOT_PATH` are expanded to the default value of `DEPOT_PATH`. This allows easy appending, prepending, etc. of the depot path value in shell scripts regardless of whether `JULIA_DEPOT_PATH` is already set or not. For example, to prepend the directory `/foo/bar` to `DEPOT_PATH` just do
"""

# ╔═╡ 322e0fdf-10f0-42a6-94cc-cbf9f1d13693
md"""
```sh
export JULIA_DEPOT_PATH=\"/foo/bar:$JULIA_DEPOT_PATH\"
```
"""

# ╔═╡ 33f1778f-ab19-4a76-bc4f-17aff3d6da13
md"""
If the `JULIA_DEPOT_PATH` environment variable is already set, its old value will be prepended with `/foo/bar`. On the other hand, if `JULIA_DEPOT_PATH` is not set, then it will be set to `/foo/bar:` which will have the effect of prepending `/foo/bar` to the default depot path. If `JULIA_DEPOT_PATH` is set to the empty string, it expands to an empty `DEPOT_PATH` array. In other words, the empty string is interpreted as a zero-element array, not a one-element array of the empty string. This behavior was chosen so that it would be possible to set an empty depot path via the environment variable. If you want the default depot path, either unset the environment variable or if it must have a value, set it to the string `:`.
"""

# ╔═╡ 6974da1b-4896-4d38-a8aa-5bcf337b3138
md"""
!!! note
    On Windows, path elements are separated by the `;` character, as is the case with most path lists on Windows.
"""

# ╔═╡ 82f075b2-924a-4cb3-9c19-eea63ae82ac2
md"""
### `JULIA_HISTORY`
"""

# ╔═╡ 1fe58d8c-e033-4dc9-9d75-343cd84218a9
md"""
The absolute path `REPL.find_hist_file()` of the REPL's history file. If `$JULIA_HISTORY` is not set, then `REPL.find_hist_file()` defaults to
"""

# ╔═╡ d405fd24-109e-4e36-94ee-7bc638b7482e
md"""
```
$(DEPOT_PATH[1])/logs/repl_history.jl
```
"""

# ╔═╡ 955575f5-b00b-4b18-8acb-f43efc135023
md"""
## External applications
"""

# ╔═╡ 08c98a74-0284-4f96-bd60-daf9b0b290e3
md"""
### `JULIA_SHELL`
"""

# ╔═╡ fb77e063-2943-469e-b5bc-8791308dc2e9
md"""
The absolute path of the shell with which Julia should execute external commands (via `Base.repl_cmd()`). Defaults to the environment variable `$SHELL`, and falls back to `/bin/sh` if `$SHELL` is unset.
"""

# ╔═╡ 65f835d4-913c-45d2-b822-fad7bf631e1b
md"""
!!! note
    On Windows, this environment variable is ignored, and external commands are executed directly.
"""

# ╔═╡ 58906a5f-fe81-45c9-835f-0791a5c4eb14
md"""
### `JULIA_EDITOR`
"""

# ╔═╡ 368822c6-393a-4e82-ab0c-4f512e896f16
md"""
The editor returned by `InteractiveUtils.editor()` and used in, e.g., [`InteractiveUtils.edit`](@ref), referring to the command of the preferred editor, for instance `vim`.
"""

# ╔═╡ 790a9f72-d3fa-4116-a510-0b746992623d
md"""
`$JULIA_EDITOR` takes precedence over `$VISUAL`, which in turn takes precedence over `$EDITOR`. If none of these environment variables is set, then the editor is taken to be `open` on Windows and OS X, or `/etc/alternatives/editor` if it exists, or `emacs` otherwise.
"""

# ╔═╡ 033a1b19-108e-40a7-a1b6-c447f5c458e0
md"""
## Parallelization
"""

# ╔═╡ 59005452-6b40-4616-8b1b-e9036c26b1bb
md"""
### `JULIA_CPU_THREADS`
"""

# ╔═╡ fb6788f8-6f0c-49f4-bb27-6ec3c883c29f
md"""
Overrides the global variable [`Base.Sys.CPU_THREADS`](@ref), the number of logical CPU cores available.
"""

# ╔═╡ b273bda5-500f-40df-a1d3-deb6c995307e
md"""
### `JULIA_WORKER_TIMEOUT`
"""

# ╔═╡ 6041c6a8-0e21-4b6d-99e5-6c5ab2e9979e
md"""
A [`Float64`](@ref) that sets the value of `Distributed.worker_timeout()` (default: `60.0`). This function gives the number of seconds a worker process will wait for a master process to establish a connection before dying.
"""

# ╔═╡ 67558540-acab-491a-b426-f5b46bbd273d
md"""
### [`JULIA_NUM_THREADS`](@id JULIA_NUM_THREADS)
"""

# ╔═╡ 499f59cb-3090-409a-8584-a031faf431aa
md"""
An unsigned 64-bit integer (`uint64_t`) that sets the maximum number of threads available to Julia. If `$JULIA_NUM_THREADS` is not positive or is not set, or if the number of CPU threads cannot be determined through system calls, then the number of threads is set to `1`.
"""

# ╔═╡ 6a68061f-bd8f-41f4-999c-48ff8ce50acf
md"""
!!! note
    `JULIA_NUM_THREADS` must be defined before starting julia; defining it in `startup.jl` is too late in the startup process.
"""

# ╔═╡ 437932f1-6ea8-4c60-b57c-d23de5cfcf52
md"""
!!! compat \"Julia 1.5\"
    In Julia 1.5 and above the number of threads can also be specified on startup using the `-t`/`--threads` command line argument.
"""

# ╔═╡ cb0a5f60-4d4a-41d8-8515-001b2d794fb9
md"""
### `JULIA_THREAD_SLEEP_THRESHOLD`
"""

# ╔═╡ 082f47ed-b45e-49ea-a822-17df58f02b7f
md"""
If set to a string that starts with the case-insensitive substring `\"infinite\"`, then spinning threads never sleep. Otherwise, `$JULIA_THREAD_SLEEP_THRESHOLD` is interpreted as an unsigned 64-bit integer (`uint64_t`) and gives, in nanoseconds, the amount of time after which spinning threads should sleep.
"""

# ╔═╡ e35cc5c0-4661-4440-9e39-6f553733dab3
md"""
### `JULIA_EXCLUSIVE`
"""

# ╔═╡ 6daf7c4b-4daa-4ba9-a9a0-23d2d392b88e
md"""
If set to anything besides `0`, then Julia's thread policy is consistent with running on a dedicated machine: the master thread is on proc 0, and threads are affinitized. Otherwise, Julia lets the operating system handle thread policy.
"""

# ╔═╡ ed18c946-4969-43f8-b608-535f070266c8
md"""
## REPL formatting
"""

# ╔═╡ d4bde309-6841-43c3-ad57-8285e54f10a2
md"""
Environment variables that determine how REPL output should be formatted at the terminal. Generally, these variables should be set to [ANSI terminal escape sequences](http://ascii-table.com/ansi-escape-sequences.php). Julia provides a high-level interface with much of the same functionality; see the section on [The Julia REPL](@ref).
"""

# ╔═╡ 8aca5a46-2156-410d-b34d-cb16b684b8a6
md"""
### `JULIA_ERROR_COLOR`
"""

# ╔═╡ 7b2d52be-9f54-45a4-b1bf-18d56e0ee681
md"""
The formatting `Base.error_color()` (default: light red, `\"\033[91m\"`) that errors should have at the terminal.
"""

# ╔═╡ 84d9c517-d7a0-4a94-be60-f92006050dc8
md"""
### `JULIA_WARN_COLOR`
"""

# ╔═╡ 11b3060b-e8ba-458e-bfd9-7d20c6947b16
md"""
The formatting `Base.warn_color()` (default: yellow, `\"\033[93m\"`) that warnings should have at the terminal.
"""

# ╔═╡ 00e3537b-afdc-46cd-9077-cbfa03aa84dd
md"""
### `JULIA_INFO_COLOR`
"""

# ╔═╡ 7a7d073f-2735-42df-9272-9360590d0c64
md"""
The formatting `Base.info_color()` (default: cyan, `\"\033[36m\"`) that info should have at the terminal.
"""

# ╔═╡ 74819494-f3ff-48c5-a28d-a883a38c0f4d
md"""
### `JULIA_INPUT_COLOR`
"""

# ╔═╡ e69aa392-2f5a-4602-8baa-6bd5f01ee2d3
md"""
The formatting `Base.input_color()` (default: normal, `\"\033[0m\"`) that input should have at the terminal.
"""

# ╔═╡ 12341fae-c862-4d1f-ab9c-a03136ce6d5a
md"""
### `JULIA_ANSWER_COLOR`
"""

# ╔═╡ 9fc69fb0-51da-437d-b0d3-b09d384d7c45
md"""
The formatting `Base.answer_color()` (default: normal, `\"\033[0m\"`) that output should have at the terminal.
"""

# ╔═╡ c51e6439-dd07-471a-b05b-7ee5b5e0ec9a
md"""
## Debugging and profiling
"""

# ╔═╡ e35a5f21-ca26-435d-8106-16085a79e0e7
md"""
### `JULIA_DEBUG`
"""

# ╔═╡ 5e6244de-636c-4850-b659-353d1405975c
md"""
Enable debug logging for a file or module, see [`Logging`](@ref Logging) for more information.
"""

# ╔═╡ c0e7cf89-7dd7-4917-9068-07e02359e640
md"""
### `JULIA_GC_ALLOC_POOL`, `JULIA_GC_ALLOC_OTHER`, `JULIA_GC_ALLOC_PRINT`
"""

# ╔═╡ 745a80ef-4155-42d7-9bf9-bd3e024df050
md"""
If set, these environment variables take strings that optionally start with the character `'r'`, followed by a string interpolation of a colon-separated list of three signed 64-bit integers (`int64_t`). This triple of integers `a:b:c` represents the arithmetic sequence `a`, `a + b`, `a + 2*b`, ... `c`.
"""

# ╔═╡ 349b2992-dad0-4fa2-894b-3c7fc6be4f18
md"""
  * If it's the `n`th time that `jl_gc_pool_alloc()` has been called, and `n`   belongs to the arithmetic sequence represented by `$JULIA_GC_ALLOC_POOL`,   then garbage collection is forced.
  * If it's the `n`th time that `maybe_collect()` has been called, and `n` belongs   to the arithmetic sequence represented by `$JULIA_GC_ALLOC_OTHER`, then garbage   collection is forced.
  * If it's the `n`th time that `jl_gc_collect()` has been called, and `n` belongs   to the arithmetic sequence represented by `$JULIA_GC_ALLOC_PRINT`, then counts   for the number of calls to `jl_gc_pool_alloc()` and `maybe_collect()` are   printed.
"""

# ╔═╡ db15250b-5779-47a6-a035-2369df8a9c41
md"""
If the value of the environment variable begins with the character `'r'`, then the interval between garbage collection events is randomized.
"""

# ╔═╡ 839d022f-7289-4117-9514-075fce0e1907
md"""
!!! note
    These environment variables only have an effect if Julia was compiled with garbage-collection debugging (that is, if `WITH_GC_DEBUG_ENV` is set to `1` in the build configuration).
"""

# ╔═╡ 2e614b57-78ec-4253-ac18-73b83de5a51c
md"""
### `JULIA_GC_NO_GENERATIONAL`
"""

# ╔═╡ 234c1e41-d1cc-4526-946c-10001e554ebc
md"""
If set to anything besides `0`, then the Julia garbage collector never performs \"quick sweeps\" of memory.
"""

# ╔═╡ 203e2ac6-8154-49c7-bce7-1b3bbfeaed3e
md"""
!!! note
    This environment variable only has an effect if Julia was compiled with garbage-collection debugging (that is, if `WITH_GC_DEBUG_ENV` is set to `1` in the build configuration).
"""

# ╔═╡ a985b633-a7c5-447c-8627-29d16d69f604
md"""
### `JULIA_GC_WAIT_FOR_DEBUGGER`
"""

# ╔═╡ d93b01f1-e5ef-4171-9fd2-6b60ed051edf
md"""
If set to anything besides `0`, then the Julia garbage collector will wait for a debugger to attach instead of aborting whenever there's a critical error.
"""

# ╔═╡ 265cc272-ff21-416e-88c8-548367a49f0e
md"""
!!! note
    This environment variable only has an effect if Julia was compiled with garbage-collection debugging (that is, if `WITH_GC_DEBUG_ENV` is set to `1` in the build configuration).
"""

# ╔═╡ 0dad3c1a-658d-4e4a-846c-28e1e4889a6b
md"""
### `ENABLE_JITPROFILING`
"""

# ╔═╡ 63ae197f-0cca-44cc-837f-05a5351849c7
md"""
If set to anything besides `0`, then the compiler will create and register an event listener for just-in-time (JIT) profiling.
"""

# ╔═╡ dea8ab48-16f4-477f-a556-616001c64963
md"""
!!! note
    This environment variable only has an effect if Julia was compiled with JIT profiling support, using either

      * Intel's [VTune™ Amplifier](https://software.intel.com/en-us/vtune) (`USE_INTEL_JITEVENTS` set to `1` in the build configuration), or
      * [OProfile](http://oprofile.sourceforge.net/news/) (`USE_OPROFILE_JITEVENTS` set to `1` in the build configuration).
      * [Perf](https://perf.wiki.kernel.org) (`USE_PERF_JITEVENTS` set to `1` in the build configuration). This integration is enabled by default.
"""

# ╔═╡ 0b95f8ad-1817-4e28-ab12-f6b8bae4fff0
md"""
### `ENABLE_GDBLISTENER`
"""

# ╔═╡ 0693cd2f-ec16-4467-b8a8-dae2ebaf2ba2
md"""
If set to anything besides `0` enables GDB registration of Julia code on release builds. On debug builds of Julia this is always enabled. Recommended to use with `-g 2`.
"""

# ╔═╡ 6e9ee422-3fc7-48b3-bfde-a479ca218235
md"""
### `JULIA_LLVM_ARGS`
"""

# ╔═╡ db765c44-5767-474f-8efe-4ffa5b8e5f12
md"""
Arguments to be passed to the LLVM backend.
"""

# ╔═╡ Cell order:
# ╟─30cb5dd4-a069-481b-8ce4-103a7ea8d11a
# ╟─ef367eeb-f952-456f-9b24-32f63cd0f05a
# ╟─bd6a045d-64bc-425a-abb5-e287d425d5a0
# ╟─bfba6dd6-5a7b-4b7c-9277-e24298219757
# ╟─d80cdcd4-7c16-47cf-a93f-4d63766d87d1
# ╟─2b24b669-5655-4c34-8ac8-51dfacd9d1b2
# ╟─a8a22556-3c12-42db-befc-4133a0676b01
# ╟─30ce49ec-c623-4896-8fae-803ee2d1b7bb
# ╟─176839c9-6ce6-414b-bca6-cffa21ea5615
# ╟─98a41ee2-a4ed-44c8-ad7e-ce40df987e63
# ╟─11d72f31-00dc-4b22-929e-e6d9d4d72784
# ╟─87f46747-ebc8-41fc-b3a4-17675184d6a7
# ╟─ad09678c-f3b4-4da7-a175-80ab9cc1d19d
# ╟─a5f6c1e4-555f-457d-bfbe-7b3a025d4dc1
# ╟─406f4b43-7338-4d15-ba09-851dd8c3db45
# ╟─eed1bbc8-f799-4bca-9ba0-1fb591631506
# ╟─c0f70c04-d3b9-44a7-a63f-d656d8c18930
# ╟─b9fc2596-bbbc-425f-ba51-1e6796c7a971
# ╟─65b8966b-079b-4ffa-ac7e-2cd0e3a0d381
# ╟─28b9d77b-d96c-42fd-a522-ad74ef72d910
# ╟─1941b484-b90b-43bf-8a49-c4edfe8a76ec
# ╟─9323bd90-db28-4e87-9df1-d4aeacf237f1
# ╟─9058971a-88f1-474a-83a8-148508cc96ce
# ╟─4ae43b45-acec-4882-a31e-a6a406ca1bfb
# ╟─d7d26ea6-c602-40a1-a140-5696f94e291a
# ╟─01d91619-1736-49b3-a6e6-aaed65d6112d
# ╟─7be17832-a982-4e79-a7d4-73cd860bd1e0
# ╟─0e65cee8-758d-406a-9849-b3c9591f2823
# ╟─91ae5249-7e37-4ac5-89a7-c13234863ec0
# ╟─221401f7-379d-4dfa-9a08-27371fa59732
# ╟─e15942c1-8078-43d4-b7d7-a4ebc6d1d46b
# ╟─322e0fdf-10f0-42a6-94cc-cbf9f1d13693
# ╟─33f1778f-ab19-4a76-bc4f-17aff3d6da13
# ╟─6974da1b-4896-4d38-a8aa-5bcf337b3138
# ╟─82f075b2-924a-4cb3-9c19-eea63ae82ac2
# ╟─1fe58d8c-e033-4dc9-9d75-343cd84218a9
# ╟─d405fd24-109e-4e36-94ee-7bc638b7482e
# ╟─955575f5-b00b-4b18-8acb-f43efc135023
# ╟─08c98a74-0284-4f96-bd60-daf9b0b290e3
# ╟─fb77e063-2943-469e-b5bc-8791308dc2e9
# ╟─65f835d4-913c-45d2-b822-fad7bf631e1b
# ╟─58906a5f-fe81-45c9-835f-0791a5c4eb14
# ╟─368822c6-393a-4e82-ab0c-4f512e896f16
# ╟─790a9f72-d3fa-4116-a510-0b746992623d
# ╟─033a1b19-108e-40a7-a1b6-c447f5c458e0
# ╟─59005452-6b40-4616-8b1b-e9036c26b1bb
# ╟─fb6788f8-6f0c-49f4-bb27-6ec3c883c29f
# ╟─b273bda5-500f-40df-a1d3-deb6c995307e
# ╟─6041c6a8-0e21-4b6d-99e5-6c5ab2e9979e
# ╟─67558540-acab-491a-b426-f5b46bbd273d
# ╟─499f59cb-3090-409a-8584-a031faf431aa
# ╟─6a68061f-bd8f-41f4-999c-48ff8ce50acf
# ╟─437932f1-6ea8-4c60-b57c-d23de5cfcf52
# ╟─cb0a5f60-4d4a-41d8-8515-001b2d794fb9
# ╟─082f47ed-b45e-49ea-a822-17df58f02b7f
# ╟─e35cc5c0-4661-4440-9e39-6f553733dab3
# ╟─6daf7c4b-4daa-4ba9-a9a0-23d2d392b88e
# ╟─ed18c946-4969-43f8-b608-535f070266c8
# ╟─d4bde309-6841-43c3-ad57-8285e54f10a2
# ╟─8aca5a46-2156-410d-b34d-cb16b684b8a6
# ╟─7b2d52be-9f54-45a4-b1bf-18d56e0ee681
# ╟─84d9c517-d7a0-4a94-be60-f92006050dc8
# ╟─11b3060b-e8ba-458e-bfd9-7d20c6947b16
# ╟─00e3537b-afdc-46cd-9077-cbfa03aa84dd
# ╟─7a7d073f-2735-42df-9272-9360590d0c64
# ╟─74819494-f3ff-48c5-a28d-a883a38c0f4d
# ╟─e69aa392-2f5a-4602-8baa-6bd5f01ee2d3
# ╟─12341fae-c862-4d1f-ab9c-a03136ce6d5a
# ╟─9fc69fb0-51da-437d-b0d3-b09d384d7c45
# ╟─c51e6439-dd07-471a-b05b-7ee5b5e0ec9a
# ╟─e35a5f21-ca26-435d-8106-16085a79e0e7
# ╟─5e6244de-636c-4850-b659-353d1405975c
# ╟─c0e7cf89-7dd7-4917-9068-07e02359e640
# ╟─745a80ef-4155-42d7-9bf9-bd3e024df050
# ╟─349b2992-dad0-4fa2-894b-3c7fc6be4f18
# ╟─db15250b-5779-47a6-a035-2369df8a9c41
# ╟─839d022f-7289-4117-9514-075fce0e1907
# ╟─2e614b57-78ec-4253-ac18-73b83de5a51c
# ╟─234c1e41-d1cc-4526-946c-10001e554ebc
# ╟─203e2ac6-8154-49c7-bce7-1b3bbfeaed3e
# ╟─a985b633-a7c5-447c-8627-29d16d69f604
# ╟─d93b01f1-e5ef-4171-9fd2-6b60ed051edf
# ╟─265cc272-ff21-416e-88c8-548367a49f0e
# ╟─0dad3c1a-658d-4e4a-846c-28e1e4889a6b
# ╟─63ae197f-0cca-44cc-837f-05a5351849c7
# ╟─dea8ab48-16f4-477f-a556-616001c64963
# ╟─0b95f8ad-1817-4e28-ab12-f6b8bae4fff0
# ╟─0693cd2f-ec16-4467-b8a8-dae2ebaf2ba2
# ╟─6e9ee422-3fc7-48b3-bfde-a479ca218235
# ╟─db765c44-5767-474f-8efe-4ffa5b8e5f12
