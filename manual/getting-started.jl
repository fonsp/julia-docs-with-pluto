### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 8435942b-e236-4d01-9341-7463e6ff3250
md"""
# [Getting Started](@id man-getting-started)
"""

# ╔═╡ e4a432cf-0f74-422c-b997-87c30e383936
md"""
Julia installation is straightforward, whether using precompiled binaries or compiling from source. Download and install Julia by following the instructions at [https://julialang.org/downloads/](https://julialang.org/downloads/).
"""

# ╔═╡ 4329753c-7656-43d8-b2df-33a17ec06489
md"""
If you are coming to Julia from one of the following languages, then you should start by reading the section on noteworthy differences from [MATLAB](@ref Noteworthy-differences-from-MATLAB), [R](@ref Noteworthy-differences-from-R), [Python](@ref Noteworthy-differences-from-Python), [C/C++](@ref Noteworthy-differences-from-C/C) or [Common Lisp](@ref Noteworthy-differences-from-Common-Lisp). This will help you avoid some common pitfalls since Julia differs from those languages in many subtle ways.
"""

# ╔═╡ 41188703-adc0-4cbb-aa82-42c644e17f2c
md"""
The easiest way to learn and experiment with Julia is by starting an interactive session (also known as a read-eval-print loop or \"REPL\") by double-clicking the Julia executable or running `julia` from the command line:
"""

# ╔═╡ 64b9ad77-ab65-460b-997b-2f4daebbc3f4
let
io = IOBuffer()
Base.banner(io)
banner = String(take!(io))
import Markdown
Markdown.parse("```\n\$ julia\n\n$(banner)\njulia> 1 + 2\n3\n\njulia> ans\n3\n```")
end

# ╔═╡ 10fa60c6-1dc2-4fec-9788-bcbf58cab4fa
md"""
To exit the interactive session, type `CTRL-D` (press the Control/`^` key together with the `d` key), or type `exit()`. When run in interactive mode, `julia` displays a banner and prompts the user for input. Once the user has entered a complete expression, such as `1 + 2`, and hits enter, the interactive session evaluates the expression and shows its value. If an expression is entered into an interactive session with a trailing semicolon, its value is not shown. The variable `ans` is bound to the value of the last evaluated expression whether it is shown or not. The `ans` variable is only bound in interactive sessions, not when Julia code is run in other ways.
"""

# ╔═╡ ede04b5d-6076-4f30-804b-0f4f8bd94246
md"""
To evaluate expressions written in a source file `file.jl`, write `include(\"file.jl\")`.
"""

# ╔═╡ 8cd9b04c-24ca-4486-b07e-f0a060c98d5c
md"""
To run code in a file non-interactively, you can give it as the first argument to the `julia` command:
"""

# ╔═╡ cbc88710-8d5d-4730-8892-ea12ff4b86f3
md"""
```
$ julia script.jl arg1 arg2...
```
"""

# ╔═╡ eb631d3d-b797-4e66-b640-1fe02ee0c674
md"""
As the example implies, the following command-line arguments to `julia` are interpreted as command-line arguments to the program `script.jl`, passed in the global constant `ARGS`. The name of the script itself is passed in as the global `PROGRAM_FILE`. Note that `ARGS` is also set when a Julia expression is given using the `-e` option on the command line (see the `julia` help output below) but `PROGRAM_FILE` will be empty. For example, to just print the arguments given to a script, you could do this:
"""

# ╔═╡ f7497765-d86f-410e-b18c-83f3aad4ed5f
md"""
```
$ julia -e 'println(PROGRAM_FILE); for x in ARGS; println(x); end' foo bar

foo
bar
```
"""

# ╔═╡ 27fb9134-e873-4585-b22a-0fbc1c4bd02b
md"""
Or you could put that code into a script and run it:
"""

# ╔═╡ 3ba98748-e396-43e8-ae69-93c2aeb8bc9c
md"""
```
$ echo 'println(PROGRAM_FILE); for x in ARGS; println(x); end' > script.jl
$ julia script.jl foo bar
script.jl
foo
bar
```
"""

# ╔═╡ 9ebe6250-c149-4071-9ef8-9e4e581f19a5
md"""
The `--` delimiter can be used to separate command-line arguments intended for the script file from arguments intended for Julia:
"""

# ╔═╡ 86ddfc77-6f4f-4a6c-9028-871bbc035071
md"""
```
$ julia --color=yes -O -- foo.jl arg1 arg2..
```
"""

