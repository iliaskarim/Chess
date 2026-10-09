FROM swift:6.0-jammy

WORKDIR /app

COPY . .

# Allow resolving package dependencies that use git@github.com: URLs
# RUN git config --global url."https://github.com/".insteadOf "git@github.com:" \

RUN swift build -c release

CMD [".build/release/Chess"]
