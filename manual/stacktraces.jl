### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 996c4230-3584-484a-bc7a-38690d01fd30
md"""
# Stack Traces
"""

# ╔═╡ be3c1e16-3a05-4916-8e0c-457d0a1dd5c5
md"""
The `StackTraces` module provides simple stack traces that are both human readable and easy to use programmatically.
"""

# ╔═╡ df6f8e7d-ff7c-43ed-84f4-b8acf11cffa1
md"""
## Viewing a stack trace
"""

# ╔═╡ 7e5e3f66-dcc7-4337-a79c-bd6baae0cd50
md"""
The primary function used to obtain a stack trace is [`stacktrace`](@ref):
"""

# ╔═╡ 8616cf6f-58f2-42f9-8fd9-0a4f6af453d0
6-element Array

# ╔═╡ 4c067993-a38e-402a-8a4b-af35d3a8131e
md"""
Calling [`stacktrace()`](@ref) returns a vector of [`StackTraces.StackFrame`](@ref) s. For ease of use, the alias [`StackTraces.StackTrace`](@ref) can be used in place of `Vector{StackFrame}`. (Examples with `[...]` indicate that output may vary depending on how the code is run.)
"""

# ╔═╡ 0183d631-5488-4997-ba57-7d3bbc9f277b
example() = stacktrace()

# ╔═╡ 084a7db7-c40e-4551-a0b2-6c0e18a5f705
example()

# ╔═╡ 3ef94ebc-45cb-4ccc-aa4f-47996dde0aa1
@noinline child() = stacktrace()

# ╔═╡ 4af7df44-e539-4482-aba3-30eb97ff6948
@noinline parent() = child()

# ╔═╡ d6c89c45-f93c-4c86-a7c9-5c71630dcd6b
grandparent() = parent()

# ╔═╡ a34c4404-8279-49a4-8d4f-d62c1e401da7
grandparent()

# ╔═╡ 1a7de95c-9ff8-4e00-9b57-2da056640f53
md"""
Note that when calling [`stacktrace()`](@ref) you'll typically see a frame with `eval at boot.jl`. When calling [`stacktrace()`](@ref) from the REPL you'll also have a few extra frames in the stack from `REPL.jl`, usually looking something like this:
"""

# ╔═╡ 0aac3674-ecec-4fba-bdd2-cfe5a277727c
example() = stacktrace()

# ╔═╡ f9f85aa8-9c93-4c74-bd20-707ba17fa6a1
example()

# ╔═╡ 3ce9f1e7-8734-42b8-b984-72ba9878e4de
md"""
## Extracting useful information
"""

# ╔═╡ 0648898a-b78c-4770-a4c8-f7f32cb1fc1a
md"""
Each [`StackTraces.StackFrame`](@ref) contains the function name, file name, line number, lambda info, a flag indicating whether the frame has been inlined, a flag indicating whether it is a C function (by default C functions do not appear in the stack trace), and an integer representation of the pointer returned by [`backtrace`](@ref):
"""

# ╔═╡ b5ab0b07-14c0-45cb-90db-3ee0bff13b27
frame = stacktrace()[3]

# ╔═╡ d047f7c7-c585-453f-b562-b7b35d782d34
frame.func

# ╔═╡ 47e2d496-53a3-42d6-b278-24f8868efecb
frame.file

# ╔═╡ 99b6a413-1c4b-4550-9b7b-0533103ef7b1
frame.line

# ╔═╡ 1f8aa731-bb1a-472d-a5cd-5c487cc91152
frame.linfo

# ╔═╡ eae3114c-6535-4c4f-9a9c-16ebeb9ae864
frame.inlined

# ╔═╡ c2ad7bf6-b22f-4436-b7fe-0d73eb62ac0a
frame.from_c

# ╔═╡ 196d505e-6a3f-4ce7-9e3e-1a92b7a5333b
frame.pointer

# ╔═╡ e88bb794-e8ab-4d53-8280-d5f9120853e5
md"""
This makes stack trace information available programmatically for logging, error handling, and more.
"""

# ╔═╡ e62c6be4-ebc5-4728-b816-5b4a52690db8
md"""
## Error handling
"""

# ╔═╡ 587a02be-efc3-4c99-bd75-2f5549c44e0a
md"""
While having easy access to information about the current state of the callstack can be helpful in many places, the most obvious application is in error handling and debugging.
"""

# ╔═╡ 34705c0d-983a-4005-8523-4a5378736c06
@noinline bad_function() = undeclared_variable

# ╔═╡ f3560937-4926-47de-9824-45de26b82f8f
@noinline example() = try
     bad_function()
 catch
     stacktrace()
 end

# ╔═╡ 846850c1-b756-4cf6-a1f8-dd8eb363935e
example()

# ╔═╡ c3706929-2f5a-4ea0-b390-a527125337be
md"""
You may notice that in the example above the first stack frame points at line 4, where [`stacktrace`](@ref) is called, rather than line 2, where *bad_function* is called, and `bad_function`'s frame is missing entirely. This is understandable, given that [`stacktrace`](@ref) is called from the context of the *catch*. While in this example it's fairly easy to find the actual source of the error, in complex cases tracking down the source of the error becomes nontrivial.
"""

