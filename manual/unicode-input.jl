### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03da5032-9e19-11eb-211c-e75241114e9f
md"""
# Unicode Input
"""

# ╔═╡ 03da5052-9e19-11eb-3fd3-87bf61847c75
md"""
The following table lists Unicode characters that can be entered via tab completion of LaTeX-like abbreviations in the Julia REPL (and in various other editing environments).  You can also get information on how to type a symbol by entering it in the REPL help, i.e. by typing `?` and then entering the symbol in the REPL (e.g., by copy-paste from somewhere you saw the symbol).
"""

# ╔═╡ 03da50a0-9e19-11eb-1060-372d7bba5626
md"""
!!! warning
    This table may appear to contain missing characters in the second column, or even show characters that are inconsistent with the characters as they are rendered in the Julia REPL. In these cases, users are strongly advised to check their choice of fonts in their browser and REPL environment, as there are known issues with glyphs in many fonts.
"""

# ╔═╡ 03da5294-9e19-11eb-2ab1-0bdb276a0523
#
# Generate a table containing all LaTeX and Emoji tab completions available in the REPL.
#
import REPL, Markdown

# ╔═╡ Cell order:
# ╟─03da5032-9e19-11eb-211c-e75241114e9f
# ╟─03da5052-9e19-11eb-3fd3-87bf61847c75
# ╟─03da50a0-9e19-11eb-1060-372d7bba5626
# ╠═03da5294-9e19-11eb-2ab1-0bdb276a0523
