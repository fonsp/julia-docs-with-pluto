### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03c7d9d4-9e19-11eb-1fe3-c94bd013aa41
md"""
# [Getting Started](@id man-getting-started)
"""

# ╔═╡ 03c7d9f2-9e19-11eb-1c6f-99319362cd71
md"""
Julia installation is straightforward, whether using precompiled binaries or compiling from source. Download and install Julia by following the instructions at [https://julialang.org/downloads/](https://julialang.org/downloads/).
"""

# ╔═╡ 03c7da1c-9e19-11eb-070c-815c9e7b5f2f
md"""
If you are coming to Julia from one of the following languages, then you should start by reading the section on noteworthy differences from [MATLAB](@ref Noteworthy-differences-from-MATLAB), [R](@ref Noteworthy-differences-from-R), [Python](@ref Noteworthy-differences-from-Python), [C/C++](@ref Noteworthy-differences-from-C/C) or [Common Lisp](@ref Noteworthy-differences-from-Common-Lisp). This will help you avoid some common pitfalls since Julia differs from those languages in many subtle ways.
"""

# ╔═╡ 03c7da2e-9e19-11eb-2984-293fc496eac4
md"""
The easiest way to learn and experiment with Julia is by starting an interactive session (also known as a read-eval-print loop or "REPL") by double-clicking the Julia executable or running `julia` from the command line:
"""

# ╔═╡ 03c7df10-9e19-11eb-0602-9bb444bdc582
io = IOBuffer()

# ╔═╡ 03c7df1a-9e19-11eb-2934-ad9664e5c66e
1 + 2\n3\n\n

