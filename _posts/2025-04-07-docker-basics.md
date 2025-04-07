---
title: Docker - Basic Guide
date: 2025-04-07 16:35:00 +0200
categories: [Guides]
tags: [Docker]
description: Mini Docker handbook. Understand Docker architecture and concepts from the beginning.
---
> This post is currently in progress
{: .prompt-info }

# Basic Infrastructure - Containers and VirutalMachines (VMs)
- underlying architecture
- Shared OS, Linux Kernel
- Linux/Windows/Mac

# Key Docker Concepts
- Image
- Container
- Docker Host

#  Docker Engine
> With knowledge of Basic Docker infra + key docker concepts + key linux concepts.
> Think where to put it. maybe after linux concepts?

- Daemon, Docker engine RESTful API, Client, Socket communication


# Essential Linux Concepts for Understanding Docker
- Port Mapping (Ports & IPs)
- Volume Mounting (Volumes & Mounts)
- Process Isolation (Namespaces & PIDs)
- Resource Limits (Control Groups)




# Dockerfile - Build Images
- Layered Architecture (COW), Storage Drivers
- CMD vs Entrypoint
-  multi-stage builds

# Docker Compose - Run multiple containers
- dedicated bridge network, communicate with service names (Internal DNS Server)

# Docker Registry
- How registries work
- Internal private registries
- Tags to specify registry
- Push


# Networking
- Default networks
- user defined networks
- network namespaces
- veth pairs

# Container Orchestration - The need of using an orchestrator
- Brief intro to why orchestrator is needed
- Why Docker alone isn't enough