locals {
  cloudwatch_url = "https://s3.amazonaws.com/cloudwatch-agent-k8s-yamls/kubernetes-monitoring"
  statsd_url = "https://s3.amazonaws.com/cloudwatch-agent-k8s-yamls/statsd"
}

data "external" "cloudwatch-ns" {
  program = ["bash", "${path.module}/sha1-http.sh"]
  query = {
    url = "${local.cloudwatch_url}/cloudwatch-namespace.yaml"
  }
}

resource "null_resource" "cloudwatch-ns" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${local.cloudwatch_url}/cloudwatch-namespace.yaml"
    environment = {
      KUBECONFIG = var.kubeconfig_filename
    }
  }
  triggers = {
    build_number = data.external.cloudwatch-ns.result.sha1
  }
}

data "external" "cloudwatch-config" {
  program = ["bash", "${path.module}/sha1-http.sh"]
  query = {
    url = "${local.cloudwatch_url}/cwagent-configmap.yaml"
  }
}

resource "null_resource" "cloudwatch-config" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${local.cloudwatch_url}/cwagent-configmap.yaml"
    environment = {
      KUBECONFIG = var.kubeconfig_filename
    }
  }
  triggers = {
    build_number = data.external.cloudwatch-config.result.sha1
  }
  depends_on = [null_resource.cloudwatch-ns]
}

data "template_file" "cloudwatch-config-patch" {
  template = <<EOF
data:
  cwagentconfig.json: |
    {
      "logs": {
        "metrics_collected": {
          "kubernetes": {
            "cluster_name": "${var.cluster_id}",
            "metrics_collection_interval": 60
          }
        },
        "force_flush_interval": 5
      }
    }
EOF
}

resource "null_resource" "cloudwatch-config-patch" {
  provisioner "local-exec" {
    command = <<EOF
cat <<EOL | kubectl -n amazon-cloudwatch patch configmap cwagentconfig -p '${data.template_file.cloudwatch-config-patch.rendered}'
EOL
EOF
    environment = {
      KUBECONFIG = var.kubeconfig_filename
    }
  }
  triggers = {
    build_number = data.external.cloudwatch-config.result.sha1
  }
  depends_on = [null_resource.cloudwatch-ns, null_resource.cloudwatch-config]
}

data "external" "cloudwatch-sa" {
  program = ["bash", "${path.module}/sha1-http.sh"]
  query = {
    url = "${local.cloudwatch_url}/cloudwatch-serviceaccount.yaml"
  }
}

resource "null_resource" "cloudwatch-sa" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${local.cloudwatch_url}/cwagent-serviceaccount.yaml"
    environment = {
      KUBECONFIG = var.kubeconfig_filename
    }
  }
  triggers = {
    build_number = data.external.cloudwatch-sa.result.sha1
  }
  depends_on = [null_resource.cloudwatch-ns]
}

data "external" "cloudwatch-daemonset" {
  program = ["bash", "${path.module}/sha1-http.sh"]
  query = {
    url = "${local.cloudwatch_url}/cwagent-daemonset.yaml"
  }
}

resource "null_resource" "cloudwatch-daemonset" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${local.cloudwatch_url}/cwagent-daemonset.yaml"
    environment = {
      KUBECONFIG = var.kubeconfig_filename
    }
  }
  triggers = {
    build_number = data.external.cloudwatch-daemonset.result.sha1
  }
  depends_on = [null_resource.cloudwatch-ns, null_resource.cloudwatch-sa]
}

data "external" "cloudwatch-statsd-config" {
  program = ["bash", "${path.module}/sha1-http.sh"]
  query = {
    url = "${local.statsd_url}/cwagent-statsd-configmap.yaml"
  }
}

resource "null_resource" "cloudwatch-statsd-config" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${local.statsd_url}/cwagent-statsd-configmap.yaml"
    environment = {
      KUBECONFIG = var.kubeconfig_filename
    }
  }
  triggers = {
    build_number = data.external.cloudwatch-statsd-config.result.sha1
  }
  depends_on = [null_resource.cloudwatch-ns]
}

data "external" "cloudwatch-statsd-daemonset" {
  program = ["bash", "${path.module}/sha1-http.sh"]
  query = {
    url = "${local.statsd_url}/cwagent-statsd-daemonset.yaml"
  }
}

resource "null_resource" "cloudwatch-statsd-daemonset" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${local.statsd_url}/cwagent-statsd-daemonset.yaml"
    environment = {
      KUBECONFIG = var.kubeconfig_filename
    }
  }
  triggers = {
    build_number = data.external.cloudwatch-statsd-daemonset.result.sha1
  }
  depends_on = [null_resource.cloudwatch-ns]
}
