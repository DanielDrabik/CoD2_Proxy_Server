FROM gcc:latest AS builder

ARG FORWARD_IP=127.0.0.1

WORKDIR /build

COPY cod2proxy_lnxded.c .

RUN sed -i "s/127.0.0.1/${FORWARD_IP}/" cod2proxy_lnxded.c && \
    sed -i 's/inet_pton(AF_INET, FORWARD_IP, \&forward_addr.sin_addr);/struct addrinfo hints_fwd, *res_fwd; memset(\&hints_fwd, 0, sizeof(hints_fwd)); hints_fwd.ai_family = AF_INET; hints_fwd.ai_socktype = SOCK_DGRAM; if (getaddrinfo(FORWARD_IP, NULL, \&hints_fwd, \&res_fwd) == 0) { forward_addr.sin_addr = ((struct sockaddr_in*)res_fwd->ai_addr)->sin_addr; freeaddrinfo(res_fwd); }/' cod2proxy_lnxded.c && \
    gcc -o cod2proxy_lnxded cod2proxy_lnxded.c -lpthread -static

FROM alpine:latest

WORKDIR /app

COPY --from=builder /build/cod2proxy_lnxded .

ENTRYPOINT ["./cod2proxy_lnxded"]
