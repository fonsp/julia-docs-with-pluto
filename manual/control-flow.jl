### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ a7d98e32-04bf-4e74-b82e-0cb8eab7fbfc
md"""
# Control Flow
"""

# ╔═╡ 78a6faa3-275a-457e-8eb4-d102ae1bbfb8
md"""
Julia provides a variety of control flow constructs:
"""

# ╔═╡ fa004e24-e2bb-4c49-afb0-9ce49a21ffbd
md"""
  * [Compound Expressions](@ref man-compound-expressions): `begin` and `;`.
  * [Conditional Evaluation](@ref man-conditional-evaluation): `if`-`elseif`-`else` and `?:` (ternary operator).
  * [Short-Circuit Evaluation](@ref): logical operators `&&` (“and”) and `||` (“or”), and also chained comparisons.
  * [Repeated Evaluation: Loops](@ref man-loops): `while` and `for`.
  * [Exception Handling](@ref): `try`-`catch`, [`error`](@ref) and [`throw`](@ref).
  * [Tasks (aka Coroutines)](@ref man-tasks): [`yieldto`](@ref).
"""

# ╔═╡ 9ea31f8e-d83d-48ae-b4a2-f4aed7f6efbb
md"""
The first five control flow mechanisms are standard to high-level programming languages. [`Task`](@ref)s are not so standard: they provide non-local control flow, making it possible to switch between temporarily-suspended computations. This is a powerful construct: both exception handling and cooperative multitasking are implemented in Julia using tasks. Everyday programming requires no direct usage of tasks, but certain problems can be solved much more easily by using tasks.
"""

# ╔═╡ b945ac07-aec7-4b0b-8025-42e2064ab485
md"""
## [Compound Expressions](@id man-compound-expressions)
"""

# ╔═╡ 8b9984e6-461e-4abb-b92e-3a8e25a0f8d5
md"""
Sometimes it is convenient to have a single expression which evaluates several subexpressions in order, returning the value of the last subexpression as its value. There are two Julia constructs that accomplish this: `begin` blocks and `;` chains. The value of both compound expression constructs is that of the last subexpression. Here's an example of a `begin` block:
"""

# ╔═╡ 33780f5e-5561-427b-967f-7ee94f99d2ef
z = begin
     x = 1
     y = 2
     x + y
 end

# ╔═╡ 627cbd71-2361-49c5-873a-edaf17b28525
md"""
Since these are fairly small, simple expressions, they could easily be placed onto a single line, which is where the `;` chain syntax comes in handy:
"""

# ╔═╡ f4999dba-3763-4736-b7d5-aa713da800ac
z = (x = 1; y = 2; x + y)

# ╔═╡ 4a6e0aa4-77a4-46ff-bbb6-2b214b77a1b2
md"""
This syntax is particularly useful with the terse single-line function definition form introduced in [Functions](@ref man-functions). Although it is typical, there is no requirement that `begin` blocks be multiline or that `;` chains be single-line:
"""

# ╔═╡ f5c97765-4f48-45ab-9341-7aa63b87b374
begin x = 1; y = 2; x + y end

# ╔═╡ b56acada-8e9b-42d4-bb85-783acdc9716e
(x = 1;
  y = 2;
  x + y)

# ╔═╡ 8a83cbfd-66d9-424c-b266-875df8bc3f38
md"""
## [Conditional Evaluation](@id man-conditional-evaluation)
"""

# ╔═╡ 936b13ce-95e7-494d-83ba-ec4e409bc75f
md"""
Conditional evaluation allows portions of code to be evaluated or not evaluated depending on the value of a boolean expression. Here is the anatomy of the `if`-`elseif`-`else` conditional syntax:
"""

# ╔═╡ 629a60bc-8723-4ad6-843b-1b43e4643740
md"""
```julia
if x < y
    println(\"x is less than y\")
elseif x > y
    println(\"x is greater than y\")
else
    println(\"x is equal to y\")
end
```
"""

# ╔═╡ e501787f-467c-4984-80b3-2c58e148a1a9
md"""
If the condition expression `x < y` is `true`, then the corresponding block is evaluated; otherwise the condition expression `x > y` is evaluated, and if it is `true`, the corresponding block is evaluated; if neither expression is true, the `else` block is evaluated. Here it is in action:
"""

# ╔═╡ 9b0bb40a-50e8-43bb-a24c-af1eee99d531
function test(x, y)
     if x < y
         println("x is less than y")
     elseif x > y
         println("x is greater than y")
     else
         println("x is equal to y")
     end
 end

# ╔═╡ 3297d6c5-0ed4-43da-966e-628434df389b
test(1, 2)

# ╔═╡ b196a31d-d1c8-4105-a113-4b53edad362a
test(2, 1)

# ╔═╡ c076ffbe-6d0b-428f-819a-9775f67375ee
test(1, 1)

# ╔═╡ 317fa49a-42ee-477f-a9bd-6baf18f50560
md"""
The `elseif` and `else` blocks are optional, and as many `elseif` blocks as desired can be used. The condition expressions in the `if`-`elseif`-`else` construct are evaluated until the first one evaluates to `true`, after which the associated block is evaluated, and no further condition expressions or blocks are evaluated.
"""

# ╔═╡ f3c36f01-4591-4b4f-bd8e-97f7547b893f
md"""
`if` blocks are \"leaky\", i.e. they do not introduce a local scope. This means that new variables defined inside the `if` clauses can be used after the `if` block, even if they weren't defined before. So, we could have defined the `test` function above as
"""

# ╔═╡ d916ba39-8507-4ef5-829d-597ffbf54760
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

# ╔═╡ aef517b5-7e45-4912-83c4-5413f86e5709
test(2, 1)

# ╔═╡ 546ad464-4cb4-40dc-8cb5-6863c0074b0f
md"""
The variable `relation` is declared inside the `if` block, but used outside. However, when depending on this behavior, make sure all possible code paths define a value for the variable. The following change to the above function results in a runtime error
"""

