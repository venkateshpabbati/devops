terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_image" "activiti-modeling-app" {
  name         = "activiti-modeling-app"
  keep_locally = true
}

resource "docker_container" "activiti-modeling-app" {
  image = docker_image.activiti-modeling-app.image_id
  name  = "activiti-modeling-app"

  ports {
    internal = 80
    external = 8052
  }
}

