### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ fd25058d-d37b-4013-b21e-4950b879de03
md"""
# Mathematical Operations and Elementary Functions
"""

# ╔═╡ ab66b973-7a3b-4ea3-a335-41155dc9ca1a
md"""
Julia provides a complete collection of basic arithmetic and bitwise operators across all of its numeric primitive types, as well as providing portable, efficient implementations of a comprehensive collection of standard mathematical functions.
"""

# ╔═╡ dac8b889-14fa-422d-a616-2321f8d032c0
md"""
## Arithmetic Operators
"""

# ╔═╡ 5a10b091-f2c3-449e-a155-1bca35f861c0
md"""
The following [arithmetic operators](https://en.wikipedia.org/wiki/Arithmetic#Arithmetic_operations) are supported on all primitive numeric types:
"""

# ╔═╡ ff47c163-94a1-4150-93e8-a0f2d4ad450b
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

# ╔═╡ f1ea4ca7-2543-46a8-9b5d-84493af941f1
md"""
A numeric literal placed directly before an identifier or parentheses, e.g. `2x` or `2(x+y)`, is treated as a multiplication, except with higher precedence than other binary operations.  See [Numeric Literal Coefficients](@ref man-numeric-literal-coefficients) for details.
"""

# ╔═╡ 554c9105-3256-4efd-bea2-e3dd1af54b89
md"""
Julia's promotion system makes arithmetic operations on mixtures of argument types \"just work\" naturally and automatically. See [Conversion and Promotion](@ref conversion-and-promotion) for details of the promotion system.
"""

# ╔═╡ 46e65749-8c2c-40ab-9d13-055467927fab
md"""
Here are some simple examples using arithmetic operators:
"""

# ╔═╡ 072707e3-9522-4fb7-96df-a0ac3771068c
1 + 2 + 3

# ╔═╡ bdb923f6-1947-4e90-b846-6ef117222978
1 - 2

# ╔═╡ 048760a4-c778-4417-910e-1f063d653197
3*2/12

# ╔═╡ 8f19fef0-ef4a-4ec7-aed4-e33392246974
md"""
(By convention, we tend to space operators more tightly if they get applied before other nearby operators. For instance, we would generally write `-x + 2` to reflect that first `x` gets negated, and then `2` is added to that result.)
"""

# ╔═╡ 015bd278-690f-4c58-94e9-a83a2931f06c
md"""
When used in multiplication, `false` acts as a *strong zero*:
"""

# ╔═╡ 5555fb86-37ec-47da-b23b-9ca6f823a131
NaN * false

# ╔═╡ be4bdb1d-30a5-4db5-88a8-7736e5959ee7
false * Inf

# ╔═╡ 7ff74f8d-9b00-495e-b18f-62b4be88cdd1
md"""
This is useful for preventing the propagation of `NaN` values in quantities that are known to be zero. See [Knuth (1992)](https://arxiv.org/abs/math/9205211) for motivation.
"""

# ╔═╡ b6c5d1ed-fc74-4c84-818b-6050e56f4977
md"""
## Boolean Operators
"""

# ╔═╡ 6fbbccaf-ef96-4dda-97b5-b879ad33a173
md"""
The following [Boolean operators](https://en.wikipedia.org/wiki/Boolean_algebra#Operations) are supported on [`Bool`](@ref) types:
"""

# ╔═╡ ebd4a088-cbc3-4bfe-bb30-1bc4beb89a18
md"""
| Expression | Name                                                    |
|:---------- |:------------------------------------------------------- |
| `!x`       | negation                                                |
| `x && y`   | [short-circuiting and](@ref man-conditional-evaluation) |
| `x \|\| y` | [short-circuiting or](@ref man-conditional-evaluation)  |
"""

# ╔═╡ 4a89b4ff-6aff-497f-9cc4-a004cb104956
md"""
Negation changes `true` to `false` and vice versa. The short-circuiting opeations are explained on the linked page.
"""

# ╔═╡ 861a2af9-5095-47f0-938f-246d3dfbf244
md"""
Note that `Bool` is an integer type and all the usual promotion rules and numeric operators are also defined on it.
"""

# ╔═╡ 43a7f905-6017-43eb-a758-4410f2d584a1
md"""
## Bitwise Operators
"""

# ╔═╡ 2b9da4b7-d099-4227-b38a-67161260b507
md"""
The following [bitwise operators](https://en.wikipedia.org/wiki/Bitwise_operation#Bitwise_operators) are supported on all primitive integer types:
"""

# ╔═╡ c2dde3a7-901b-4b42-af49-f8ba9bc746b8
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

# ╔═╡ fe014784-b49c-4444-80d8-3899b8bb5c24
md"""
Here are some examples with bitwise operators:
"""

# ╔═╡ d862a756-85f8-4200-94af-dedee918c188
~123

# ╔═╡ 73f12f9c-1706-411b-a2ad-b3c2c9a071e5
123 & 234