# ╔═╡ d4bd3f4d-5048-457c-b8f8-b4ccb221d9b7
md"""
See also [Scripting](@ref man-scripting) for more information on writing Julia scripts.
"""

# ╔═╡ 1d91540d-874b-4531-a8df-7634869dcff4
md"""
Julia can be started in parallel mode with either the `-p` or the `--machine-file` options. `-p n` will launch an additional `n` worker processes, while `--machine-file file` will launch a worker for each line in file `file`. The machines defined in `file` must be accessible via a password-less `ssh` login, with Julia installed at the same location as the current host. Each machine definition takes the form `[count*][user@]host[:port] [bind_addr[:port]]`. `user` defaults to current user, `port` to the standard ssh port. `count` is the number of workers to spawn on the node, and defaults to 1. The optional `bind-to bind_addr[:port]` specifies the IP address and port that other workers should use to connect to this worker.
"""

# ╔═╡ b77786f9-f391-4815-91f2-6a99f03b08e0
md"""
If you have code that you want executed whenever Julia is run, you can put it in `~/.julia/config/startup.jl`:
"""

# ╔═╡ ad9cc430-67b3-414d-8068-08f4c97ac459
md"""
```
$ echo 'println(\"Greetings! 你好! 안녕하세요?\")' > ~/.julia/config/startup.jl
$ julia
Greetings! 你好! 안녕하세요?

...
```
"""

# ╔═╡ e6f04df9-c843-4f6b-bd56-34af4abff4ed
md"""
Note that although you should have a `~/.julia` directory once you've run Julia for the first time, you may need to create the `~/.julia/config` folder and the `~/.julia/config/startup.jl` file if you use it.
"""

# ╔═╡ 8b23e5df-fbfc-495c-950e-9899c0959ec4
md"""
There are various ways to run Julia code and provide options, similar to those available for the `perl` and `ruby` programs:
"""

# ╔═╡ 951953c8-0d69-49ea-a56c-3522e0aaa973
md"""
```
julia [switches] -- [programfile] [args...]
```
"""

# ╔═╡ e8d08d1e-a053-4440-933a-0c4c211dfcb9
md"""
A detailed list of all the available switches can be found at [Command-line Options](@ref command-line-options).
"""

# ╔═╡ adab6d88-9f0e-4a46-81a9-79c7d69cb272
md"""
## Resources
"""

# ╔═╡ d4740030-3549-4b7a-815b-31ec160dab42
md"""
A curated list of useful learning resources to help new users get started can be found on the [learning](https://julialang.org/learning/) page of the main Julia web site.
"""

# ╔═╡ Cell order:
# ╟─8435942b-e236-4d01-9341-7463e6ff3250
# ╟─e4a432cf-0f74-422c-b997-87c30e383936
# ╟─4329753c-7656-43d8-b2df-33a17ec06489
# ╟─41188703-adc0-4cbb-aa82-42c644e17f2c
# ╟─64b9ad77-ab65-460b-997b-2f4daebbc3f4
# ╟─10fa60c6-1dc2-4fec-9788-bcbf58cab4fa
# ╟─ede04b5d-6076-4f30-804b-0f4f8bd94246
# ╟─8cd9b04c-24ca-4486-b07e-f0a060c98d5c
# ╟─cbc88710-8d5d-4730-8892-ea12ff4b86f3
# ╟─eb631d3d-b797-4e66-b640-1fe02ee0c674
# ╟─f7497765-d86f-410e-b18c-83f3aad4ed5f
# ╟─27fb9134-e873-4585-b22a-0fbc1c4bd02b
# ╟─3ba98748-e396-43e8-ae69-93c2aeb8bc9c
# ╟─9ebe6250-c149-4071-9ef8-9e4e581f19a5
# ╟─86ddfc77-6f4f-4a6c-9028-871bbc035071
# ╟─d4bd3f4d-5048-457c-b8f8-b4ccb221d9b7
# ╟─1d91540d-874b-4531-a8df-7634869dcff4
# ╟─b77786f9-f391-4815-91f2-6a99f03b08e0
# ╟─ad9cc430-67b3-414d-8068-08f4c97ac459
# ╟─e6f04df9-c843-4f6b-bd56-34af4abff4ed
# ╟─8b23e5df-fbfc-495c-950e-9899c0959ec4
# ╟─951953c8-0d69-49ea-a56c-3522e0aaa973
# ╟─e8d08d1e-a053-4440-933a-0c4c211dfcb9
# ╟─adab6d88-9f0e-4a46-81a9-79c7d69cb272
# ╟─d4740030-3549-4b7a-815b-31ec160dab42
