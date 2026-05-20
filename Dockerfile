FROM ubuntu:latest

# Install dependencies needed to download Luvit
RUN apt-get update && apt-get install -y curl git make gcc build-essential libssl-dev

WORKDIR /app

# Install Luvit runtime environment using the official universal installer script
RUN curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh
RUN mv luvi lit luvit /usr/local/bin/

# Copy your bot source code into the container
COPY . .

# Install modules correctly using the native lit package format
RUN lit install SinisterRectus/discordia
RUN lit install luvit/coro-http

# Run your Lua bot file
CMD ["luvit", "bot.lua"]