# ╔═╡ b57d62da-70e8-456a-9f83-b0881458b1d8
123 | 234

# ╔═╡ af975d32-c51e-40ea-b6f2-ee2902e5e858
123 ⊻ 234

# ╔═╡ f739bfec-48c0-4140-8977-b26b05eae500
xor(123, 234)

# ╔═╡ 12a5385d-a3f3-4b87-8cde-4f9b29b63a98
~UInt32(123)

# ╔═╡ 94624ba4-8109-4c47-8d4d-cdcaa7943a39
~UInt8(123)

# ╔═╡ 9c530d9b-4b25-4a9d-9890-28ea52b6826c
md"""
## Updating operators
"""

# ╔═╡ 249fbec5-e753-469e-801c-d827c2eef710
md"""
Every binary arithmetic and bitwise operator also has an updating version that assigns the result of the operation back into its left operand. The updating version of the binary operator is formed by placing a `=` immediately after the operator. For example, writing `x += 3` is equivalent to writing `x = x + 3`:
"""

# ╔═╡ 4b691387-0895-47eb-9df3-08405af31513
x = 1

# ╔═╡ 79f2e17a-bd36-4bcb-96c8-9fc257673590
x += 3

# ╔═╡ ba5ca060-a5ea-428a-9524-d7e4bf5b2a03
x

# ╔═╡ 2b7ae945-f283-4215-a582-5e2172a36e55
md"""
The updating versions of all the binary arithmetic and bitwise operators are:
"""

# ╔═╡ 2c4fdfa6-a56e-49e0-b851-031d42e13b66
md"""
```
+=  -=  *=  /=  \=  ÷=  %=  ^=  &=  |=  ⊻=  >>>=  >>=  <<=
```
"""

# ╔═╡ 6d1614f1-6c52-4c0b-a0a3-3571277007ea
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

# ╔═╡ 34ea63db-e79c-4d69-bacf-1a9ad2bcf198
md"""
## [Vectorized \"dot\" operators](@id man-dot-operators)
"""

# ╔═╡ 5db242d0-4704-4ac4-b72e-2a0182eea021
md"""
For *every* binary operation like `^`, there is a corresponding \"dot\" operation `.^` that is *automatically* defined to perform `^` element-by-element on arrays. For example, `[1,2,3] ^ 3` is not defined, since there is no standard mathematical meaning to \"cubing\" a (non-square) array, but `[1,2,3] .^ 3` is defined as computing the elementwise (or \"vectorized\") result `[1^3, 2^3, 3^3]`.  Similarly for unary operators like `!` or `√`, there is a corresponding `.√` that applies the operator elementwise.
"""

# ╔═╡ 20f1bf41-169e-488f-adab-3de74e8f8117
[1,2,3] .^ 3

# ╔═╡ 4ab61792-18f9-4fbe-a0b9-80d78f9939df
md"""
More specifically, `a .^ b` is parsed as the [\"dot\" call](@ref man-vectorized) `(^).(a,b)`, which performs a [broadcast](@ref Broadcasting) operation: it can combine arrays and scalars, arrays of the same size (performing the operation elementwise), and even arrays of different shapes (e.g. combining row and column vectors to produce a matrix). Moreover, like all vectorized \"dot calls,\" these \"dot operators\" are *fusing*. For example, if you compute `2 .* A.^2 .+ sin.(A)` (or equivalently `@. 2A^2 + sin(A)`, using the [`@.`](@ref @__dot__) macro) for an array `A`, it performs a *single* loop over `A`, computing `2a^2 + sin(a)` for each element of `A`. In particular, nested dot calls like `f.(g.(x))` are fused, and \"adjacent\" binary operators like `x .+ 3 .* x.^2` are equivalent to nested dot calls `(+).(x, (*).(3, (^).(x, 2)))`.
"""

# ╔═╡ a442c76d-ffc7-49fd-b96a-bb2c23ab95d8
md"""
Furthermore, \"dotted\" updating operators like `a .+= b` (or `@. a += b`) are parsed as `a .= a .+ b`, where `.=` is a fused *in-place* assignment operation (see the [dot syntax documentation](@ref man-vectorized)).
"""

# ╔═╡ b4c7a9b1-5733-44e0-ae9c-ec9d6b0c7786
md"""
Note the dot syntax is also applicable to user-defined operators. For example, if you define `⊗(A,B) = kron(A,B)` to give a convenient infix syntax `A ⊗ B` for Kronecker products ([`kron`](@ref)), then `[A,B] .⊗ [C,D]` will compute `[A⊗C, B⊗D]` with no additional coding.
"""

# ╔═╡ 3c7dcac6-7ada-4377-bb66-7c67d49b43fe
md"""
Combining dot operators with numeric literals can be ambiguous. For example, it is not clear whether `1.+x` means `1. + x` or `1 .+ x`. Therefore this syntax is disallowed, and spaces must be used around the operator in such cases.
"""

# ╔═╡ 362416cb-9799-4086-989c-36e9a100e77c
md"""
## Numeric Comparisons
"""

