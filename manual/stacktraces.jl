### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03d5dc96-9e19-11eb-279f-99417304d274
md"""
# Stack Traces
"""

# ╔═╡ 03d5dcbe-9e19-11eb-3dee-b756e83ee98e
md"""
The `StackTraces` module provides simple stack traces that are both human readable and easy to use programmatically.
"""

# ╔═╡ 03d5dcd4-9e19-11eb-0030-711304d07113
md"""
## Viewing a stack trace
"""

# ╔═╡ 03d5dcf0-9e19-11eb-2c98-8f21207e7084
md"""
The primary function used to obtain a stack trace is [`stacktrace`](@ref):
"""

# ╔═╡ 03d5de94-9e19-11eb-2fc9-7ffb34fc813f
6-element Array

# ╔═╡ 03d5dec6-9e19-11eb-13c5-fd19658cc667
md"""
Calling [`stacktrace()`](@ref) returns a vector of [`StackTraces.StackFrame`](@ref) s. For ease of use, the alias [`StackTraces.StackTrace`](@ref) can be used in place of `Vector{StackFrame}`. (Examples with `[...]` indicate that output may vary depending on how the code is run.)
"""

# ╔═╡ 03d5e54c-9e19-11eb-0ef2-65424beb468d
example() = stacktrace()

# ╔═╡ 03d5e54c-9e19-11eb-33ed-cf57436b0548
example()

# ╔═╡ 03d5e556-9e19-11eb-2439-27e6eecb8677
@noinline child() = stacktrace()

# ╔═╡ 03d5e560-9e19-11eb-3497-314d57e023b0
@noinline parent() = child()

# ╔═╡ 03d5e560-9e19-11eb-1397-391d3057772c
grandparent() = parent()

# ╔═╡ 03d5e56a-9e19-11eb-31d0-2df6d99a3f05
grandparent()

# ╔═╡ 03d5e59c-9e19-11eb-1a38-8fc67f3bbda3
md"""
Note that when calling [`stacktrace()`](@ref) you'll typically see a frame with `eval at boot.jl`. When calling [`stacktrace()`](@ref) from the REPL you'll also have a few extra frames in the stack from `REPL.jl`, usually looking something like this:
"""

# ╔═╡ 03d5e754-9e19-11eb-29f6-d15b46f4c257
example() = stacktrace()

# ╔═╡ 03d5e754-9e19-11eb-0218-c5aaf54d34ee
example()

# ╔═╡ 03d5e768-9e19-11eb-2413-011ba8c89a32
md"""
## Extracting useful information
"""

# ╔═╡ 03d5e790-9e19-11eb-392c-11941435dfa9
md"""
Each [`StackTraces.StackFrame`](@ref) contains the function name, file name, line number, lambda info, a flag indicating whether the frame has been inlined, a flag indicating whether it is a C function (by default C functions do not appear in the stack trace), and an integer representation of the pointer returned by [`backtrace`](@ref):
"""

# ╔═╡ 03d5ec86-9e19-11eb-3805-557248c9f754
frame = stacktrace()[3]

# ╔═╡ 03d5ec86-9e19-11eb-0639-7537fccc654d
frame.func

# ╔═╡ 03d5ec90-9e19-11eb-0bb1-5966f0303b31
frame.file

# ╔═╡ 03d5ec90-9e19-11eb-2381-af99637adfd1
frame.line

# ╔═╡ 03d5eca4-9e19-11eb-0b8d-5157e219d8aa
frame.linfo

# ╔═╡ 03d5ecae-9e19-11eb-3fb4-3bd61d248647
frame.inlined

# ╔═╡ 03d5ecae-9e19-11eb-3dec-1bb2cfbe5f3e
frame.from_c

# ╔═╡ 03d5ecb8-9e19-11eb-37f4-399b6e4ea10f
frame.pointer

# ╔═╡ 03d5eccc-9e19-11eb-28aa-e7d8be0c539b
md"""
This makes stack trace information available programmatically for logging, error handling, and more.
"""

# ╔═╡ 03d5ece0-9e19-11eb-12c2-2be050f66b46
md"""
## Error handling
"""

# ╔═╡ 03d5ecfe-9e19-11eb-3cd6-1747736d3294
md"""
While having easy access to information about the current state of the callstack can be helpful in many places, the most obvious application is in error handling and debugging.
"""

# ╔═╡ 03d5f1b6-9e19-11eb-295a-7b6ba0afc7e1
@noinline bad_function() = undeclared_variable

# ╔═╡ 03d5f1c2-9e19-11eb-313d-5d1ed735f9cb
@noinline example() = try
           bad_function()
       catch
           stacktrace()
       end

# ╔═╡ 03d5f1cc-9e19-11eb-08fa-0f0b69204907
example()

# ╔═╡ 03d5f208-9e19-11eb-0442-f1cc0bc04c38
md"""
You may notice that in the example above the first stack frame points at line 4, where [`stacktrace`](@ref) is called, rather than line 2, where *bad_function* is called, and `bad_function`'s frame is missing entirely. This is understandable, given that [`stacktrace`](@ref) is called from the context of the *catch*. While in this example it's fairly easy to find the actual source of the error, in complex cases tracking down the source of the error becomes nontrivial.
"""

