### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03d16bf0-9e19-11eb-08cb-b920ab55344c
md"""
# Networking and Streams
"""

# ╔═╡ 03d16d0a-9e19-11eb-24e5-eda0ca00213e
md"""
Julia provides a rich interface to deal with streaming I/O objects such as terminals, pipes and TCP sockets. This interface, though asynchronous at the system level, is presented in a synchronous manner to the programmer and it is usually unnecessary to think about the underlying asynchronous operation. This is achieved by making heavy use of Julia cooperative threading ([coroutine](@ref man-tasks)) functionality.
"""

# ╔═╡ 03d16d46-9e19-11eb-2ee9-455b1102d2a3
md"""
## Basic Stream I/O
"""

# ╔═╡ 03d16d82-9e19-11eb-0b6e-91986eefcc70
md"""
All Julia streams expose at least a [`read`](@ref) and a [`write`](@ref) method, taking the stream as their first argument, e.g.:
"""

# ╔═╡ 03d17408-9e19-11eb-06be-49f571e38a7a
write(stdout, "Hello World");  # suppress return value 11 with ;

# ╔═╡ 03d17426-9e19-11eb-200f-9976cc2cf745
read(stdin, Char)

# ╔═╡ 03d17460-9e19-11eb-3af6-4b36273b7df6
md"""
Note that [`write`](@ref) returns 11, the number of bytes (in `"Hello World"`) written to [`stdout`](@ref), but this return value is suppressed with the `;`.
"""

# ╔═╡ 03d17492-9e19-11eb-236a-57eb55b30520
md"""
Here Enter was pressed again so that Julia would read the newline. Now, as you can see from this example, [`write`](@ref) takes the data to write as its second argument, while [`read`](@ref) takes the type of the data to be read as the second argument.
"""

# ╔═╡ 03d174a8-9e19-11eb-18dd-f761f84e0d24
md"""
For example, to read a simple byte array, we could do:
"""

# ╔═╡ 03d177a2-9e19-11eb-0d73-05b0a29c0ee8
x = zeros(UInt8, 4)

# ╔═╡ 03d177a2-9e19-11eb-359a-d565dcbcfdff
read!(stdin, x)

# ╔═╡ 03d177c8-9e19-11eb-171e-a7a0d73e04b5
md"""
However, since this is slightly cumbersome, there are several convenience methods provided. For example, we could have written the above as:
"""

# ╔═╡ 03d178d6-9e19-11eb-1996-6dfdd25cb44f
read(stdin, 4)

# ╔═╡ 03d178f4-9e19-11eb-06c0-1527353c7f79
md"""
or if we had wanted to read the entire line instead:
"""

# ╔═╡ 03d179b2-9e19-11eb-232e-dfce7e1034a3
readline(stdin)

# ╔═╡ 03d179c6-9e19-11eb-2d66-ad58b345fa27
md"""
Note that depending on your terminal settings, your TTY may be line buffered and might thus require an additional enter before the data is sent to Julia.
"""

# ╔═╡ 03d17a0c-9e19-11eb-012f-9b74c4c7ba59
md"""
To read every line from [`stdin`](@ref) you can use [`eachline`](@ref):
"""

# ╔═╡ 03d17a52-9e19-11eb-2c6a-03040b6a405d
md"""
```julia
for line in eachline(stdin)
    print("Found $line")
end
```
"""

# ╔═╡ 03d17a72-9e19-11eb-31ed-e7665b9335ab
md"""
or [`read`](@ref) if you wanted to read by character instead:
"""

# ╔═╡ 03d17a8e-9e19-11eb-3302-65a9a7b64adf
md"""
```julia
while !eof(stdin)
    x = read(stdin, Char)
    println("Found: $x")
end
```
"""

# ╔═╡ 03d17a98-9e19-11eb-133f-3fcd96b3c8a6
md"""
## Text I/O
"""