# ╔═╡ b68fdd2a-e7cb-4f09-a34a-1af6e2c195c0
md"""
Standard comparison operations are defined for all the primitive numeric types:
"""

# ╔═╡ 6cf238f4-27dd-47ee-9bb2-9a21d10bcbb7
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

# ╔═╡ 097c1342-62e7-4c0a-ae96-9345848565b0
md"""
Here are some simple examples:
"""

# ╔═╡ 32157d18-6faf-4e7a-babe-ee3ecf1f1a70
1 == 1

# ╔═╡ d62922c3-d994-4c53-9dd6-51b37e2cbe45
1 == 2

# ╔═╡ 9888f460-188c-4c2e-963f-b7487e83555b
1 != 2

# ╔═╡ 197f815b-6555-456a-a869-d72936d899ce
1 == 1.0

# ╔═╡ 468ab8c8-e627-4fb3-a8ad-d0ecc82aa36c
1 < 2

# ╔═╡ 8316b803-3cc2-43a5-b774-9efd8b6177b2
1.0 > 3

# ╔═╡ eefaecf8-bd4a-4c93-9371-792949b8a86a
1 >= 1.0

# ╔═╡ 762ff7b1-38c0-4e0a-bc44-cb6a16720307
-1 <= 1

# ╔═╡ aa81a051-b62e-4d87-a044-7675895a1585
-1 <= -1

# ╔═╡ f0671a76-e45a-4d0c-84d0-f1b9e253201f
-1 <= -2

# ╔═╡ cfcba3a5-20f0-4e66-9203-1ae0a8bf05ff
3 < -0.5

# ╔═╡ cab3a32d-36a9-4351-ab99-07939b02e1a6
md"""
Integers are compared in the standard manner – by comparison of bits. Floating-point numbers are compared according to the [IEEE 754 standard](https://en.wikipedia.org/wiki/IEEE_754-2008):
"""

# ╔═╡ 005859a5-bced-456f-81de-7c486a678ebd
md"""
  * Finite numbers are ordered in the usual manner.
  * Positive zero is equal but not greater than negative zero.
  * `Inf` is equal to itself and greater than everything else except `NaN`.
  * `-Inf` is equal to itself and less than everything else except `NaN`.
  * `NaN` is not equal to, not less than, and not greater than anything, including itself.
"""

# ╔═╡ 48b5b93b-6d85-4e4e-ac3d-3b229956d9ee
md"""
The last point is potentially surprising and thus worth noting:
"""

# ╔═╡ d13d8015-0764-44f3-b6cf-24ec7a005668
NaN == NaN

# ╔═╡ 47c8ab81-ea02-410f-8c79-28da475225be
NaN != NaN

# ╔═╡ d143429d-cf62-4f88-8a0a-1dc35d660424
NaN < NaN

# ╔═╡ 7762e13f-2677-412a-aa15-232a828278cf
NaN > NaN

# ╔═╡ 7e499e70-16c5-4080-9444-03cef5a2b436
md"""
and can cause headaches when working with [arrays](@ref man-multi-dim-arrays):
"""

# ╔═╡ 1957c97d-fba3-4450-a4f2-9dad21a962a8
[1 NaN] == [1 NaN]

# ╔═╡ 0e9e8fdc-5095-4bcf-a7ca-588f7a5cde08
md"""
Julia provides additional functions to test numbers for special values, which can be useful in situations like hash key comparisons:
"""

# ╔═╡ 0c0d4f16-c04c-4900-b8f5-08e36e056440
md"""
| Function                | Tests if                  |
|:----------------------- |:------------------------- |
| [`isequal(x, y)`](@ref) | `x` and `y` are identical |
| [`isfinite(x)`](@ref)   | `x` is a finite number    |
| [`isinf(x)`](@ref)      | `x` is infinite           |
| [`isnan(x)`](@ref)      | `x` is not a number       |
"""

# ╔═╡ 627b9690-4f43-4b24-b327-4d6e57a04fea
md"""
[`isequal`](@ref) considers `NaN`s equal to each other:
"""

# ╔═╡ fd22bc99-993a-4dfc-892c-4071e2218dd8
isequal(NaN, NaN)

# ╔═╡ f6146444-569f-40b4-a0e4-17a06381fda9
isequal([1 NaN], [1 NaN])

# ╔═╡ d4a319d1-1c87-4af4-93b8-c0874391ddc6
isequal(NaN, NaN32)

# ╔═╡ 17be057d-39b9-4db6-9065-9c7fa68ec4df
md"""
`isequal` can also be used to distinguish signed zeros:
"""

# ╔═╡ ecf4edb1-46ad-44bd-99d2-d489693497bd
-0.0 == 0.0

# ╔═╡ a3b39e69-aa91-4eca-bac9-222a61052142
isequal(-0.0, 0.0)

# ╔═╡ 9d8d4034-7abe-4c1e-91e2-f5c1b7f2b248
md"""
Mixed-type comparisons between signed integers, unsigned integers, and floats can be tricky. A great deal of care has been taken to ensure that Julia does them correctly.
"""

