### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 97a3c822-2cbc-4452-abc6-8e1e96c2b1e6
md"""
# Networking and Streams
"""

# ╔═╡ a250e55b-d277-4a88-9ebe-84a9bcc84e38
md"""
Julia provides a rich interface to deal with streaming I/O objects such as terminals, pipes and TCP sockets. This interface, though asynchronous at the system level, is presented in a synchronous manner to the programmer and it is usually unnecessary to think about the underlying asynchronous operation. This is achieved by making heavy use of Julia cooperative threading ([coroutine](@ref man-tasks)) functionality.
"""

# ╔═╡ 054b8206-8021-4b76-b319-0d759b2c1db6
md"""
## Basic Stream I/O
"""

# ╔═╡ b67340bd-f751-4c2d-a340-199b23ba2183
md"""
All Julia streams expose at least a [`read`](@ref) and a [`write`](@ref) method, taking the stream as their first argument, e.g.:
"""

# ╔═╡ d15f8202-f246-4a86-91c3-6597a34b0cc3
write(stdout, "Hello World");  # suppress return value 11 with ;

# ╔═╡ 2e2a68e8-439b-422d-b592-43eb0d8d6a6c
read(stdin, Char)

# ╔═╡ 60165db3-1f54-4e38-828e-4f8139ac781d
md"""
Note that [`write`](@ref) returns 11, the number of bytes (in `\"Hello World\"`) written to [`stdout`](@ref), but this return value is suppressed with the `;`.
"""

# ╔═╡ 7ceaba7d-a8fb-46d4-a4e7-44b9a0421450
md"""
Here Enter was pressed again so that Julia would read the newline. Now, as you can see from this example, [`write`](@ref) takes the data to write as its second argument, while [`read`](@ref) takes the type of the data to be read as the second argument.
"""

# ╔═╡ eb871b80-a9d8-433c-b434-e8fd88ac6ff6
md"""
For example, to read a simple byte array, we could do:
"""

# ╔═╡ aab4de56-f9e2-412d-a6b2-4fce1d0d5e45
x = zeros(UInt8, 4)

# ╔═╡ 98270d40-5653-4363-8e0a-a32f0591cfc1
read!(stdin, x)

# ╔═╡ 5d7fc6d2-2880-4243-8c62-cebece902b81
md"""
However, since this is slightly cumbersome, there are several convenience methods provided. For example, we could have written the above as:
"""

# ╔═╡ 8b2be140-6123-40e6-9d4f-25e4cc52ee72
read(stdin, 4)

# ╔═╡ 87f5babf-6b5f-4e4d-bccc-f31c0ee7899b
md"""
or if we had wanted to read the entire line instead:
"""

# ╔═╡ 855f5c7c-97d9-4809-bb8a-d7460e7baae0
readline(stdin)

# ╔═╡ 90648cc8-635f-45a1-8207-93b8a54fd2a5
md"""
Note that depending on your terminal settings, your TTY may be line buffered and might thus require an additional enter before the data is sent to Julia.
"""

# ╔═╡ 7bbeaa83-642b-46be-a954-172ae3f6611c
md"""
To read every line from [`stdin`](@ref) you can use [`eachline`](@ref):
"""

# ╔═╡ c904b208-375c-4b87-96f8-d77e33de1f18
md"""
```julia
for line in eachline(stdin)
    print(\"Found $line\")
end
```
"""

# ╔═╡ b212d9fe-a2c1-4130-9052-e864f476e363
md"""
or [`read`](@ref) if you wanted to read by character instead:
"""

# ╔═╡ e568be6e-1926-4a5a-9441-c863ac3562cd
md"""
```julia
while !eof(stdin)
    x = read(stdin, Char)
    println(\"Found: $x\")
end
```
"""

# ╔═╡ d870f434-e9bf-4bb9-8846-f10fff0dfc1c
md"""
## Text I/O
"""