# ╔═╡ 03d17ab6-9e19-11eb-26de-33154050a12c
md"""
Note that the [`write`](@ref) method mentioned above operates on binary streams. In particular, values do not get converted to any canonical text representation but are written out as is:
"""

# ╔═╡ 03d17c46-9e19-11eb-2af4-7127f267ec13
write(stdout, 0x61);  # suppress return value 1 with ;

# ╔═╡ 03d17c82-9e19-11eb-0648-c56f3fa16150
md"""
Note that `a` is written to [`stdout`](@ref) by the [`write`](@ref) function and that the returned value is `1` (since `0x61` is one byte).
"""

# ╔═╡ 03d17caa-9e19-11eb-36f5-c5c2d13e7fb2
md"""
For text I/O, use the [`print`](@ref) or [`show`](@ref) methods, depending on your needs (see the documentation for these two methods for a detailed discussion of the difference between them):
"""

# ╔═╡ 03d17db8-9e19-11eb-3eb5-fd8843910a1b
print(stdout, 0x61)

# ╔═╡ 03d17de0-9e19-11eb-1906-f1f06162dfe0
md"""
See [Custom pretty-printing](@ref man-custom-pretty-printing) for more information on how to implement display methods for custom types.
"""

# ╔═╡ 03d17dea-9e19-11eb-20ff-43b1add2daf7
md"""
## IO Output Contextual Properties
"""

# ╔═╡ 03d17e1c-9e19-11eb-3c23-0dc364248408
md"""
Sometimes IO output can benefit from the ability to pass contextual information into show methods. The [`IOContext`](@ref) object provides this framework for associating arbitrary metadata with an IO object. For example, `:compact => true` adds a hinting parameter to the IO object that the invoked show method should print a shorter output (if applicable). See the [`IOContext`](@ref) documentation for a list of common properties.
"""

# ╔═╡ 03d17e30-9e19-11eb-0d17-6b6ba8cd9cde
md"""
## Working with Files
"""

# ╔═╡ 03d17e6c-9e19-11eb-0e88-afa42b367719
md"""
Like many other environments, Julia has an [`open`](@ref) function, which takes a filename and returns an [`IOStream`](@ref) object that you can use to read and write things from the file. For example, if we have a file, `hello.txt`, whose contents are `Hello, World!`:
"""

# ╔═╡ 03d180e2-9e19-11eb-3b97-c934b1fcdc58
f = open("hello.txt")

# ╔═╡ 03d180ec-9e19-11eb-2774-21ef3dfcc552
readlines(f)

# ╔═╡ 03d1810a-9e19-11eb-2d92-5bc7913c3680
md"""
If you want to write to a file, you can open it with the write (`"w"`) flag:
"""

# ╔═╡ 03d18470-9e19-11eb-3e48-196a7d078456
f = open("hello.txt","w")

# ╔═╡ 03d1847c-9e19-11eb-29eb-8f47d1f831e6
write(f,"Hello again.")

# ╔═╡ 03d18498-9e19-11eb-1a43-6f192ce1e51b
md"""
If you examine the contents of `hello.txt` at this point, you will notice that it is empty; nothing has actually been written to disk yet. This is because the `IOStream` must be closed before the write is actually flushed to disk:
"""

# ╔═╡ 03d18574-9e19-11eb-3313-15633b05d026
close(f)

# ╔═╡ 03d18592-9e19-11eb-09ba-bd5427ba1ade
md"""
Examining `hello.txt` again will show its contents have been changed.
"""

# ╔═╡ 03d185b2-9e19-11eb-09e5-bd384f31f867
md"""
Opening a file, doing something to its contents, and closing it again is a very common pattern. To make this easier, there exists another invocation of [`open`](@ref) which takes a function as its first argument and filename as its second, opens the file, calls the function with the file as an argument, and then closes it again. For example, given a function:
"""

# ╔═╡ 03d185c4-9e19-11eb-0d89-01e41b6bda5c
md"""
```julia
function read_and_capitalize(f::IOStream)
    return uppercase(read(f, String))
end
```
"""