# ╔═╡ c79488ab-7770-4e9c-8201-0cd0914b684d
md"""
For other types, `isequal` defaults to calling [`==`](@ref), so if you want to define equality for your own types then you only need to add a [`==`](@ref) method.  If you define your own equality function, you should probably define a corresponding [`hash`](@ref) method to ensure that `isequal(x,y)` implies `hash(x) == hash(y)`.
"""

# ╔═╡ c9c03f00-5da2-46b9-a07a-4360f79c9138
md"""
### Chaining comparisons
"""

# ╔═╡ 7a5afaf0-39f4-46fc-b591-9ef0e09f3090
md"""
Unlike most languages, with the [notable exception of Python](https://en.wikipedia.org/wiki/Python_syntax_and_semantics#Comparison_operators), comparisons can be arbitrarily chained:
"""

# ╔═╡ 24a29ab6-d728-4305-9bfa-1a3198cc67af
1 < 2 <= 2 < 3 == 3 > 2 >= 1 == 1 < 3 != 5

# ╔═╡ 4db9cfda-5d63-41cb-8cc8-eb47fcf6e58f
md"""
Chaining comparisons is often quite convenient in numerical code. Chained comparisons use the `&&` operator for scalar comparisons, and the [`&`](@ref) operator for elementwise comparisons, which allows them to work on arrays. For example, `0 .< A .< 1` gives a boolean array whose entries are true where the corresponding elements of `A` are between 0 and 1.
"""

# ╔═╡ d80e9fef-c1b0-4ff6-9dc1-e7e8abd0de8c
md"""
Note the evaluation behavior of chained comparisons:
"""

# ╔═╡ e8623202-db13-4eb5-aef1-411e3a6f1c64
v(x) = (println(x); x)

# ╔═╡ 4c238977-3b5f-4637-96ec-c1880bea8878
v(1) < v(2) <= v(3)

# ╔═╡ 79d90478-9616-4437-bd12-c2947b761db3
v(1) > v(2) <= v(3)

# ╔═╡ d312f6c8-95e1-44ba-9a56-706a1bfa47bf
md"""
The middle expression is only evaluated once, rather than twice as it would be if the expression were written as `v(1) < v(2) && v(2) <= v(3)`. However, the order of evaluations in a chained comparison is undefined. It is strongly recommended not to use expressions with side effects (such as printing) in chained comparisons. If side effects are required, the short-circuit `&&` operator should be used explicitly (see [Short-Circuit Evaluation](@ref)).
"""

# ╔═╡ 9ad3c5f7-5aa1-4007-8da7-41437db3df37
md"""
### Elementary Functions
"""

# ╔═╡ 7f84887f-fd66-414b-b4c0-6efa10462087
md"""
Julia provides a comprehensive collection of mathematical functions and operators. These mathematical operations are defined over as broad a class of numerical values as permit sensible definitions, including integers, floating-point numbers, rationals, and complex numbers, wherever such definitions make sense.
"""

# ╔═╡ 1507c0b8-3dfe-48d3-bc5d-e2453e0d323d
md"""
Moreover, these functions (like any Julia function) can be applied in \"vectorized\" fashion to arrays and other collections with the [dot syntax](@ref man-vectorized) `f.(A)`, e.g. `sin.(A)` will compute the sine of each element of an array `A`.
"""

# ╔═╡ 42f6cb56-1310-4433-ba58-9a29af5dcfb2
md"""
## Operator Precedence and Associativity
"""

# ╔═╡ fad61e50-75b5-4c04-943b-92e85d900020
md"""
Julia applies the following order and associativity of operations, from highest precedence to lowest:
"""

# ╔═╡ 352d5533-32b4-4370-872a-5dd4954d345d
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

# ╔═╡ 559e6e95-3465-4bb1-a78c-a93646a667f4
md"""
[^1]: The unary operators `+` and `-` require explicit parentheses around their argument to disambiguate them from the operator `++`, etc. Other compositions of unary operators are parsed with right-associativity, e. g., `√√-a` as `√(√(-a))`.
"""

# ╔═╡ 9ab521ff-8689-4b08-9376-2d96a583b784
md"""
[^2]: The operators `+`, `++` and `*` are non-associative. `a + b + c` is parsed as `+(a, b, c)` not `+(+(a, b), c)`. However, the fallback methods for `+(a, b, c, d...)` and `*(a, b, c, d...)` both default to left-associative evaluation.
"""

# ╔═╡ 190a43d2-3ee1-40de-936a-d93d42250784
md"""
For a complete list of *every* Julia operator's precedence, see the top of this file: [`src/julia-parser.scm`](https://github.com/JuliaLang/julia/blob/master/src/julia-parser.scm). Note that some of the operators there are not defined in the `Base` module but may be given definitions by standard libraries, packages or user code.
"""

