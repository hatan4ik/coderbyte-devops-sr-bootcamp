package main

deny[msg] {
  input.kind == "Deployment"
  img := input.spec.template.spec.containers[_].image
  not trusted_image(img)
  not has_cosign_annotation(input.spec.template.metadata.annotations)
  msg := sprintf("container image %s is not trusted or signed", [img])
}

trusted_image(img) {
  startswith(img, "ghcr.io/your-org/")
}

has_cosign_annotation(ann) {
  ann["cosign.sigstore.dev/signature"] != ""
}
