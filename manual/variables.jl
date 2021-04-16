### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 3336d78a-1442-4d69-b0b1-87834af32365
md"""
# [Variables](@id man-variables)
"""

# ╔═╡ 18fdd1aa-7b5c-4c11-88f6-3521dc38c170
md"""
A variable, in Julia, is a name associated (or bound) to a value. It's useful when you want to store a value (that you obtained after some math, for example) for later use. For example:
"""

# ╔═╡ 30ac7a38-990c-4651-8f1d-02f8f97f35da
# Assign the value 10 to the variable x

# ╔═╡ e6bb2980-9bd5-43f0-bbff-f68321b90c9d
x = 10

# ╔═╡ fecec70e-1774-4166-858b-c98c37ffc230
x + 1

# ╔═╡ 7737e3d8-3941-4a4b-ab11-5631012dee6a
x = 1 + 1

# ╔═╡ 0d017da5-4fab-4576-a444-fdba79a8248d
x = "Hello World!"

# ╔═╡ 665cf24e-50d5-49a2-a9e9-0154cb03e9dc
md"""
Julia provides an extremely flexible system for naming variables. Variable names are case-sensitive, and have no semantic meaning (that is, the language will not treat variables differently based on their names).
"""

# ╔═╡ 4f02151a-9b68-45cf-ba7c-c37931abb5a6
x = 1.0

# ╔═╡ 24ac43d7-9cf3-4812-b16f-4d62d3c88b2b
y = -3

# ╔═╡ d4c9571f-31ae-4c41-9224-31be53fa0b3c
Z = "My string"

# ╔═╡ b5917b78-9549-4773-9c43-3c2cb0115c6e
customary_phrase = "Hello world!"

# ╔═╡ 61e8cd34-9c6b-413c-8129-2c0be425943b
UniversalDeclarationOfHumanRightsStart = "人人生而自由，在尊严和权利上一律平等。"

# ╔═╡ 2d95b5bd-e323-4dd8-adfe-9d56d92ff45c
md"""
Unicode names (in UTF-8 encoding) are allowed:
"""

# ╔═╡ ea3122a0-2ed4-49d8-8880-572b6c4687f4
δ = 0.00001

# ╔═╡ 2e12f5f9-0c52-483f-88d9-2f676cb401a8
안녕하세요 = "Hello"

# ╔═╡ fcdde579-e2bd-4402-b508-d99735365ca9
md"""
In the Julia REPL and several other Julia editing environments, you can type many Unicode math symbols by typing the backslashed LaTeX symbol name followed by tab. For example, the variable name `δ` can be entered by typing `\delta`-*tab*, or even `α̂⁽²⁾` by `\alpha`-*tab*-`\hat`- *tab*-`\^(2)`-*tab*. (If you find a symbol somewhere, e.g. in someone else's code, that you don't know how to type, the REPL help will tell you: just type `?` and then paste the symbol.)
"""

# ╔═╡ 4bde1949-b8c1-4424-b395-6a7ce0e07d22
md"""
Julia will even let you redefine built-in constants and functions if needed (although this is not recommended to avoid potential confusions):
"""

# ╔═╡ da3a54ea-8449-4332-abc3-d08e33388405
pi = 3

# ╔═╡ bd8cd954-420c-40e1-ad1d-3b9de609a982
pi

# ╔═╡ 9f5c3f05-7991-4e6f-bfc0-110a5bd52c36
sqrt = 4

# ╔═╡ fdb05804-8629-45d6-a3d6-f3215f92dde3
md"""
However, if you try to redefine a built-in constant or function already in use, Julia will give you an error:
"""

# ╔═╡ 3a26f31b-2766-41fa-b80e-4e8014784e08
pi

# ╔═╡ 030a3e68-424e-4e63-8b2f-d66ff958c12b
pi = 3

# ╔═╡ bc4b6b79-8e1b-48dd-96db-2853d4439691
sqrt(100)

# ╔═╡ 30573134-dd5b-484f-8405-778c5a4d6df1
sqrt = 4

# ╔═╡ 01dbb281-1cfe-4074-ac96-b76bc2489286
md"""
## Allowed Variable Names
"""

# ╔═╡ 81daa45c-381b-4cef-be6b-7a5e0a9c1477
md"""
Variable names must begin with a letter (A-Z or a-z), underscore, or a subset of Unicode code points greater than 00A0; in particular, [Unicode character categories](http://www.fileformat.info/info/unicode/category/index.htm) Lu/Ll/Lt/Lm/Lo/Nl (letters), Sc/So (currency and other symbols), and a few other letter-like characters (e.g. a subset of the Sm math symbols) are allowed. Subsequent characters may also include ! and digits (0-9 and other characters in categories Nd/No), as well as other Unicode code points: diacritics and other modifying marks (categories Mn/Mc/Me/Sk), some punctuation connectors (category Pc), primes, and a few other characters.
"""

# ╔═╡ 7a6dfb76-51e5-49fd-a6b5-54f712bf714b
md"""
Operators like `+` are also valid identifiers, but are parsed specially. In some contexts, operators can be used just like variables; for example `(+)` refers to the addition function, and `(+) = f` will reassign it. Most of the Unicode infix operators (in category Sm), such as `⊕`, are parsed as infix operators and are available for user-defined methods (e.g. you can use `const ⊗ = kron` to define `⊗` as an infix Kronecker product).  Operators can also be suffixed with modifying marks, primes, and sub/superscripts, e.g. `+̂ₐ″` is parsed as an infix operator with the same precedence as `+`. A space is required between an operator that ends with a subscript/superscript letter and a subsequent variable name. For example, if `+ᵃ` is an operator, then `+ᵃx` must be written as `+ᵃ x` to distinguish it from `+ ᵃx` where `ᵃx` is the variable name.
"""

