FROM almalinux/almalinux:latest as builder
RUN dnf install clang go make libbpf-devel -y
WORKDIR /
COPY app .
RUN make

FROM scratch
COPY --from=builder /exec_scrape /exec_scrape
CMD ["/exec_scrape"]