# ╔═╡ 33e28ab3-b17d-49bb-9296-0799c76edf98
function test(x,y)
     if x < y
         relation = "less than"
     elseif x == y
         relation = "equal to"
     end
     println("x is ", relation, " y.")
 end

# ╔═╡ 00f60a01-dd1a-47a8-9ffb-e76cc0ef9dd6
test(1,2)

# ╔═╡ 82048e95-5f63-43eb-aa11-6c9971d1a097
test(2,1)

# ╔═╡ ad37fcb7-214a-49c3-baec-9c2177968bf7
md"""
`if` blocks also return a value, which may seem unintuitive to users coming from many other languages. This value is simply the return value of the last executed statement in the branch that was chosen, so
"""

# ╔═╡ 21fd2750-c600-42d8-acb9-ecf260f0f518
x = 3

# ╔═╡ 257203bc-9af9-4037-bf07-2ddec453f489
if x > 0
     "positive!"
 else
     "negative..."
 end

# ╔═╡ 4227d132-a775-404a-859c-59a1ddafe7d1
md"""
Note that very short conditional statements (one-liners) are frequently expressed using Short-Circuit Evaluation in Julia, as outlined in the next section.
"""

# ╔═╡ acdff3b2-fea7-4366-bad1-4f303acc94a0
md"""
Unlike C, MATLAB, Perl, Python, and Ruby – but like Java, and a few other stricter, typed languages – it is an error if the value of a conditional expression is anything but `true` or `false`:
"""

# ╔═╡ 7c819ca5-9705-4f40-bbce-faf3cdd969ba
if 1
     println("true")
 end

# ╔═╡ b63badc0-71ea-4251-bd59-073bc381a602
md"""
This error indicates that the conditional was of the wrong type: [`Int64`](@ref) rather than the required [`Bool`](@ref).
"""

# ╔═╡ 213a3f20-a869-4b59-baba-023344755c17
md"""
The so-called \"ternary operator\", `?:`, is closely related to the `if`-`elseif`-`else` syntax, but is used where a conditional choice between single expression values is required, as opposed to conditional execution of longer blocks of code. It gets its name from being the only operator in most languages taking three operands:
"""

# ╔═╡ 71e66d90-9c72-448d-8dc4-1308043b24a9
md"""
```julia
a ? b : c
```
"""

# ╔═╡ a306b129-54ca-4c3b-a74f-663c608f3513
md"""
The expression `a`, before the `?`, is a condition expression, and the ternary operation evaluates the expression `b`, before the `:`, if the condition `a` is `true` or the expression `c`, after the `:`, if it is `false`. Note that the spaces around `?` and `:` are mandatory: an expression like `a?b:c` is not a valid ternary expression (but a newline is acceptable after both the `?` and the `:`).
"""

# ╔═╡ 27672e73-5d46-4a70-85f3-16466bdfabfc
md"""
The easiest way to understand this behavior is to see an example. In the previous example, the `println` call is shared by all three branches: the only real choice is which literal string to print. This could be written more concisely using the ternary operator. For the sake of clarity, let's try a two-way version first:
"""

# ╔═╡ 52ae2c7b-5938-46c3-a105-815fe8b96f1f
x = 1; y = 2;

# ╔═╡ 7a99be10-7b59-47ca-898f-8c18349dd568
println(x < y ? "less than" : "not less than")

# ╔═╡ 9ba610ea-5d19-44d1-a735-2f2e22d5d59f
x = 1; y = 0;

# ╔═╡ 91a86c36-b6ac-4e8a-ac40-4b20d436cd97
println(x < y ? "less than" : "not less than")

# ╔═╡ 1fa81fb0-7ca3-418e-8605-8a38d8bddc33
md"""
If the expression `x < y` is true, the entire ternary operator expression evaluates to the string `\"less than\"` and otherwise it evaluates to the string `\"not less than\"`. The original three-way example requires chaining multiple uses of the ternary operator together:
"""

# ╔═╡ ae246d44-0934-4d4c-accb-d0af834f61fb
test(x, y) = println(x < y ? "x is less than y"    :
                      x > y ? "x is greater than y" : "x is equal to y")

# ╔═╡ 2fd9cdc0-050b-4459-8864-5a16396f3bf2
test(1, 2)

# ╔═╡ a2a55819-9d9d-4cec-9364-0986b9eb53af
test(2, 1)

# ╔═╡ ad757a3c-c92f-48ed-bb6a-7a53e80e05df
test(1, 1)

# ╔═╡ b303cec9-4fd2-46b5-a69d-d61efa848a02
md"""
To facilitate chaining, the operator associates from right to left.
"""

# ╔═╡ 51b4813e-f8f6-4a52-88d2-fb0998132585
md"""
It is significant that like `if`-`elseif`-`else`, the expressions before and after the `:` are only evaluated if the condition expression evaluates to `true` or `false`, respectively:
"""

# ╔═╡ 4f3b93e0-7e92-4956-9d12-12cfd9c5f13f
v(x) = (println(x); x)

# ╔═╡ 312cdd07-6c03-4e58-a693-564b49acffdc
1 < 2 ? v("yes") : v("no")

# ╔═╡ a60d02de-f511-430f-a010-d40844c08075
1 > 2 ? v("yes") : v("no")

# ╔═╡ 446d7be3-aa1f-4bb6-87cf-331192121198
md"""
## Short-Circuit Evaluation
"""

# ╔═╡ 3005698f-45ad-423d-9386-ebeebecd733a
md"""
The `&&` and `||` operators in Julia correspond to logical “and” and “or” operations, respectively, and are typically used for this purpose.  However, they have an additional property of *short-circuit* evaluation: they don't necessarily evaluate their second argument, as explained below.  (There are also bitwise `&` and `|` operators that can be used as logical “and” and “or” *without* short-circuit behavior, but beware that `&` and `|` have higher precedence than `&&` and `||` for evaluation order.)
"""

# ╔═╡ a3d46375-82e2-4460-a4ed-34c5b555eb55
md"""
Short-circuit evaluation is quite similar to conditional evaluation. The behavior is found in most imperative programming languages having the `&&` and `||` boolean operators: in a series of boolean expressions connected by these operators, only the minimum number of expressions are evaluated as are necessary to determine the final boolean value of the entire chain. Explicitly, this means that:
"""

