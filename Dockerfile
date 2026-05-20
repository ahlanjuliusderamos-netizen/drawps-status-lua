FROM ubuntu:latest

# Install dependencies needed to download Luvit and unpack tarballs
RUN apt-get update && apt-get install -y curl git make gcc build-essential libssl-dev

WORKDIR /app

# Install Luvit runtime environment using the official universal installer script
RUN curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh
RUN mv luvi lit luvit /usr/local/bin/

# Create the standard Luvit local modules directory
RUN mkdir -p deps

# Download and extract Discordia and Coro-Http directly to bypass Git permission issues
RUN curl -L https://github.com/SinisterRectus/discordia/archive/refs/tags/v2.12.1.tar.gz | tar -xzf - -C deps/ && mv deps/discordia-2.12.1 deps/discordia
RUN curl -L https://github.com/luvit/coro-http/archive/refs/tags/v3.1.2.tar.gz | tar -xzf - -C deps/ && mv deps/coro-http-3.1.2 deps/coro-http

# Copy your bot source code into the container
COPY . .

# Run your Lua bot file
CMD ["luvit", "bot.lua"]
