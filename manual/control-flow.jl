### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03be4ec8-9e19-11eb-324e-43b995c507f7
md"""
# Control Flow
"""

# ╔═╡ 03be4f04-9e19-11eb-296c-7daa5211e21f
md"""
Julia provides a variety of control flow constructs:
"""

# ╔═╡ 03be509e-9e19-11eb-1173-db0dd8cea10d
md"""
  * [Compound Expressions](@ref man-compound-expressions): `begin` and `;`.
  * [Conditional Evaluation](@ref man-conditional-evaluation): `if`-`elseif`-`else` and `?:` (ternary operator).
  * [Short-Circuit Evaluation](@ref): logical operators `&&` (“and”) and `||` (“or”), and also chained comparisons.
  * [Repeated Evaluation: Loops](@ref man-loops): `while` and `for`.
  * [Exception Handling](@ref): `try`-`catch`, [`error`](@ref) and [`throw`](@ref).
  * [Tasks (aka Coroutines)](@ref man-tasks): [`yieldto`](@ref).
"""

# ╔═╡ 03be50bc-9e19-11eb-08a9-0385258493b4
md"""
The first five control flow mechanisms are standard to high-level programming languages. [`Task`](@ref)s are not so standard: they provide non-local control flow, making it possible to switch between temporarily-suspended computations. This is a powerful construct: both exception handling and cooperative multitasking are implemented in Julia using tasks. Everyday programming requires no direct usage of tasks, but certain problems can be solved much more easily by using tasks.
"""

# ╔═╡ 03be50f8-9e19-11eb-1f4e-d1cfbc0ea97d
md"""
## [Compound Expressions](@id man-compound-expressions)
"""

# ╔═╡ 03be5120-9e19-11eb-2c34-1b3d769f40a7
md"""
Sometimes it is convenient to have a single expression which evaluates several subexpressions in order, returning the value of the last subexpression as its value. There are two Julia constructs that accomplish this: `begin` blocks and `;` chains. The value of both compound expression constructs is that of the last subexpression. Here's an example of a `begin` block:
"""

# ╔═╡ 03be55d0-9e19-11eb-35e3-2937ee486b28
z = begin
           x = 1
           y = 2
           x + y
       end

# ╔═╡ 03be55f8-9e19-11eb-2917-a5ae56a4c0b7
md"""
Since these are fairly small, simple expressions, they could easily be placed onto a single line, which is where the `;` chain syntax comes in handy:
"""

# ╔═╡ 03be594a-9e19-11eb-0b4b-0faa65eab053
z = (x = 1; y = 2; x + y)

# ╔═╡ 03be5972-9e19-11eb-373e-e1113288f183
md"""
This syntax is particularly useful with the terse single-line function definition form introduced in [Functions](@ref man-functions). Although it is typical, there is no requirement that `begin` blocks be multiline or that `;` chains be single-line:
"""

# ╔═╡ 03be5ee0-9e19-11eb-06ad-d14c12628e99
begin x = 1; y = 2; x + y end

# ╔═╡ 03be5eea-9e19-11eb-3b9d-4da43c41fe58
(x = 1;
        y = 2;
        x + y)

# ╔═╡ 03be5f1c-9e19-11eb-3125-4f41ae7c14e0
md"""
## [Conditional Evaluation](@id man-conditional-evaluation)
"""

# ╔═╡ 03be5f3a-9e19-11eb-3938-1d08fc3414ca
md"""
Conditional evaluation allows portions of code to be evaluated or not evaluated depending on the value of a boolean expression. Here is the anatomy of the `if`-`elseif`-`else` conditional syntax:
"""

# ╔═╡ 03be5f76-9e19-11eb-021a-17b4012479cb
md"""
```julia
if x < y
    println("x is less than y")
elseif x > y
    println("x is greater than y")
else
    println("x is equal to y")
end
```
"""

# ╔═╡ 03be5f9e-9e19-11eb-1ef6-09c7c130daa4
md"""
If the condition expression `x < y` is `true`, then the corresponding block is evaluated; otherwise the condition expression `x > y` is evaluated, and if it is `true`, the corresponding block is evaluated; if neither expression is true, the `else` block is evaluated. Here it is in action:
"""

# ╔═╡ 03be68a4-9e19-11eb-3602-d73bb8a0532e
function test(x, y)
           if x < y
               println("x is less than y")
           elseif x > y
               println("x is greater than y")
           else
               println("x is equal to y")
           end
       end

# ╔═╡ 03be68ae-9e19-11eb-389e-cbfa2db5d887
test(1, 2)

# ╔═╡ 03be68ae-9e19-11eb-069b-fd76d2d7dacb
test(2, 1)

# ╔═╡ 03be68ae-9e19-11eb-294c-716a9d44d30d
test(1, 1)

# ╔═╡ 03be68ea-9e19-11eb-3093-05669de4d5b1
md"""
The `elseif` and `else` blocks are optional, and as many `elseif` blocks as desired can be used. The condition expressions in the `if`-`elseif`-`else` construct are evaluated until the first one evaluates to `true`, after which the associated block is evaluated, and no further condition expressions or blocks are evaluated.
"""

# ╔═╡ 03be690a-9e19-11eb-3d87-bd2f456a4b44
md"""
`if` blocks are "leaky", i.e. they do not introduce a local scope. This means that new variables defined inside the `if` clauses can be used after the `if` block, even if they weren't defined before. So, we could have defined the `test` function above as
"""

# ╔═╡ 03be710a-9e19-11eb-131c-33b92c2105b6
function test(x,y)
           if x < y
               relation = "less than"
           elseif x == y
               relation = "equal to"
           else
               relation = "greater than"
           end
           println("x is ", relation, " y.")
       end

# ╔═╡ 03be710a-9e19-11eb-341d-456fa2ea46c7
test(2, 1)

# ╔═╡ 03be713c-9e19-11eb-02c5-c1288284e146
md"""
The variable `relation` is declared inside the `if` block, but used outside. However, when depending on this behavior, make sure all possible code paths define a value for the variable. The following change to the above function results in a runtime error
"""

# ╔═╡ 03be790c-9e19-11eb-3c98-77637cc6ff2f
function test(x,y)
           if x < y
               relation = "less than"
           elseif x == y
               relation = "equal to"
           end
           println("x is ", relation, " y.")
       end