# ╔═╡ 276b6510-27b6-470b-a46c-49c360a12630
md"""
Note that the [`write`](@ref) method mentioned above operates on binary streams. In particular, values do not get converted to any canonical text representation but are written out as is:
"""

# ╔═╡ f7cf941d-4293-4d97-9e21-5d796684620e
write(stdout, 0x61);  # suppress return value 1 with ;

# ╔═╡ d594b2c1-3cbc-40ff-816c-0b8b04ab2635
md"""
Note that `a` is written to [`stdout`](@ref) by the [`write`](@ref) function and that the returned value is `1` (since `0x61` is one byte).
"""

# ╔═╡ 738b80ca-8e9c-4fbb-b6b3-c088dd95e223
md"""
For text I/O, use the [`print`](@ref) or [`show`](@ref) methods, depending on your needs (see the documentation for these two methods for a detailed discussion of the difference between them):
"""

# ╔═╡ 5bfa6858-f84c-4d54-a2cc-bbe507246cc3
print(stdout, 0x61)

# ╔═╡ 24e13609-7a22-4277-af34-82e119f7301e
md"""
See [Custom pretty-printing](@ref man-custom-pretty-printing) for more information on how to implement display methods for custom types.
"""

# ╔═╡ 91b26ef3-fb42-4444-ab2d-57997286dc88
md"""
## IO Output Contextual Properties
"""

# ╔═╡ 44c29277-d154-4d13-8e7c-7c7753575f97
md"""
Sometimes IO output can benefit from the ability to pass contextual information into show methods. The [`IOContext`](@ref) object provides this framework for associating arbitrary metadata with an IO object. For example, `:compact => true` adds a hinting parameter to the IO object that the invoked show method should print a shorter output (if applicable). See the [`IOContext`](@ref) documentation for a list of common properties.
"""

# ╔═╡ fccc93c6-d809-4adb-ac5c-9940c57a537f
md"""
## Working with Files
"""

# ╔═╡ 2ae3b51f-7cbc-4362-8b2c-7294d0a53160
md"""
Like many other environments, Julia has an [`open`](@ref) function, which takes a filename and returns an [`IOStream`](@ref) object that you can use to read and write things from the file. For example, if we have a file, `hello.txt`, whose contents are `Hello, World!`:
"""

# ╔═╡ c09a3d30-a5ed-4377-81f2-8a7f865080ec
f = open("hello.txt")

# ╔═╡ 74075999-ff5a-4f66-b3b4-383aa5f1e6e4
readlines(f)

# ╔═╡ 9648ba35-db01-4579-b73f-cbd1c8750685
md"""
If you want to write to a file, you can open it with the write (`\"w\"`) flag:
"""

# ╔═╡ c61cbcbc-91ce-4529-bc0f-8c62b2ce7067
f = open("hello.txt","w")

# ╔═╡ 3957a698-6ab9-4ae6-bde5-6276dbf3ce1c
write(f,"Hello again.")

# ╔═╡ 4677b43c-c63f-48e0-b465-d46669cae26c
md"""
If you examine the contents of `hello.txt` at this point, you will notice that it is empty; nothing has actually been written to disk yet. This is because the `IOStream` must be closed before the write is actually flushed to disk:
"""

# ╔═╡ 41744423-f827-4c19-9486-b7af624e870a
close(f)

# ╔═╡ 3782ed86-5fb4-4909-a663-7ed1958d4547
md"""
Examining `hello.txt` again will show its contents have been changed.
"""

# ╔═╡ 851deee7-398a-4207-b8f6-33184d32ec94
md"""
Opening a file, doing something to its contents, and closing it again is a very common pattern. To make this easier, there exists another invocation of [`open`](@ref) which takes a function as its first argument and filename as its second, opens the file, calls the function with the file as an argument, and then closes it again. For example, given a function:
"""

