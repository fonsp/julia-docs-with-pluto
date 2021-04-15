### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03cb0226-9e19-11eb-0c66-1fb779369ec4
md"""
# Mathematical Operations and Elementary Functions
"""

# ╔═╡ 03cb0242-9e19-11eb-3170-b5ebfb1875b8
md"""
Julia provides a complete collection of basic arithmetic and bitwise operators across all of its numeric primitive types, as well as providing portable, efficient implementations of a comprehensive collection of standard mathematical functions.
"""

# ╔═╡ 03cb0274-9e19-11eb-336f-a384f87e5754
md"""
## Arithmetic Operators
"""

# ╔═╡ 03cb02ee-9e19-11eb-3ce5-7955bd7c803c
md"""
The following [arithmetic operators](https://en.wikipedia.org/wiki/Arithmetic#Arithmetic_operations) are supported on all primitive numeric types:
"""

# ╔═╡ 03cb0582-9e19-11eb-2956-b72b602d93d3
md"""
| Expression | Name           | Description                            |
|:---------- |:-------------- |:-------------------------------------- |
| `+x`       | unary plus     | the identity operation                 |
| `-x`       | unary minus    | maps values to their additive inverses |
| `x + y`    | binary plus    | performs addition                      |
| `x - y`    | binary minus   | performs subtraction                   |
| `x * y`    | times          | performs multiplication                |
| `x / y`    | divide         | performs division                      |
| `x ÷ y`    | integer divide | x / y, truncated to an integer         |
| `x \ y`    | inverse divide | equivalent to `y / x`                  |
| `x ^ y`    | power          | raises `x` to the `y`th power          |
| `x % y`    | remainder      | equivalent to `rem(x,y)`               |
"""

# ╔═╡ 03cb05a0-9e19-11eb-02bf-150c552f7ba2
md"""
A numeric literal placed directly before an identifier or parentheses, e.g. `2x` or `2(x+y)`, is treated as a multiplication, except with higher precedence than other binary operations.  See [Numeric Literal Coefficients](@ref man-numeric-literal-coefficients) for details.
"""

# ╔═╡ 03cb05be-9e19-11eb-3bc9-81b74a35a94e
md"""
Julia's promotion system makes arithmetic operations on mixtures of argument types "just work" naturally and automatically. See [Conversion and Promotion](@ref conversion-and-promotion) for details of the promotion system.
"""

# ╔═╡ 03cb05c8-9e19-11eb-1461-a569863b2df8
md"""
Here are some simple examples using arithmetic operators:
"""

# ╔═╡ 03cb0c58-9e19-11eb-26c9-151178ccabc9
1 + 2 + 3

# ╔═╡ 03cb0c58-9e19-11eb-0b90-31721c7b0694
1 - 2

# ╔═╡ 03cb0c62-9e19-11eb-23df-1dcb95231b47
3*2/12

# ╔═╡ 03cb0c80-9e19-11eb-2d94-1b6931ab68d9
md"""
(By convention, we tend to space operators more tightly if they get applied before other nearby operators. For instance, we would generally write `-x + 2` to reflect that first `x` gets negated, and then `2` is added to that result.)
"""

# ╔═╡ 03cb0ca8-9e19-11eb-3ddd-a513148bbc6d
md"""
When used in multiplication, `false` acts as a *strong zero*:
"""

# ╔═╡ 03cb0e58-9e19-11eb-1d3b-0b9408ffdd53
NaN * false

# ╔═╡ 03cb0e58-9e19-11eb-0b4a-679e5f34725f
false * Inf

# ╔═╡ 03cb0e7e-9e19-11eb-2ba0-f515768a0811
md"""
This is useful for preventing the propagation of `NaN` values in quantities that are known to be zero. See [Knuth (1992)](https://arxiv.org/abs/math/9205211) for motivation.
"""

# ╔═╡ 03cb0e92-9e19-11eb-23fb-17fe3b6ef0a7
md"""
## Boolean Operators
"""

# ╔═╡ 03cb0eb0-9e19-11eb-10a4-358084651633
md"""
The following [Boolean operators](https://en.wikipedia.org/wiki/Boolean_algebra#Operations) are supported on [`Bool`](@ref) types:
"""

# ╔═╡ 03cb0f3c-9e19-11eb-3959-7d184d31853e
md"""
| Expression | Name                                                    |
|:---------- |:------------------------------------------------------- |
| `!x`       | negation                                                |
| `x && y`   | [short-circuiting and](@ref man-conditional-evaluation) |
| `x \|\| y` | [short-circuiting or](@ref man-conditional-evaluation)  |
"""

# ╔═╡ 03cb0f5c-9e19-11eb-2cc8-ad3e513c3111
md"""
Negation changes `true` to `false` and vice versa. The short-circuiting opeations are explained on the linked page.
"""

# ╔═╡ 03cb0f64-9e19-11eb-0367-9daf5321eb08
md"""
Note that `Bool` is an integer type and all the usual promotion rules and numeric operators are also defined on it.
"""

# ╔═╡ 03cb0f78-9e19-11eb-351b-8b112ebbaac1
md"""
## Bitwise Operators
"""

# ╔═╡ 03cb0f96-9e19-11eb-1597-c30dda38bd4f
md"""
The following [bitwise operators](https://en.wikipedia.org/wiki/Bitwise_operation#Bitwise_operators) are supported on all primitive integer types:
"""

# ╔═╡ 03cb1054-9e19-11eb-01ec-ddd8f533b2b4
md"""
| Expression | Name                                                                     |
|:---------- |:------------------------------------------------------------------------ |
| `~x`       | bitwise not                                                              |
| `x & y`    | bitwise and                                                              |
| `x \| y`   | bitwise or                                                               |
| `x ⊻ y`    | bitwise xor (exclusive or)                                               |
| `x >>> y`  | [logical shift](https://en.wikipedia.org/wiki/Logical_shift) right       |
| `x >> y`   | [arithmetic shift](https://en.wikipedia.org/wiki/Arithmetic_shift) right |
| `x << y`   | logical/arithmetic shift left                                            |
"""