# ╔═╡ 03be7914-9e19-11eb-0139-8b4b04e26bf3
test(1,2)

# ╔═╡ 03be7914-9e19-11eb-3ca2-a7e521cbba47
test(2,1)

# ╔═╡ 03be793e-9e19-11eb-0c55-336dd386a46b
md"""
`if` blocks also return a value, which may seem unintuitive to users coming from many other languages. This value is simply the return value of the last executed statement in the branch that was chosen, so
"""

# ╔═╡ 03be7c88-9e19-11eb-2cee-9dd00ecb38ce
x = 3

# ╔═╡ 03be7c88-9e19-11eb-07f0-1d4846831885
if x > 0
           "positive!"
       else
           "negative..."
       end

# ╔═╡ 03be7c9a-9e19-11eb-28a9-11bd236d7926
md"""
Note that very short conditional statements (one-liners) are frequently expressed using Short-Circuit Evaluation in Julia, as outlined in the next section.
"""

# ╔═╡ 03be7ccc-9e19-11eb-011a-5368cc577712
md"""
Unlike C, MATLAB, Perl, Python, and Ruby – but like Java, and a few other stricter, typed languages – it is an error if the value of a conditional expression is anything but `true` or `false`:
"""

# ╔═╡ 03be7eca-9e19-11eb-3bc8-79dfaf28e5ef
if 1
           println("true")
       end

# ╔═╡ 03be7ee8-9e19-11eb-0eae-1396d456d165
md"""
This error indicates that the conditional was of the wrong type: [`Int64`](@ref) rather than the required [`Bool`](@ref).
"""

# ╔═╡ 03be7f10-9e19-11eb-3ef3-f331ef7482b6
md"""
The so-called "ternary operator", `?:`, is closely related to the `if`-`elseif`-`else` syntax, but is used where a conditional choice between single expression values is required, as opposed to conditional execution of longer blocks of code. It gets its name from being the only operator in most languages taking three operands:
"""

# ╔═╡ 03be7f2e-9e19-11eb-1b26-d125f9da180f
md"""
```julia
a ? b : c
```
"""

# ╔═╡ 03be7f60-9e19-11eb-07c7-cf2d0e879111
md"""
The expression `a`, before the `?`, is a condition expression, and the ternary operation evaluates the expression `b`, before the `:`, if the condition `a` is `true` or the expression `c`, after the `:`, if it is `false`. Note that the spaces around `?` and `:` are mandatory: an expression like `a?b:c` is not a valid ternary expression (but a newline is acceptable after both the `?` and the `:`).
"""

# ╔═╡ 03be7f7e-9e19-11eb-2da3-23fc49f3ee7b
md"""
The easiest way to understand this behavior is to see an example. In the previous example, the `println` call is shared by all three branches: the only real choice is which literal string to print. This could be written more concisely using the ternary operator. For the sake of clarity, let's try a two-way version first:
"""

# ╔═╡ 03be87bc-9e19-11eb-2fa8-47b06ab38a5b
x = 1; y = 2;

# ╔═╡ 03be87bc-9e19-11eb-39c1-8718f079948e
println(x < y ? "less than" : "not less than")

# ╔═╡ 03be87c4-9e19-11eb-180b-5b931417e30a
x = 1; y = 0;

# ╔═╡ 03be87c4-9e19-11eb-3d1f-6d02d4749bfe
println(x < y ? "less than" : "not less than")

# ╔═╡ 03be87f6-9e19-11eb-1d6d-2d5e55236338
md"""
If the expression `x < y` is true, the entire ternary operator expression evaluates to the string `"less than"` and otherwise it evaluates to the string `"not less than"`. The original three-way example requires chaining multiple uses of the ternary operator together:
"""

# ╔═╡ 03be8efe-9e19-11eb-2589-713164409e1f
test(x, y) = println(x < y ? "x is less than y"    :
                            x > y ? "x is greater than y" : "x is equal to y")

# ╔═╡ 03be8f0a-9e19-11eb-237b-77e9d41bdb88
test(1, 2)

# ╔═╡ 03be8f0a-9e19-11eb-2326-d382dc340f4d
test(2, 1)

# ╔═╡ 03be8f14-9e19-11eb-0363-119563585332
test(1, 1)

# ╔═╡ 03be8f3c-9e19-11eb-1dac-ab1c482be870
md"""
To facilitate chaining, the operator associates from right to left.
"""

# ╔═╡ 03be8f5a-9e19-11eb-1311-d72cc8aa9f5a
md"""
It is significant that like `if`-`elseif`-`else`, the expressions before and after the `:` are only evaluated if the condition expression evaluates to `true` or `false`, respectively:
"""

# ╔═╡ 03be96e4-9e19-11eb-3c61-f96738ea4118
v(x) = (println(x); x)

# ╔═╡ 03be96f8-9e19-11eb-301d-53b26eb54d12
1 < 2 ? v("yes") : v("no")

# ╔═╡ 03be96f8-9e19-11eb-004f-298a2b2ae8ba
1 > 2 ? v("yes") : v("no")

# ╔═╡ 03be970a-9e19-11eb-0036-a3fca3c12d27
md"""
## Short-Circuit Evaluation
"""

# ╔═╡ 03be9752-9e19-11eb-0825-bb71f4358560
md"""
The `&&` and `||` operators in Julia correspond to logical “and” and “or” operations, respectively, and are typically used for this purpose.  However, they have an additional property of *short-circuit* evaluation: they don't necessarily evaluate their second argument, as explained below.  (There are also bitwise `&` and `|` operators that can be used as logical “and” and “or” *without* short-circuit behavior, but beware that `&` and `|` have higher precedence than `&&` and `||` for evaluation order.)
"""

# ╔═╡ 03be977a-9e19-11eb-0cd4-d97393d907f5
md"""
Short-circuit evaluation is quite similar to conditional evaluation. The behavior is found in most imperative programming languages having the `&&` and `||` boolean operators: in a series of boolean expressions connected by these operators, only the minimum number of expressions are evaluated as are necessary to determine the final boolean value of the entire chain. Explicitly, this means that:
"""

