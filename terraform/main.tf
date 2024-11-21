terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.82.0"
    }
  }
}


resource "yandex_iam_service_account" "sa" {
  name = "sa"
  description = "Kubernetes Service account. Terraform created"
}

resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = var.folder_id
  role = "editor"
  members = [ "serviceAccount:${yandex_iam_service_account.sa.id}" ]
}

resource "yandex_resourcemanager_folder_iam_binding" "images-puller" {
  folder_id = var.folder_id
  role = "container-registry.images.puller"
  members = [ "serviceAccount:${yandex_iam_service_account.sa.id}" ]
}

resource "yandex_resourcemanager_folder_iam_binding" "vpc-publicAdmin" {
  folder_id = var.folder_id
  role = "vpc.publicAdmin"
  members = [ "serviceAccount:${yandex_iam_service_account.sa.id}" ]
}

resource "yandex_resourcemanager_folder_iam_binding" "certificates-downloader" {
  folder_id = var.folder_id
  role = "certificate-manager.certificates.downloader"
  members = [ "serviceAccount:${yandex_iam_service_account.sa.id}" ]
}

resource "yandex_resourcemanager_folder_iam_binding" "storage-viewer" {
  folder_id = var.folder_id
  role = "storage.viewer"
  members = [ "serviceAccount:${yandex_iam_service_account.sa.id}" ]
}

resource "yandex_vpc_network" "k8s-network" {
  name = "k8s-network"
}

resource "yandex_vpc_subnet" "k8s-subnet" {
  name = "k8s-subnet"
  v4_cidr_blocks = [ "10.10.0.0/24" ]
  zone = var.zone_name
  network_id = yandex_vpc_network.k8s-network.id
}


resource "yandex_kubernetes_cluster" "k8s-cluster" {
  name = "k8s-cluster"
  description = "Terraform installed cluster"
  network_id = yandex_vpc_network.k8s-network.id

  service_account_id = yandex_iam_service_account.sa.id
  node_service_account_id = yandex_iam_service_account.sa.id
  depends_on = [
    yandex_resourcemanager_folder_iam_binding.editor,
    yandex_resourcemanager_folder_iam_binding.images-puller
  ]

  release_channel = "STABLE"

  master {
    zonal {
        zone = yandex_vpc_subnet.k8s-subnet.zone
        subnet_id = yandex_vpc_subnet.k8s-subnet.id
    }

    version = "1.24"
    public_ip = true
  }
}

resource "yandex_kubernetes_node_group" "k8s-node-group" {

    name = "k8s-node-group"
    version = "1.24"
    cluster_id = yandex_kubernetes_cluster.k8s-cluster.id

    instance_template {

      platform_id="standard-v3"

      network_interface {
        nat = true
        subnet_ids = [yandex_vpc_subnet.k8s-subnet.id]
      }

      resources {
        memory = 8
        cores = 4
      }

      boot_disk {
        type = "network-hdd"
        size = 30
      }
    }

    scale_policy {
      fixed_scale {
        size = 1
      }
    }

    allocation_policy {
      location {
        zone = var.zone_name
      }
    }

    deploy_policy {
      max_expansion = 1
      max_unavailable = 1
    }
}



resource "yandex_vpc_security_group" "k8s-public-services" {
  name = "k8s-public-services"
  network_id = yandex_vpc_network.k8s-network.id
  ingress {
    protocol = "TCP"
    predefined_target = "loadbalancer_healthchecks"
    from_port = 0
    to_port = 65535
  }
  ingress {
    protocol = "ANY"
    predefined_target = "self_security_group"
    from_port = 0
    to_port = 65535
  }
  ingress {
    protocol = "ANY"
    v4_cidr_blocks = concat(yandex_vpc_subnet.k8s-subnet.v4_cidr_blocks)
    from_port = 0
    to_port = 65535
  }
  ingress {
    protocol = "ICMP"
    v4_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }
  ingress {
    protocol = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port = 30000
    to_port = 32767
  }
  ingress {
    protocol = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port = 6443
  }
  ingress {
    protocol = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port = 443
  }
  ingress {
    protocol = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port = 80
  }
  egress {
    protocol = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 65535
  }
}

resource "yandex_vpc_address" "address" {
  name = "static-ip"
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}


resource "yandex_dns_zone" "domain" {
  name = replace(var.domain, ".", "-")
  zone = join("", [var.domain, "."])
  public = true
  private_networks = [yandex_vpc_network.k8s-network.id]
}

resource "yandex_dns_recordset" "dns_domain_record" {
  zone_id = yandex_dns_zone.domain.id
  name = join("", [var.domain, "."])
  type = "A"
  ttl = 300
  data = [yandex_vpc_address.address.external_ipv4_address[0].address]
}

resource "yandex_dns_recordset" "dns_domain_prometheus" {
  zone_id = yandex_dns_zone.domain.id
  name = join("", ["prometheus.", var.domain, "."])
  type = "A"
  ttl = 300
  data = [yandex_vpc_address.address.external_ipv4_address[0].address]
}

resource "yandex_dns_recordset" "dns_domain_grafana" {
  zone_id = yandex_dns_zone.domain.id
  name = join("", ["grafana.", var.domain, "."])
  type = "A"
  ttl = 300
  data = [yandex_vpc_address.address.external_ipv4_address[0].address]
}