# ╔═╡ 03cb1068-9e19-11eb-04cc-1b1d6faba1a7
md"""
Here are some examples with bitwise operators:
"""

# ╔═╡ 03cb172a-9e19-11eb-3a7a-4fc72bff1014
~123

# ╔═╡ 03cb1734-9e19-11eb-0e25-33ae9d4185c2
123 & 234

# ╔═╡ 03cb1734-9e19-11eb-35ad-6bdd98116e10
123 | 234

# ╔═╡ 03cb173e-9e19-11eb-1131-cbe40545510f
123 ⊻ 234

# ╔═╡ 03cb1748-9e19-11eb-0070-67c705a7a9a4
xor(123, 234)

# ╔═╡ 03cb1748-9e19-11eb-3a93-63f1c8b2ab22
~UInt32(123)

# ╔═╡ 03cb1748-9e19-11eb-232c-4d007326d2a4
~UInt8(123)

# ╔═╡ 03cb175c-9e19-11eb-23b1-473e7adf265a
md"""
## Updating operators
"""

# ╔═╡ 03cb1784-9e19-11eb-1aaa-279484641f14
md"""
Every binary arithmetic and bitwise operator also has an updating version that assigns the result of the operation back into its left operand. The updating version of the binary operator is formed by placing a `=` immediately after the operator. For example, writing `x += 3` is equivalent to writing `x = x + 3`:
"""

# ╔═╡ 03cb1a04-9e19-11eb-24bd-cdfe4ab97967
x = 1

# ╔═╡ 03cb1a0e-9e19-11eb-2464-99cedeeba8e4
x += 3

# ╔═╡ 03cb1a18-9e19-11eb-39f1-09112a177428
x

# ╔═╡ 03cb1a22-9e19-11eb-19f4-2d880d3831f8
md"""
The updating versions of all the binary arithmetic and bitwise operators are:
"""

# ╔═╡ 03cb1ab8-9e19-11eb-2dff-f34f269994e3
+=

# ╔═╡ 03cb1bd2-9e19-11eb-334d-51bcca51080c
md"""
!!! note
    An updating operator rebinds the variable on the left-hand side. As a result, the type of the variable may change.

    ```jldoctest
    julia> x = 0x01; typeof(x)
    UInt8

    julia> x *= 2 # Same as x = x * 2
    2

    julia> typeof(x)
    Int64
    ```
"""

# ╔═╡ 03cb1be4-9e19-11eb-3bb8-238c1b8d1f58
md"""
## [Vectorized "dot" operators](@id man-dot-operators)
"""

# ╔═╡ 03cb1c2a-9e19-11eb-01e4-055a61aeacb8
md"""
For *every* binary operation like `^`, there is a corresponding "dot" operation `.^` that is *automatically* defined to perform `^` element-by-element on arrays. For example, `[1,2,3] ^ 3` is not defined, since there is no standard mathematical meaning to "cubing" a (non-square) array, but `[1,2,3] .^ 3` is defined as computing the elementwise (or "vectorized") result `[1^3, 2^3, 3^3]`.  Similarly for unary operators like `!` or `√`, there is a corresponding `.√` that applies the operator elementwise.
"""

# ╔═╡ 03cb1dd8-9e19-11eb-1938-879a25ca0535
[1,2,3] .^ 3

# ╔═╡ 03cb1e28-9e19-11eb-16c0-39bec19be201
md"""
More specifically, `a .^ b` is parsed as the ["dot" call](@ref man-vectorized) `(^).(a,b)`, which performs a [broadcast](@ref Broadcasting) operation: it can combine arrays and scalars, arrays of the same size (performing the operation elementwise), and even arrays of different shapes (e.g. combining row and column vectors to produce a matrix). Moreover, like all vectorized "dot calls," these "dot operators" are *fusing*. For example, if you compute `2 .* A.^2 .+ sin.(A)` (or equivalently `@. 2A^2 + sin(A)`, using the [`@.`](@ref @__dot__) macro) for an array `A`, it performs a *single* loop over `A`, computing `2a^2 + sin(a)` for each element of `A`. In particular, nested dot calls like `f.(g.(x))` are fused, and "adjacent" binary operators like `x .+ 3 .* x.^2` are equivalent to nested dot calls `(+).(x, (*).(3, (^).(x, 2)))`.
"""

# ╔═╡ 03cb1e50-9e19-11eb-3908-d189c2911842
md"""
Furthermore, "dotted" updating operators like `a .+= b` (or `@. a += b`) are parsed as `a .= a .+ b`, where `.=` is a fused *in-place* assignment operation (see the [dot syntax documentation](@ref man-vectorized)).
"""

# ╔═╡ 03cb1e70-9e19-11eb-12e5-c95381972049
md"""
Note the dot syntax is also applicable to user-defined operators. For example, if you define `⊗(A,B) = kron(A,B)` to give a convenient infix syntax `A ⊗ B` for Kronecker products ([`kron`](@ref)), then `[A,B] .⊗ [C,D]` will compute `[A⊗C, B⊗D]` with no additional coding.
"""

# ╔═╡ 03cb1e8c-9e19-11eb-064e-93d9ec3272d7
md"""
Combining dot operators with numeric literals can be ambiguous. For example, it is not clear whether `1.+x` means `1. + x` or `1 .+ x`. Therefore this syntax is disallowed, and spaces must be used around the operator in such cases.
"""

# ╔═╡ 03cb1e96-9e19-11eb-34e5-cb76bd5f9936
md"""
## Numeric Comparisons
"""

# ╔═╡ 03cb1eaa-9e19-11eb-30da-6d7136cf442b
md"""
Standard comparison operations are defined for all the primitive numeric types:
"""