# ╔═╡ 03be97e8-9e19-11eb-135a-abb9e5cdcb3e
md"""
  * In the expression `a && b`, the subexpression `b` is only evaluated if `a` evaluates to `true`.
  * In the expression `a || b`, the subexpression `b` is only evaluated if `a` evaluates to `false`.
"""

# ╔═╡ 03be9812-9e19-11eb-11f9-29c184d72f64
md"""
The reasoning is that `a && b` must be `false` if `a` is `false`, regardless of the value of `b`, and likewise, the value of `a || b` must be true if `a` is `true`, regardless of the value of `b`. Both `&&` and `||` associate to the right, but `&&` has higher precedence than `||` does. It's easy to experiment with this behavior:
"""

# ╔═╡ 03bea650-9e19-11eb-3885-9964db78c559
t(x) = (println(x); true)

# ╔═╡ 03bea650-9e19-11eb-3c35-65d88be2dcc4
f(x) = (println(x); false)

# ╔═╡ 03bea65c-9e19-11eb-2aed-f336bb9c395f
t(1) && t(2)

# ╔═╡ 03bea65c-9e19-11eb-1b5e-41e772ed2672
t(1) && f(2)

# ╔═╡ 03bea666-9e19-11eb-1828-5b716ea1e812
f(1) && t(2)

# ╔═╡ 03bea67a-9e19-11eb-3732-6559ba0fac6c
f(1) && f(2)

# ╔═╡ 03bea67a-9e19-11eb-0991-5d420b2a87a4
t(1) || t(2)

# ╔═╡ 03bea684-9e19-11eb-2190-5758eab6c04f
t(1) || f(2)

# ╔═╡ 03bea684-9e19-11eb-1463-25ef6685f190
f(1) || t(2)

# ╔═╡ 03bea68e-9e19-11eb-3993-db135c072e62
f(1) || f(2)

# ╔═╡ 03bea6ac-9e19-11eb-05b0-bbe45bd46167
md"""
You can easily experiment in the same way with the associativity and precedence of various combinations of `&&` and `||` operators.
"""

# ╔═╡ 03bea6d4-9e19-11eb-2ac5-49b89edd2aa5
md"""
This behavior is frequently used in Julia to form an alternative to very short `if` statements. Instead of `if <cond> <statement> end`, one can write `<cond> && <statement>` (which could be read as: <cond> *and then* <statement>). Similarly, instead of `if ! <cond> <statement> end`, one can write `<cond> || <statement>` (which could be read as: <cond> *or else* <statement>).
"""

# ╔═╡ 03bea6e8-9e19-11eb-3973-2943d818a323
md"""
For example, a recursive factorial routine could be defined like this:
"""

# ╔═╡ 03beb002-9e19-11eb-2f37-a5639c7ef229
function fact(n::Int)
           n >= 0 || error("n must be non-negative")
           n == 0 && return 1
           n * fact(n-1)
       end

# ╔═╡ 03beb00c-9e19-11eb-393d-db827bd9f2db
fact(5)

# ╔═╡ 03beb00c-9e19-11eb-0d58-49e2ee2ed7c9
fact(0)

# ╔═╡ 03beb016-9e19-11eb-0f67-4383cd88d261
fact(-1)

# ╔═╡ 03beb048-9e19-11eb-22d0-5fb5d0b2529a
md"""
Boolean operations *without* short-circuit evaluation can be done with the bitwise boolean operators introduced in [Mathematical Operations and Elementary Functions](@ref): `&` and `|`. These are normal functions, which happen to support infix operator syntax, but always evaluate their arguments:
"""

# ╔═╡ 03beb2d2-9e19-11eb-26a0-d344c0c7b8ed
f(1) & t(2)

# ╔═╡ 03beb2dc-9e19-11eb-2160-ed8088550c52
t(1) | t(2)

# ╔═╡ 03beb2fa-9e19-11eb-22ee-dd6c9b98c754
md"""
Just like condition expressions used in `if`, `elseif` or the ternary operator, the operands of `&&` or `||` must be boolean values (`true` or `false`). Using a non-boolean value anywhere except for the last entry in a conditional chain is an error:
"""

# ╔═╡ 03beb3fc-9e19-11eb-1579-838007b3338a
1 && true

# ╔═╡ 03beb426-9e19-11eb-1c97-819889a26bc2
md"""
On the other hand, any type of expression can be used at the end of a conditional chain. It will be evaluated and returned depending on the preceding conditionals:
"""

# ╔═╡ 03beb840-9e19-11eb-0bf8-f76189632761
true && (x = (1, 2, 3))

# ╔═╡ 03beb840-9e19-11eb-0682-edcc9ca4eea0
false && (x = (1, 2, 3))

# ╔═╡ 03beb85e-9e19-11eb-01eb-41ca6c79bbf2
md"""
## [Repeated Evaluation: Loops](@id man-loops)
"""

# ╔═╡ 03beb886-9e19-11eb-25b4-29fa3041f3e1
md"""
There are two constructs for repeated evaluation of expressions: the `while` loop and the `for` loop. Here is an example of a `while` loop:
"""

# ╔═╡ 03bebcb4-9e19-11eb-0199-15f084621d8f
i = 1;

# ╔═╡ 03bebcbe-9e19-11eb-0435-d96eddcbb0b8
while i <= 5
           println(i)
           global i += 1
       end

# ╔═╡ 03bebcde-9e19-11eb-0f35-35a214b3f5ef
md"""
The `while` loop evaluates the condition expression (`i <= 5` in this case), and as long it remains `true`, keeps also evaluating the body of the `while` loop. If the condition expression is `false` when the `while` loop is first reached, the body is never evaluated.
"""

# ╔═╡ 03bebd04-9e19-11eb-307f-011647304b41
md"""
The `for` loop makes common repeated evaluation idioms easier to write. Since counting up and down like the above `while` loop does is so common, it can be expressed more concisely with a `for` loop:
"""

# ╔═╡ 03bebf48-9e19-11eb-10ab-cff5f9c56f36
for i = 1:5
           println(i)
       end