# ╔═╡ ba9389ba-b038-4c9e-b5cf-4740f0412d24
md"""
You can also find the numerical precedence for any given operator via the built-in function `Base.operator_precedence`, where higher numbers take precedence:
"""

# ╔═╡ 24e1adae-10b9-43d3-bfd5-ea66869e20dc
Base.operator_precedence(:+), Base.operator_precedence(:*), Base.operator_precedence(:.)

# ╔═╡ 470e27e4-ffe6-4c3b-8f42-70448eadf2a9
Base.operator_precedence(:sin), Base.operator_precedence(:+=), Base.operator_precedence(:(=))  # (Note the necessary parens on `:(=)`)

# ╔═╡ 40fa8545-5e81-4829-b56e-39d42f9f4a47
md"""
A symbol representing the operator associativity can also be found by calling the built-in function `Base.operator_associativity`:
"""

# ╔═╡ 1cf839eb-c6f1-4268-8025-6cb134c98604
Base.operator_associativity(:-), Base.operator_associativity(:+), Base.operator_associativity(:^)

# ╔═╡ 27e90f0a-f2cb-4aba-b389-18792a14a3c3
Base.operator_associativity(:⊗), Base.operator_associativity(:sin), Base.operator_associativity(:→)

# ╔═╡ 3f979827-b404-44ba-8c81-b30726b957ea
md"""
Note that symbols such as `:sin` return precedence `0`. This value represents invalid operators and not operators of lowest precedence. Similarly, such operators are assigned associativity `:none`.
"""

# ╔═╡ 0f6d868b-f3ba-4ea7-b040-b1f98f5e87a6
md"""
[Numeric literal coefficients](@ref man-numeric-literal-coefficients), e.g. `2x`, are treated as multiplications with higher precedence than any other binary operation, with the exception of `^` where they have higher precedence only as the exponent.
"""

# ╔═╡ 3e6e90c8-5231-41ae-acf0-6cca4b362a1b
x = 3; 2x^2

# ╔═╡ 4f7eee5f-57ea-4484-bc95-588b3e9c8ded
x = 3; 2^2x

# ╔═╡ e7779eb3-30ca-4e63-a37e-23533604e5fa
md"""
Juxtaposition parses like a unary operator, which has the same natural asymmetry around exponents: `-x^y` and `2x^y` parse as `-(x^y)` and `2(x^y)` whereas `x^-y` and `x^2y` parse as `x^(-y)` and `x^(2y)`.
"""

# ╔═╡ 7401aa75-a33d-4086-a021-cf274dc4480f
md"""
## Numerical Conversions
"""

# ╔═╡ a43442db-6bb3-4147-ba46-f15dbef3ab42
md"""
Julia supports three forms of numerical conversion, which differ in their handling of inexact conversions.
"""

# ╔═╡ abea6b51-5ff5-4330-8f5a-6ac6a58e949f
md"""
  * The notation `T(x)` or `convert(T,x)` converts `x` to a value of type `T`.

      * If `T` is a floating-point type, the result is the nearest representable value, which could be positive or negative infinity.
      * If `T` is an integer type, an `InexactError` is raised if `x` is not representable by `T`.
  * `x % T` converts an integer `x` to a value of integer type `T` congruent to `x` modulo `2^n`, where `n` is the number of bits in `T`. In other words, the binary representation is truncated to fit.
  * The [Rounding functions](@ref) take a type `T` as an optional argument. For example, `round(Int,x)` is a shorthand for `Int(round(x))`.
"""

# ╔═╡ acc16734-a254-4349-b529-123f454d68c0
md"""
The following examples show the different forms.
"""

# ╔═╡ 33a92934-da45-48df-88b8-881bff42cab2
Int8(127)

# ╔═╡ e8c23040-dc38-4acc-be98-5291ef986766
Int8(128)

# ╔═╡ c0c7c909-6b3d-4cc9-b305-426b294aab03
Int8(127.0)

# ╔═╡ ce3ace89-cd3f-4ee6-af23-922b6b35d11b
Int8(3.14)

# ╔═╡ ade835ae-304c-4fdf-9251-e05cd199ef00
Int8(128.0)

# ╔═╡ 18a8b3a7-d863-44e8-b1f1-4458666e4487
127 % Int8

# ╔═╡ a9d84d4c-85b8-42ea-8d17-5df8e0e0d0a8
128 % Int8

# ╔═╡ 270a8b9a-090d-4584-8731-c5861085e6a4
round(Int8,127.4)

# ╔═╡ d43137d9-eece-4f31-835c-ac3c5d394205
round(Int8,127.6)

# ╔═╡ 325806af-f6a1-4108-9689-ee061d719b04
md"""
See [Conversion and Promotion](@ref conversion-and-promotion) for how to define your own conversions and promotions.
"""

# ╔═╡ ed211605-cae5-4482-9983-8bcd712b0de2
md"""
### Rounding functions
"""

# ╔═╡ b811cd89-00b4-46da-a351-6c04287dfb31
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