# ╔═╡ 87c2eaf7-f4ed-4073-bb75-eb412d2d16af
md"""
```julia
function read_and_capitalize(f::IOStream)
    return uppercase(read(f, String))
end
```
"""

# ╔═╡ 14fed456-fc54-45fc-8bf7-a19a8c0c4053
md"""
You can call:
"""

# ╔═╡ 45c2ca69-ed76-4b8c-a180-533fdaf96839
open(read_and_capitalize, "hello.txt")

# ╔═╡ b102c7a9-b97b-41da-bf29-5159162ab375
md"""
to open `hello.txt`, call `read_and_capitalize` on it, close `hello.txt` and return the capitalized contents.
"""

# ╔═╡ 1ac601cb-7a77-4aa0-b548-06d11493fcfa
md"""
To avoid even having to define a named function, you can use the `do` syntax, which creates an anonymous function on the fly:
"""

# ╔═╡ c50a6863-d521-4ffa-a38f-17148f9bf989
open("hello.txt") do f
     uppercase(read(f, String))
 end

# ╔═╡ 9ad7cb17-e429-44c8-a9a3-b23c8d8e2828
md"""
## A simple TCP example
"""

# ╔═╡ 9e3b530b-cce3-4071-9967-c08482d137f9
md"""
Let's jump right in with a simple example involving TCP sockets. This functionality is in a standard library package called `Sockets`. Let's first create a simple server:
"""

# ╔═╡ ecbadf6a-89ff-4573-a6ba-b4b2439eeaa0
using Sockets

# ╔═╡ d13eff59-05ad-4fee-bde6-2ef471ef5147
@async begin
     server = listen(2000)
     while true
         sock = accept(server)
         println("Hello World\n")
     end
 end

# ╔═╡ b794cdc3-a5a7-403e-bc89-90b9c8bac2c0
md"""
To those familiar with the Unix socket API, the method names will feel familiar, though their usage is somewhat simpler than the raw Unix socket API. The first call to [`listen`](@ref) will create a server waiting for incoming connections on the specified port (2000) in this case. The same function may also be used to create various other kinds of servers:
"""

# ╔═╡ f632e55b-de04-48b3-b5fa-26786237d5e7
listen(2000) # Listens on localhost:2000 (IPv4)

# ╔═╡ d02ee3b1-26f0-415e-8d7e-9c4984847f80
listen(ip"127.0.0.1",2000) # Equivalent to the first

# ╔═╡ 87b87566-299d-47c1-bfb5-1dbeb15e34cc
listen(ip"::1",2000) # Listens on localhost:2000 (IPv6)

# ╔═╡ ec5fa43c-1007-4ef7-8fc6-759a44efda85
listen(IPv4(0),2001) # Listens on port 2001 on all IPv4 interfaces

# ╔═╡ fae32917-e7bc-4c7e-a6ba-38d24ae0549c
listen(IPv6(0),2001) # Listens on port 2001 on all IPv6 interfaces

# ╔═╡ 3c15833d-053b-4b77-9cd7-72b9a738f64d
listen("testsocket") # Listens on a UNIX domain socket

# ╔═╡ 41f9e865-881c-41f2-bde3-19a5bc63fcec
listen("\\\\.\\pipe\\testsocket") # Listens on a Windows named pipe

# ╔═╡ 2d1fa256-e118-484a-945e-686cfd1ca7b8
md"""
Note that the return type of the last invocation is different. This is because this server does not listen on TCP, but rather on a named pipe (Windows) or UNIX domain socket. Also note that Windows named pipe format has to be a specific pattern such that the name prefix (`\\.\pipe\`) uniquely identifies the [file type](https://docs.microsoft.com/windows/desktop/ipc/pipe-names). The difference between TCP and named pipes or UNIX domain sockets is subtle and has to do with the [`accept`](@ref) and [`connect`](@ref) methods. The [`accept`](@ref) method retrieves a connection to the client that is connecting on the server we just created, while the [`connect`](@ref) function connects to a server using the specified method. The [`connect`](@ref) function takes the same arguments as [`listen`](@ref), so, assuming the environment (i.e. host, cwd, etc.) is the same you should be able to pass the same arguments to [`connect`](@ref) as you did to listen to establish the connection. So let's try that out (after having created the server above):
"""