# ╔═╡ 03bebf70-9e19-11eb-270c-99754ef7d11d
md"""
Here the `1:5` is a range object, representing the sequence of numbers 1, 2, 3, 4, 5. The `for` loop iterates through these values, assigning each one in turn to the variable `i`. One rather important distinction between the previous `while` loop form and the `for` loop form is the scope during which the variable is visible. If the variable `i` has not been introduced in another scope, in the `for` loop form, it is visible only inside of the `for` loop, and not outside/afterwards. You'll either need a new interactive session instance or a different variable name to test this:
"""

# ╔═╡ 03bec240-9e19-11eb-024c-a52c837f1727
for j = 1:5
           println(j)
       end

# ╔═╡ 03bec24c-9e19-11eb-37be-e5b37f9a5cf1
j

# ╔═╡ 03bec25e-9e19-11eb-0e4a-cd77525c34b7
md"""
See [Scope of Variables](@ref scope-of-variables) for a detailed explanation of variable scope and how it works in Julia.
"""

# ╔═╡ 03bec27e-9e19-11eb-39be-79fc23e6261b
md"""
In general, the `for` loop construct can iterate over any container. In these cases, the alternative (but fully equivalent) keyword `in` or `∈` is typically used instead of `=`, since it makes the code read more clearly:
"""

# ╔═╡ 03bec808-9e19-11eb-254f-4783c5742faa
for i in [1,4,0]
           println(i)
       end

# ╔═╡ 03bec812-9e19-11eb-3508-79a09b0a15e3
for s ∈ ["foo","bar","baz"]
           println(s)
       end

# ╔═╡ 03bec830-9e19-11eb-0953-91f48ed76653
md"""
Various types of iterable containers will be introduced and discussed in later sections of the manual (see, e.g., [Multi-dimensional Arrays](@ref man-multi-dim-arrays)).
"""

# ╔═╡ 03bec858-9e19-11eb-2725-79d8176647b7
md"""
It is sometimes convenient to terminate the repetition of a `while` before the test condition is falsified or stop iterating in a `for` loop before the end of the iterable object is reached. This can be accomplished with the `break` keyword:
"""

# ╔═╡ 03bed154-9e19-11eb-3390-a7dd5dd2e9fd
i = 1;

# ╔═╡ 03bed154-9e19-11eb-32f8-5f4d82094d83
while true
           println(i)
           if i >= 5
               break
           end
           global i += 1
       end

# ╔═╡ 03bed160-9e19-11eb-0a0c-ad7f30b0999d
for j = 1:1000
           println(j)
           if j >= 5
               break
           end
       end

# ╔═╡ 03bed186-9e19-11eb-2824-057529405bf5
md"""
Without the `break` keyword, the above `while` loop would never terminate on its own, and the `for` loop would iterate up to 1000. These loops are both exited early by using `break`.
"""

# ╔═╡ 03bed1a4-9e19-11eb-162e-55cdc49f1a62
md"""
In other circumstances, it is handy to be able to stop an iteration and move on to the next one immediately. The `continue` keyword accomplishes this:
"""

# ╔═╡ 03bed5ca-9e19-11eb-2139-87fdf9a9f4a2
for i = 1:10
           if i % 3 != 0
               continue
           end
           println(i)
       end

# ╔═╡ 03bed5f0-9e19-11eb-0e4b-53115e5e198d
md"""
This is a somewhat contrived example since we could produce the same behavior more clearly by negating the condition and placing the `println` call inside the `if` block. In realistic usage there is more code to be evaluated after the `continue`, and often there are multiple points from which one calls `continue`.
"""

# ╔═╡ 03bed60e-9e19-11eb-14dc-b51da2044954
md"""
Multiple nested `for` loops can be combined into a single outer loop, forming the cartesian product of its iterables:
"""

# ╔═╡ 03bed9c4-9e19-11eb-20a8-4fc48df8baf8
for i = 1:2, j = 3:4
           println((i, j))
       end

# ╔═╡ 03bed9ec-9e19-11eb-2e16-8b3cfb969cbc
md"""
With this syntax, iterables may still refer to outer loop variables; e.g. `for i = 1:n, j = 1:i` is valid. However a `break` statement inside such a loop exits the entire nest of loops, not just the inner one. Both variables (`i` and `j`) are set to their current iteration values each time the inner loop runs. Therefore, assignments to `i` will not be visible to subsequent iterations:
"""

# ╔═╡ 03bede92-9e19-11eb-13bb-d3942fe9cef4
for i = 1:2, j = 3:4
           println((i, j))
           i = 0
       end

# ╔═╡ 03beded8-9e19-11eb-2f55-91894ad15186
md"""
If this example were rewritten to use a `for` keyword for each variable, then the output would be different: the second and fourth values would contain `0`.
"""

# ╔═╡ 03bedef6-9e19-11eb-1d3b-c7329d894faf
md"""
Multiple containers can be iterated over at the same time in a single `for` loop using [`zip`](@ref):
"""

# ╔═╡ 03bee504-9e19-11eb-3378-cd973cd73cb8
for (j, k) in zip([1 2 3], [4 5 6 7])
           println((j,k))
       end

# ╔═╡ 03bee568-9e19-11eb-0a63-8302679b8720
md"""
Using [`zip`](@ref) will create an iterator that is a tuple containing the subiterators for the containers passed to it. The `zip` iterator will iterate over all subiterators in order, choosing the $i$th element of each subiterator in the $i$th iteration of the `for` loop. Once any of the subiterators run out, the `for` loop will stop.
"""

# ╔═╡ 03bee590-9e19-11eb-2afa-2330a14797ef
md"""
## Exception Handling
"""

# ╔═╡ 03bee5a4-9e19-11eb-35c6-43740c6ae874
md"""
When an unexpected condition occurs, a function may be unable to return a reasonable value to its caller. In such cases, it may be best for the exceptional condition to either terminate the program while printing a diagnostic error message, or if the programmer has provided code to handle such exceptional circumstances then allow that code to take the appropriate action.
"""

# ╔═╡ 03bee5ea-9e19-11eb-18e8-f9435d50d998
md"""
### Built-in `Exception`s
"""

# ╔═╡ 03bee608-9e19-11eb-2bfd-75dad5d618a8
md"""
`Exception`s are thrown when an unexpected condition has occurred. The built-in `Exception`s listed below all interrupt the normal flow of control.
"""

