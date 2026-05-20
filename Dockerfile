FROM ubuntu:latest

# Install dependencies needed to download Luvit
RUN apt-get update && apt-get install -y curl git make gcc build-essential libssl-dev

WORKDIR /app

# Install Luvit runtime environment
RUN curl -L https://lit.luvit.io/packages/luvit/stable/linux/amd64 | sh
RUN mv luvi lit luvit /usr/local/bin/

# Copy your bot source code into the container
COPY . .

# Install the required Discordia modules
RUN lit install SinisterRectus/discordia
RUN lit install luvit/coro-http
RUN lit install creativecreatures/json

# Run your Lua bot file
CMD ["luvit", "bot.lua"]