# ╔═╡ 48f34685-7569-4c1c-93c4-782981484de2
md"""
  * In the expression `a && b`, the subexpression `b` is only evaluated if `a` evaluates to `true`.
  * In the expression `a || b`, the subexpression `b` is only evaluated if `a` evaluates to `false`.
"""

# ╔═╡ 34b777ad-1044-43e7-b2eb-310a47f62c99
md"""
The reasoning is that `a && b` must be `false` if `a` is `false`, regardless of the value of `b`, and likewise, the value of `a || b` must be true if `a` is `true`, regardless of the value of `b`. Both `&&` and `||` associate to the right, but `&&` has higher precedence than `||` does. It's easy to experiment with this behavior:
"""

# ╔═╡ 2bf8e09b-7f36-4864-b159-ea185f15c6dd
t(x) = (println(x); true)

# ╔═╡ ed8991a7-fcfe-47e7-a3b4-735a4d053dce
f(x) = (println(x); false)

# ╔═╡ f660e6f0-83b4-4ae0-b79c-fc922a2a8db9
t(1) && t(2)

# ╔═╡ d6b6bb4c-28ae-41cc-b62a-4a75f2ef405b
t(1) && f(2)

# ╔═╡ cd20a9c2-60aa-4367-b26b-5d28e76b5772
f(1) && t(2)

# ╔═╡ 1e14a190-d160-465d-97ed-598e1462d296
f(1) && f(2)

# ╔═╡ e95f322a-a330-4062-806b-58d412629772
t(1) || t(2)

# ╔═╡ 70bf2bc8-1361-4138-96b5-9f3a806c93a6
t(1) || f(2)

# ╔═╡ 9088b204-7fce-433b-bf4f-4bdb758c83e4
f(1) || t(2)

# ╔═╡ 7bed0b0c-01c7-450f-adfa-ce21ef472cc4
f(1) || f(2)

# ╔═╡ 7e6fde03-44e5-4654-bf1f-197b1de50215
md"""
You can easily experiment in the same way with the associativity and precedence of various combinations of `&&` and `||` operators.
"""

# ╔═╡ 04e31617-0999-45ac-8fa2-a163e7cae48e
md"""
This behavior is frequently used in Julia to form an alternative to very short `if` statements. Instead of `if <cond> <statement> end`, one can write `<cond> && <statement>` (which could be read as: <cond> *and then* <statement>). Similarly, instead of `if ! <cond> <statement> end`, one can write `<cond> || <statement>` (which could be read as: <cond> *or else* <statement>).
"""

# ╔═╡ 666fe368-2ca1-4ff5-bdde-2f0545167316
md"""
For example, a recursive factorial routine could be defined like this:
"""

# ╔═╡ df4d8c09-1bdc-4eb7-9f33-40f1ffd88976
function fact(n::Int)
     n >= 0 || error("n must be non-negative")
     n == 0 && return 1
     n * fact(n-1)
 end

# ╔═╡ 2aab81dc-fd51-4ccb-91d9-832f7e10a21d
fact(5)

# ╔═╡ adf6e465-bfe3-493c-b1a5-f0f223155bb0
fact(0)

# ╔═╡ 0c64ff78-1608-45fc-bc60-493ccc5a5d37
fact(-1)

# ╔═╡ a12746a5-8134-46d9-9986-48c92dba3047
md"""
Boolean operations *without* short-circuit evaluation can be done with the bitwise boolean operators introduced in [Mathematical Operations and Elementary Functions](@ref): `&` and `|`. These are normal functions, which happen to support infix operator syntax, but always evaluate their arguments:
"""

# ╔═╡ 57786aab-9c1f-4813-bdc4-d0376cd07d91
f(1) & t(2)

# ╔═╡ e54c77de-1cf9-47f0-9d12-278929091fee
t(1) | t(2)

# ╔═╡ b009d01e-29ba-4636-a2b5-f4e01c6dbf24
md"""
Just like condition expressions used in `if`, `elseif` or the ternary operator, the operands of `&&` or `||` must be boolean values (`true` or `false`). Using a non-boolean value anywhere except for the last entry in a conditional chain is an error:
"""

# ╔═╡ cbfc3b44-53ad-44b8-9a0d-9b4a641b4bb4
1 && true

# ╔═╡ cf91fc76-41c7-4492-9a24-ad4704c5e12d
md"""
On the other hand, any type of expression can be used at the end of a conditional chain. It will be evaluated and returned depending on the preceding conditionals:
"""

# ╔═╡ 7706598d-cbae-4570-bd67-0bf83fe2ca65
true && (x = (1, 2, 3))

# ╔═╡ 1ea75568-fa1e-4ebd-8b32-1f7a2c687fa6
false && (x = (1, 2, 3))

# ╔═╡ 9e00e7a3-55a7-4709-9ea0-cedc29e26ce0
md"""
## [Repeated Evaluation: Loops](@id man-loops)
"""

# ╔═╡ f6eea02f-4d43-41b0-9be8-731d172d35db
md"""
There are two constructs for repeated evaluation of expressions: the `while` loop and the `for` loop. Here is an example of a `while` loop:
"""

# ╔═╡ 294b6109-153f-4770-bb62-bf208e701e09
i = 1;

# ╔═╡ 0a0dbb7f-c7d5-4e2f-ad84-767bc1b50439
while i <= 5
     println(i)
     global i += 1
 end

# ╔═╡ dcd3f929-e80b-4382-bf1f-9ca9a9038079
md"""
The `while` loop evaluates the condition expression (`i <= 5` in this case), and as long it remains `true`, keeps also evaluating the body of the `while` loop. If the condition expression is `false` when the `while` loop is first reached, the body is never evaluated.
"""

# ╔═╡ c79a8b8f-9059-45ee-9693-c44025a4987a
md"""
The `for` loop makes common repeated evaluation idioms easier to write. Since counting up and down like the above `while` loop does is so common, it can be expressed more concisely with a `for` loop:
"""