# ╔═╡ 1b2c4fba-c808-4feb-9f1d-6906f9b8c9ec
md"""
### Division functions
"""

# ╔═╡ 8e3637ee-647a-490f-b5e1-705c47ce85a2
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

# ╔═╡ befe83cb-cf5d-4701-9e95-08f5e36c9307
md"""
### Sign and absolute value functions
"""

# ╔═╡ db589fdf-8d1f-48a0-ab4d-54e57d4849ca
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

# ╔═╡ 771608cc-eec8-4051-a8df-c80affba61a1
md"""
### Powers, logs and roots
"""

# ╔═╡ 560515c7-f45e-48d0-9e11-02c25ac5ad11
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

# ╔═╡ 6a14508a-3848-462e-bd6e-4082ef2e07a8
md"""
For an overview of why functions like [`hypot`](@ref), [`expm1`](@ref), and [`log1p`](@ref) are necessary and useful, see John D. Cook's excellent pair of blog posts on the subject: [expm1, log1p, erfc](https://www.johndcook.com/blog/2010/06/07/math-library-functions-that-seem-unnecessary/), and [hypot](https://www.johndcook.com/blog/2010/06/02/whats-so-hard-about-finding-a-hypotenuse/).
"""

# ╔═╡ 563dc307-af5a-43a6-af7f-3ccfb42c5db7
md"""
### Trigonometric and hyperbolic functions
"""

# ╔═╡ 093ce0dd-96cc-4e98-a71d-fd23d0aab42e
md"""
All the standard trigonometric and hyperbolic functions are also defined:
"""

# ╔═╡ 140dfa97-c05d-4242-828c-a39f14a7978e
md"""
```
sin    cos    tan    cot    sec    csc
sinh   cosh   tanh   coth   sech   csch
asin   acos   atan   acot   asec   acsc
asinh  acosh  atanh  acoth  asech  acsch
sinc   cosc
```
"""

# ╔═╡ d952f504-39d8-48e2-897a-83a41b062815
md"""
These are all single-argument functions, with [`atan`](@ref) also accepting two arguments corresponding to a traditional [`atan2`](https://en.wikipedia.org/wiki/Atan2) function.
"""

# ╔═╡ 3f46babf-e7dd-41d2-a9a2-a187b7c858a0
md"""
Additionally, [`sinpi(x)`](@ref) and [`cospi(x)`](@ref) are provided for more accurate computations of [`sin(pi*x)`](@ref) and [`cos(pi*x)`](@ref) respectively.
"""

# ╔═╡ d48e84cd-ce77-488c-9d67-7ccc5a0d6f06
md"""
In order to compute trigonometric functions with degrees instead of radians, suffix the function with `d`. For example, [`sind(x)`](@ref) computes the sine of `x` where `x` is specified in degrees. The complete list of trigonometric functions with degree variants is:
"""

# ╔═╡ dbc2eb39-2b0a-4717-b1a6-8ac5dfb18e4b
md"""
```
sind   cosd   tand   cotd   secd   cscd
asind  acosd  atand  acotd  asecd  acscd
```
"""

# ╔═╡ d00f2ac0-7e04-49b9-9c8e-6306bf5362ba
md"""
### Special functions
"""

# ╔═╡ a16a9f5b-3951-45d5-8e77-4c9445ef22d3
md"""
Many other special mathematical functions are provided by the package [SpecialFunctions.jl](https://github.com/JuliaMath/SpecialFunctions.jl).
"""