# ╔═╡ 03d185e0-9e19-11eb-1338-29027d3e4e45
md"""
You can call:
"""

# ╔═╡ 03d1871a-9e19-11eb-075d-3bd1dcd569a3
open(read_and_capitalize, "hello.txt")

# ╔═╡ 03d1872c-9e19-11eb-2ba9-ad19a79e6a1b
md"""
to open `hello.txt`, call `read_and_capitalize` on it, close `hello.txt` and return the capitalized contents.
"""

# ╔═╡ 03d1875e-9e19-11eb-0150-4531c5eba80f
md"""
To avoid even having to define a named function, you can use the `do` syntax, which creates an anonymous function on the fly:
"""

# ╔═╡ 03d18a10-9e19-11eb-233a-0d0972ae7db1
open("hello.txt") do f
           uppercase(read(f, String))
       end

# ╔═╡ 03d18a24-9e19-11eb-3c94-a568f3ab94f6
md"""
## A simple TCP example
"""

# ╔═╡ 03d18a38-9e19-11eb-259f-47ce78e46a04
md"""
Let's jump right in with a simple example involving TCP sockets. This functionality is in a standard library package called `Sockets`. Let's first create a simple server:
"""

# ╔═╡ 03d19050-9e19-11eb-079b-13c5b9111b60
using Sockets

# ╔═╡ 03d19050-9e19-11eb-22b8-4128efbb496e
@async begin
           server = listen(2000)
           while true
               sock = accept(server)
               println("Hello World\n")
           end
       end

# ╔═╡ 03d19082-9e19-11eb-20fc-eb962ce8f64a
md"""
To those familiar with the Unix socket API, the method names will feel familiar, though their usage is somewhat simpler than the raw Unix socket API. The first call to [`listen`](@ref) will create a server waiting for incoming connections on the specified port (2000) in this case. The same function may also be used to create various other kinds of servers:
"""

# ╔═╡ 03d19ad2-9e19-11eb-3db6-257f3212832b
listen(2000) # Listens on localhost:2000 (IPv4)

# ╔═╡ 03d19ae6-9e19-11eb-1744-f55c08f9ce90
listen(ip"127.0.0.1",2000) # Equivalent to the first

# ╔═╡ 03d19af0-9e19-11eb-1132-67f1bca33c44
listen(ip"::1",2000) # Listens on localhost:2000 (IPv6)

# ╔═╡ 03d19af0-9e19-11eb-179c-33dc30c707b8
listen(IPv4(0),2001) # Listens on port 2001 on all IPv4 interfaces

# ╔═╡ 03d19af0-9e19-11eb-16f8-3b4bb799ff27
listen(IPv6(0),2001) # Listens on port 2001 on all IPv6 interfaces

# ╔═╡ 03d19af8-9e19-11eb-2c48-61b5daafaad1
listen("testsocket") # Listens on a UNIX domain socket

# ╔═╡ 03d19b04-9e19-11eb-2c3b-c9a0aae10eb9
listen("\\\\.\\pipe\\testsocket") # Listens on a Windows named pipe

# ╔═╡ 03d19b5e-9e19-11eb-1c3f-6db35b7c3562
md"""
Note that the return type of the last invocation is different. This is because this server does not listen on TCP, but rather on a named pipe (Windows) or UNIX domain socket. Also note that Windows named pipe format has to be a specific pattern such that the name prefix (`\\.\pipe\`) uniquely identifies the [file type](https://docs.microsoft.com/windows/desktop/ipc/pipe-names). The difference between TCP and named pipes or UNIX domain sockets is subtle and has to do with the [`accept`](@ref) and [`connect`](@ref) methods. The [`accept`](@ref) method retrieves a connection to the client that is connecting on the server we just created, while the [`connect`](@ref) function connects to a server using the specified method. The [`connect`](@ref) function takes the same arguments as [`listen`](@ref), so, assuming the environment (i.e. host, cwd, etc.) is the same you should be able to pass the same arguments to [`connect`](@ref) as you did to listen to establish the connection. So let's try that out (after having created the server above):
"""