# ╔═╡ 5434cfdb-d162-4417-902f-d946f5263a44
connect(2000)

# ╔═╡ 6f18923f-30e2-4b3a-8844-dab963b64ccc
Hello World

# ╔═╡ 6318cc8b-d01f-4b67-932f-efc61d714e78
md"""
As expected we saw \"Hello World\" printed. So, let's actually analyze what happened behind the scenes. When we called [`connect`](@ref), we connect to the server we had just created. Meanwhile, the accept function returns a server-side connection to the newly created socket and prints \"Hello World\" to indicate that the connection was successful.
"""

# ╔═╡ 5c9cf6a6-00e5-420e-a861-0e6d5846b6fd
md"""
A great strength of Julia is that since the API is exposed synchronously even though the I/O is actually happening asynchronously, we didn't have to worry about callbacks or even making sure that the server gets to run. When we called [`connect`](@ref) the current task waited for the connection to be established and only continued executing after that was done. In this pause, the server task resumed execution (because a connection request was now available), accepted the connection, printed the message and waited for the next client. Reading and writing works in the same way. To see this, consider the following simple echo server:
"""

# ╔═╡ ad568cdb-f45c-4d2e-b633-c50bcda76c6e
@async begin
     server = listen(2001)
     while true
         sock = accept(server)
         @async while isopen(sock)
             write(sock, readline(sock, keep=true))
         end
     end
 end

# ╔═╡ 2f3d50da-df1e-4d48-9123-91906364402a
clientside = connect(2001)

# ╔═╡ 61dce3b6-8038-48e5-b203-cc4a74789d9b
@async while isopen(clientside)
     write(stdout, readline(clientside, keep=true))
 end

# ╔═╡ 38c5e8b9-4329-4e43-b69b-bc69fe873fcf
println(clientside,"Hello World from the Echo Server")

# ╔═╡ 52607f2f-80e4-41cb-8ccc-c3e2da77ef09
md"""
As with other streams, use [`close`](@ref) to disconnect the socket:
"""

# ╔═╡ 266ae844-93ec-4da0-8440-1c0f5f03738a
close(clientside)

# ╔═╡ 4fb6ed42-cfbb-479d-abb3-6da661cb57f4
md"""
## Resolving IP Addresses
"""

# ╔═╡ acb2b0a3-9190-4d90-9d1b-1ecaa19f4932
md"""
One of the [`connect`](@ref) methods that does not follow the [`listen`](@ref) methods is `connect(host::String,port)`, which will attempt to connect to the host given by the `host` parameter on the port given by the `port` parameter. It allows you to do things like:
"""

# ╔═╡ e09a7d61-de1c-4978-a1cd-a02cb8e00261
connect("google.com", 80)

# ╔═╡ ab39aba4-b919-43f9-a01d-b800d7290005
md"""
At the base of this functionality is [`getaddrinfo`](@ref), which will do the appropriate address resolution:
"""

# ╔═╡ 90e928a8-6260-45d4-8021-1de7719066e2
getaddrinfo("google.com")

# ╔═╡ e8d802b6-9f23-4a80-90da-78d9e56838d4
md"""
## Asynchronous I/O
"""

# ╔═╡ 97a55b27-a010-4460-963d-b7ae172f3bc5
md"""
All I/O operations exposed by [`Base.read`](@ref) and [`Base.write`](@ref) can be performed asynchronously through the use of [coroutines](@ref man-tasks). You can create a new coroutine to read from or write to a stream using the [`@async`](@ref) macro:
"""