# ╔═╡ Cell order:
# ╟─fd25058d-d37b-4013-b21e-4950b879de03
# ╟─ab66b973-7a3b-4ea3-a335-41155dc9ca1a
# ╟─dac8b889-14fa-422d-a616-2321f8d032c0
# ╟─5a10b091-f2c3-449e-a155-1bca35f861c0
# ╟─ff47c163-94a1-4150-93e8-a0f2d4ad450b
# ╟─f1ea4ca7-2543-46a8-9b5d-84493af941f1
# ╟─554c9105-3256-4efd-bea2-e3dd1af54b89
# ╟─46e65749-8c2c-40ab-9d13-055467927fab
# ╠═072707e3-9522-4fb7-96df-a0ac3771068c
# ╠═bdb923f6-1947-4e90-b846-6ef117222978
# ╠═048760a4-c778-4417-910e-1f063d653197
# ╟─8f19fef0-ef4a-4ec7-aed4-e33392246974
# ╟─015bd278-690f-4c58-94e9-a83a2931f06c
# ╠═5555fb86-37ec-47da-b23b-9ca6f823a131
# ╠═be4bdb1d-30a5-4db5-88a8-7736e5959ee7
# ╟─7ff74f8d-9b00-495e-b18f-62b4be88cdd1
# ╟─b6c5d1ed-fc74-4c84-818b-6050e56f4977
# ╟─6fbbccaf-ef96-4dda-97b5-b879ad33a173
# ╟─ebd4a088-cbc3-4bfe-bb30-1bc4beb89a18
# ╟─4a89b4ff-6aff-497f-9cc4-a004cb104956
# ╟─861a2af9-5095-47f0-938f-246d3dfbf244
# ╟─43a7f905-6017-43eb-a758-4410f2d584a1
# ╟─2b9da4b7-d099-4227-b38a-67161260b507
# ╟─c2dde3a7-901b-4b42-af49-f8ba9bc746b8
# ╟─fe014784-b49c-4444-80d8-3899b8bb5c24
# ╠═d862a756-85f8-4200-94af-dedee918c188
# ╠═73f12f9c-1706-411b-a2ad-b3c2c9a071e5
# ╠═b57d62da-70e8-456a-9f83-b0881458b1d8
# ╠═af975d32-c51e-40ea-b6f2-ee2902e5e858
# ╠═f739bfec-48c0-4140-8977-b26b05eae500
# ╠═12a5385d-a3f3-4b87-8cde-4f9b29b63a98
# ╠═94624ba4-8109-4c47-8d4d-cdcaa7943a39
# ╟─9c530d9b-4b25-4a9d-9890-28ea52b6826c
# ╟─249fbec5-e753-469e-801c-d827c2eef710
# ╠═4b691387-0895-47eb-9df3-08405af31513
# ╠═79f2e17a-bd36-4bcb-96c8-9fc257673590
# ╠═ba5ca060-a5ea-428a-9524-d7e4bf5b2a03
# ╟─2b7ae945-f283-4215-a582-5e2172a36e55
# ╟─2c4fdfa6-a56e-49e0-b851-031d42e13b66
# ╟─6d1614f1-6c52-4c0b-a0a3-3571277007ea
# ╟─34ea63db-e79c-4d69-bacf-1a9ad2bcf198
# ╟─5db242d0-4704-4ac4-b72e-2a0182eea021
# ╠═20f1bf41-169e-488f-adab-3de74e8f8117
# ╟─4ab61792-18f9-4fbe-a0b9-80d78f9939df
# ╟─a442c76d-ffc7-49fd-b96a-bb2c23ab95d8
# ╟─b4c7a9b1-5733-44e0-ae9c-ec9d6b0c7786
# ╟─3c7dcac6-7ada-4377-bb66-7c67d49b43fe
# ╟─362416cb-9799-4086-989c-36e9a100e77c
# ╟─b68fdd2a-e7cb-4f09-a34a-1af6e2c195c0
# ╟─6cf238f4-27dd-47ee-9bb2-9a21d10bcbb7
# ╟─097c1342-62e7-4c0a-ae96-9345848565b0
# ╠═32157d18-6faf-4e7a-babe-ee3ecf1f1a70
# ╠═d62922c3-d994-4c53-9dd6-51b37e2cbe45
# ╠═9888f460-188c-4c2e-963f-b7487e83555b
# ╠═197f815b-6555-456a-a869-d72936d899ce
# ╠═468ab8c8-e627-4fb3-a8ad-d0ecc82aa36c
# ╠═8316b803-3cc2-43a5-b774-9efd8b6177b2
# ╠═eefaecf8-bd4a-4c93-9371-792949b8a86a
# ╠═762ff7b1-38c0-4e0a-bc44-cb6a16720307
# ╠═aa81a051-b62e-4d87-a044-7675895a1585
# ╠═f0671a76-e45a-4d0c-84d0-f1b9e253201f
# ╠═cfcba3a5-20f0-4e66-9203-1ae0a8bf05ff
# ╟─cab3a32d-36a9-4351-ab99-07939b02e1a6
# ╟─005859a5-bced-456f-81de-7c486a678ebd
# ╟─48b5b93b-6d85-4e4e-ac3d-3b229956d9ee
# ╠═d13d8015-0764-44f3-b6cf-24ec7a005668
# ╠═47c8ab81-ea02-410f-8c79-28da475225be
# ╠═d143429d-cf62-4f88-8a0a-1dc35d660424
# ╠═7762e13f-2677-412a-aa15-232a828278cf
# ╟─7e499e70-16c5-4080-9444-03cef5a2b436
# ╠═1957c97d-fba3-4450-a4f2-9dad21a962a8
# ╟─0e9e8fdc-5095-4bcf-a7ca-588f7a5cde08
# ╟─0c0d4f16-c04c-4900-b8f5-08e36e056440
# ╟─627b9690-4f43-4b24-b327-4d6e57a04fea
# ╠═fd22bc99-993a-4dfc-892c-4071e2218dd8
# ╠═f6146444-569f-40b4-a0e4-17a06381fda9
# ╠═d4a319d1-1c87-4af4-93b8-c0874391ddc6
# ╟─17be057d-39b9-4db6-9065-9c7fa68ec4df
# ╠═ecf4edb1-46ad-44bd-99d2-d489693497bd
# ╠═a3b39e69-aa91-4eca-bac9-222a61052142
# ╟─9d8d4034-7abe-4c1e-91e2-f5c1b7f2b248
# ╟─c79488ab-7770-4e9c-8201-0cd0914b684d
# ╟─c9c03f00-5da2-46b9-a07a-4360f79c9138
# ╟─7a5afaf0-39f4-46fc-b591-9ef0e09f3090
# ╠═24a29ab6-d728-4305-9bfa-1a3198cc67af
# ╟─4db9cfda-5d63-41cb-8cc8-eb47fcf6e58f
# ╟─d80e9fef-c1b0-4ff6-9dc1-e7e8abd0de8c
# ╠═e8623202-db13-4eb5-aef1-411e3a6f1c64
# ╠═4c238977-3b5f-4637-96ec-c1880bea8878
# ╠═79d90478-9616-4437-bd12-c2947b761db3
# ╟─d312f6c8-95e1-44ba-9a56-706a1bfa47bf
# ╟─9ad3c5f7-5aa1-4007-8da7-41437db3df37
# ╟─7f84887f-fd66-414b-b4c0-6efa10462087
# ╟─1507c0b8-3dfe-48d3-bc5d-e2453e0d323d
# ╟─42f6cb56-1310-4433-ba58-9a29af5dcfb2
# ╟─fad61e50-75b5-4c04-943b-92e85d900020
# ╟─352d5533-32b4-4370-872a-5dd4954d345d
# ╟─559e6e95-3465-4bb1-a78c-a93646a667f4
# ╟─9ab521ff-8689-4b08-9376-2d96a583b784
# ╟─190a43d2-3ee1-40de-936a-d93d42250784
# ╟─ba9389ba-b038-4c9e-b5cf-4740f0412d24
# ╠═24e1adae-10b9-43d3-bfd5-ea66869e20dc
# ╠═470e27e4-ffe6-4c3b-8f42-70448eadf2a9
# ╟─40fa8545-5e81-4829-b56e-39d42f9f4a47
# ╠═1cf839eb-c6f1-4268-8025-6cb134c98604
# ╠═27e90f0a-f2cb-4aba-b389-18792a14a3c3
# ╟─3f979827-b404-44ba-8c81-b30726b957ea
# ╟─0f6d868b-f3ba-4ea7-b040-b1f98f5e87a6
# ╠═3e6e90c8-5231-41ae-acf0-6cca4b362a1b
# ╠═4f7eee5f-57ea-4484-bc95-588b3e9c8ded
# ╟─e7779eb3-30ca-4e63-a37e-23533604e5fa
# ╟─7401aa75-a33d-4086-a021-cf274dc4480f
# ╟─a43442db-6bb3-4147-ba46-f15dbef3ab42
# ╟─abea6b51-5ff5-4330-8f5a-6ac6a58e949f
# ╟─acc16734-a254-4349-b529-123f454d68c0
# ╠═33a92934-da45-48df-88b8-881bff42cab2
# ╠═e8c23040-dc38-4acc-be98-5291ef986766
# ╠═c0c7c909-6b3d-4cc9-b305-426b294aab03
# ╠═ce3ace89-cd3f-4ee6-af23-922b6b35d11b
# ╠═ade835ae-304c-4fdf-9251-e05cd199ef00
# ╠═18a8b3a7-d863-44e8-b1f1-4458666e4487
# ╠═a9d84d4c-85b8-42ea-8d17-5df8e0e0d0a8
# ╠═270a8b9a-090d-4584-8731-c5861085e6a4
# ╠═d43137d9-eece-4f31-835c-ac3c5d394205
# ╟─325806af-f6a1-4108-9689-ee061d719b04
# ╟─ed211605-cae5-4482-9983-8bcd712b0de2
# ╟─b811cd89-00b4-46da-a351-6c04287dfb31
# ╟─1b2c4fba-c808-4feb-9f1d-6906f9b8c9ec
# ╟─8e3637ee-647a-490f-b5e1-705c47ce85a2
# ╟─befe83cb-cf5d-4701-9e95-08f5e36c9307
# ╟─db589fdf-8d1f-48a0-ab4d-54e57d4849ca
# ╟─771608cc-eec8-4051-a8df-c80affba61a1
# ╟─560515c7-f45e-48d0-9e11-02c25ac5ad11
# ╟─6a14508a-3848-462e-bd6e-4082ef2e07a8
# ╟─563dc307-af5a-43a6-af7f-3ccfb42c5db7
# ╟─093ce0dd-96cc-4e98-a71d-fd23d0aab42e
# ╟─140dfa97-c05d-4242-828c-a39f14a7978e
# ╟─d952f504-39d8-48e2-897a-83a41b062815
# ╟─3f46babf-e7dd-41d2-a9a2-a187b7c858a0
# ╟─d48e84cd-ce77-488c-9d67-7ccc5a0d6f06
# ╟─dbc2eb39-2b0a-4717-b1a6-8ac5dfb18e4b
# ╟─d00f2ac0-7e04-49b9-9c8e-6306bf5362ba
# ╟─a16a9f5b-3951-45d5-8e77-4c9445ef22d3
