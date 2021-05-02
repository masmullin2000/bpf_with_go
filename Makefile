APP="exec_scrape"
REG="192.168.2.51:5000"

.PHONY: build
build: vmlinux
	docker build -t $(APP) .
	-docker rm -f dummy
	docker create -it --name dummy $(APP) /bin/sh
	docker cp dummy:$(APP) $(APP)
	docker rm -f dummy
	docker save $(APP) | gzip -9 > $(APP).tar.gz

.PHONY: push
push: build
	docker tag $(APP) $(REG)/$(APP)
	docker push $(REG)/$(APP)
	docker image remove $(REG)/$(APP)

.PHONY: rund
rund: build
	docker run -it --privileged -v /sys/kernel/debug:/sys/kernel/debug $(APP)

.PHONY: container
container: build
	docker run -it --privileged -v /sys/kernel/debug:/sys/kernel/debug $(APP) /bin/sh

.PHONY: vmlinux
vmlinux:
	cd app && make clean && make vmlinux

.PHONY: clean
clean:
	-docker system prune -a
	-rm -f $(APP)
	cd app && make clean