# ╔═╡ 03d5f230-9e19-11eb-0588-91b085d36d60
md"""
This can be remedied by passing the result of [`catch_backtrace`](@ref) to [`stacktrace`](@ref). Instead of returning callstack information for the current context, [`catch_backtrace`](@ref) returns stack information for the context of the most recent exception:
"""

# ╔═╡ 03d5f712-9e19-11eb-32b4-8ff4d6838947
@noinline bad_function() = undeclared_variable

# ╔═╡ 03d5f712-9e19-11eb-1432-2fc92d54789f
@noinline example() = try
           bad_function()
       catch
           stacktrace(catch_backtrace())
       end

# ╔═╡ 03d5f71c-9e19-11eb-01cd-15c1990e419d
example()

# ╔═╡ 03d5f73a-9e19-11eb-32a6-e93ba77ebabe
md"""
Notice that the stack trace now indicates the appropriate line number and the missing frame.
"""

# ╔═╡ 03d60054-9e19-11eb-3c05-17c60bfadffb
@noinline child() = error("Whoops!")

# ╔═╡ 03d60054-9e19-11eb-0684-b9f017466907
@noinline parent() = child()

# ╔═╡ 03d6005e-9e19-11eb-0401-45af614e8ecb
@noinline function grandparent()
           try
               parent()
           catch err
               println("ERROR: ", err.msg)
               stacktrace(catch_backtrace())
           end
       end

# ╔═╡ 03d6005e-9e19-11eb-1f0a-6d2e3cac36e4
grandparent()

# ╔═╡ 03d60086-9e19-11eb-0ed0-21795f0168e5
md"""
## Exception stacks and `catch_stack`
"""

# ╔═╡ 03d600f4-9e19-11eb-21cc-e526f5f84f55
md"""
!!! compat "Julia 1.1"
    Exception stacks requires at least Julia 1.1.
"""

# ╔═╡ 03d60112-9e19-11eb-09d8-25fc06c1e4c8
md"""
While handling an exception further exceptions may be thrown. It can be useful to inspect all these exceptions to identify the root cause of a problem. The julia runtime supports this by pushing each exception onto an internal *exception stack* as it occurs. When the code exits a `catch` normally, any exceptions which were pushed onto the stack in the associated `try` are considered to be successfully handled and are removed from the stack.
"""

# ╔═╡ 03d6013a-9e19-11eb-36c5-9359e9839948
md"""
The stack of current exceptions can be accessed using the experimental [`Base.catch_stack`](@ref) function. For example,
"""

# ╔═╡ 03d607c0-9e19-11eb-08f7-c33ea4441b7d
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

# ╔═╡ 03d607d2-9e19-11eb-29c6-9fc5a6c30b96
md"""
In this example the root cause exception (A) is first on the stack, with a further exception (B) following it. After exiting both catch blocks normally (i.e., without throwing a further exception) all exceptions are removed from the stack and are no longer accessible.
"""

# ╔═╡ 03d607f2-9e19-11eb-2bde-cb60c48fd257
md"""
The exception stack is stored on the `Task` where the exceptions occurred. When a task fails with uncaught exceptions, `catch_stack(task)` may be used to inspect the exception stack for that task.
"""

# ╔═╡ 03d6081a-9e19-11eb-04f3-efbd76041e61
md"""
## Comparison with [`backtrace`](@ref)
"""

# ╔═╡ 03d60838-9e19-11eb-0ea3-a76cfd725e4c
md"""
A call to [`backtrace`](@ref) returns a vector of `Union{Ptr{Nothing}, Base.InterpreterIP}`, which may then be passed into [`stacktrace`](@ref) for translation:
"""

# ╔═╡ 03d60a18-9e19-11eb-07d4-5f79f98bc8c0
trace = backtrace()

# ╔═╡ 03d60a22-9e19-11eb-3b78-43ced5f0b355
stacktrace(trace)

# ╔═╡ 03d60a68-9e19-11eb-14eb-a184ec8b059d
md"""
Notice that the vector returned by [`backtrace`](@ref) had 18 elements, while the vector returned by [`stacktrace`](@ref) only has 6. This is because, by default, [`stacktrace`](@ref) removes any lower-level C functions from the stack. If you want to include stack frames from C calls, you can do it like this:
"""

# ╔═╡ 03d60b94-9e19-11eb-3981-3b2b80945814
stacktrace(trace, true)

# ╔═╡ 03d60bb2-9e19-11eb-1a51-8d304666f6bd
md"""
Individual pointers returned by [`backtrace`](@ref) can be translated into [`StackTraces.StackFrame`](@ref) s by passing them into [`StackTraces.lookup`](@ref):
"""

# ╔═╡ 03d610d0-9e19-11eb-056b-1f358a738764
pointer = backtrace()[1];