# ╔═╡ 03d19d3e-9e19-11eb-245a-9d2e3d681a29
connect(2000)

# ╔═╡ 03d19d3e-9e19-11eb-294b-577445d28010
Hello World

# ╔═╡ 03d19d7a-9e19-11eb-04ac-51f99032e8af
md"""
As expected we saw "Hello World" printed. So, let's actually analyze what happened behind the scenes. When we called [`connect`](@ref), we connect to the server we had just created. Meanwhile, the accept function returns a server-side connection to the newly created socket and prints "Hello World" to indicate that the connection was successful.
"""

# ╔═╡ 03d19da2-9e19-11eb-2865-dbbad22c3c41
md"""
A great strength of Julia is that since the API is exposed synchronously even though the I/O is actually happening asynchronously, we didn't have to worry about callbacks or even making sure that the server gets to run. When we called [`connect`](@ref) the current task waited for the connection to be established and only continued executing after that was done. In this pause, the server task resumed execution (because a connection request was now available), accepted the connection, printed the message and waited for the next client. Reading and writing works in the same way. To see this, consider the following simple echo server:
"""

# ╔═╡ 03d1a9da-9e19-11eb-1f48-a3d047a58af6
@async begin
           server = listen(2001)
           while true
               sock = accept(server)
               @async while isopen(sock)
                   write(sock, readline(sock, keep=true))
               end
           end
       end

# ╔═╡ 03d1a9e6-9e19-11eb-31e7-23b780525e93
clientside = connect(2001)

# ╔═╡ 03d1a9fa-9e19-11eb-3ca9-89bd78c8080b
@async while isopen(clientside)
           write(stdout, readline(clientside, keep=true))
       end

# ╔═╡ 03d1aa0c-9e19-11eb-0b18-5deeeae219ae
println(clientside,"Hello World from the Echo Server")

# ╔═╡ 03d1aa2c-9e19-11eb-26bc-9dd311cf9ea8
md"""
As with other streams, use [`close`](@ref) to disconnect the socket:
"""

# ╔═╡ 03d1aae2-9e19-11eb-3c76-177ece9658c2
close(clientside)

# ╔═╡ 03d1aafe-9e19-11eb-0f9e-61efc0c9d004
md"""
## Resolving IP Addresses
"""

# ╔═╡ 03d1ab26-9e19-11eb-1f6d-934115180cbd
md"""
One of the [`connect`](@ref) methods that does not follow the [`listen`](@ref) methods is `connect(host::String,port)`, which will attempt to connect to the host given by the `host` parameter on the port given by the `port` parameter. It allows you to do things like:
"""

# ╔═╡ 03d1ac98-9e19-11eb-2d85-ab4551dc1140
connect("google.com", 80)

# ╔═╡ 03d1acc0-9e19-11eb-0265-4110c46324a7
md"""
At the base of this functionality is [`getaddrinfo`](@ref), which will do the appropriate address resolution:
"""

# ╔═╡ 03d1ae0a-9e19-11eb-1f2b-5dbc3af9b0f6
getaddrinfo("google.com")

# ╔═╡ 03d1ae1e-9e19-11eb-09ef-af69b9361b96
md"""
## Asynchronous I/O
"""

# ╔═╡ 03d1ae50-9e19-11eb-3f66-670275664c0c
md"""
All I/O operations exposed by [`Base.read`](@ref) and [`Base.write`](@ref) can be performed asynchronously through the use of [coroutines](@ref man-tasks). You can create a new coroutine to read from or write to a stream using the [`@async`](@ref) macro:
"""

# ╔═╡ 03d1b424-9e19-11eb-2ef3-157a407b8fd8
task = @async open("foo.txt", "w") do io
           write(io, "Hello, World!")
       end;