# ╔═╡ 03bee950-9e19-11eb-1424-11e3d68a11ff
md"""
| `Exception`                   |
|:----------------------------- |
| [`ArgumentError`](@ref)       |
| [`BoundsError`](@ref)         |
| [`CompositeException`](@ref)  |
| [`DimensionMismatch`](@ref)   |
| [`DivideError`](@ref)         |
| [`DomainError`](@ref)         |
| [`EOFError`](@ref)            |
| [`ErrorException`](@ref)      |
| [`InexactError`](@ref)        |
| [`InitError`](@ref)           |
| [`InterruptException`](@ref)  |
| `InvalidStateException`       |
| [`KeyError`](@ref)            |
| [`LoadError`](@ref)           |
| [`OutOfMemoryError`](@ref)    |
| [`ReadOnlyMemoryError`](@ref) |
| [`RemoteException`](@ref)     |
| [`MethodError`](@ref)         |
| [`OverflowError`](@ref)       |
| [`Meta.ParseError`](@ref)     |
| [`SystemError`](@ref)         |
| [`TypeError`](@ref)           |
| [`UndefRefError`](@ref)       |
| [`UndefVarError`](@ref)       |
| [`StringIndexError`](@ref)    |
"""

# ╔═╡ 03bee976-9e19-11eb-0b2f-b302112ab96f
md"""
For example, the [`sqrt`](@ref) function throws a [`DomainError`](@ref) if applied to a negative real value:
"""

# ╔═╡ 03beeb44-9e19-11eb-24c6-919de6e04828
sqrt(-1)

# ╔═╡ 03beeb76-9e19-11eb-1be3-374ef410cd20
md"""
You may define your own exceptions in the following way:
"""

# ╔═╡ 03beed10-9e19-11eb-14e4-9d8226c055f8
struct MyCustomException <: Exception end

# ╔═╡ 03beed38-9e19-11eb-2f27-c74b75e4dd7d
md"""
### The [`throw`](@ref) function
"""

# ╔═╡ 03beed7c-9e19-11eb-00f7-11697c722c11
md"""
Exceptions can be created explicitly with [`throw`](@ref). For example, a function defined only for nonnegative numbers could be written to [`throw`](@ref) a [`DomainError`](@ref) if the argument is negative:
"""

# ╔═╡ 03bef420-9e19-11eb-27e2-bb3a181d5859
f(x) = x>=0 ? exp(-x) : throw(DomainError(x, "argument must be nonnegative"))

# ╔═╡ 03bef420-9e19-11eb-1c45-b77a97c5bd81
f(1)

# ╔═╡ 03bef42c-9e19-11eb-1dde-0bd8e44ef15b
f(-1)

# ╔═╡ 03bef45e-9e19-11eb-053c-efa7f12ff01c
md"""
Note that [`DomainError`](@ref) without parentheses is not an exception, but a type of exception. It needs to be called to obtain an `Exception` object:
"""

# ╔═╡ 03bef6fc-9e19-11eb-20a2-9f0b59ba4e2a
typeof(DomainError(nothing)) <: Exception

# ╔═╡ 03bef6fc-9e19-11eb-2ebc-5190214ac148
typeof(DomainError) <: Exception

# ╔═╡ 03bef710-9e19-11eb-262d-e93a09c95cbb
md"""
Additionally, some exception types take one or more arguments that are used for error reporting:
"""

# ╔═╡ 03bef88a-9e19-11eb-1266-9d7fb2a18f3a
throw(UndefVarError(:x))

# ╔═╡ 03bef8be-9e19-11eb-10cf-cbca098c0d38
md"""
This mechanism can be implemented easily by custom exception types following the way [`UndefVarError`](@ref) is written:
"""

# ╔═╡ 03befefc-9e19-11eb-3acc-6d3aefbffe93
struct MyUndefVarError <: Exception
           var::Symbol
       end

# ╔═╡ 03beff08-9e19-11eb-1f49-6feca5f9da8c
Base.showerror(io::IO, e::MyUndefVarError) = print(io, e.var, " not defined")

# ╔═╡ 03bf0084-9e19-11eb-1b88-130d42185b69
md"""
!!! note
    When writing an error message, it is preferred to make the first word lowercase. For example,

    `size(A) == size(B) || throw(DimensionMismatch("size of A not equal to size of B"))`

    is preferred over

    `size(A) == size(B) || throw(DimensionMismatch("Size of A not equal to size of B"))`.

    However, sometimes it makes sense to keep the uppercase first letter, for instance if an argument to a function is a capital letter:

    `size(A,1) == size(B,2) || throw(DimensionMismatch("A has first dimension..."))`.
"""

# ╔═╡ 03bf00a2-9e19-11eb-1170-7b106ca5fd9c
md"""
### Errors
"""

# ╔═╡ 03bf00c8-9e19-11eb-18e8-156f8df2437c
md"""
The [`error`](@ref) function is used to produce an [`ErrorException`](@ref) that interrupts the normal flow of control.
"""

# ╔═╡ 03bf00fc-9e19-11eb-3b02-63ff4c14c178
md"""
Suppose we want to stop execution immediately if the square root of a negative number is taken. To do this, we can define a fussy version of the [`sqrt`](@ref) function that raises an error if its argument is negative:
"""

# ╔═╡ 03bf06ce-9e19-11eb-381b-237c5739b1b0
fussy_sqrt(x) = x >= 0 ? sqrt(x) : error("negative x not allowed")

# ╔═╡ 03bf06da-9e19-11eb-299e-d5e3995f3482
fussy_sqrt(2)

# ╔═╡ 03bf06da-9e19-11eb-3125-492fcec94f41
fussy_sqrt(-1)

# ╔═╡ 03bf070c-9e19-11eb-2579-51e5fa53dd35
md"""
If `fussy_sqrt` is called with a negative value from another function, instead of trying to continue execution of the calling function, it returns immediately, displaying the error message in the interactive session:
"""

# ╔═╡ 03bf0e26-9e19-11eb-14f6-6117ce92617e
function verbose_fussy_sqrt(x)
           println("before fussy_sqrt")
           r = fussy_sqrt(x)
           println("after fussy_sqrt")
           return r
       end

# ╔═╡ 03bf0e30-9e19-11eb-089e-274472eb15ee
verbose_fussy_sqrt(2)

