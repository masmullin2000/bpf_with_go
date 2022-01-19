FROM almalinux:8.5 as builder
RUN dnf install epel-release dnf-plugins-core -y
#RUN dnf config-manager --enable epel -y
#RUN dnf repolist 
RUN dnf --enablerepo=powertools install clang go make libbpf-devel -y
WORKDIR /
COPY app .
RUN make

FROM scratch
COPY --from=builder /exec_scrape /exec_scrape
CMD ["/exec_scrape"]