# ╔═╡ 03d1b440-9e19-11eb-0dc9-8d7c4a057976
wait(task)

# ╔═╡ 03d1b440-9e19-11eb-26be-935ce02549b9
readlines("foo.txt")

# ╔═╡ 03d1b468-9e19-11eb-1c58-01d0f81ac5c4
md"""
It's common to run into situations where you want to perform multiple asynchronous operations concurrently and wait until they've all completed. You can use the [`@sync`](@ref) macro to cause your program to block until all of the coroutines it wraps around have exited:
"""

# ╔═╡ 03d1be22-9e19-11eb-1c35-5555700580a9
using Sockets

# ╔═╡ 03d1be4a-9e19-11eb-1acc-f3325d511022
@sync for hostname in ("google.com", "github.com", "julialang.org")
           @async begin
               conn = connect(hostname, 80)
               write(conn, "GET / HTTP/1.1\r\nHost:$(hostname)\r\n\r\n")
               readline(conn, keep=true)
               println("Finished connection to $(hostname)")
           end
       end

# ╔═╡ Cell order:
# ╟─03d16bf0-9e19-11eb-08cb-b920ab55344c
# ╟─03d16d0a-9e19-11eb-24e5-eda0ca00213e
# ╟─03d16d46-9e19-11eb-2ee9-455b1102d2a3
# ╟─03d16d82-9e19-11eb-0b6e-91986eefcc70
# ╠═03d17408-9e19-11eb-06be-49f571e38a7a
# ╠═03d17426-9e19-11eb-200f-9976cc2cf745
# ╟─03d17460-9e19-11eb-3af6-4b36273b7df6
# ╟─03d17492-9e19-11eb-236a-57eb55b30520
# ╟─03d174a8-9e19-11eb-18dd-f761f84e0d24
# ╠═03d177a2-9e19-11eb-0d73-05b0a29c0ee8
# ╠═03d177a2-9e19-11eb-359a-d565dcbcfdff
# ╟─03d177c8-9e19-11eb-171e-a7a0d73e04b5
# ╠═03d178d6-9e19-11eb-1996-6dfdd25cb44f
# ╟─03d178f4-9e19-11eb-06c0-1527353c7f79
# ╠═03d179b2-9e19-11eb-232e-dfce7e1034a3
# ╟─03d179c6-9e19-11eb-2d66-ad58b345fa27
# ╟─03d17a0c-9e19-11eb-012f-9b74c4c7ba59
# ╟─03d17a52-9e19-11eb-2c6a-03040b6a405d
# ╟─03d17a72-9e19-11eb-31ed-e7665b9335ab
# ╟─03d17a8e-9e19-11eb-3302-65a9a7b64adf
# ╟─03d17a98-9e19-11eb-133f-3fcd96b3c8a6
# ╟─03d17ab6-9e19-11eb-26de-33154050a12c
# ╠═03d17c46-9e19-11eb-2af4-7127f267ec13
# ╟─03d17c82-9e19-11eb-0648-c56f3fa16150
# ╟─03d17caa-9e19-11eb-36f5-c5c2d13e7fb2
# ╠═03d17db8-9e19-11eb-3eb5-fd8843910a1b
# ╟─03d17de0-9e19-11eb-1906-f1f06162dfe0
# ╟─03d17dea-9e19-11eb-20ff-43b1add2daf7
# ╟─03d17e1c-9e19-11eb-3c23-0dc364248408
# ╟─03d17e30-9e19-11eb-0d17-6b6ba8cd9cde
# ╟─03d17e6c-9e19-11eb-0e88-afa42b367719
# ╠═03d180e2-9e19-11eb-3b97-c934b1fcdc58
# ╠═03d180ec-9e19-11eb-2774-21ef3dfcc552
# ╟─03d1810a-9e19-11eb-2d92-5bc7913c3680
# ╠═03d18470-9e19-11eb-3e48-196a7d078456
# ╠═03d1847c-9e19-11eb-29eb-8f47d1f831e6
# ╟─03d18498-9e19-11eb-1a43-6f192ce1e51b
# ╠═03d18574-9e19-11eb-3313-15633b05d026
# ╟─03d18592-9e19-11eb-09ba-bd5427ba1ade
# ╟─03d185b2-9e19-11eb-09e5-bd384f31f867
# ╟─03d185c4-9e19-11eb-0d89-01e41b6bda5c
# ╟─03d185e0-9e19-11eb-1338-29027d3e4e45
# ╠═03d1871a-9e19-11eb-075d-3bd1dcd569a3
# ╟─03d1872c-9e19-11eb-2ba9-ad19a79e6a1b
# ╟─03d1875e-9e19-11eb-0150-4531c5eba80f
# ╠═03d18a10-9e19-11eb-233a-0d0972ae7db1
# ╟─03d18a24-9e19-11eb-3c94-a568f3ab94f6
# ╟─03d18a38-9e19-11eb-259f-47ce78e46a04
# ╠═03d19050-9e19-11eb-079b-13c5b9111b60
# ╠═03d19050-9e19-11eb-22b8-4128efbb496e
# ╟─03d19082-9e19-11eb-20fc-eb962ce8f64a
# ╠═03d19ad2-9e19-11eb-3db6-257f3212832b
# ╠═03d19ae6-9e19-11eb-1744-f55c08f9ce90
# ╠═03d19af0-9e19-11eb-1132-67f1bca33c44
# ╠═03d19af0-9e19-11eb-179c-33dc30c707b8
# ╠═03d19af0-9e19-11eb-16f8-3b4bb799ff27
# ╠═03d19af8-9e19-11eb-2c48-61b5daafaad1
# ╠═03d19b04-9e19-11eb-2c3b-c9a0aae10eb9
# ╟─03d19b5e-9e19-11eb-1c3f-6db35b7c3562
# ╠═03d19d3e-9e19-11eb-245a-9d2e3d681a29
# ╠═03d19d3e-9e19-11eb-294b-577445d28010
# ╟─03d19d7a-9e19-11eb-04ac-51f99032e8af
# ╟─03d19da2-9e19-11eb-2865-dbbad22c3c41
# ╠═03d1a9da-9e19-11eb-1f48-a3d047a58af6
# ╠═03d1a9e6-9e19-11eb-31e7-23b780525e93
# ╠═03d1a9fa-9e19-11eb-3ca9-89bd78c8080b
# ╠═03d1aa0c-9e19-11eb-0b18-5deeeae219ae
# ╟─03d1aa2c-9e19-11eb-26bc-9dd311cf9ea8
# ╠═03d1aae2-9e19-11eb-3c76-177ece9658c2
# ╟─03d1aafe-9e19-11eb-0f9e-61efc0c9d004
# ╟─03d1ab26-9e19-11eb-1f6d-934115180cbd
# ╠═03d1ac98-9e19-11eb-2d85-ab4551dc1140
# ╟─03d1acc0-9e19-11eb-0265-4110c46324a7
# ╠═03d1ae0a-9e19-11eb-1f2b-5dbc3af9b0f6
# ╟─03d1ae1e-9e19-11eb-09ef-af69b9361b96
# ╟─03d1ae50-9e19-11eb-3f66-670275664c0c
# ╠═03d1b424-9e19-11eb-2ef3-157a407b8fd8
# ╠═03d1b440-9e19-11eb-0dc9-8d7c4a057976
# ╠═03d1b440-9e19-11eb-26be-935ce02549b9
# ╟─03d1b468-9e19-11eb-1c58-01d0f81ac5c4
# ╠═03d1be22-9e19-11eb-1c35-5555700580a9
# ╠═03d1be4a-9e19-11eb-1acc-f3325d511022