# ╔═╡ b0dd49a6-8b75-4347-9551-bc9cd0513799
task = @async open("foo.txt", "w") do io
     write(io, "Hello, World!")
 end;

# ╔═╡ 3679af70-7a65-497e-b545-96b75448ba3a
wait(task)

# ╔═╡ c73476e0-f156-44a8-8ce3-2ed128637bdf
readlines("foo.txt")

# ╔═╡ 90311526-2758-4f80-a11b-93575814f863
md"""
It's common to run into situations where you want to perform multiple asynchronous operations concurrently and wait until they've all completed. You can use the [`@sync`](@ref) macro to cause your program to block until all of the coroutines it wraps around have exited:
"""

# ╔═╡ f81d07ae-a490-4772-94c8-9889d726b8fd
using Sockets

# ╔═╡ c798ebbc-eebb-40f8-8ec7-df4d88315dfb
@sync for hostname in ("google.com", "github.com", "julialang.org")
     @async begin
         conn = connect(hostname, 80)
         write(conn, "GET / HTTP/1.1\r\nHost:$(hostname)\r\n\r\n")
         readline(conn, keep=true)
         println("Finished connection to $(hostname)")
     end
 end

# ╔═╡ Cell order:
# ╟─97a3c822-2cbc-4452-abc6-8e1e96c2b1e6
# ╟─a250e55b-d277-4a88-9ebe-84a9bcc84e38
# ╟─054b8206-8021-4b76-b319-0d759b2c1db6
# ╟─b67340bd-f751-4c2d-a340-199b23ba2183
# ╠═d15f8202-f246-4a86-91c3-6597a34b0cc3
# ╠═2e2a68e8-439b-422d-b592-43eb0d8d6a6c
# ╟─60165db3-1f54-4e38-828e-4f8139ac781d
# ╟─7ceaba7d-a8fb-46d4-a4e7-44b9a0421450
# ╟─eb871b80-a9d8-433c-b434-e8fd88ac6ff6
# ╠═aab4de56-f9e2-412d-a6b2-4fce1d0d5e45
# ╠═98270d40-5653-4363-8e0a-a32f0591cfc1
# ╟─5d7fc6d2-2880-4243-8c62-cebece902b81
# ╠═8b2be140-6123-40e6-9d4f-25e4cc52ee72
# ╟─87f5babf-6b5f-4e4d-bccc-f31c0ee7899b
# ╠═855f5c7c-97d9-4809-bb8a-d7460e7baae0
# ╟─90648cc8-635f-45a1-8207-93b8a54fd2a5
# ╟─7bbeaa83-642b-46be-a954-172ae3f6611c
# ╟─c904b208-375c-4b87-96f8-d77e33de1f18
# ╟─b212d9fe-a2c1-4130-9052-e864f476e363
# ╟─e568be6e-1926-4a5a-9441-c863ac3562cd
# ╟─d870f434-e9bf-4bb9-8846-f10fff0dfc1c
# ╟─276b6510-27b6-470b-a46c-49c360a12630
# ╠═f7cf941d-4293-4d97-9e21-5d796684620e
# ╟─d594b2c1-3cbc-40ff-816c-0b8b04ab2635
# ╟─738b80ca-8e9c-4fbb-b6b3-c088dd95e223
# ╠═5bfa6858-f84c-4d54-a2cc-bbe507246cc3
# ╟─24e13609-7a22-4277-af34-82e119f7301e
# ╟─91b26ef3-fb42-4444-ab2d-57997286dc88
# ╟─44c29277-d154-4d13-8e7c-7c7753575f97
# ╟─fccc93c6-d809-4adb-ac5c-9940c57a537f
# ╟─2ae3b51f-7cbc-4362-8b2c-7294d0a53160
# ╠═c09a3d30-a5ed-4377-81f2-8a7f865080ec
# ╠═74075999-ff5a-4f66-b3b4-383aa5f1e6e4
# ╟─9648ba35-db01-4579-b73f-cbd1c8750685
# ╠═c61cbcbc-91ce-4529-bc0f-8c62b2ce7067
# ╠═3957a698-6ab9-4ae6-bde5-6276dbf3ce1c
# ╟─4677b43c-c63f-48e0-b465-d46669cae26c
# ╠═41744423-f827-4c19-9486-b7af624e870a
# ╟─3782ed86-5fb4-4909-a663-7ed1958d4547
# ╟─851deee7-398a-4207-b8f6-33184d32ec94
# ╟─87c2eaf7-f4ed-4073-bb75-eb412d2d16af
# ╟─14fed456-fc54-45fc-8bf7-a19a8c0c4053
# ╠═45c2ca69-ed76-4b8c-a180-533fdaf96839
# ╟─b102c7a9-b97b-41da-bf29-5159162ab375
# ╟─1ac601cb-7a77-4aa0-b548-06d11493fcfa
# ╠═c50a6863-d521-4ffa-a38f-17148f9bf989
# ╟─9ad7cb17-e429-44c8-a9a3-b23c8d8e2828
# ╟─9e3b530b-cce3-4071-9967-c08482d137f9
# ╠═ecbadf6a-89ff-4573-a6ba-b4b2439eeaa0
# ╠═d13eff59-05ad-4fee-bde6-2ef471ef5147
# ╟─b794cdc3-a5a7-403e-bc89-90b9c8bac2c0
# ╠═f632e55b-de04-48b3-b5fa-26786237d5e7
# ╠═d02ee3b1-26f0-415e-8d7e-9c4984847f80
# ╠═87b87566-299d-47c1-bfb5-1dbeb15e34cc
# ╠═ec5fa43c-1007-4ef7-8fc6-759a44efda85
# ╠═fae32917-e7bc-4c7e-a6ba-38d24ae0549c
# ╠═3c15833d-053b-4b77-9cd7-72b9a738f64d
# ╠═41f9e865-881c-41f2-bde3-19a5bc63fcec
# ╟─2d1fa256-e118-484a-945e-686cfd1ca7b8
# ╠═5434cfdb-d162-4417-902f-d946f5263a44
# ╠═6f18923f-30e2-4b3a-8844-dab963b64ccc
# ╟─6318cc8b-d01f-4b67-932f-efc61d714e78
# ╟─5c9cf6a6-00e5-420e-a861-0e6d5846b6fd
# ╠═ad568cdb-f45c-4d2e-b633-c50bcda76c6e
# ╠═2f3d50da-df1e-4d48-9123-91906364402a
# ╠═61dce3b6-8038-48e5-b203-cc4a74789d9b
# ╠═38c5e8b9-4329-4e43-b69b-bc69fe873fcf
# ╟─52607f2f-80e4-41cb-8ccc-c3e2da77ef09
# ╠═266ae844-93ec-4da0-8440-1c0f5f03738a
# ╟─4fb6ed42-cfbb-479d-abb3-6da661cb57f4
# ╟─acb2b0a3-9190-4d90-9d1b-1ecaa19f4932
# ╠═e09a7d61-de1c-4978-a1cd-a02cb8e00261
# ╟─ab39aba4-b919-43f9-a01d-b800d7290005
# ╠═90e928a8-6260-45d4-8021-1de7719066e2
# ╟─e8d802b6-9f23-4a80-90da-78d9e56838d4
# ╟─97a55b27-a010-4460-963d-b7ae172f3bc5
# ╠═b0dd49a6-8b75-4347-9551-bc9cd0513799
# ╠═3679af70-7a65-497e-b545-96b75448ba3a
# ╠═c73476e0-f156-44a8-8ce3-2ed128637bdf
# ╟─90311526-2758-4f80-a11b-93575814f863
# ╠═f81d07ae-a490-4772-94c8-9889d726b8fd
# ╠═c798ebbc-eebb-40f8-8ec7-df4d88315dfb