# ╔═╡ 03bf0e3a-9e19-11eb-229e-fdd7916bcfc3
verbose_fussy_sqrt(-1)

# ╔═╡ 03bf0e58-9e19-11eb-2578-ab9756a4ae02
md"""
### The `try/catch` statement
"""

# ╔═╡ 03bf0e94-9e19-11eb-1b10-bbee01698567
md"""
The `try/catch` statement allows for `Exception`s to be tested for, and for the graceful handling of things that may ordinarily break your application. For example, in the below code the function for square root would normally throw an exception. By placing a `try/catch` block around it we can mitigate that here. You may choose how you wish to handle this exception, whether logging it, return a placeholder value or as in the case below where we just printed out a statement. One thing to think about when deciding how to handle unexpected situations is that using a `try/catch` block is much slower than using conditional branching to handle those situations. Below there are more examples of handling exceptions with a `try/catch` block:
"""

# ╔═╡ 03bf11e8-9e19-11eb-208a-e9f2ca6f56a6
try
           sqrt("ten")
       catch e
           println("You should have entered a numeric value")
       end

# ╔═╡ 03bf121a-9e19-11eb-1569-77cdee8e1d67
md"""
`try/catch` statements also allow the `Exception` to be saved in a variable. The following contrived example calculates the square root of the second element of `x` if `x` is indexable, otherwise assumes `x` is a real number and returns its square root:
"""

# ╔═╡ 03bf1eac-9e19-11eb-2c65-85f44c8a57fe
sqrt_second(x) = try
           sqrt(x[2])
       catch y
           if isa(y, DomainError)
               sqrt(complex(x[2], 0))
           elseif isa(y, BoundsError)
               sqrt(x)
           end
       end

# ╔═╡ 03bf1eca-9e19-11eb-0748-197919f700f8
sqrt_second([1 4])

# ╔═╡ 03bf1ed4-9e19-11eb-0273-5143803b9b82
sqrt_second([1 -4])

# ╔═╡ 03bf1ed4-9e19-11eb-29a1-331f27395fb0
sqrt_second(9)

# ╔═╡ 03bf1ede-9e19-11eb-15e2-4792f014f48a
sqrt_second(-9)

# ╔═╡ 03bf1f42-9e19-11eb-3312-417824208fe9
md"""
Note that the symbol following `catch` will always be interpreted as a name for the exception, so care is needed when writing `try/catch` expressions on a single line. The following code will *not* work to return the value of `x` in case of an error:
"""

# ╔═╡ 03bf1f7e-9e19-11eb-2c86-61f23da7ee67
md"""
```julia
try bad() catch x end
```
"""

# ╔═╡ 03bf1f94-9e19-11eb-3a8c-27aa36b1d228
md"""
Instead, use a semicolon or insert a line break after `catch`:
"""

# ╔═╡ 03bf1fba-9e19-11eb-16ca-0fdf485a4255
md"""
```julia
try bad() catch; x end

try bad()
catch
    x
end
```
"""

# ╔═╡ 03bf1ff4-9e19-11eb-01f3-dfe5be6568b2
md"""
The power of the `try/catch` construct lies in the ability to unwind a deeply nested computation immediately to a much higher level in the stack of calling functions. There are situations where no error has occurred, but the ability to unwind the stack and pass a value to a higher level is desirable. Julia provides the [`rethrow`](@ref), [`backtrace`](@ref), [`catch_backtrace`](@ref) and [`Base.catch_stack`](@ref) functions for more advanced error handling.
"""

# ╔═╡ 03bf200a-9e19-11eb-0b4f-2d39c8167bfe
md"""
### `finally` Clauses
"""

# ╔═╡ 03bf2026-9e19-11eb-2d2f-657518c50996
md"""
In code that performs state changes or uses resources like files, there is typically clean-up work (such as closing files) that needs to be done when the code is finished. Exceptions potentially complicate this task, since they can cause a block of code to exit before reaching its normal end. The `finally` keyword provides a way to run some code when a given block of code exits, regardless of how it exits.
"""

# ╔═╡ 03bf2058-9e19-11eb-0a50-ed56e3175e04
md"""
For example, here is how we can guarantee that an opened file is closed:
"""

# ╔═╡ 03bf206e-9e19-11eb-13aa-a1d064de2fab
md"""
```julia
f = open("file")
try
    # operate on file f
finally
    close(f)
end
```
"""

# ╔═╡ 03bf20a0-9e19-11eb-31a3-b7de1b8d3cb4
md"""
When control leaves the `try` block (for example due to a `return`, or just finishing normally), `close(f)` will be executed. If the `try` block exits due to an exception, the exception will continue propagating. A `catch` block may be combined with `try` and `finally` as well. In this case the `finally` block will run after `catch` has handled the error.
"""

# ╔═╡ 03bf2122-9e19-11eb-00e8-3532a6e04b80
md"""
## [Tasks (aka Coroutines)](@id man-tasks)
"""

# ╔═╡ 03bf2154-9e19-11eb-2f7a-2761b5fb6d23
md"""
Tasks are a control flow feature that allows computations to be suspended and resumed in a flexible manner. We mention them here only for completeness; for a full discussion see [Asynchronous Programming](@ref man-asynchronous).
"""