# ╔═╡ 03cb1f86-9e19-11eb-3d01-69d892d522fb
md"""
| Operator                     | Name                     |
|:---------------------------- |:------------------------ |
| [`==`](@ref)                 | equality                 |
| [`!=`](@ref), [`≠`](@ref !=) | inequality               |
| [`<`](@ref)                  | less than                |
| [`<=`](@ref), [`≤`](@ref <=) | less than or equal to    |
| [`>`](@ref)                  | greater than             |
| [`>=`](@ref), [`≥`](@ref >=) | greater than or equal to |
"""

# ╔═╡ 03cb1f9a-9e19-11eb-061b-b1fa47fd011c
md"""
Here are some simple examples:
"""

# ╔═╡ 03cb2a10-9e19-11eb-17eb-c71ff2961c31
1 == 1

# ╔═╡ 03cb2a10-9e19-11eb-1f6d-3b323d518377
1 == 2

# ╔═╡ 03cb2a1c-9e19-11eb-0a77-9136ad8b4033
1 != 2

# ╔═╡ 03cb2a26-9e19-11eb-3920-a52e85dfb0af
1 == 1.0

# ╔═╡ 03cb2a26-9e19-11eb-36c3-65fd79ef0aae
1 < 2

# ╔═╡ 03cb2a30-9e19-11eb-3e41-8d591cb7e5e6
1.0 > 3

# ╔═╡ 03cb2a30-9e19-11eb-0f3c-9f017cdae550
1 >= 1.0

# ╔═╡ 03cb2a30-9e19-11eb-0775-c714beb2d2f2
-1 <= 1

# ╔═╡ 03cb2a3a-9e19-11eb-0ee9-d7072653124d
-1 <= -1

# ╔═╡ 03cb2a3a-9e19-11eb-0b2d-a5d1d1916b49
-1 <= -2

# ╔═╡ 03cb2a42-9e19-11eb-2ae7-0d0468a74694
3 < -0.5

# ╔═╡ 03cb2a62-9e19-11eb-06c1-17de75aca710
md"""
Integers are compared in the standard manner – by comparison of bits. Floating-point numbers are compared according to the [IEEE 754 standard](https://en.wikipedia.org/wiki/IEEE_754-2008):
"""

# ╔═╡ 03cb2b3e-9e19-11eb-3b6b-ab6808e1181e
md"""
  * Finite numbers are ordered in the usual manner.
  * Positive zero is equal but not greater than negative zero.
  * `Inf` is equal to itself and greater than everything else except `NaN`.
  * `-Inf` is equal to itself and less than everything else except `NaN`.
  * `NaN` is not equal to, not less than, and not greater than anything, including itself.
"""

# ╔═╡ 03cb2b46-9e19-11eb-2aa6-4d9402b72ff8
md"""
The last point is potentially surprising and thus worth noting:
"""

# ╔═╡ 03cb2e22-9e19-11eb-31db-83d4f33b3b0e
NaN == NaN

# ╔═╡ 03cb2e2c-9e19-11eb-2068-431059c85e0c
NaN != NaN

# ╔═╡ 03cb2e36-9e19-11eb-3e1a-f91f70d0d7ff
NaN < NaN

# ╔═╡ 03cb2e36-9e19-11eb-27f5-3f8df0fd9d00
NaN > NaN

# ╔═╡ 03cb2e54-9e19-11eb-2a6d-8fc3ca1c80e8
md"""
and can cause headaches when working with [arrays](@ref man-multi-dim-arrays):
"""

# ╔═╡ 03cb308e-9e19-11eb-3299-3b3d2444e08c
[1 NaN] == [1 NaN]

# ╔═╡ 03cb30a2-9e19-11eb-2743-c9acdd998239
md"""
Julia provides additional functions to test numbers for special values, which can be useful in situations like hash key comparisons:
"""

# ╔═╡ 03cb314c-9e19-11eb-1798-f725c727f0b9
md"""
| Function                | Tests if                  |
|:----------------------- |:------------------------- |
| [`isequal(x, y)`](@ref) | `x` and `y` are identical |
| [`isfinite(x)`](@ref)   | `x` is a finite number    |
| [`isinf(x)`](@ref)      | `x` is infinite           |
| [`isnan(x)`](@ref)      | `x` is not a number       |
"""

# ╔═╡ 03cb316a-9e19-11eb-2e8d-6b5617bad825
md"""
[`isequal`](@ref) considers `NaN`s equal to each other:
"""

# ╔═╡ 03cb362e-9e19-11eb-1f7c-ad55ebf01b60
isequal(NaN, NaN)

# ╔═╡ 03cb3638-9e19-11eb-33db-2597b808ea62
isequal([1 NaN], [1 NaN])

# ╔═╡ 03cb3638-9e19-11eb-2523-03436261c9c2
isequal(NaN, NaN32)

# ╔═╡ 03cb3654-9e19-11eb-2908-93591f277ffc
md"""
`isequal` can also be used to distinguish signed zeros:
"""

# ╔═╡ 03cb38ea-9e19-11eb-3571-552e09bf062d
-0.0 == 0.0

# ╔═╡ 03cb38ea-9e19-11eb-1f44-c35c59b5fe79
isequal(-0.0, 0.0)

# ╔═╡ 03cb38fe-9e19-11eb-26ed-094e0ffb1dfe
md"""
Mixed-type comparisons between signed integers, unsigned integers, and floats can be tricky. A great deal of care has been taken to ensure that Julia does them correctly.
"""

# ╔═╡ 03cb3930-9e19-11eb-27c1-b7881fb4881c
md"""
For other types, `isequal` defaults to calling [`==`](@ref), so if you want to define equality for your own types then you only need to add a [`==`](@ref) method.  If you define your own equality function, you should probably define a corresponding [`hash`](@ref) method to ensure that `isequal(x,y)` implies `hash(x) == hash(y)`.
"""

# ╔═╡ 03cb3962-9e19-11eb-18c5-630f7ab3f37f
md"""
### Chaining comparisons
"""

