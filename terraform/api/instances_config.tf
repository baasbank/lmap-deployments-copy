// Configure the Google Cloud provider Instances and instance groups

resource "google_compute_instance_template" "lmap_api_instance_template" {
  name = "lmap-api-instance-template"
  description = "This template is used to create app server instances."
  instance_description = "A Learning Map API Server instance."
  machine_type = "${var.machine_type}"
  metadata_startup_script = "${lookup(var.startup_scripts, "api")}"
  disk {
    boot = "true"
    source_image = "lmap-api-base-image"
  }
  network_interface {
    subnetwork  = "${google_compute_subnetwork.subnet_private_api.self_link}"
  }
  tags = ["http-server", "https-server", "private"]
  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "lmap_vault" {
  name         = "lmap-vault-server"
  description  = "A vault instance to help with secrets management."
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  metadata_startup_script = "${lookup(var.startup_scripts, "vault")}"
  boot_disk {
    initialize_params {
      image = "lmap-vault-base-image"
    }
  }
  network_interface {
    subnetwork  = "${google_compute_subnetwork.subnet_private_api.self_link}"
    address = "${google_compute_address.ip_st_api_vault.address}"
  }
  tags = ["vault-server", "private"]
  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "lmap_redis" {
  name         = "lmap-redis-server"
  description  = "A redis server."
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  metadata_startup_script = "${lookup(var.startup_scripts, "redis")}"
  boot_disk {
    initialize_params {
      image = "lmap-redis-base-image"
    }
  }
  network_interface {
    subnetwork  = "${google_compute_subnetwork.subnet_private_api.self_link}"
    address = "${google_compute_address.ip_st_api_redis.address}"
  }
  tags = ["redis-server", "private"]
  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "lmap_postgresql" {
  name         = "lmap-postgresql-server"
  description  = "A postgresql server."
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  metadata_startup_script = "${lookup(var.startup_scripts, "postgresql")}"
  boot_disk {
    initialize_params {
      image = "lmap-postgresdb-base-image"
    }
  }
  network_interface {
    subnetwork  = "${google_compute_subnetwork.subnet_private_api.self_link}"
    address = "${google_compute_address.ip_st_api_postgresql.address}"
  }
  tags = ["postgresql-server", "public"]
  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "lmap_dbbarman" {
  name         = "lmap-dbbarman-server"
  description  = "DBBarman."
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  metadata_startup_script = "${lookup(var.startup_scripts, "backup_db")}"
  boot_disk {
    initialize_params {
      image = "lmap-barman-base-image"
    }
  }
  network_interface {
    subnetwork  = "${google_compute_subnetwork.subnet_private_api.self_link}"
    address = "${google_compute_address.ip_st_api_backup_db.address}"
  }
  tags = ["private"]
  service_account {
    scopes = ["cloud-platform"]
  }
  depends_on = ["google_compute_instance.lmap_postgresql"]
}