# ╔═╡ 03c7df26-9e19-11eb-02ef-8350ea40aed2
ans\n3\n```")

# ╔═╡ 03c7df58-9e19-11eb-1028-6967e7902ddf
md"""
To exit the interactive session, type `CTRL-D` (press the Control/`^` key together with the `d` key), or type `exit()`. When run in interactive mode, `julia` displays a banner and prompts the user for input. Once the user has entered a complete expression, such as `1 + 2`, and hits enter, the interactive session evaluates the expression and shows its value. If an expression is entered into an interactive session with a trailing semicolon, its value is not shown. The variable `ans` is bound to the value of the last evaluated expression whether it is shown or not. The `ans` variable is only bound in interactive sessions, not when Julia code is run in other ways.
"""

# ╔═╡ 03c7df74-9e19-11eb-1e77-0f5dbc0288a7
md"""
To evaluate expressions written in a source file `file.jl`, write `include("file.jl")`.
"""

# ╔═╡ 03c7df8a-9e19-11eb-1b7c-155b3d7ebcc6
md"""
To run code in a file non-interactively, you can give it as the first argument to the `julia` command:
"""

# ╔═╡ 03c7e050-9e19-11eb-343b-83bf419990ef
$ julia script

# ╔═╡ 03c7e078-9e19-11eb-0d36-910ec7f0de5b
md"""
As the example implies, the following command-line arguments to `julia` are interpreted as command-line arguments to the program `script.jl`, passed in the global constant `ARGS`. The name of the script itself is passed in as the global `PROGRAM_FILE`. Note that `ARGS` is also set when a Julia expression is given using the `-e` option on the command line (see the `julia` help output below) but `PROGRAM_FILE` will be empty. For example, to just print the arguments given to a script, you could do this:
"""

# ╔═╡ 03c7e152-9e19-11eb-0393-9f52de744d29
$ julia -e '

# ╔═╡ 03c7e168-9e19-11eb-0c1a-47b5e633b342
md"""
Or you could put that code into a script and run it:
"""

# ╔═╡ 03c7e1fe-9e19-11eb-1c08-7166e244ccaa
$ echo '

# ╔═╡ 03c7e21c-9e19-11eb-0e9b-7924185b799d
md"""
The `--` delimiter can be used to separate command-line arguments intended for the script file from arguments intended for Julia:
"""

# ╔═╡ 03c7e294-9e19-11eb-2a16-f5ef14159658
$ julia -

# ╔═╡ 03c7e2b2-9e19-11eb-3f4a-ad5079817b5c
md"""
See also [Scripting](@ref man-scripting) for more information on writing Julia scripts.
"""

# ╔═╡ 03c7e2ec-9e19-11eb-0d73-cb7ac0ace730
md"""
Julia can be started in parallel mode with either the `-p` or the `--machine-file` options. `-p n` will launch an additional `n` worker processes, while `--machine-file file` will launch a worker for each line in file `file`. The machines defined in `file` must be accessible via a password-less `ssh` login, with Julia installed at the same location as the current host. Each machine definition takes the form `[count*][user@]host[:port] [bind_addr[:port]]`. `user` defaults to current user, `port` to the standard ssh port. `count` is the number of workers to spawn on the node, and defaults to 1. The optional `bind-to bind_addr[:port]` specifies the IP address and port that other workers should use to connect to this worker.
"""

# ╔═╡ 03c7e302-9e19-11eb-1a1c-699df9e53963
md"""
If you have code that you want executed whenever Julia is run, you can put it in `~/.julia/config/startup.jl`:
"""

# ╔═╡ 03c7e398-9e19-11eb-0f92-0f9f1f967528
$ echo '

# ╔═╡ 03c7e3b6-9e19-11eb-0dc8-f575805a566f
md"""
Note that although you should have a `~/.julia` directory once you've run Julia for the first time, you may need to create the `~/.julia/config` folder and the `~/.julia/config/startup.jl` file if you use it.
"""

# ╔═╡ 03c7e3ca-9e19-11eb-2977-07cb89784a0e
md"""
There are various ways to run Julia code and provide options, similar to those available for the `perl` and `ruby` programs:
"""

# ╔═╡ 03c7e42e-9e19-11eb-138d-dd48178ed8fd
julia [

# ╔═╡ 03c7e44c-9e19-11eb-2a28-b71a342c28b2
md"""
A detailed list of all the available switches can be found at [Command-line Options](@ref command-line-options).
"""

# ╔═╡ 03c7e460-9e19-11eb-2a26-3b52d9946c5f
md"""
## Resources
"""

# ╔═╡ 03c7e474-9e19-11eb-020b-df5631bd44dc
md"""
A curated list of useful learning resources to help new users get started can be found on the [learning](https://julialang.org/learning/) page of the main Julia web site.
"""

# ╔═╡ Cell order:
# ╟─03c7d9d4-9e19-11eb-1fe3-c94bd013aa41
# ╟─03c7d9f2-9e19-11eb-1c6f-99319362cd71
# ╟─03c7da1c-9e19-11eb-070c-815c9e7b5f2f
# ╟─03c7da2e-9e19-11eb-2984-293fc496eac4
# ╠═03c7df10-9e19-11eb-0602-9bb444bdc582
# ╠═03c7df1a-9e19-11eb-2934-ad9664e5c66e
# ╠═03c7df26-9e19-11eb-02ef-8350ea40aed2
# ╟─03c7df58-9e19-11eb-1028-6967e7902ddf
# ╟─03c7df74-9e19-11eb-1e77-0f5dbc0288a7
# ╟─03c7df8a-9e19-11eb-1b7c-155b3d7ebcc6
# ╠═03c7e050-9e19-11eb-343b-83bf419990ef
# ╟─03c7e078-9e19-11eb-0d36-910ec7f0de5b
# ╠═03c7e152-9e19-11eb-0393-9f52de744d29
# ╟─03c7e168-9e19-11eb-0c1a-47b5e633b342
# ╠═03c7e1fe-9e19-11eb-1c08-7166e244ccaa
# ╟─03c7e21c-9e19-11eb-0e9b-7924185b799d
# ╠═03c7e294-9e19-11eb-2a16-f5ef14159658
# ╟─03c7e2b2-9e19-11eb-3f4a-ad5079817b5c
# ╟─03c7e2ec-9e19-11eb-0d73-cb7ac0ace730
# ╟─03c7e302-9e19-11eb-1a1c-699df9e53963
# ╠═03c7e398-9e19-11eb-0f92-0f9f1f967528
# ╟─03c7e3b6-9e19-11eb-0dc8-f575805a566f
# ╟─03c7e3ca-9e19-11eb-2977-07cb89784a0e
# ╠═03c7e42e-9e19-11eb-138d-dd48178ed8fd
# ╟─03c7e44c-9e19-11eb-2a28-b71a342c28b2
# ╟─03c7e460-9e19-11eb-2a26-3b52d9946c5f
# ╟─03c7e474-9e19-11eb-020b-df5631bd44dc