# ╔═╡ 03cb3976-9e19-11eb-1916-83c537ca0ca3
md"""
Unlike most languages, with the [notable exception of Python](https://en.wikipedia.org/wiki/Python_syntax_and_semantics#Comparison_operators), comparisons can be arbitrarily chained:
"""

# ╔═╡ 03cb3d5c-9e19-11eb-22c0-cb68e9549d88
1 < 2 <= 2 < 3 == 3 > 2 >= 1 == 1 < 3 != 5

# ╔═╡ 03cb3d7c-9e19-11eb-1892-239bfa98b092
md"""
Chaining comparisons is often quite convenient in numerical code. Chained comparisons use the `&&` operator for scalar comparisons, and the [`&`](@ref) operator for elementwise comparisons, which allows them to work on arrays. For example, `0 .< A .< 1` gives a boolean array whose entries are true where the corresponding elements of `A` are between 0 and 1.
"""

# ╔═╡ 03cb3d90-9e19-11eb-3421-a14d89aa5015
md"""
Note the evaluation behavior of chained comparisons:
"""

# ╔═╡ 03cb43a0-9e19-11eb-2bc0-6de282349763
v(x) = (println(x); x)

# ╔═╡ 03cb43a0-9e19-11eb-0843-4715d8c175d5
v(1) < v(2) <= v(3)

# ╔═╡ 03cb43a8-9e19-11eb-315d-4ff2ef492561
v(1) > v(2) <= v(3)

# ╔═╡ 03cb43d2-9e19-11eb-3d33-6d5b029d6a7b
md"""
The middle expression is only evaluated once, rather than twice as it would be if the expression were written as `v(1) < v(2) && v(2) <= v(3)`. However, the order of evaluations in a chained comparison is undefined. It is strongly recommended not to use expressions with side effects (such as printing) in chained comparisons. If side effects are required, the short-circuit `&&` operator should be used explicitly (see [Short-Circuit Evaluation](@ref)).
"""

# ╔═╡ 03cb43da-9e19-11eb-33f5-95adf3077eb8
md"""
### Elementary Functions
"""

# ╔═╡ 03cb43ee-9e19-11eb-3f24-9d91110f5968
md"""
Julia provides a comprehensive collection of mathematical functions and operators. These mathematical operations are defined over as broad a class of numerical values as permit sensible definitions, including integers, floating-point numbers, rationals, and complex numbers, wherever such definitions make sense.
"""

# ╔═╡ 03cb440c-9e19-11eb-12a3-159a0f433524
md"""
Moreover, these functions (like any Julia function) can be applied in "vectorized" fashion to arrays and other collections with the [dot syntax](@ref man-vectorized) `f.(A)`, e.g. `sin.(A)` will compute the sine of each element of an array `A`.
"""

# ╔═╡ 03cb4420-9e19-11eb-3198-c71cbf0afea2
md"""
## Operator Precedence and Associativity
"""

# ╔═╡ 03cb442a-9e19-11eb-2c10-1525a873d264
md"""
Julia applies the following order and associativity of operations, from highest precedence to lowest:
"""

# ╔═╡ 03cb45e2-9e19-11eb-33df-c749dc82b062
md"""
| Category       | Operators                                              | Associativity   |
|:-------------- |:------------------------------------------------------ |:--------------- |
| Syntax         | `.` followed by `::`                                   | Left            |
| Exponentiation | `^`                                                    | Right           |
| Unary          | `+ - √`                                                | Right[^1]       |
| Bitshifts      | `<< >> >>>`                                            | Left            |
| Fractions      | `//`                                                   | Left            |
| Multiplication | `* / % & \ ÷`                                          | Left[^2]        |
| Addition       | `+ - \| ⊻`                                             | Left[^2]        |
| Syntax         | `: ..`                                                 | Left            |
| Syntax         | `\|>`                                                  | Left            |
| Syntax         | `<\|`                                                  | Right           |
| Comparisons    | `> < >= <= == === != !== <:`                           | Non-associative |
| Control flow   | `&&` followed by `\|\|` followed by `?`                | Right           |
| Pair           | `=>`                                                   | Right           |
| Assignments    | `= += -= *= /= //= \= ^= ÷= %= \|= &= ⊻= <<= >>= >>>=` | Right           |
"""

# ╔═╡ 03cb4678-9e19-11eb-2a5b-8dd90b827692
md"""
[^1]: The unary operators `+` and `-` require explicit parentheses around their argument to disambiguate them from the operator `++`, etc. Other compositions of unary operators are parsed with right-associativity, e. g., `√√-a` as `√(√(-a))`.
"""

# ╔═╡ 03cb46c8-9e19-11eb-16bb-adf210e2395b
md"""
[^2]: The operators `+`, `++` and `*` are non-associative. `a + b + c` is parsed as `+(a, b, c)` not `+(+(a, b), c)`. However, the fallback methods for `+(a, b, c, d...)` and `*(a, b, c, d...)` both default to left-associative evaluation.
"""

# ╔═╡ 03cb46f0-9e19-11eb-3585-bf699e9c814c
md"""
For a complete list of *every* Julia operator's precedence, see the top of this file: [`src/julia-parser.scm`](https://github.com/JuliaLang/julia/blob/master/src/julia-parser.scm). Note that some of the operators there are not defined in the `Base` module but may be given definitions by standard libraries, packages or user code.
"""

# ╔═╡ 03cb4702-9e19-11eb-2709-43a6d816cef7
md"""
You can also find the numerical precedence for any given operator via the built-in function `Base.operator_precedence`, where higher numbers take precedence:
"""

# ╔═╡ 03cb4d6c-9e19-11eb-1cb3-27a6a55f130f
Base.operator_precedence(:+), Base.operator_precedence(:*), Base.operator_precedence(:.)