# ╔═╡ f64904a4-00ee-40c2-96f6-f1321c139ae5
md"""
This can be remedied by passing the result of [`catch_backtrace`](@ref) to [`stacktrace`](@ref). Instead of returning callstack information for the current context, [`catch_backtrace`](@ref) returns stack information for the context of the most recent exception:
"""

# ╔═╡ 222a1c77-0cbf-4f93-9597-f4eaa4230af5
@noinline bad_function() = undeclared_variable

# ╔═╡ 930d3c75-56a6-4b0c-9fdf-74f3d44f92f5
@noinline example() = try
     bad_function()
 catch
     stacktrace(catch_backtrace())
 end

# ╔═╡ 90fa5d9c-ab3f-4b98-b637-bd2154a841e0
example()

# ╔═╡ 61850b41-3f54-4143-873f-7be510176cc6
md"""
Notice that the stack trace now indicates the appropriate line number and the missing frame.
"""

# ╔═╡ d3bba8fe-edb5-43f1-8f8e-54798d3c1fa4
@noinline child() = error("Whoops!")

# ╔═╡ 67b46f80-5612-4edd-a025-2bb425796fea
@noinline parent() = child()

# ╔═╡ 299d95f2-f7ea-424d-9e2c-152753aa4201
@noinline function grandparent()
     try
         parent()
     catch err
         println("ERROR: ", err.msg)
         stacktrace(catch_backtrace())
     end
 end

# ╔═╡ e3e5dc6e-0079-4a18-b821-740764d4cc06
grandparent()

# ╔═╡ 578bbcd4-2535-48ec-91b8-40d3c8f7bdfa
md"""
## Exception stacks and `catch_stack`
"""

# ╔═╡ 7b00df43-6e5d-427a-ab32-26ed38426bdf
md"""
!!! compat \"Julia 1.1\"
    Exception stacks requires at least Julia 1.1.
"""

# ╔═╡ 9ad337fd-c8d2-441f-92bb-fa86451cf789
md"""
While handling an exception further exceptions may be thrown. It can be useful to inspect all these exceptions to identify the root cause of a problem. The julia runtime supports this by pushing each exception onto an internal *exception stack* as it occurs. When the code exits a `catch` normally, any exceptions which were pushed onto the stack in the associated `try` are considered to be successfully handled and are removed from the stack.
"""

# ╔═╡ 21e2ea79-198e-40bc-a77d-20b8052e0fb9
md"""
The stack of current exceptions can be accessed using the experimental [`Base.catch_stack`](@ref) function. For example,
"""

# ╔═╡ 70dacc82-f34b-4b52-af9e-492ac184a869
try
     error("(A) The root cause")
 catch
     try
         error("(B) An exception while handling the exception")
     catch
         for (exc, bt) in Base.catch_stack()
             showerror(stdout, exc, bt)
             println(stdout)
         end
     end
 end

# ╔═╡ a8543c6c-c801-42b0-9988-09322f2c5082
md"""
In this example the root cause exception (A) is first on the stack, with a further exception (B) following it. After exiting both catch blocks normally (i.e., without throwing a further exception) all exceptions are removed from the stack and are no longer accessible.
"""

# ╔═╡ 5087247f-91a0-450f-a99d-b096646084a1
md"""
The exception stack is stored on the `Task` where the exceptions occurred. When a task fails with uncaught exceptions, `catch_stack(task)` may be used to inspect the exception stack for that task.
"""

# ╔═╡ f6b1e5df-b751-4331-8a19-0194dc4c31ad
md"""
## Comparison with [`backtrace`](@ref)
"""

# ╔═╡ 6c324241-cad6-478c-a44c-68411c722e5a
md"""
A call to [`backtrace`](@ref) returns a vector of `Union{Ptr{Nothing}, Base.InterpreterIP}`, which may then be passed into [`stacktrace`](@ref) for translation:
"""

# ╔═╡ dc8fd0dd-db81-40b3-91e6-17472de81363
trace = backtrace()

# ╔═╡ d0f6a2d6-a860-4b9e-9a24-13dfde80d35a
stacktrace(trace)

# ╔═╡ 59408bf6-4cbc-43e3-a78d-0e98478113cc
md"""
Notice that the vector returned by [`backtrace`](@ref) had 18 elements, while the vector returned by [`stacktrace`](@ref) only has 6. This is because, by default, [`stacktrace`](@ref) removes any lower-level C functions from the stack. If you want to include stack frames from C calls, you can do it like this:
"""

# ╔═╡ 3bb7738b-abb0-4c97-a73e-34f6f8ac72ec
stacktrace(trace, true)

# ╔═╡ ec546169-3037-4232-b2e7-1b3d78551a28
md"""
Individual pointers returned by [`backtrace`](@ref) can be translated into [`StackTraces.StackFrame`](@ref) s by passing them into [`StackTraces.lookup`](@ref):
"""