# ╔═╡ 47bf6e08-fecd-401e-a7f3-2736e04b08a3
for i = 1:5
     println(i)
 end

# ╔═╡ e2795429-13e6-49a4-88db-af7771eb713b
md"""
Here the `1:5` is a range object, representing the sequence of numbers 1, 2, 3, 4, 5. The `for` loop iterates through these values, assigning each one in turn to the variable `i`. One rather important distinction between the previous `while` loop form and the `for` loop form is the scope during which the variable is visible. If the variable `i` has not been introduced in another scope, in the `for` loop form, it is visible only inside of the `for` loop, and not outside/afterwards. You'll either need a new interactive session instance or a different variable name to test this:
"""

# ╔═╡ b33b7f9b-90bb-4781-8207-2e08984a8582
for j = 1:5
     println(j)
 end

# ╔═╡ 803c27af-b9aa-46f2-9b1b-b8da50114279
j

# ╔═╡ 9f238ae3-187c-4344-a822-1426207769fa
md"""
See [Scope of Variables](@ref scope-of-variables) for a detailed explanation of variable scope and how it works in Julia.
"""

# ╔═╡ 9d0207f0-d4ad-40d3-b673-591d22055098
md"""
In general, the `for` loop construct can iterate over any container. In these cases, the alternative (but fully equivalent) keyword `in` or `∈` is typically used instead of `=`, since it makes the code read more clearly:
"""

# ╔═╡ 84f61f6d-f979-4958-985a-0bd5b19a5c0d
for i in [1,4,0]
     println(i)
 end

# ╔═╡ 0e5df6e1-14ea-44e7-8c1f-6721da772ce8
for s ∈ ["foo","bar","baz"]
     println(s)
 end

# ╔═╡ fad51bcf-2a5e-48e8-af2b-f7037880331c
md"""
Various types of iterable containers will be introduced and discussed in later sections of the manual (see, e.g., [Multi-dimensional Arrays](@ref man-multi-dim-arrays)).
"""

# ╔═╡ 6e34006e-d77d-468d-aeeb-9a726f0fcd2c
md"""
It is sometimes convenient to terminate the repetition of a `while` before the test condition is falsified or stop iterating in a `for` loop before the end of the iterable object is reached. This can be accomplished with the `break` keyword:
"""

# ╔═╡ 78f57b3b-71ed-4800-9982-f3df39b2b531
i = 1;

# ╔═╡ 2a9524b4-b2c5-4983-8c1b-c552e05ed910
while true
     println(i)
     if i >= 5
         break
     end
     global i += 1
 end

# ╔═╡ 471b1e6f-4643-4b65-8f83-b2f5b25fb74d
for j = 1:1000
     println(j)
     if j >= 5
         break
     end
 end

# ╔═╡ 745f3283-8077-4652-9d71-bbe071b1d750
md"""
Without the `break` keyword, the above `while` loop would never terminate on its own, and the `for` loop would iterate up to 1000. These loops are both exited early by using `break`.
"""

# ╔═╡ c8c0a6c4-1095-4261-9f74-f93ac2997775
md"""
In other circumstances, it is handy to be able to stop an iteration and move on to the next one immediately. The `continue` keyword accomplishes this:
"""

# ╔═╡ 586ca0bd-56d5-4dc7-b6ba-5b3e41181cdf
for i = 1:10
     if i % 3 != 0
         continue
     end
     println(i)
 end

# ╔═╡ f68a927e-494f-491d-9259-bb8e3aca1a85
md"""
This is a somewhat contrived example since we could produce the same behavior more clearly by negating the condition and placing the `println` call inside the `if` block. In realistic usage there is more code to be evaluated after the `continue`, and often there are multiple points from which one calls `continue`.
"""

# ╔═╡ 7043e62f-d333-4946-b2a1-532691ca3daa
md"""
Multiple nested `for` loops can be combined into a single outer loop, forming the cartesian product of its iterables:
"""

# ╔═╡ 637d0d33-06cb-409e-9364-8ed6d7f62f4b
for i = 1:2, j = 3:4
     println((i, j))
 end

# ╔═╡ 8c195b79-b4e0-4eb9-ae4b-9f14742eeae7
md"""
With this syntax, iterables may still refer to outer loop variables; e.g. `for i = 1:n, j = 1:i` is valid. However a `break` statement inside such a loop exits the entire nest of loops, not just the inner one. Both variables (`i` and `j`) are set to their current iteration values each time the inner loop runs. Therefore, assignments to `i` will not be visible to subsequent iterations:
"""

# ╔═╡ 4ee5caa1-47d5-473b-a909-4a9627a6d79b
for i = 1:2, j = 3:4
     println((i, j))
     i = 0
 end

# ╔═╡ a0cf4b98-0b05-417e-a82b-50ee37922602
md"""
If this example were rewritten to use a `for` keyword for each variable, then the output would be different: the second and fourth values would contain `0`.
"""

# ╔═╡ 43cc0447-7c7d-4f9b-93b8-3352e98d5ac2
md"""
Multiple containers can be iterated over at the same time in a single `for` loop using [`zip`](@ref):
"""

# ╔═╡ 0fabb21c-31e6-4980-b0bf-8c28d9e092d1
for (j, k) in zip([1 2 3], [4 5 6 7])
     println((j,k))
 end

# ╔═╡ 9dbb2d7a-b4b8-447d-ab4e-e1bab3ba7c4a
md"""
Using [`zip`](@ref) will create an iterator that is a tuple containing the subiterators for the containers passed to it. The `zip` iterator will iterate over all subiterators in order, choosing the $i$th element of each subiterator in the $i$th iteration of the `for` loop. Once any of the subiterators run out, the `for` loop will stop.
"""

# ╔═╡ 394c4724-42b5-429e-8ad7-dd7c742e0029
md"""
## Exception Handling
"""

# ╔═╡ a1248530-2c77-4562-b8f3-545d498982b1
md"""
When an unexpected condition occurs, a function may be unable to return a reasonable value to its caller. In such cases, it may be best for the exceptional condition to either terminate the program while printing a diagnostic error message, or if the programmer has provided code to handle such exceptional circumstances then allow that code to take the appropriate action.
"""