# ╔═╡ 03cb4d78-9e19-11eb-105f-eb74897b4981
Base.operator_precedence(:sin), Base.operator_precedence(:+=), Base.operator_precedence(:(=))  # (Note the necessary parens on `:(=)`)

# ╔═╡ 03cb4d8a-9e19-11eb-38a7-9d7ad0d637a6
md"""
A symbol representing the operator associativity can also be found by calling the built-in function `Base.operator_associativity`:
"""

# ╔═╡ 03cb5352-9e19-11eb-1971-1920394f76c7
Base.operator_associativity(:-), Base.operator_associativity(:+), Base.operator_associativity(:^)

# ╔═╡ 03cb5352-9e19-11eb-31d3-bff591000518
Base.operator_associativity(:⊗), Base.operator_associativity(:sin), Base.operator_associativity(:→)

# ╔═╡ 03cb5370-9e19-11eb-3938-3f82d9c362ef
md"""
Note that symbols such as `:sin` return precedence `0`. This value represents invalid operators and not operators of lowest precedence. Similarly, such operators are assigned associativity `:none`.
"""

# ╔═╡ 03cb5398-9e19-11eb-32c0-6db731d99f51
md"""
[Numeric literal coefficients](@ref man-numeric-literal-coefficients), e.g. `2x`, are treated as multiplications with higher precedence than any other binary operation, with the exception of `^` where they have higher precedence only as the exponent.
"""

# ╔═╡ 03cb576c-9e19-11eb-3b55-b1e5b897812b
x = 3; 2x^2

# ╔═╡ 03cb576c-9e19-11eb-1e79-311810496f73
x = 3; 2^2x

# ╔═╡ 03cb5794-9e19-11eb-1973-07c7d9734daf
md"""
Juxtaposition parses like a unary operator, which has the same natural asymmetry around exponents: `-x^y` and `2x^y` parse as `-(x^y)` and `2(x^y)` whereas `x^-y` and `x^2y` parse as `x^(-y)` and `x^(2y)`.
"""

# ╔═╡ 03cb57a8-9e19-11eb-0900-b552df6e4f92
md"""
## Numerical Conversions
"""

# ╔═╡ 03cb57b2-9e19-11eb-2522-2d0bde7cfeda
md"""
Julia supports three forms of numerical conversion, which differ in their handling of inexact conversions.
"""

# ╔═╡ 03cb58d4-9e19-11eb-01ff-8194dae4d79f
md"""
  * The notation `T(x)` or `convert(T,x)` converts `x` to a value of type `T`.

      * If `T` is a floating-point type, the result is the nearest representable value, which could be positive or negative infinity.
      * If `T` is an integer type, an `InexactError` is raised if `x` is not representable by `T`.
  * `x % T` converts an integer `x` to a value of integer type `T` congruent to `x` modulo `2^n`, where `n` is the number of bits in `T`. In other words, the binary representation is truncated to fit.
  * The [Rounding functions](@ref) take a type `T` as an optional argument. For example, `round(Int,x)` is a shorthand for `Int(round(x))`.
"""

# ╔═╡ 03cb58e6-9e19-11eb-0037-8138bf5ae0a8
md"""
The following examples show the different forms.
"""

# ╔═╡ 03cb6072-9e19-11eb-37b0-a1cc714a99a4
Int8(127)

# ╔═╡ 03cb607c-9e19-11eb-136a-d3dcaf55d03e
Int8(128)

# ╔═╡ 03cb60b8-9e19-11eb-2809-a39ee71d50bf
Int8(127.0)

# ╔═╡ 03cb60b8-9e19-11eb-3f4b-9da20d42c04e
Int8(3.14)

# ╔═╡ 03cb60c0-9e19-11eb-11df-ef0db1a6c91d
Int8(128.0)

# ╔═╡ 03cb60c0-9e19-11eb-1997-57cf2205bf62
127 % Int8

# ╔═╡ 03cb60cc-9e19-11eb-13a2-131263a1704f
128 % Int8

# ╔═╡ 03cb60cc-9e19-11eb-10e0-d1baf6946481
round(Int8,127.4)

# ╔═╡ 03cb60d6-9e19-11eb-2f6c-b35367fe38c9
round(Int8,127.6)

# ╔═╡ 03cb60f2-9e19-11eb-3d90-21fde5bb849b
md"""
See [Conversion and Promotion](@ref conversion-and-promotion) for how to define your own conversions and promotions.
"""

# ╔═╡ 03cb6108-9e19-11eb-0622-31db48359c44
md"""
### Rounding functions
"""

# ╔═╡ 03cb6266-9e19-11eb-02e9-47403308855c
md"""
| Function              | Description                      | Return type |
|:--------------------- |:-------------------------------- |:----------- |
| [`round(x)`](@ref)    | round `x` to the nearest integer | `typeof(x)` |
| [`round(T, x)`](@ref) | round `x` to the nearest integer | `T`         |
| [`floor(x)`](@ref)    | round `x` towards `-Inf`         | `typeof(x)` |
| [`floor(T, x)`](@ref) | round `x` towards `-Inf`         | `T`         |
| [`ceil(x)`](@ref)     | round `x` towards `+Inf`         | `typeof(x)` |
| [`ceil(T, x)`](@ref)  | round `x` towards `+Inf`         | `T`         |
| [`trunc(x)`](@ref)    | round `x` towards zero           | `typeof(x)` |
| [`trunc(T, x)`](@ref) | round `x` towards zero           | `T`         |
"""

# ╔═╡ 03cb627a-9e19-11eb-3000-eb8394a0c85d
md"""
### Division functions
"""

