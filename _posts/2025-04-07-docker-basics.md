---
title: Docker - Basic Guide
date: 2025-04-07 16:35:00 +0200
categories: [Guides]
tags: [Docker]
description: Mini Docker handbook. Understand Docker architecture and concepts from the beginning.
---
> This post is currently in progress
{: .prompt-info }

**It works on my computer!**
And that's how Docker is born.

Jokes aside, before Docker, if you wanted to share a project under the same conditions, you would have to be on the same OS, download the code, the dependencies, execute the project in a certain way etc.

Nowadays, you can create **containers** that **encapsulate** all of that and can be **run on every machine**, because all of it is "contained" 😉 on it. By running the container you are replicating the same environment, soooo no more: It works on my computer justification is possible!

## 1. Basic Infrastructure - Virutal Machines (VMs) and Containers
To understand Docker, it's really useful to first understand **how it works at hardware level**, and its advantages against using a VM.

### Virtual Machine (VM)
A VM is a software-based emulation of a physical computer allowing it to run a **separate operating system** and applications within a **single host machine**. [](https://azure.microsoft.com/en-us/resources/cloud-computing-dictionary/what-is-a-virtual-machine#:~:text=A%20virtual%20machine%20(VM)%20is,02/)

Meaning - you can have on your computer, another full-blown machine with its own operating system and kernel.

**What is the infrastructure that makes this possible?**


The key underlying technology behind virtualization are **hypervisors**, which act as **intermediaries between the physical hardware and the VMs**, allocating resources like CPU, memory and storage.

#### Types of hypervisors
##### Type 1


The de facto standard for enterprise-class virtualization.
This hypervisor has a **direct connection to the hardware**, thus achieving a really good performance with little latency.


![Virtual Machine Infrastructure - Hypervisors Type 1](../assets/img/vm-hypervisorsT1.svg)

##### Type 2


Type 2 hypervisors are installed **on top of an existing host OS**, which introduces latency, and compromises the VMs running on top of the host if any security flaws or vulnerabilities arises.

But, this makes it **simpler and faster to set up** and use for light tasks, becoming really useful for chores such as testing a software product prior to release or learning a new OS.

![Virtual Machine Infrastructure - Hypervisors Type 2](../assets/img/vm-hypervisorsT2.svg)


### Docker Container
Containers offer a new perspective, instead of abstracting the physical hardware, which requires a full copy of an OS, binaries, libraries, etc taking up tens of GBs; containers only virtualize software layers above the operating system level.

This results in lightweight, fast and portable environments, but because all containers on the same machine share the host OS kernel, a vulnerability there can be exploited by a compromised container, potentially leading to a complete system compromise.

Note: dive deeper on some other section maybe on risks and how to prevent them? all containers on the same machine will share the OS kernel, so a vulnerability in the kernel can affect all containers. 
1. (https://sysdig.com/learn-cloud-native/container-security-best-practices/#:~:text=Protect%20your%20resources,layer%20for%20filtering%20network%20requests.)
 2.(https://infosecwriteups.com/unmasking-containers-processes-through-the-hosts-lens-57bbe4e3ed74)
3. https://docs.docker.com/engine/security/

![Virtual Machine Infrastructure - Hypervisors Type 1](../assets/img/docker-containers.svg)


The key point to understand is:
* VMs isolation comes by abstracting the physical hardware - you can see each VM as a separate computer which needs an hypervisor as an intermediary between them and the hardware
* Docker containers isolation comes from the application layer - you can see each container as an isolated process on the host OS, which needs a runtime as an intermediary between them and the OS

 NOTE: add limitations on containers because they share host OS kernel. How to run containers with linux image in windows.


## 2. Key Docker Concepts
### Image

#### Definition
Template or package used to create a container. Includes everything you need to run the container: code, dependencies, libraries and environment variables.

You can create your own images, to include exactly what you need. To gather together all instructions required to build an image, you can specify them formally in a text file, called **Dockerfile**.

> [Instructions supported by Dockerfile](https://docs.docker.com/reference/dockerfile/#overview).


#### Image layers
A Docker image consists of one or more layers, each layer representing an instruction in the images' Dockerfile (but not every instruction generates a layer). Each layer is identified by a unique hash and every layer is read-only.

Examples:
```Dockerfile
FROM ubuntu:22.04
```
This `FROM` statement creates a layer from the `ubuntu:22.04` image.

> Already created images can be reused as the base of your image. There are official ready to use Docker images available on [Docker Hub public registry](https://hub.docker.com/search?badges=official). 

```Dockerfile
LABEL org.opencontainers.image.authors="org@example.com"
```
The `LABEL` command, only modifies the image metadata, and doesn't produce a new layer.


When you run a Docker container from an image, Docker creates a writable layer on top of the image layers, called the container layer. This layer stores any changes that are made to the container during its lifetime. But this last layer is discarded when the container is stopped or deleted (check Docker Volumes and storage drivers if you want to persist changes after container lifetime).


<figure style="text-align: center;">
  <img src="../assets/img/container-layers.webp" alt="Docker layers" style="max-width: 100%; width: 400px; height: auto;">
  <figcaption style="margin-top: 0.5em; font-size: 0.9em; color: gray;">
    Docker layers
  </figcaption>
</figure>

##### Layers efficiency
Each layer is only a set of differences from the layer before it. Both adding, and removing files will result in a new layer.

Altough you could set instructions in different ways, there are best practices to improve image efficiency (less memory usage, faster builds, faster pipelines etc)

Using this code as an example:
> Keep in mind that `apt-get update` command will download package indexes into `/var/lib/apt/lists`

```Dockerfile
# Two layers
RUN apt-get update
RUN rm -rf /var/lib/apt/lists/*

# One layer
RUN apt-get update && rm -rf /var/lib/apt/lists/*
```

The first scenario will generate two different layers. The first layer will have the `/var/lib/apt/lists/*` directory available, altough it's later removed in the next instruction. This will cause a larger image size.

In the second scenario, only produces one layer, and the directory removed will never be part of the image.

Let's reproduce this scenario and verify the image size is actually smaller:

1. Generate both Dockerfiles:

```Dockerfile
# Dockerfile.bad
FROM ubuntu:20.04
RUN apt-get update
RUN rm -rf /var/lib/apt/lists/*
```

```Dockerfile
# Dockerfile.good
FROM ubuntu:20.04
RUN apt-get update && rm -rf /var/lib/apt/lists/*
```

2. Build both images:

```shell
docker build -f Dockerfile.bad -t bad-image .
docker build -f Dockerfile.good -t good-image .
```

3. Compare their sizes

```shell
docker images | grep image
```
![Images sizes](../assets/img/images_size.png)

4. Inspect image layers

```sh
docker history bad-image
```
![Bad-Image layers](../assets/img/badimage-layers.png)

As you can see, this Docker image contains 8 layers. Looking at the two top rows:
- `RUN apt-get update` creates a new layer (~58.3MB), the data is stored permanently in this layer's snapshot
- `RUN rm -rf /var/lib/apt/lists/*` creates another layer (0B), the files are removed but this operation doesn't shrink the earlier layer, it only makes them _invisible_ in the final container filesystem.

Final image size = 72.8 MB (base image) + 58.3MB (apt-get) ~= 131MB


```
docker history good-image
```
![Good-Image layers](../assets/img/goodimage-layers.png)
This other image has only 7 layers. You can verify that the one-liner instruction (`apt-get ...` and `rm ...`) won't take up any space when run, because the files generated by the `apt-get update` are removed in the same `RUN` step

Final image size = 72.8 MB (base image)
>58.2 less MB than the previous image.

5. Conclusion


Obviosuly this is a toy scenario, but it easily demonstrates how we need to be careful on how we define our `Dockerfiles`, because it has a direct impact on the images efficiency.



### Container
Running instance of an image. Multiple containers can be created from a single image.

As Dockerfiles are used to create the _recipe_ to create an image. The **docker-compose** file is defined for
running multi-container applications, specifying how each container it's created (underlying image etc) and how the running containers can communicate.

NOTE: dive a bit deeper on container being processes (https://labs.iximiuz.com/tutorials/containers-are-processes-d17b1df8)
https://www.youtube.com/watch?v=7CKCWqUkMJ4
https://securitylabs.datadoghq.com/articles/container-security-fundamentals-part-1/


### Docker Host

## 3. Docker Engine
> With knowledge of Basic Docker infra + key docker concepts + key linux concepts.
> Think where to put it. maybe after linux concepts?

- Daemon, Docker engine RESTful API, Client, Socket communication


## 4. Essential Linux Concepts for Understanding Docker
- Port Mapping (Ports & IPs)
- Volume Mounting (Volumes & Mounts)
- Process Isolation (Namespaces & PIDs)
- Resource Limits (Control Groups)




## 5. Dockerfile - Build Images
- Layered Architecture (COW), Storage Drivers
- CMD vs Entrypoint
-  multi-stage builds

## 6. Docker Compose - Run multiple containers
- dedicated bridge network, communicate with service names (Internal DNS Server)

## 7. Docker Registry
- How registries work
- Internal private registries
- Tags to specify registry
- Push


## 8. Networking
- Default networks
- user defined networks
- network namespaces
- veth pairs

## 9. Container Orchestration - The need of using an orchestrator
- Brief intro to why orchestrator is needed
- Why Docker alone isn't enough



# Resources
- [Hypervisor types](https://www.techtarget.com/searchitoperations/tip/Whats-the-difference-between-Type-1-vs-Type-2-hypervisor#:~:text=A%20Type%201%20hypervisor%20has%20direct%20access,be%20accomplished%20through%20the%20host%20operating%20system.)