# ╔═╡ 72b37a4b-8600-4b1b-a617-d359dee3b3b1
md"""
### Built-in `Exception`s
"""

# ╔═╡ 3b7b6e8a-4bd8-49a8-b89f-2ef4ccfe5d04
md"""
`Exception`s are thrown when an unexpected condition has occurred. The built-in `Exception`s listed below all interrupt the normal flow of control.
"""

# ╔═╡ 754ce083-54a9-4444-9131-cd5b07fe8e04
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

# ╔═╡ ad7592bf-1759-461a-b812-c190a9a2332b
md"""
For example, the [`sqrt`](@ref) function throws a [`DomainError`](@ref) if applied to a negative real value:
"""

# ╔═╡ 12b897e1-f235-4306-8d92-8bb2951b0365
sqrt(-1)

# ╔═╡ 4b4992b1-b40b-4256-b0a2-72f5f31385c1
md"""
You may define your own exceptions in the following way:
"""

# ╔═╡ 0351318f-a7ec-4824-ae86-f8656128c8aa
struct MyCustomException <: Exception end

# ╔═╡ 7821bac3-6045-4afa-83c5-2aff4b6b05ed
md"""
### The [`throw`](@ref) function
"""

# ╔═╡ 96080928-ae3c-4393-8a41-26d2bbc66795
md"""
Exceptions can be created explicitly with [`throw`](@ref). For example, a function defined only for nonnegative numbers could be written to [`throw`](@ref) a [`DomainError`](@ref) if the argument is negative:
"""

# ╔═╡ e988003b-ad4b-4069-8849-599730bc0567
f(x) = x>=0 ? exp(-x) : throw(DomainError(x, "argument must be nonnegative"))

# ╔═╡ 8dd669ac-01f6-4e1b-bc0a-74841ebdd9b1
f(1)

# ╔═╡ c1884994-c631-4d15-9d6e-74571c51d677
f(-1)

# ╔═╡ 67f452f6-4ae1-4952-934f-575576d5cfac
md"""
Note that [`DomainError`](@ref) without parentheses is not an exception, but a type of exception. It needs to be called to obtain an `Exception` object:
"""

# ╔═╡ 481f0907-1955-4011-a0bc-1bcd7b00ebc6
typeof(DomainError(nothing)) <: Exception

# ╔═╡ 0f8df86e-970f-4d6a-9894-ae10bfeef93b
typeof(DomainError) <: Exception

# ╔═╡ 3dd3bb6c-f586-45f1-ae9f-74662416bdd1
md"""
Additionally, some exception types take one or more arguments that are used for error reporting:
"""

# ╔═╡ 5c4b06c1-26d5-42e9-be84-79de54ea14e3
throw(UndefVarError(:x))

# ╔═╡ ef3518a3-596a-44a5-b83a-ed824c037cf1
md"""
This mechanism can be implemented easily by custom exception types following the way [`UndefVarError`](@ref) is written:
"""

# ╔═╡ 30ab54fb-9437-4e98-bd0b-9ac379deec90
struct MyUndefVarError <: Exception
     var::Symbol
 end

# ╔═╡ f38a4543-5893-43e9-87d3-af93398fde83
Base.showerror(io::IO, e::MyUndefVarError) = print(io, e.var, " not defined")

# ╔═╡ e1a6ca64-a588-40f4-a8ed-63c803528882
md"""
!!! note
    When writing an error message, it is preferred to make the first word lowercase. For example,

    `size(A) == size(B) || throw(DimensionMismatch(\"size of A not equal to size of B\"))`

    is preferred over

    `size(A) == size(B) || throw(DimensionMismatch(\"Size of A not equal to size of B\"))`.

    However, sometimes it makes sense to keep the uppercase first letter, for instance if an argument to a function is a capital letter:

    `size(A,1) == size(B,2) || throw(DimensionMismatch(\"A has first dimension...\"))`.
"""

# ╔═╡ 2b168394-8ad9-42eb-bd0c-31710d762171
md"""
### Errors
"""

# ╔═╡ c99b3445-19f2-443b-8e28-80df416d1de2
md"""
The [`error`](@ref) function is used to produce an [`ErrorException`](@ref) that interrupts the normal flow of control.
"""

# ╔═╡ 5ea09765-b297-47a2-8b2a-c1a4c7483e1c
md"""
Suppose we want to stop execution immediately if the square root of a negative number is taken. To do this, we can define a fussy version of the [`sqrt`](@ref) function that raises an error if its argument is negative:
"""

# ╔═╡ cc846b09-8ca8-436f-8158-bbd95976e155
fussy_sqrt(x) = x >= 0 ? sqrt(x) : error("negative x not allowed")

# ╔═╡ 80c4a4bf-6ec2-41af-bda8-9accf6d11948
fussy_sqrt(2)

# ╔═╡ e7d64867-6cd9-4117-8906-ab00f90d5ce6
fussy_sqrt(-1)

# ╔═╡ a4c13426-84fe-4edf-8e84-f8af90d4a668
md"""
If `fussy_sqrt` is called with a negative value from another function, instead of trying to continue execution of the calling function, it returns immediately, displaying the error message in the interactive session:
"""

# ╔═╡ 5e7eaa5f-9d8a-433f-82cc-464d7b37e58a
function verbose_fussy_sqrt(x)
     println("before fussy_sqrt")
     r = fussy_sqrt(x)
     println("after fussy_sqrt")
     return r
 end

# ╔═╡ d7c44390-b6a5-4650-8020-576cfc85def9
verbose_fussy_sqrt(2)

# ╔═╡ 496daa9e-3d44-4971-a160-ec7307efa475
verbose_fussy_sqrt(-1)

# ╔═╡ 25db8aa9-e686-4605-8fc4-4ee65013304e
md"""
### The `try/catch` statement
"""

