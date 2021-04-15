### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03dbc084-9e19-11eb-1c56-e1db5bce5185
md"""
# [Variables](@id man-variables)
"""

# ╔═╡ 03dbc0a2-9e19-11eb-15bd-65653ef7735a
md"""
A variable, in Julia, is a name associated (or bound) to a value. It's useful when you want to store a value (that you obtained after some math, for example) for later use. For example:
"""

# ╔═╡ 03dbc836-9e19-11eb-04cb-bf61f736b1c6
# Assign the value 10 to the variable x

# ╔═╡ 03dbc854-9e19-11eb-1bbb-8796f2c2f901
x = 10

# ╔═╡ 03dbc854-9e19-11eb-11dd-7b2f36cd82bf
x + 1

# ╔═╡ 03dbc85e-9e19-11eb-387b-6344552121d3
x = 1 + 1

# ╔═╡ 03dbc85e-9e19-11eb-37de-bfb11c8d6f99
x = "Hello World!"

# ╔═╡ 03dbc87c-9e19-11eb-365b-0f194a4bdd53
md"""
Julia provides an extremely flexible system for naming variables. Variable names are case-sensitive, and have no semantic meaning (that is, the language will not treat variables differently based on their names).
"""

# ╔═╡ 03dbce1c-9e19-11eb-240c-51474682dbfd
x = 1.0

# ╔═╡ 03dbce30-9e19-11eb-0b2a-1df0963ecdd8
y = -3

# ╔═╡ 03dbce30-9e19-11eb-15a5-edbc2ddc9273
Z = "My string"

# ╔═╡ 03dbce3a-9e19-11eb-074d-8f591c58a0b4
customary_phrase = "Hello world!"

# ╔═╡ 03dbce42-9e19-11eb-2f2f-c51c45ef859e
UniversalDeclarationOfHumanRightsStart = "人人生而自由，在尊严和权利上一律平等。"

# ╔═╡ 03dbce62-9e19-11eb-3d2d-8fd7ce96745e
md"""
Unicode names (in UTF-8 encoding) are allowed:
"""

# ╔═╡ 03dbd0e0-9e19-11eb-311a-07dd1fe0712f
δ = 0.00001

# ╔═╡ 03dbd0ec-9e19-11eb-22a7-bfb02e06d176
안녕하세요 = "Hello"

# ╔═╡ 03dbd350-9e19-11eb-2a33-799a05ab6233
md"""
In the Julia REPL and several other Julia editing environments, you can type many Unicode math symbols by typing the backslashed LaTeX symbol name followed by tab. For example, the variable name `δ` can be entered by typing `\delta`-*tab*, or even `α̂⁽²⁾` by `\alpha`-*tab*-`\hat`- *tab*-`\^(2)`-*tab*. (If you find a symbol somewhere, e.g. in someone else's code, that you don't know how to type, the REPL help will tell you: just type `?` and then paste the symbol.)
"""

# ╔═╡ 03dbd376-9e19-11eb-1d1b-9f6e1c2b7f8e
md"""
Julia will even let you redefine built-in constants and functions if needed (although this is not recommended to avoid potential confusions):
"""

# ╔═╡ 03dbd6fa-9e19-11eb-3b74-0da203c6ec86
pi = 3

# ╔═╡ 03dbd704-9e19-11eb-34a1-ed8ed35f55b3
pi

# ╔═╡ 03dbd718-9e19-11eb-035a-adfb4cdb37ec
sqrt = 4

# ╔═╡ 03dbd72c-9e19-11eb-2b82-8514f3fa875c
md"""
However, if you try to redefine a built-in constant or function already in use, Julia will give you an error:
"""

# ╔═╡ 03dbddc6-9e19-11eb-05a9-d9048cacf115
pi

# ╔═╡ 03dbddc6-9e19-11eb-12a3-471fce505b83
pi = 3

# ╔═╡ 03dbddd0-9e19-11eb-116d-d5105586036b
sqrt(100)

# ╔═╡ 03dbddee-9e19-11eb-3006-f5dba5b52820
sqrt = 4

# ╔═╡ 03dbde34-9e19-11eb-23f9-610ff04dfb5b
md"""
## Allowed Variable Names
"""

# ╔═╡ 03dbde98-9e19-11eb-0a86-e7318a8039ff
md"""
Variable names must begin with a letter (A-Z or a-z), underscore, or a subset of Unicode code points greater than 00A0; in particular, [Unicode character categories](http://www.fileformat.info/info/unicode/category/index.htm) Lu/Ll/Lt/Lm/Lo/Nl (letters), Sc/So (currency and other symbols), and a few other letter-like characters (e.g. a subset of the Sm math symbols) are allowed. Subsequent characters may also include ! and digits (0-9 and other characters in categories Nd/No), as well as other Unicode code points: diacritics and other modifying marks (categories Mn/Mc/Me/Sk), some punctuation connectors (category Pc), primes, and a few other characters.
"""

# ╔═╡ 03dbdef2-9e19-11eb-2d81-d3a4d7dba494
md"""
Operators like `+` are also valid identifiers, but are parsed specially. In some contexts, operators can be used just like variables; for example `(+)` refers to the addition function, and `(+) = f` will reassign it. Most of the Unicode infix operators (in category Sm), such as `⊕`, are parsed as infix operators and are available for user-defined methods (e.g. you can use `const ⊗ = kron` to define `⊗` as an infix Kronecker product).  Operators can also be suffixed with modifying marks, primes, and sub/superscripts, e.g. `+̂ₐ″` is parsed as an infix operator with the same precedence as `+`. A space is required between an operator that ends with a subscript/superscript letter and a subsequent variable name. For example, if `+ᵃ` is an operator, then `+ᵃx` must be written as `+ᵃ x` to distinguish it from `+ ᵃx` where `ᵃx` is the variable name.
"""

