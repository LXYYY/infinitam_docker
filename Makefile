.PHONY: build run-root run attach run-nvidia

XAUTH:=/tmp/.docker.xauth
CUDA_VERSION:=7
ROS_VERSION:=indigo
UBUNTU_VERSION:=trusty
DOCKER_NAME:=infinitam:$(ROS_VERSION)-cuda$(TF_VERSION)
ROS_PACKAGE:=perception

build:
	@docker build -t ros-cuda:$(ROS_VERSION)-cuda$(CUDA_VERSION) ros_cuda$(CUDA_VERSION)/.
	@docker build --build-arg myuser=${shell whoami} \
		--build-arg CUDA_SET_VERSION=$(CUDA_VERSION)\
		--build-arg ROS_SET_VERSION=$(ROS_VERSION)\
		--build-arg UBUNTU_SET_VERSION=$(UBUNTU_VERSION)\
		-t $(DOCKER_NAME)-$(ROS_PACKAGE) .
run:
	make build
	#touch $(XAUTH)
	#xauth nlist ${DISPLAY} | sed -e 's/^..../ffff/' | xauth -f $(XAUTH) nmerge - 
	nvidia-docker run -it --gpus all --name voxgraph  --rm \
	   --env="DISPLAY=${DISPLAY}" \
	   --env="QT_X11_NO_MITSHM=1" \
	   --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
	   -e XAUTHORITY=$(XAUTH) \
	   --volume="$(XAUTH):$(XAUTH)" \
	   -e HOME=${HOME} \
	   -u ${shell whoami} \
	   -v /etc/localtime:/etc/localtime \
	   -v ${HOME}/Workspace/infiniTAM_ws:${HOME}/Workspace/infiniTAM_ws \
	   --security-opt seccomp=unconfined \
	   --net=host \
	   --privileged \
	   $(DOCKER_NAME)-perception

attach:
	docker exec -it $(DOCKER_NAME) /bin/bash


