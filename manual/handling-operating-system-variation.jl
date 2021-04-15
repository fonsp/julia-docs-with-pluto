### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03c83398-9e19-11eb-27f8-d77b92cfda7d
md"""
# Handling Operating System Variation
"""

# ╔═╡ 03c833ca-9e19-11eb-2bc1-6588d1ebdd5c
md"""
When writing cross-platform applications or libraries, it is often necessary to allow for differences between operating systems. The variable `Sys.KERNEL` can be used to handle such cases. There are several functions in the `Sys` module intended to make this easier, such as `isunix`, `islinux`, `isapple`, `isbsd`, `isfreebsd`, and `iswindows`. These may be used as follows:
"""

# ╔═╡ 03c833f2-9e19-11eb-2f1b-5b5573044ecd
md"""
```julia
if Sys.iswindows()
    windows_specific_thing(a)
end
```
"""

# ╔═╡ 03c83410-9e19-11eb-0e22-eb80ef2f7e5d
md"""
Note that `islinux`, `isapple`, and `isfreebsd` are mutually exclusive subsets of `isunix`. Additionally, there is a macro `@static` which makes it possible to use these functions to conditionally hide invalid code, as demonstrated in the following examples.
"""

# ╔═╡ 03c83424-9e19-11eb-3da4-a566b83d5f47
md"""
Simple blocks:
"""

# ╔═╡ 03c83802-9e19-11eb-08ad-8d45ff731895
ccall((@static Sys.iswindows() ? :_fopen : :fopen), ...

# ╔═╡ 03c83816-9e19-11eb-3136-8788ca8b09ec
md"""
Complex blocks:
"""

# ╔═╡ 03c83834-9e19-11eb-0374-1bf58139b0e1
md"""
```julia
@static if Sys.islinux()
    linux_specific_thing(a)
else
    generic_thing(a)
end
```
"""

# ╔═╡ 03c83852-9e19-11eb-159e-91beccd6baf9
md"""
When chaining conditionals (including `if`/`elseif`/`end`), the `@static` must be repeated for each level (parentheses optional, but recommended for readability):
"""

# ╔═╡ 03c83868-9e19-11eb-21b0-b3ce76748e64
md"""
```julia
@static Sys.iswindows() ? :a : (@static Sys.isapple() ? :b : :c)
```
"""

# ╔═╡ Cell order:
# ╟─03c83398-9e19-11eb-27f8-d77b92cfda7d
# ╟─03c833ca-9e19-11eb-2bc1-6588d1ebdd5c
# ╟─03c833f2-9e19-11eb-2f1b-5b5573044ecd
# ╟─03c83410-9e19-11eb-0e22-eb80ef2f7e5d
# ╟─03c83424-9e19-11eb-3da4-a566b83d5f47
# ╠═03c83802-9e19-11eb-08ad-8d45ff731895
# ╟─03c83816-9e19-11eb-3136-8788ca8b09ec
# ╟─03c83834-9e19-11eb-0374-1bf58139b0e1
# ╟─03c83852-9e19-11eb-159e-91beccd6baf9
# ╟─03c83868-9e19-11eb-21b0-b3ce76748e64