# ╔═╡ fceb1a04-4dd5-4386-91ff-c516ca92a42a
md"""
The `try/catch` statement allows for `Exception`s to be tested for, and for the graceful handling of things that may ordinarily break your application. For example, in the below code the function for square root would normally throw an exception. By placing a `try/catch` block around it we can mitigate that here. You may choose how you wish to handle this exception, whether logging it, return a placeholder value or as in the case below where we just printed out a statement. One thing to think about when deciding how to handle unexpected situations is that using a `try/catch` block is much slower than using conditional branching to handle those situations. Below there are more examples of handling exceptions with a `try/catch` block:
"""

# ╔═╡ 516c067d-24ab-4e47-89ef-560d2a92143f
try
     sqrt("ten")
 catch e
     println("You should have entered a numeric value")
 end

# ╔═╡ f6c82245-8c4e-4a39-ba23-6c2b3ad0a53c
md"""
`try/catch` statements also allow the `Exception` to be saved in a variable. The following contrived example calculates the square root of the second element of `x` if `x` is indexable, otherwise assumes `x` is a real number and returns its square root:
"""

# ╔═╡ a474e616-1eed-4c43-9ec9-e82d4854b5df
sqrt_second(x) = try
     sqrt(x[2])
 catch y
     if isa(y, DomainError)
         sqrt(complex(x[2], 0))
     elseif isa(y, BoundsError)
         sqrt(x)
     end
 end

# ╔═╡ 96cb110e-83d6-407f-b786-51101f8a3bdc
sqrt_second([1 4])

# ╔═╡ dd518e45-5f62-4053-a020-ce7d5a2e8481
sqrt_second([1 -4])

# ╔═╡ 005d58b4-e6ab-48d0-b805-e1c2a410052a
sqrt_second(9)

# ╔═╡ 0a179c03-497c-4982-bfb6-56525cedab2d
sqrt_second(-9)

# ╔═╡ c3bd3386-be7e-4665-8329-0f26bea2d6af
md"""
Note that the symbol following `catch` will always be interpreted as a name for the exception, so care is needed when writing `try/catch` expressions on a single line. The following code will *not* work to return the value of `x` in case of an error:
"""

# ╔═╡ a9bba7e3-7ba6-40e3-a5ae-1b5d33d30ec1
md"""
```julia
try bad() catch x end
```
"""

# ╔═╡ 1335d197-ac60-4c2d-8c82-c35b1239042d
md"""
Instead, use a semicolon or insert a line break after `catch`:
"""

# ╔═╡ 9a202442-5cca-4ad9-bb92-30357ea9673f
md"""
```julia
try bad() catch; x end

try bad()
catch
    x
end
```
"""

# ╔═╡ d670e43b-99a6-4c4a-af3c-3c51a9e7333a
md"""
The power of the `try/catch` construct lies in the ability to unwind a deeply nested computation immediately to a much higher level in the stack of calling functions. There are situations where no error has occurred, but the ability to unwind the stack and pass a value to a higher level is desirable. Julia provides the [`rethrow`](@ref), [`backtrace`](@ref), [`catch_backtrace`](@ref) and [`Base.catch_stack`](@ref) functions for more advanced error handling.
"""

# ╔═╡ b966367f-2a46-4ed8-9257-9a57eb719e86
md"""
### `finally` Clauses
"""

# ╔═╡ a5fff3cb-eb42-4add-9725-e9687ab9cd39
md"""
In code that performs state changes or uses resources like files, there is typically clean-up work (such as closing files) that needs to be done when the code is finished. Exceptions potentially complicate this task, since they can cause a block of code to exit before reaching its normal end. The `finally` keyword provides a way to run some code when a given block of code exits, regardless of how it exits.
"""

# ╔═╡ c38c6288-bb52-4449-9d8f-59bae06d7ac5
md"""
For example, here is how we can guarantee that an opened file is closed:
"""

# ╔═╡ d4790dd0-a6dc-40c1-956d-1f4e2303cf48
md"""
```julia
f = open(\"file\")
try
    # operate on file f
finally
    close(f)
end
```
"""

# ╔═╡ 1afcbca0-cc55-461e-ade6-06a821e81b06
md"""
When control leaves the `try` block (for example due to a `return`, or just finishing normally), `close(f)` will be executed. If the `try` block exits due to an exception, the exception will continue propagating. A `catch` block may be combined with `try` and `finally` as well. In this case the `finally` block will run after `catch` has handled the error.
"""

# ╔═╡ 1105627b-be04-4c93-bee6-f887c4952b11
md"""
## [Tasks (aka Coroutines)](@id man-tasks)
"""

# ╔═╡ 787787db-1510-4913-8d7c-f31ac26447a8
md"""
Tasks are a control flow feature that allows computations to be suspended and resumed in a flexible manner. We mention them here only for completeness; for a full discussion see [Asynchronous Programming](@ref man-asynchronous).
"""