# ╔═╡ 03cb63ec-9e19-11eb-243c-43bbf316e537
md"""
| Function                  | Description                                                                                             |
|:------------------------- |:------------------------------------------------------------------------------------------------------- |
| [`div(x,y)`](@ref), `x÷y` | truncated division; quotient rounded towards zero                                                       |
| [`fld(x,y)`](@ref)        | floored division; quotient rounded towards `-Inf`                                                       |
| [`cld(x,y)`](@ref)        | ceiling division; quotient rounded towards `+Inf`                                                       |
| [`rem(x,y)`](@ref)        | remainder; satisfies `x == div(x,y)*y + rem(x,y)`; sign matches `x`                                     |
| [`mod(x,y)`](@ref)        | modulus; satisfies `x == fld(x,y)*y + mod(x,y)`; sign matches `y`                                       |
| [`mod1(x,y)`](@ref)       | `mod` with offset 1; returns `r∈(0,y]` for `y>0` or `r∈[y,0)` for `y<0`, where `mod(r, y) == mod(x, y)` |
| [`mod2pi(x)`](@ref)       | modulus with respect to 2pi;  `0 <= mod2pi(x) < 2pi`                                                    |
| [`divrem(x,y)`](@ref)     | returns `(div(x,y),rem(x,y))`                                                                           |
| [`fldmod(x,y)`](@ref)     | returns `(fld(x,y),mod(x,y))`                                                                           |
| [`gcd(x,y...)`](@ref)     | greatest positive common divisor of `x`, `y`,...                                                        |
| [`lcm(x,y...)`](@ref)     | least positive common multiple of `x`, `y`,...                                                          |
"""

# ╔═╡ 03cb6400-9e19-11eb-251b-d12e77fedc72
md"""
### Sign and absolute value functions
"""

# ╔═╡ 03cb64ca-9e19-11eb-3578-fb0910aeeff6
md"""
| Function                | Description                                                |
|:----------------------- |:---------------------------------------------------------- |
| [`abs(x)`](@ref)        | a positive value with the magnitude of `x`                 |
| [`abs2(x)`](@ref)       | the squared magnitude of `x`                               |
| [`sign(x)`](@ref)       | indicates the sign of `x`, returning -1, 0, or +1          |
| [`signbit(x)`](@ref)    | indicates whether the sign bit is on (true) or off (false) |
| [`copysign(x,y)`](@ref) | a value with the magnitude of `x` and the sign of `y`      |
| [`flipsign(x,y)`](@ref) | a value with the magnitude of `x` and the sign of `x*y`    |
"""

# ╔═╡ 03cb64dc-9e19-11eb-2312-4d573c19c8b7
md"""
### Powers, logs and roots
"""

# ╔═╡ 03cb6660-9e19-11eb-09bc-ab05852376e8
md"""
| Function                 | Description                                                                |
|:------------------------ |:-------------------------------------------------------------------------- |
| [`sqrt(x)`](@ref), `√x`  | square root of `x`                                                         |
| [`cbrt(x)`](@ref), `∛x`  | cube root of `x`                                                           |
| [`hypot(x,y)`](@ref)     | hypotenuse of right-angled triangle with other sides of length `x` and `y` |
| [`exp(x)`](@ref)         | natural exponential function at `x`                                        |
| [`expm1(x)`](@ref)       | accurate `exp(x)-1` for `x` near zero                                      |
| [`ldexp(x,n)`](@ref)     | `x*2^n` computed efficiently for integer values of `n`                     |
| [`log(x)`](@ref)         | natural logarithm of `x`                                                   |
| [`log(b,x)`](@ref)       | base `b` logarithm of `x`                                                  |
| [`log2(x)`](@ref)        | base 2 logarithm of `x`                                                    |
| [`log10(x)`](@ref)       | base 10 logarithm of `x`                                                   |
| [`log1p(x)`](@ref)       | accurate `log(1+x)` for `x` near zero                                      |
| [`exponent(x)`](@ref)    | binary exponent of `x`                                                     |
| [`significand(x)`](@ref) | binary significand (a.k.a. mantissa) of a floating-point number `x`        |
"""

# ╔═╡ 03cb6692-9e19-11eb-2fa5-374aa7a384b6
md"""
For an overview of why functions like [`hypot`](@ref), [`expm1`](@ref), and [`log1p`](@ref) are necessary and useful, see John D. Cook's excellent pair of blog posts on the subject: [expm1, log1p, erfc](https://www.johndcook.com/blog/2010/06/07/math-library-functions-that-seem-unnecessary/), and [hypot](https://www.johndcook.com/blog/2010/06/02/whats-so-hard-about-finding-a-hypotenuse/).
"""

# ╔═╡ 03cb66a8-9e19-11eb-09e1-c3998079396e
md"""
### Trigonometric and hyperbolic functions
"""

# ╔═╡ 03cb66bc-9e19-11eb-3265-e1138c81f39c
md"""
All the standard trigonometric and hyperbolic functions are also defined:
"""

# ╔═╡ 03cb678e-9e19-11eb-3083-a7bbe21db241
sin    cos

# ╔═╡ 03cb67b6-9e19-11eb-0c52-59d193ac3477
md"""
These are all single-argument functions, with [`atan`](@ref) also accepting two arguments corresponding to a traditional [`atan2`](https://en.wikipedia.org/wiki/Atan2) function.
"""

# ╔═╡ 03cb67de-9e19-11eb-1d6a-a3190b168a56
md"""
Additionally, [`sinpi(x)`](@ref) and [`cospi(x)`](@ref) are provided for more accurate computations of [`sin(pi*x)`](@ref) and [`cos(pi*x)`](@ref) respectively.
"""

# ╔═╡ 03cb67fa-9e19-11eb-2114-a3e5f154dfb3
md"""
In order to compute trigonometric functions with degrees instead of radians, suffix the function with `d`. For example, [`sind(x)`](@ref) computes the sine of `x` where `x` is specified in degrees. The complete list of trigonometric functions with degree variants is:
"""

# ╔═╡ 03cb6892-9e19-11eb-19f6-4d3518734942
sind   cosd

# ╔═╡ 03cb68a6-9e19-11eb-0595-43e77c37bee9
md"""
### Special functions
"""

