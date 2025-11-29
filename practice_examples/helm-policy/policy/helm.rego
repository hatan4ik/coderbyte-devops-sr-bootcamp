package main

violation[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.securityContext.runAsNonRoot
  msg := sprintf("container %s must run as non-root", [container.name])
}

violation[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container.securityContext.allowPrivilegeEscalation
  msg := sprintf("container %s allows privilege escalation", [container.name])
}

violation[msg] {
  input.kind == "Deployment"
  not input.metadata.labels["app"]
  msg := "Deployment must have app label"
}