# ╔═╡ 03d610e6-9e19-11eb-37b5-0147accb820d
frame = StackTraces.lookup(pointer)

# ╔═╡ 03d610e6-9e19-11eb-121a-1fb7f5054089
println("The top frame is from $(frame[1].func)!")

# ╔═╡ Cell order:
# ╟─03d5dc96-9e19-11eb-279f-99417304d274
# ╟─03d5dcbe-9e19-11eb-3dee-b756e83ee98e
# ╟─03d5dcd4-9e19-11eb-0030-711304d07113
# ╟─03d5dcf0-9e19-11eb-2c98-8f21207e7084
# ╠═03d5de94-9e19-11eb-2fc9-7ffb34fc813f
# ╟─03d5dec6-9e19-11eb-13c5-fd19658cc667
# ╠═03d5e54c-9e19-11eb-0ef2-65424beb468d
# ╠═03d5e54c-9e19-11eb-33ed-cf57436b0548
# ╠═03d5e556-9e19-11eb-2439-27e6eecb8677
# ╠═03d5e560-9e19-11eb-3497-314d57e023b0
# ╠═03d5e560-9e19-11eb-1397-391d3057772c
# ╠═03d5e56a-9e19-11eb-31d0-2df6d99a3f05
# ╟─03d5e59c-9e19-11eb-1a38-8fc67f3bbda3
# ╠═03d5e754-9e19-11eb-29f6-d15b46f4c257
# ╠═03d5e754-9e19-11eb-0218-c5aaf54d34ee
# ╟─03d5e768-9e19-11eb-2413-011ba8c89a32
# ╟─03d5e790-9e19-11eb-392c-11941435dfa9
# ╠═03d5ec86-9e19-11eb-3805-557248c9f754
# ╠═03d5ec86-9e19-11eb-0639-7537fccc654d
# ╠═03d5ec90-9e19-11eb-0bb1-5966f0303b31
# ╠═03d5ec90-9e19-11eb-2381-af99637adfd1
# ╠═03d5eca4-9e19-11eb-0b8d-5157e219d8aa
# ╠═03d5ecae-9e19-11eb-3fb4-3bd61d248647
# ╠═03d5ecae-9e19-11eb-3dec-1bb2cfbe5f3e
# ╠═03d5ecb8-9e19-11eb-37f4-399b6e4ea10f
# ╟─03d5eccc-9e19-11eb-28aa-e7d8be0c539b
# ╟─03d5ece0-9e19-11eb-12c2-2be050f66b46
# ╟─03d5ecfe-9e19-11eb-3cd6-1747736d3294
# ╠═03d5f1b6-9e19-11eb-295a-7b6ba0afc7e1
# ╠═03d5f1c2-9e19-11eb-313d-5d1ed735f9cb
# ╠═03d5f1cc-9e19-11eb-08fa-0f0b69204907
# ╟─03d5f208-9e19-11eb-0442-f1cc0bc04c38
# ╟─03d5f230-9e19-11eb-0588-91b085d36d60
# ╠═03d5f712-9e19-11eb-32b4-8ff4d6838947
# ╠═03d5f712-9e19-11eb-1432-2fc92d54789f
# ╠═03d5f71c-9e19-11eb-01cd-15c1990e419d
# ╟─03d5f73a-9e19-11eb-32a6-e93ba77ebabe
# ╠═03d60054-9e19-11eb-3c05-17c60bfadffb
# ╠═03d60054-9e19-11eb-0684-b9f017466907
# ╠═03d6005e-9e19-11eb-0401-45af614e8ecb
# ╠═03d6005e-9e19-11eb-1f0a-6d2e3cac36e4
# ╟─03d60086-9e19-11eb-0ed0-21795f0168e5
# ╟─03d600f4-9e19-11eb-21cc-e526f5f84f55
# ╟─03d60112-9e19-11eb-09d8-25fc06c1e4c8
# ╟─03d6013a-9e19-11eb-36c5-9359e9839948
# ╠═03d607c0-9e19-11eb-08f7-c33ea4441b7d
# ╟─03d607d2-9e19-11eb-29c6-9fc5a6c30b96
# ╟─03d607f2-9e19-11eb-2bde-cb60c48fd257
# ╟─03d6081a-9e19-11eb-04f3-efbd76041e61
# ╟─03d60838-9e19-11eb-0ea3-a76cfd725e4c
# ╠═03d60a18-9e19-11eb-07d4-5f79f98bc8c0
# ╠═03d60a22-9e19-11eb-3b78-43ced5f0b355
# ╟─03d60a68-9e19-11eb-14eb-a184ec8b059d
# ╠═03d60b94-9e19-11eb-3981-3b2b80945814
# ╟─03d60bb2-9e19-11eb-1a51-8d304666f6bd
# ╠═03d610d0-9e19-11eb-056b-1f358a738764
# ╠═03d610e6-9e19-11eb-37b5-0147accb820d
# ╠═03d610e6-9e19-11eb-121a-1fb7f5054089