# ╔═╡ 03dbdf10-9e19-11eb-2018-5b5fbbb1f332
md"""
The only explicitly disallowed names for variables are the names of the built-in [Keywords](@ref):
"""

# ╔═╡ 03dbe06e-9e19-11eb-0e6a-f9041b45b5eb
else

# ╔═╡ 03dbe078-9e19-11eb-0d86-c5d788dd2702
try =

# ╔═╡ 03dbe0d2-9e19-11eb-1b1e-6f38648f3331
md"""
Some Unicode characters are considered to be equivalent in identifiers. Different ways of entering Unicode combining characters (e.g., accents) are treated as equivalent (specifically, Julia identifiers are [NFC](http://www.macchiato.com/unicode/nfc-faq)-normalized). The Unicode characters `ɛ` (U+025B: Latin small letter open e) and `µ` (U+00B5: micro sign) are treated as equivalent to the corresponding Greek letters, because the former are easily accessible via some input methods.
"""

# ╔═╡ 03dbe0e6-9e19-11eb-2712-b50a76b048c8
md"""
## Stylistic Conventions
"""

# ╔═╡ 03dbe0fc-9e19-11eb-07b7-897009a863c6
md"""
While Julia imposes few restrictions on valid names, it has become useful to adopt the following conventions:
"""

# ╔═╡ 03dbe264-9e19-11eb-0719-a5b2ecf33ed1
md"""
  * Names of variables are in lower case.
  * Word separation can be indicated by underscores (`'_'`), but use of underscores is discouraged unless the name would be hard to read otherwise.
  * Names of `Type`s and `Module`s begin with a capital letter and word separation is shown with upper camel case instead of underscores.
  * Names of `function`s and `macro`s are in lower case, without underscores.
  * Functions that write to their arguments have names that end in `!`. These are sometimes called "mutating" or "in-place" functions because they are intended to produce changes in their arguments after the function is called, not just return a value.
"""

# ╔═╡ 03dbe280-9e19-11eb-32ad-3fd0cede12a0
md"""
For more information about stylistic conventions, see the [Style Guide](@ref).
"""

# ╔═╡ Cell order:
# ╟─03dbc084-9e19-11eb-1c56-e1db5bce5185
# ╟─03dbc0a2-9e19-11eb-15bd-65653ef7735a
# ╠═03dbc836-9e19-11eb-04cb-bf61f736b1c6
# ╠═03dbc854-9e19-11eb-1bbb-8796f2c2f901
# ╠═03dbc854-9e19-11eb-11dd-7b2f36cd82bf
# ╠═03dbc85e-9e19-11eb-387b-6344552121d3
# ╠═03dbc85e-9e19-11eb-37de-bfb11c8d6f99
# ╟─03dbc87c-9e19-11eb-365b-0f194a4bdd53
# ╠═03dbce1c-9e19-11eb-240c-51474682dbfd
# ╠═03dbce30-9e19-11eb-0b2a-1df0963ecdd8
# ╠═03dbce30-9e19-11eb-15a5-edbc2ddc9273
# ╠═03dbce3a-9e19-11eb-074d-8f591c58a0b4
# ╠═03dbce42-9e19-11eb-2f2f-c51c45ef859e
# ╟─03dbce62-9e19-11eb-3d2d-8fd7ce96745e
# ╠═03dbd0e0-9e19-11eb-311a-07dd1fe0712f
# ╠═03dbd0ec-9e19-11eb-22a7-bfb02e06d176
# ╟─03dbd350-9e19-11eb-2a33-799a05ab6233
# ╟─03dbd376-9e19-11eb-1d1b-9f6e1c2b7f8e
# ╠═03dbd6fa-9e19-11eb-3b74-0da203c6ec86
# ╠═03dbd704-9e19-11eb-34a1-ed8ed35f55b3
# ╠═03dbd718-9e19-11eb-035a-adfb4cdb37ec
# ╟─03dbd72c-9e19-11eb-2b82-8514f3fa875c
# ╠═03dbddc6-9e19-11eb-05a9-d9048cacf115
# ╠═03dbddc6-9e19-11eb-12a3-471fce505b83
# ╠═03dbddd0-9e19-11eb-116d-d5105586036b
# ╠═03dbddee-9e19-11eb-3006-f5dba5b52820
# ╟─03dbde34-9e19-11eb-23f9-610ff04dfb5b
# ╟─03dbde98-9e19-11eb-0a86-e7318a8039ff
# ╟─03dbdef2-9e19-11eb-2d81-d3a4d7dba494
# ╟─03dbdf10-9e19-11eb-2018-5b5fbbb1f332
# ╠═03dbe06e-9e19-11eb-0e6a-f9041b45b5eb
# ╠═03dbe078-9e19-11eb-0d86-c5d788dd2702
# ╟─03dbe0d2-9e19-11eb-1b1e-6f38648f3331
# ╟─03dbe0e6-9e19-11eb-2712-b50a76b048c8
# ╟─03dbe0fc-9e19-11eb-07b7-897009a863c6
# ╟─03dbe264-9e19-11eb-0719-a5b2ecf33ed1
# ╟─03dbe280-9e19-11eb-32ad-3fd0cede12a0