# ╔═╡ 4f0a544a-24ca-4f58-a69d-be49ae2186fc
pointer = backtrace()[1];

# ╔═╡ 4cc27021-1598-4561-ae5b-94131fa324c9
frame = StackTraces.lookup(pointer)

# ╔═╡ c4988efd-7bfd-4631-b417-7afa23d7bc06
println("The top frame is from $(frame[1].func)!")

# ╔═╡ Cell order:
# ╟─996c4230-3584-484a-bc7a-38690d01fd30
# ╟─be3c1e16-3a05-4916-8e0c-457d0a1dd5c5
# ╟─df6f8e7d-ff7c-43ed-84f4-b8acf11cffa1
# ╟─7e5e3f66-dcc7-4337-a79c-bd6baae0cd50
# ╠═8616cf6f-58f2-42f9-8fd9-0a4f6af453d0
# ╟─4c067993-a38e-402a-8a4b-af35d3a8131e
# ╠═0183d631-5488-4997-ba57-7d3bbc9f277b
# ╠═084a7db7-c40e-4551-a0b2-6c0e18a5f705
# ╠═3ef94ebc-45cb-4ccc-aa4f-47996dde0aa1
# ╠═4af7df44-e539-4482-aba3-30eb97ff6948
# ╠═d6c89c45-f93c-4c86-a7c9-5c71630dcd6b
# ╠═a34c4404-8279-49a4-8d4f-d62c1e401da7
# ╟─1a7de95c-9ff8-4e00-9b57-2da056640f53
# ╠═0aac3674-ecec-4fba-bdd2-cfe5a277727c
# ╠═f9f85aa8-9c93-4c74-bd20-707ba17fa6a1
# ╟─3ce9f1e7-8734-42b8-b984-72ba9878e4de
# ╟─0648898a-b78c-4770-a4c8-f7f32cb1fc1a
# ╠═b5ab0b07-14c0-45cb-90db-3ee0bff13b27
# ╠═d047f7c7-c585-453f-b562-b7b35d782d34
# ╠═47e2d496-53a3-42d6-b278-24f8868efecb
# ╠═99b6a413-1c4b-4550-9b7b-0533103ef7b1
# ╠═1f8aa731-bb1a-472d-a5cd-5c487cc91152
# ╠═eae3114c-6535-4c4f-9a9c-16ebeb9ae864
# ╠═c2ad7bf6-b22f-4436-b7fe-0d73eb62ac0a
# ╠═196d505e-6a3f-4ce7-9e3e-1a92b7a5333b
# ╟─e88bb794-e8ab-4d53-8280-d5f9120853e5
# ╟─e62c6be4-ebc5-4728-b816-5b4a52690db8
# ╟─587a02be-efc3-4c99-bd75-2f5549c44e0a
# ╠═34705c0d-983a-4005-8523-4a5378736c06
# ╠═f3560937-4926-47de-9824-45de26b82f8f
# ╠═846850c1-b756-4cf6-a1f8-dd8eb363935e
# ╟─c3706929-2f5a-4ea0-b390-a527125337be
# ╟─f64904a4-00ee-40c2-96f6-f1321c139ae5
# ╠═222a1c77-0cbf-4f93-9597-f4eaa4230af5
# ╠═930d3c75-56a6-4b0c-9fdf-74f3d44f92f5
# ╠═90fa5d9c-ab3f-4b98-b637-bd2154a841e0
# ╟─61850b41-3f54-4143-873f-7be510176cc6
# ╠═d3bba8fe-edb5-43f1-8f8e-54798d3c1fa4
# ╠═67b46f80-5612-4edd-a025-2bb425796fea
# ╠═299d95f2-f7ea-424d-9e2c-152753aa4201
# ╠═e3e5dc6e-0079-4a18-b821-740764d4cc06
# ╟─578bbcd4-2535-48ec-91b8-40d3c8f7bdfa
# ╟─7b00df43-6e5d-427a-ab32-26ed38426bdf
# ╟─9ad337fd-c8d2-441f-92bb-fa86451cf789
# ╟─21e2ea79-198e-40bc-a77d-20b8052e0fb9
# ╠═70dacc82-f34b-4b52-af9e-492ac184a869
# ╟─a8543c6c-c801-42b0-9988-09322f2c5082
# ╟─5087247f-91a0-450f-a99d-b096646084a1
# ╟─f6b1e5df-b751-4331-8a19-0194dc4c31ad
# ╟─6c324241-cad6-478c-a44c-68411c722e5a
# ╠═dc8fd0dd-db81-40b3-91e6-17472de81363
# ╠═d0f6a2d6-a860-4b9e-9a24-13dfde80d35a
# ╟─59408bf6-4cbc-43e3-a78d-0e98478113cc
# ╠═3bb7738b-abb0-4c97-a73e-34f6f8ac72ec
# ╟─ec546169-3037-4232-b2e7-1b3d78551a28
# ╠═4f0a544a-24ca-4f58-a69d-be49ae2186fc
# ╠═4cc27021-1598-4561-ae5b-94131fa324c9
# ╠═c4988efd-7bfd-4631-b417-7afa23d7bc06
