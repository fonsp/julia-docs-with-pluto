### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 269e95ad-12e1-45a5-a022-7253f57e368a
md"""
# Handling Operating System Variation
"""

# ╔═╡ a8c31996-488c-474e-9adf-7e13c505d553
md"""
When writing cross-platform applications or libraries, it is often necessary to allow for differences between operating systems. The variable `Sys.KERNEL` can be used to handle such cases. There are several functions in the `Sys` module intended to make this easier, such as `isunix`, `islinux`, `isapple`, `isbsd`, `isfreebsd`, and `iswindows`. These may be used as follows:
"""

# ╔═╡ 675bbae1-cc96-473f-a8fe-fd91bc0eba2b
md"""
```julia
if Sys.iswindows()
    windows_specific_thing(a)
end
```
"""

# ╔═╡ 50e441cd-b9df-4be8-9296-20c2398e14a6
md"""
Note that `islinux`, `isapple`, and `isfreebsd` are mutually exclusive subsets of `isunix`. Additionally, there is a macro `@static` which makes it possible to use these functions to conditionally hide invalid code, as demonstrated in the following examples.
"""

# ╔═╡ 11f41d43-f00b-4aee-a48a-99b0a9726e93
md"""
Simple blocks:
"""

# ╔═╡ 865652ec-9e8b-44b2-aef0-34e6318db02e
md"""
```
ccall((@static Sys.iswindows() ? :_fopen : :fopen), ...)
```
"""

# ╔═╡ 6a3efa0a-7b13-4a86-9ad4-64991e719e00
md"""
Complex blocks:
"""

# ╔═╡ 7c704467-ef81-43bb-9496-230f437aa2fe
md"""
```julia
@static if Sys.islinux()
    linux_specific_thing(a)
else
    generic_thing(a)
end
```
"""

# ╔═╡ bdb3335e-c553-4be5-9039-86ce4c0221a1
md"""
When chaining conditionals (including `if`/`elseif`/`end`), the `@static` must be repeated for each level (parentheses optional, but recommended for readability):
"""

# ╔═╡ 2ea34ae9-96a9-4f66-a70f-d9993896f974
md"""
```julia
@static Sys.iswindows() ? :a : (@static Sys.isapple() ? :b : :c)
```
"""

# ╔═╡ Cell order:
# ╟─269e95ad-12e1-45a5-a022-7253f57e368a
# ╟─a8c31996-488c-474e-9adf-7e13c505d553
# ╟─675bbae1-cc96-473f-a8fe-fd91bc0eba2b
# ╟─50e441cd-b9df-4be8-9296-20c2398e14a6
# ╟─11f41d43-f00b-4aee-a48a-99b0a9726e93
# ╟─865652ec-9e8b-44b2-aef0-34e6318db02e
# ╟─6a3efa0a-7b13-4a86-9ad4-64991e719e00
# ╟─7c704467-ef81-43bb-9496-230f437aa2fe
# ╟─bdb3335e-c553-4be5-9039-86ce4c0221a1
# ╟─2ea34ae9-96a9-4f66-a70f-d9993896f974
