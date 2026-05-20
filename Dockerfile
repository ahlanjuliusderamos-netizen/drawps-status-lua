FROM ubuntu:latest

# Install dependencies needed to download Luvit and unpack tarballs
RUN apt-get update && apt-get install -y curl git make gcc build-essential libssl-dev

WORKDIR /app

# Install Luvit runtime environment using the official universal installer script
RUN curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh
RUN mv luvi lit luvit /usr/local/bin/

# Pre-create the exact target folders for your modules
RUN mkdir -p deps/discordia deps/coro-http

# Download and extract directly into their folders, stripping the messy GitHub root folder name
RUN curl -L https://github.com/SinisterRectus/discordia/archive/refs/heads/master.tar.gz | tar -xzf - -C deps/discordia --strip-components=1
RUN curl -L https://github.com/luvit/coro-http/archive/refs/heads/master.tar.gz | tar -xzf - -C deps/coro-http --strip-components=1

# Copy your bot source code into the container
COPY . .

# Run your Lua bot file
CMD ["luvit", "bot.lua"]
