FROM ubuntu:latest

# Install dependencies needed to download Luvit and unpack tarballs
RUN apt-get update && apt-get install -y curl git make gcc build-essential libssl-dev

WORKDIR /app

# Install Luvit runtime environment using the official universal installer script
RUN curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh
RUN mv luvi lit luvit /usr/local/bin/

# Create the standard Luvit local modules directory
RUN mkdir -p deps

# Download and extract Discordia and Coro-Http directly from their master branches
RUN curl -L https://github.com/SinisterRectus/discordia/archive/refs/heads/master.tar.gz | tar -xzf - -C deps/ && mv deps/discordia-master deps/discordia
RUN curl -L https://github.com/luvit/coro-http/archive/refs/heads/master.tar.gz | tar -xzf - -C deps/ && mv deps/coro-http-master deps/coro-http

# Copy your bot source code into the container
COPY . .

# Run your Lua bot file
CMD ["luvit", "bot.lua"]