# ╔═╡ Cell order:
# ╟─a7d98e32-04bf-4e74-b82e-0cb8eab7fbfc
# ╟─78a6faa3-275a-457e-8eb4-d102ae1bbfb8
# ╟─fa004e24-e2bb-4c49-afb0-9ce49a21ffbd
# ╟─9ea31f8e-d83d-48ae-b4a2-f4aed7f6efbb
# ╟─b945ac07-aec7-4b0b-8025-42e2064ab485
# ╟─8b9984e6-461e-4abb-b92e-3a8e25a0f8d5
# ╠═33780f5e-5561-427b-967f-7ee94f99d2ef
# ╟─627cbd71-2361-49c5-873a-edaf17b28525
# ╠═f4999dba-3763-4736-b7d5-aa713da800ac
# ╟─4a6e0aa4-77a4-46ff-bbb6-2b214b77a1b2
# ╠═f5c97765-4f48-45ab-9341-7aa63b87b374
# ╠═b56acada-8e9b-42d4-bb85-783acdc9716e
# ╟─8a83cbfd-66d9-424c-b266-875df8bc3f38
# ╟─936b13ce-95e7-494d-83ba-ec4e409bc75f
# ╟─629a60bc-8723-4ad6-843b-1b43e4643740
# ╟─e501787f-467c-4984-80b3-2c58e148a1a9
# ╠═9b0bb40a-50e8-43bb-a24c-af1eee99d531
# ╠═3297d6c5-0ed4-43da-966e-628434df389b
# ╠═b196a31d-d1c8-4105-a113-4b53edad362a
# ╠═c076ffbe-6d0b-428f-819a-9775f67375ee
# ╟─317fa49a-42ee-477f-a9bd-6baf18f50560
# ╟─f3c36f01-4591-4b4f-bd8e-97f7547b893f
# ╠═d916ba39-8507-4ef5-829d-597ffbf54760
# ╠═aef517b5-7e45-4912-83c4-5413f86e5709
# ╟─546ad464-4cb4-40dc-8cb5-6863c0074b0f
# ╠═33e28ab3-b17d-49bb-9296-0799c76edf98
# ╠═00f60a01-dd1a-47a8-9ffb-e76cc0ef9dd6
# ╠═82048e95-5f63-43eb-aa11-6c9971d1a097
# ╟─ad37fcb7-214a-49c3-baec-9c2177968bf7
# ╠═21fd2750-c600-42d8-acb9-ecf260f0f518
# ╠═257203bc-9af9-4037-bf07-2ddec453f489
# ╟─4227d132-a775-404a-859c-59a1ddafe7d1
# ╟─acdff3b2-fea7-4366-bad1-4f303acc94a0
# ╠═7c819ca5-9705-4f40-bbce-faf3cdd969ba
# ╟─b63badc0-71ea-4251-bd59-073bc381a602
# ╟─213a3f20-a869-4b59-baba-023344755c17
# ╟─71e66d90-9c72-448d-8dc4-1308043b24a9
# ╟─a306b129-54ca-4c3b-a74f-663c608f3513
# ╟─27672e73-5d46-4a70-85f3-16466bdfabfc
# ╠═52ae2c7b-5938-46c3-a105-815fe8b96f1f
# ╠═7a99be10-7b59-47ca-898f-8c18349dd568
# ╠═9ba610ea-5d19-44d1-a735-2f2e22d5d59f
# ╠═91a86c36-b6ac-4e8a-ac40-4b20d436cd97
# ╟─1fa81fb0-7ca3-418e-8605-8a38d8bddc33
# ╠═ae246d44-0934-4d4c-accb-d0af834f61fb
# ╠═2fd9cdc0-050b-4459-8864-5a16396f3bf2
# ╠═a2a55819-9d9d-4cec-9364-0986b9eb53af
# ╠═ad757a3c-c92f-48ed-bb6a-7a53e80e05df
# ╟─b303cec9-4fd2-46b5-a69d-d61efa848a02
# ╟─51b4813e-f8f6-4a52-88d2-fb0998132585
# ╠═4f3b93e0-7e92-4956-9d12-12cfd9c5f13f
# ╠═312cdd07-6c03-4e58-a693-564b49acffdc
# ╠═a60d02de-f511-430f-a010-d40844c08075
# ╟─446d7be3-aa1f-4bb6-87cf-331192121198
# ╟─3005698f-45ad-423d-9386-ebeebecd733a
# ╟─a3d46375-82e2-4460-a4ed-34c5b555eb55
# ╟─48f34685-7569-4c1c-93c4-782981484de2
# ╟─34b777ad-1044-43e7-b2eb-310a47f62c99
# ╠═2bf8e09b-7f36-4864-b159-ea185f15c6dd
# ╠═ed8991a7-fcfe-47e7-a3b4-735a4d053dce
# ╠═f660e6f0-83b4-4ae0-b79c-fc922a2a8db9
# ╠═d6b6bb4c-28ae-41cc-b62a-4a75f2ef405b
# ╠═cd20a9c2-60aa-4367-b26b-5d28e76b5772
# ╠═1e14a190-d160-465d-97ed-598e1462d296
# ╠═e95f322a-a330-4062-806b-58d412629772
# ╠═70bf2bc8-1361-4138-96b5-9f3a806c93a6
# ╠═9088b204-7fce-433b-bf4f-4bdb758c83e4
# ╠═7bed0b0c-01c7-450f-adfa-ce21ef472cc4
# ╟─7e6fde03-44e5-4654-bf1f-197b1de50215
# ╟─04e31617-0999-45ac-8fa2-a163e7cae48e
# ╟─666fe368-2ca1-4ff5-bdde-2f0545167316
# ╠═df4d8c09-1bdc-4eb7-9f33-40f1ffd88976
# ╠═2aab81dc-fd51-4ccb-91d9-832f7e10a21d
# ╠═adf6e465-bfe3-493c-b1a5-f0f223155bb0
# ╠═0c64ff78-1608-45fc-bc60-493ccc5a5d37
# ╟─a12746a5-8134-46d9-9986-48c92dba3047
# ╠═57786aab-9c1f-4813-bdc4-d0376cd07d91
# ╠═e54c77de-1cf9-47f0-9d12-278929091fee
# ╟─b009d01e-29ba-4636-a2b5-f4e01c6dbf24
# ╠═cbfc3b44-53ad-44b8-9a0d-9b4a641b4bb4
# ╟─cf91fc76-41c7-4492-9a24-ad4704c5e12d
# ╠═7706598d-cbae-4570-bd67-0bf83fe2ca65
# ╠═1ea75568-fa1e-4ebd-8b32-1f7a2c687fa6
# ╟─9e00e7a3-55a7-4709-9ea0-cedc29e26ce0
# ╟─f6eea02f-4d43-41b0-9be8-731d172d35db
# ╠═294b6109-153f-4770-bb62-bf208e701e09
# ╠═0a0dbb7f-c7d5-4e2f-ad84-767bc1b50439
# ╟─dcd3f929-e80b-4382-bf1f-9ca9a9038079
# ╟─c79a8b8f-9059-45ee-9693-c44025a4987a
# ╠═47bf6e08-fecd-401e-a7f3-2736e04b08a3
# ╟─e2795429-13e6-49a4-88db-af7771eb713b
# ╠═b33b7f9b-90bb-4781-8207-2e08984a8582
# ╠═803c27af-b9aa-46f2-9b1b-b8da50114279
# ╟─9f238ae3-187c-4344-a822-1426207769fa
# ╟─9d0207f0-d4ad-40d3-b673-591d22055098
# ╠═84f61f6d-f979-4958-985a-0bd5b19a5c0d
# ╠═0e5df6e1-14ea-44e7-8c1f-6721da772ce8
# ╟─fad51bcf-2a5e-48e8-af2b-f7037880331c
# ╟─6e34006e-d77d-468d-aeeb-9a726f0fcd2c
# ╠═78f57b3b-71ed-4800-9982-f3df39b2b531
# ╠═2a9524b4-b2c5-4983-8c1b-c552e05ed910
# ╠═471b1e6f-4643-4b65-8f83-b2f5b25fb74d
# ╟─745f3283-8077-4652-9d71-bbe071b1d750
# ╟─c8c0a6c4-1095-4261-9f74-f93ac2997775
# ╠═586ca0bd-56d5-4dc7-b6ba-5b3e41181cdf
# ╟─f68a927e-494f-491d-9259-bb8e3aca1a85
# ╟─7043e62f-d333-4946-b2a1-532691ca3daa
# ╠═637d0d33-06cb-409e-9364-8ed6d7f62f4b
# ╟─8c195b79-b4e0-4eb9-ae4b-9f14742eeae7
# ╠═4ee5caa1-47d5-473b-a909-4a9627a6d79b
# ╟─a0cf4b98-0b05-417e-a82b-50ee37922602
# ╟─43cc0447-7c7d-4f9b-93b8-3352e98d5ac2
# ╠═0fabb21c-31e6-4980-b0bf-8c28d9e092d1
# ╟─9dbb2d7a-b4b8-447d-ab4e-e1bab3ba7c4a
# ╟─394c4724-42b5-429e-8ad7-dd7c742e0029
# ╟─a1248530-2c77-4562-b8f3-545d498982b1
# ╟─72b37a4b-8600-4b1b-a617-d359dee3b3b1
# ╟─3b7b6e8a-4bd8-49a8-b89f-2ef4ccfe5d04
# ╟─754ce083-54a9-4444-9131-cd5b07fe8e04
# ╟─ad7592bf-1759-461a-b812-c190a9a2332b
# ╠═12b897e1-f235-4306-8d92-8bb2951b0365
# ╟─4b4992b1-b40b-4256-b0a2-72f5f31385c1
# ╠═0351318f-a7ec-4824-ae86-f8656128c8aa
# ╟─7821bac3-6045-4afa-83c5-2aff4b6b05ed
# ╟─96080928-ae3c-4393-8a41-26d2bbc66795
# ╠═e988003b-ad4b-4069-8849-599730bc0567
# ╠═8dd669ac-01f6-4e1b-bc0a-74841ebdd9b1
# ╠═c1884994-c631-4d15-9d6e-74571c51d677
# ╟─67f452f6-4ae1-4952-934f-575576d5cfac
# ╠═481f0907-1955-4011-a0bc-1bcd7b00ebc6
# ╠═0f8df86e-970f-4d6a-9894-ae10bfeef93b
# ╟─3dd3bb6c-f586-45f1-ae9f-74662416bdd1
# ╠═5c4b06c1-26d5-42e9-be84-79de54ea14e3
# ╟─ef3518a3-596a-44a5-b83a-ed824c037cf1
# ╠═30ab54fb-9437-4e98-bd0b-9ac379deec90
# ╠═f38a4543-5893-43e9-87d3-af93398fde83
# ╟─e1a6ca64-a588-40f4-a8ed-63c803528882
# ╟─2b168394-8ad9-42eb-bd0c-31710d762171
# ╟─c99b3445-19f2-443b-8e28-80df416d1de2
# ╟─5ea09765-b297-47a2-8b2a-c1a4c7483e1c
# ╠═cc846b09-8ca8-436f-8158-bbd95976e155
# ╠═80c4a4bf-6ec2-41af-bda8-9accf6d11948
# ╠═e7d64867-6cd9-4117-8906-ab00f90d5ce6
# ╟─a4c13426-84fe-4edf-8e84-f8af90d4a668
# ╠═5e7eaa5f-9d8a-433f-82cc-464d7b37e58a
# ╠═d7c44390-b6a5-4650-8020-576cfc85def9
# ╠═496daa9e-3d44-4971-a160-ec7307efa475
# ╟─25db8aa9-e686-4605-8fc4-4ee65013304e
# ╟─fceb1a04-4dd5-4386-91ff-c516ca92a42a
# ╠═516c067d-24ab-4e47-89ef-560d2a92143f
# ╟─f6c82245-8c4e-4a39-ba23-6c2b3ad0a53c
# ╠═a474e616-1eed-4c43-9ec9-e82d4854b5df
# ╠═96cb110e-83d6-407f-b786-51101f8a3bdc
# ╠═dd518e45-5f62-4053-a020-ce7d5a2e8481
# ╠═005d58b4-e6ab-48d0-b805-e1c2a410052a
# ╠═0a179c03-497c-4982-bfb6-56525cedab2d
# ╟─c3bd3386-be7e-4665-8329-0f26bea2d6af
# ╟─a9bba7e3-7ba6-40e3-a5ae-1b5d33d30ec1
# ╟─1335d197-ac60-4c2d-8c82-c35b1239042d
# ╟─9a202442-5cca-4ad9-bb92-30357ea9673f
# ╟─d670e43b-99a6-4c4a-af3c-3c51a9e7333a
# ╟─b966367f-2a46-4ed8-9257-9a57eb719e86
# ╟─a5fff3cb-eb42-4add-9725-e9687ab9cd39
# ╟─c38c6288-bb52-4449-9d8f-59bae06d7ac5
# ╟─d4790dd0-a6dc-40c1-956d-1f4e2303cf48
# ╟─1afcbca0-cc55-461e-ade6-06a821e81b06
# ╟─1105627b-be04-4c93-bee6-f887c4952b11
# ╟─787787db-1510-4913-8d7c-f31ac26447a8
