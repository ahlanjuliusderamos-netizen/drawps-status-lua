FROM ubuntu:latest

# Install dependencies needed to download Luvit and clone git repositories
RUN apt-get update && apt-get install -y curl git make gcc build-essential libssl-dev

WORKDIR /app

# Install Luvit runtime environment using the official universal installer script
RUN curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh
RUN mv luvi lit luvit /usr/local/bin/

# Create the standard Luvit local modules directory
RUN mkdir -p deps

# Tell Git to rewrite old SSH submodule links to public HTTPS links (bypasses username prompt)
RUN git config --global url."https://github.com/".insteadOf "git@github.com:"

# Manually clone the required modules recursively with all dependencies included
RUN git clone --recursive https://github.com/SinisterRectus/discordia.git deps/discordia
RUN git clone --recursive https://github.com/luvit/coro-http.git deps/coro-http

# Copy your bot source code into the container
COPY . .

# Run your Lua bot file
CMD ["luvit", "bot.lua"]