# ╔═╡ 03cb68ba-9e19-11eb-07cc-99a0555d8c98
md"""
Many other special mathematical functions are provided by the package [SpecialFunctions.jl](https://github.com/JuliaMath/SpecialFunctions.jl).
"""

# ╔═╡ Cell order:
# ╟─03cb0226-9e19-11eb-0c66-1fb779369ec4
# ╟─03cb0242-9e19-11eb-3170-b5ebfb1875b8
# ╟─03cb0274-9e19-11eb-336f-a384f87e5754
# ╟─03cb02ee-9e19-11eb-3ce5-7955bd7c803c
# ╟─03cb0582-9e19-11eb-2956-b72b602d93d3
# ╟─03cb05a0-9e19-11eb-02bf-150c552f7ba2
# ╟─03cb05be-9e19-11eb-3bc9-81b74a35a94e
# ╟─03cb05c8-9e19-11eb-1461-a569863b2df8
# ╠═03cb0c58-9e19-11eb-26c9-151178ccabc9
# ╠═03cb0c58-9e19-11eb-0b90-31721c7b0694
# ╠═03cb0c62-9e19-11eb-23df-1dcb95231b47
# ╟─03cb0c80-9e19-11eb-2d94-1b6931ab68d9
# ╟─03cb0ca8-9e19-11eb-3ddd-a513148bbc6d
# ╠═03cb0e58-9e19-11eb-1d3b-0b9408ffdd53
# ╠═03cb0e58-9e19-11eb-0b4a-679e5f34725f
# ╟─03cb0e7e-9e19-11eb-2ba0-f515768a0811
# ╟─03cb0e92-9e19-11eb-23fb-17fe3b6ef0a7
# ╟─03cb0eb0-9e19-11eb-10a4-358084651633
# ╟─03cb0f3c-9e19-11eb-3959-7d184d31853e
# ╟─03cb0f5c-9e19-11eb-2cc8-ad3e513c3111
# ╟─03cb0f64-9e19-11eb-0367-9daf5321eb08
# ╟─03cb0f78-9e19-11eb-351b-8b112ebbaac1
# ╟─03cb0f96-9e19-11eb-1597-c30dda38bd4f
# ╟─03cb1054-9e19-11eb-01ec-ddd8f533b2b4
# ╟─03cb1068-9e19-11eb-04cc-1b1d6faba1a7
# ╠═03cb172a-9e19-11eb-3a7a-4fc72bff1014
# ╠═03cb1734-9e19-11eb-0e25-33ae9d4185c2
# ╠═03cb1734-9e19-11eb-35ad-6bdd98116e10
# ╠═03cb173e-9e19-11eb-1131-cbe40545510f
# ╠═03cb1748-9e19-11eb-0070-67c705a7a9a4
# ╠═03cb1748-9e19-11eb-3a93-63f1c8b2ab22
# ╠═03cb1748-9e19-11eb-232c-4d007326d2a4
# ╟─03cb175c-9e19-11eb-23b1-473e7adf265a
# ╟─03cb1784-9e19-11eb-1aaa-279484641f14
# ╠═03cb1a04-9e19-11eb-24bd-cdfe4ab97967
# ╠═03cb1a0e-9e19-11eb-2464-99cedeeba8e4
# ╠═03cb1a18-9e19-11eb-39f1-09112a177428
# ╟─03cb1a22-9e19-11eb-19f4-2d880d3831f8
# ╠═03cb1ab8-9e19-11eb-2dff-f34f269994e3
# ╟─03cb1bd2-9e19-11eb-334d-51bcca51080c
# ╟─03cb1be4-9e19-11eb-3bb8-238c1b8d1f58
# ╟─03cb1c2a-9e19-11eb-01e4-055a61aeacb8
# ╠═03cb1dd8-9e19-11eb-1938-879a25ca0535
# ╟─03cb1e28-9e19-11eb-16c0-39bec19be201
# ╟─03cb1e50-9e19-11eb-3908-d189c2911842
# ╟─03cb1e70-9e19-11eb-12e5-c95381972049
# ╟─03cb1e8c-9e19-11eb-064e-93d9ec3272d7
# ╟─03cb1e96-9e19-11eb-34e5-cb76bd5f9936
# ╟─03cb1eaa-9e19-11eb-30da-6d7136cf442b
# ╟─03cb1f86-9e19-11eb-3d01-69d892d522fb
# ╟─03cb1f9a-9e19-11eb-061b-b1fa47fd011c
# ╠═03cb2a10-9e19-11eb-17eb-c71ff2961c31
# ╠═03cb2a10-9e19-11eb-1f6d-3b323d518377
# ╠═03cb2a1c-9e19-11eb-0a77-9136ad8b4033
# ╠═03cb2a26-9e19-11eb-3920-a52e85dfb0af
# ╠═03cb2a26-9e19-11eb-36c3-65fd79ef0aae
# ╠═03cb2a30-9e19-11eb-3e41-8d591cb7e5e6
# ╠═03cb2a30-9e19-11eb-0f3c-9f017cdae550
# ╠═03cb2a30-9e19-11eb-0775-c714beb2d2f2
# ╠═03cb2a3a-9e19-11eb-0ee9-d7072653124d
# ╠═03cb2a3a-9e19-11eb-0b2d-a5d1d1916b49
# ╠═03cb2a42-9e19-11eb-2ae7-0d0468a74694
# ╟─03cb2a62-9e19-11eb-06c1-17de75aca710
# ╟─03cb2b3e-9e19-11eb-3b6b-ab6808e1181e
# ╟─03cb2b46-9e19-11eb-2aa6-4d9402b72ff8
# ╠═03cb2e22-9e19-11eb-31db-83d4f33b3b0e
# ╠═03cb2e2c-9e19-11eb-2068-431059c85e0c
# ╠═03cb2e36-9e19-11eb-3e1a-f91f70d0d7ff
# ╠═03cb2e36-9e19-11eb-27f5-3f8df0fd9d00
# ╟─03cb2e54-9e19-11eb-2a6d-8fc3ca1c80e8
# ╠═03cb308e-9e19-11eb-3299-3b3d2444e08c
# ╟─03cb30a2-9e19-11eb-2743-c9acdd998239
# ╟─03cb314c-9e19-11eb-1798-f725c727f0b9
# ╟─03cb316a-9e19-11eb-2e8d-6b5617bad825
# ╠═03cb362e-9e19-11eb-1f7c-ad55ebf01b60
# ╠═03cb3638-9e19-11eb-33db-2597b808ea62
# ╠═03cb3638-9e19-11eb-2523-03436261c9c2
# ╟─03cb3654-9e19-11eb-2908-93591f277ffc
# ╠═03cb38ea-9e19-11eb-3571-552e09bf062d
# ╠═03cb38ea-9e19-11eb-1f44-c35c59b5fe79
# ╟─03cb38fe-9e19-11eb-26ed-094e0ffb1dfe
# ╟─03cb3930-9e19-11eb-27c1-b7881fb4881c
# ╟─03cb3962-9e19-11eb-18c5-630f7ab3f37f
# ╟─03cb3976-9e19-11eb-1916-83c537ca0ca3
# ╠═03cb3d5c-9e19-11eb-22c0-cb68e9549d88
# ╟─03cb3d7c-9e19-11eb-1892-239bfa98b092
# ╟─03cb3d90-9e19-11eb-3421-a14d89aa5015
# ╠═03cb43a0-9e19-11eb-2bc0-6de282349763
# ╠═03cb43a0-9e19-11eb-0843-4715d8c175d5
# ╠═03cb43a8-9e19-11eb-315d-4ff2ef492561
# ╟─03cb43d2-9e19-11eb-3d33-6d5b029d6a7b
# ╟─03cb43da-9e19-11eb-33f5-95adf3077eb8
# ╟─03cb43ee-9e19-11eb-3f24-9d91110f5968
# ╟─03cb440c-9e19-11eb-12a3-159a0f433524
# ╟─03cb4420-9e19-11eb-3198-c71cbf0afea2
# ╟─03cb442a-9e19-11eb-2c10-1525a873d264
# ╟─03cb45e2-9e19-11eb-33df-c749dc82b062
# ╟─03cb4678-9e19-11eb-2a5b-8dd90b827692
# ╟─03cb46c8-9e19-11eb-16bb-adf210e2395b
# ╟─03cb46f0-9e19-11eb-3585-bf699e9c814c
# ╟─03cb4702-9e19-11eb-2709-43a6d816cef7
# ╠═03cb4d6c-9e19-11eb-1cb3-27a6a55f130f
# ╠═03cb4d78-9e19-11eb-105f-eb74897b4981
# ╟─03cb4d8a-9e19-11eb-38a7-9d7ad0d637a6
# ╠═03cb5352-9e19-11eb-1971-1920394f76c7
# ╠═03cb5352-9e19-11eb-31d3-bff591000518
# ╟─03cb5370-9e19-11eb-3938-3f82d9c362ef
# ╟─03cb5398-9e19-11eb-32c0-6db731d99f51
# ╠═03cb576c-9e19-11eb-3b55-b1e5b897812b
# ╠═03cb576c-9e19-11eb-1e79-311810496f73
# ╟─03cb5794-9e19-11eb-1973-07c7d9734daf
# ╟─03cb57a8-9e19-11eb-0900-b552df6e4f92
# ╟─03cb57b2-9e19-11eb-2522-2d0bde7cfeda
# ╟─03cb58d4-9e19-11eb-01ff-8194dae4d79f
# ╟─03cb58e6-9e19-11eb-0037-8138bf5ae0a8
# ╠═03cb6072-9e19-11eb-37b0-a1cc714a99a4
# ╠═03cb607c-9e19-11eb-136a-d3dcaf55d03e
# ╠═03cb60b8-9e19-11eb-2809-a39ee71d50bf
# ╠═03cb60b8-9e19-11eb-3f4b-9da20d42c04e
# ╠═03cb60c0-9e19-11eb-11df-ef0db1a6c91d
# ╠═03cb60c0-9e19-11eb-1997-57cf2205bf62
# ╠═03cb60cc-9e19-11eb-13a2-131263a1704f
# ╠═03cb60cc-9e19-11eb-10e0-d1baf6946481
# ╠═03cb60d6-9e19-11eb-2f6c-b35367fe38c9
# ╟─03cb60f2-9e19-11eb-3d90-21fde5bb849b
# ╟─03cb6108-9e19-11eb-0622-31db48359c44
# ╟─03cb6266-9e19-11eb-02e9-47403308855c
# ╟─03cb627a-9e19-11eb-3000-eb8394a0c85d
# ╟─03cb63ec-9e19-11eb-243c-43bbf316e537
# ╟─03cb6400-9e19-11eb-251b-d12e77fedc72
# ╟─03cb64ca-9e19-11eb-3578-fb0910aeeff6
# ╟─03cb64dc-9e19-11eb-2312-4d573c19c8b7
# ╟─03cb6660-9e19-11eb-09bc-ab05852376e8
# ╟─03cb6692-9e19-11eb-2fa5-374aa7a384b6
# ╟─03cb66a8-9e19-11eb-09e1-c3998079396e
# ╟─03cb66bc-9e19-11eb-3265-e1138c81f39c
# ╠═03cb678e-9e19-11eb-3083-a7bbe21db241
# ╟─03cb67b6-9e19-11eb-0c52-59d193ac3477
# ╟─03cb67de-9e19-11eb-1d6a-a3190b168a56
# ╟─03cb67fa-9e19-11eb-2114-a3e5f154dfb3
# ╠═03cb6892-9e19-11eb-19f6-4d3518734942
# ╟─03cb68a6-9e19-11eb-0595-43e77c37bee9
# ╟─03cb68ba-9e19-11eb-07cc-99a0555d8c98