# ╔═╡ 0e5df58e-e9e2-4e6d-aaa5-c03af7f8ef07
md"""
The only explicitly disallowed names for variables are the names of the built-in [Keywords](@ref):
"""

# ╔═╡ 0a95f21d-1443-4b18-aeba-14b1df4ad011
else

# ╔═╡ cce5974f-5099-488f-960e-693da4c3d2e8
try =

# ╔═╡ 9dcbbde4-2a5d-4e21-9174-404aac3d2281
md"""
Some Unicode characters are considered to be equivalent in identifiers. Different ways of entering Unicode combining characters (e.g., accents) are treated as equivalent (specifically, Julia identifiers are [NFC](http://www.macchiato.com/unicode/nfc-faq)-normalized). The Unicode characters `ɛ` (U+025B: Latin small letter open e) and `µ` (U+00B5: micro sign) are treated as equivalent to the corresponding Greek letters, because the former are easily accessible via some input methods.
"""

# ╔═╡ aa2effaf-d585-4181-a6e7-5c7a8200e5d3
md"""
## Stylistic Conventions
"""

# ╔═╡ 5baf5f68-d35d-4606-90cc-34c9eafdcc04
md"""
While Julia imposes few restrictions on valid names, it has become useful to adopt the following conventions:
"""

# ╔═╡ 8cd11c2e-8ffb-4258-999c-e27b4b200b26
md"""
  * Names of variables are in lower case.
  * Word separation can be indicated by underscores (`'_'`), but use of underscores is discouraged unless the name would be hard to read otherwise.
  * Names of `Type`s and `Module`s begin with a capital letter and word separation is shown with upper camel case instead of underscores.
  * Names of `function`s and `macro`s are in lower case, without underscores.
  * Functions that write to their arguments have names that end in `!`. These are sometimes called \"mutating\" or \"in-place\" functions because they are intended to produce changes in their arguments after the function is called, not just return a value.
"""

# ╔═╡ adc1358b-2fcb-4a9d-86b4-263e8b641a5f
md"""
For more information about stylistic conventions, see the [Style Guide](@ref).
"""

# ╔═╡ Cell order:
# ╟─3336d78a-1442-4d69-b0b1-87834af32365
# ╟─18fdd1aa-7b5c-4c11-88f6-3521dc38c170
# ╠═30ac7a38-990c-4651-8f1d-02f8f97f35da
# ╠═e6bb2980-9bd5-43f0-bbff-f68321b90c9d
# ╠═fecec70e-1774-4166-858b-c98c37ffc230
# ╠═7737e3d8-3941-4a4b-ab11-5631012dee6a
# ╠═0d017da5-4fab-4576-a444-fdba79a8248d
# ╟─665cf24e-50d5-49a2-a9e9-0154cb03e9dc
# ╠═4f02151a-9b68-45cf-ba7c-c37931abb5a6
# ╠═24ac43d7-9cf3-4812-b16f-4d62d3c88b2b
# ╠═d4c9571f-31ae-4c41-9224-31be53fa0b3c
# ╠═b5917b78-9549-4773-9c43-3c2cb0115c6e
# ╠═61e8cd34-9c6b-413c-8129-2c0be425943b
# ╟─2d95b5bd-e323-4dd8-adfe-9d56d92ff45c
# ╠═ea3122a0-2ed4-49d8-8880-572b6c4687f4
# ╠═2e12f5f9-0c52-483f-88d9-2f676cb401a8
# ╟─fcdde579-e2bd-4402-b508-d99735365ca9
# ╟─4bde1949-b8c1-4424-b395-6a7ce0e07d22
# ╠═da3a54ea-8449-4332-abc3-d08e33388405
# ╠═bd8cd954-420c-40e1-ad1d-3b9de609a982
# ╠═9f5c3f05-7991-4e6f-bfc0-110a5bd52c36
# ╟─fdb05804-8629-45d6-a3d6-f3215f92dde3
# ╠═3a26f31b-2766-41fa-b80e-4e8014784e08
# ╠═030a3e68-424e-4e63-8b2f-d66ff958c12b
# ╠═bc4b6b79-8e1b-48dd-96db-2853d4439691
# ╠═30573134-dd5b-484f-8405-778c5a4d6df1
# ╟─01dbb281-1cfe-4074-ac96-b76bc2489286
# ╟─81daa45c-381b-4cef-be6b-7a5e0a9c1477
# ╟─7a6dfb76-51e5-49fd-a6b5-54f712bf714b
# ╟─0e5df58e-e9e2-4e6d-aaa5-c03af7f8ef07
# ╠═0a95f21d-1443-4b18-aeba-14b1df4ad011
# ╠═cce5974f-5099-488f-960e-693da4c3d2e8
# ╟─9dcbbde4-2a5d-4e21-9174-404aac3d2281
# ╟─aa2effaf-d585-4181-a6e7-5c7a8200e5d3
# ╟─5baf5f68-d35d-4606-90cc-34c9eafdcc04
# ╟─8cd11c2e-8ffb-4258-999c-e27b4b200b26
# ╟─adc1358b-2fcb-4a9d-86b4-263e8b641a5f