# ╔═╡ Cell order:
# ╟─03be4ec8-9e19-11eb-324e-43b995c507f7
# ╟─03be4f04-9e19-11eb-296c-7daa5211e21f
# ╟─03be509e-9e19-11eb-1173-db0dd8cea10d
# ╟─03be50bc-9e19-11eb-08a9-0385258493b4
# ╟─03be50f8-9e19-11eb-1f4e-d1cfbc0ea97d
# ╟─03be5120-9e19-11eb-2c34-1b3d769f40a7
# ╠═03be55d0-9e19-11eb-35e3-2937ee486b28
# ╟─03be55f8-9e19-11eb-2917-a5ae56a4c0b7
# ╠═03be594a-9e19-11eb-0b4b-0faa65eab053
# ╟─03be5972-9e19-11eb-373e-e1113288f183
# ╠═03be5ee0-9e19-11eb-06ad-d14c12628e99
# ╠═03be5eea-9e19-11eb-3b9d-4da43c41fe58
# ╟─03be5f1c-9e19-11eb-3125-4f41ae7c14e0
# ╟─03be5f3a-9e19-11eb-3938-1d08fc3414ca
# ╟─03be5f76-9e19-11eb-021a-17b4012479cb
# ╟─03be5f9e-9e19-11eb-1ef6-09c7c130daa4
# ╠═03be68a4-9e19-11eb-3602-d73bb8a0532e
# ╠═03be68ae-9e19-11eb-389e-cbfa2db5d887
# ╠═03be68ae-9e19-11eb-069b-fd76d2d7dacb
# ╠═03be68ae-9e19-11eb-294c-716a9d44d30d
# ╟─03be68ea-9e19-11eb-3093-05669de4d5b1
# ╟─03be690a-9e19-11eb-3d87-bd2f456a4b44
# ╠═03be710a-9e19-11eb-131c-33b92c2105b6
# ╠═03be710a-9e19-11eb-341d-456fa2ea46c7
# ╟─03be713c-9e19-11eb-02c5-c1288284e146
# ╠═03be790c-9e19-11eb-3c98-77637cc6ff2f
# ╠═03be7914-9e19-11eb-0139-8b4b04e26bf3
# ╠═03be7914-9e19-11eb-3ca2-a7e521cbba47
# ╟─03be793e-9e19-11eb-0c55-336dd386a46b
# ╠═03be7c88-9e19-11eb-2cee-9dd00ecb38ce
# ╠═03be7c88-9e19-11eb-07f0-1d4846831885
# ╟─03be7c9a-9e19-11eb-28a9-11bd236d7926
# ╟─03be7ccc-9e19-11eb-011a-5368cc577712
# ╠═03be7eca-9e19-11eb-3bc8-79dfaf28e5ef
# ╟─03be7ee8-9e19-11eb-0eae-1396d456d165
# ╟─03be7f10-9e19-11eb-3ef3-f331ef7482b6
# ╟─03be7f2e-9e19-11eb-1b26-d125f9da180f
# ╟─03be7f60-9e19-11eb-07c7-cf2d0e879111
# ╟─03be7f7e-9e19-11eb-2da3-23fc49f3ee7b
# ╠═03be87bc-9e19-11eb-2fa8-47b06ab38a5b
# ╠═03be87bc-9e19-11eb-39c1-8718f079948e
# ╠═03be87c4-9e19-11eb-180b-5b931417e30a
# ╠═03be87c4-9e19-11eb-3d1f-6d02d4749bfe
# ╟─03be87f6-9e19-11eb-1d6d-2d5e55236338
# ╠═03be8efe-9e19-11eb-2589-713164409e1f
# ╠═03be8f0a-9e19-11eb-237b-77e9d41bdb88
# ╠═03be8f0a-9e19-11eb-2326-d382dc340f4d
# ╠═03be8f14-9e19-11eb-0363-119563585332
# ╟─03be8f3c-9e19-11eb-1dac-ab1c482be870
# ╟─03be8f5a-9e19-11eb-1311-d72cc8aa9f5a
# ╠═03be96e4-9e19-11eb-3c61-f96738ea4118
# ╠═03be96f8-9e19-11eb-301d-53b26eb54d12
# ╠═03be96f8-9e19-11eb-004f-298a2b2ae8ba
# ╟─03be970a-9e19-11eb-0036-a3fca3c12d27
# ╟─03be9752-9e19-11eb-0825-bb71f4358560
# ╟─03be977a-9e19-11eb-0cd4-d97393d907f5
# ╟─03be97e8-9e19-11eb-135a-abb9e5cdcb3e
# ╟─03be9812-9e19-11eb-11f9-29c184d72f64
# ╠═03bea650-9e19-11eb-3885-9964db78c559
# ╠═03bea650-9e19-11eb-3c35-65d88be2dcc4
# ╠═03bea65c-9e19-11eb-2aed-f336bb9c395f
# ╠═03bea65c-9e19-11eb-1b5e-41e772ed2672
# ╠═03bea666-9e19-11eb-1828-5b716ea1e812
# ╠═03bea67a-9e19-11eb-3732-6559ba0fac6c
# ╠═03bea67a-9e19-11eb-0991-5d420b2a87a4
# ╠═03bea684-9e19-11eb-2190-5758eab6c04f
# ╠═03bea684-9e19-11eb-1463-25ef6685f190
# ╠═03bea68e-9e19-11eb-3993-db135c072e62
# ╟─03bea6ac-9e19-11eb-05b0-bbe45bd46167
# ╟─03bea6d4-9e19-11eb-2ac5-49b89edd2aa5
# ╟─03bea6e8-9e19-11eb-3973-2943d818a323
# ╠═03beb002-9e19-11eb-2f37-a5639c7ef229
# ╠═03beb00c-9e19-11eb-393d-db827bd9f2db
# ╠═03beb00c-9e19-11eb-0d58-49e2ee2ed7c9
# ╠═03beb016-9e19-11eb-0f67-4383cd88d261
# ╟─03beb048-9e19-11eb-22d0-5fb5d0b2529a
# ╠═03beb2d2-9e19-11eb-26a0-d344c0c7b8ed
# ╠═03beb2dc-9e19-11eb-2160-ed8088550c52
# ╟─03beb2fa-9e19-11eb-22ee-dd6c9b98c754
# ╠═03beb3fc-9e19-11eb-1579-838007b3338a
# ╟─03beb426-9e19-11eb-1c97-819889a26bc2
# ╠═03beb840-9e19-11eb-0bf8-f76189632761
# ╠═03beb840-9e19-11eb-0682-edcc9ca4eea0
# ╟─03beb85e-9e19-11eb-01eb-41ca6c79bbf2
# ╟─03beb886-9e19-11eb-25b4-29fa3041f3e1
# ╠═03bebcb4-9e19-11eb-0199-15f084621d8f
# ╠═03bebcbe-9e19-11eb-0435-d96eddcbb0b8
# ╟─03bebcde-9e19-11eb-0f35-35a214b3f5ef
# ╟─03bebd04-9e19-11eb-307f-011647304b41
# ╠═03bebf48-9e19-11eb-10ab-cff5f9c56f36
# ╟─03bebf70-9e19-11eb-270c-99754ef7d11d
# ╠═03bec240-9e19-11eb-024c-a52c837f1727
# ╠═03bec24c-9e19-11eb-37be-e5b37f9a5cf1
# ╟─03bec25e-9e19-11eb-0e4a-cd77525c34b7
# ╟─03bec27e-9e19-11eb-39be-79fc23e6261b
# ╠═03bec808-9e19-11eb-254f-4783c5742faa
# ╠═03bec812-9e19-11eb-3508-79a09b0a15e3
# ╟─03bec830-9e19-11eb-0953-91f48ed76653
# ╟─03bec858-9e19-11eb-2725-79d8176647b7
# ╠═03bed154-9e19-11eb-3390-a7dd5dd2e9fd
# ╠═03bed154-9e19-11eb-32f8-5f4d82094d83
# ╠═03bed160-9e19-11eb-0a0c-ad7f30b0999d
# ╟─03bed186-9e19-11eb-2824-057529405bf5
# ╟─03bed1a4-9e19-11eb-162e-55cdc49f1a62
# ╠═03bed5ca-9e19-11eb-2139-87fdf9a9f4a2
# ╟─03bed5f0-9e19-11eb-0e4b-53115e5e198d
# ╟─03bed60e-9e19-11eb-14dc-b51da2044954
# ╠═03bed9c4-9e19-11eb-20a8-4fc48df8baf8
# ╟─03bed9ec-9e19-11eb-2e16-8b3cfb969cbc
# ╠═03bede92-9e19-11eb-13bb-d3942fe9cef4
# ╟─03beded8-9e19-11eb-2f55-91894ad15186
# ╟─03bedef6-9e19-11eb-1d3b-c7329d894faf
# ╠═03bee504-9e19-11eb-3378-cd973cd73cb8
# ╟─03bee568-9e19-11eb-0a63-8302679b8720
# ╟─03bee590-9e19-11eb-2afa-2330a14797ef
# ╟─03bee5a4-9e19-11eb-35c6-43740c6ae874
# ╟─03bee5ea-9e19-11eb-18e8-f9435d50d998
# ╟─03bee608-9e19-11eb-2bfd-75dad5d618a8
# ╟─03bee950-9e19-11eb-1424-11e3d68a11ff
# ╟─03bee976-9e19-11eb-0b2f-b302112ab96f
# ╠═03beeb44-9e19-11eb-24c6-919de6e04828
# ╟─03beeb76-9e19-11eb-1be3-374ef410cd20
# ╠═03beed10-9e19-11eb-14e4-9d8226c055f8
# ╟─03beed38-9e19-11eb-2f27-c74b75e4dd7d
# ╟─03beed7c-9e19-11eb-00f7-11697c722c11
# ╠═03bef420-9e19-11eb-27e2-bb3a181d5859
# ╠═03bef420-9e19-11eb-1c45-b77a97c5bd81
# ╠═03bef42c-9e19-11eb-1dde-0bd8e44ef15b
# ╟─03bef45e-9e19-11eb-053c-efa7f12ff01c
# ╠═03bef6fc-9e19-11eb-20a2-9f0b59ba4e2a
# ╠═03bef6fc-9e19-11eb-2ebc-5190214ac148
# ╟─03bef710-9e19-11eb-262d-e93a09c95cbb
# ╠═03bef88a-9e19-11eb-1266-9d7fb2a18f3a
# ╟─03bef8be-9e19-11eb-10cf-cbca098c0d38
# ╠═03befefc-9e19-11eb-3acc-6d3aefbffe93
# ╠═03beff08-9e19-11eb-1f49-6feca5f9da8c
# ╟─03bf0084-9e19-11eb-1b88-130d42185b69
# ╟─03bf00a2-9e19-11eb-1170-7b106ca5fd9c
# ╟─03bf00c8-9e19-11eb-18e8-156f8df2437c
# ╟─03bf00fc-9e19-11eb-3b02-63ff4c14c178
# ╠═03bf06ce-9e19-11eb-381b-237c5739b1b0
# ╠═03bf06da-9e19-11eb-299e-d5e3995f3482
# ╠═03bf06da-9e19-11eb-3125-492fcec94f41
# ╟─03bf070c-9e19-11eb-2579-51e5fa53dd35
# ╠═03bf0e26-9e19-11eb-14f6-6117ce92617e
# ╠═03bf0e30-9e19-11eb-089e-274472eb15ee
# ╠═03bf0e3a-9e19-11eb-229e-fdd7916bcfc3
# ╟─03bf0e58-9e19-11eb-2578-ab9756a4ae02
# ╟─03bf0e94-9e19-11eb-1b10-bbee01698567
# ╠═03bf11e8-9e19-11eb-208a-e9f2ca6f56a6
# ╟─03bf121a-9e19-11eb-1569-77cdee8e1d67
# ╠═03bf1eac-9e19-11eb-2c65-85f44c8a57fe
# ╠═03bf1eca-9e19-11eb-0748-197919f700f8
# ╠═03bf1ed4-9e19-11eb-0273-5143803b9b82
# ╠═03bf1ed4-9e19-11eb-29a1-331f27395fb0
# ╠═03bf1ede-9e19-11eb-15e2-4792f014f48a
# ╟─03bf1f42-9e19-11eb-3312-417824208fe9
# ╟─03bf1f7e-9e19-11eb-2c86-61f23da7ee67
# ╟─03bf1f94-9e19-11eb-3a8c-27aa36b1d228
# ╟─03bf1fba-9e19-11eb-16ca-0fdf485a4255
# ╟─03bf1ff4-9e19-11eb-01f3-dfe5be6568b2
# ╟─03bf200a-9e19-11eb-0b4f-2d39c8167bfe
# ╟─03bf2026-9e19-11eb-2d2f-657518c50996
# ╟─03bf2058-9e19-11eb-0a50-ed56e3175e04
# ╟─03bf206e-9e19-11eb-13aa-a1d064de2fab
# ╟─03bf20a0-9e19-11eb-31a3-b7de1b8d3cb4
# ╟─03bf2122-9e19-11eb-00e8-3532a6e04b80
# ╟─03bf2154-9e19-11eb-2f7a-2761b5fb6d23
