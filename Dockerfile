FROM registry.ci.openshift.org/ocp/builder:rhel-9-golang-1.22-openshift-4.18 AS builder
WORKDIR /go/src/github.com/openshift/shared-resources-operator
COPY . .
COPY vendor/github.com/openshift/api/sharedresource/v1alpha1/zz_generated.crd-manifests/sharedsecrets.crd.yaml assets/0000_10_sharedsecret.crd.yaml
COPY vendor/github.com/openshift/api/sharedresource/v1alpha1/zz_generated.crd-manifests/sharedconfigmaps.crd.yaml assets/0000_10_sharedconfigmap.crd.yaml
RUN make update
RUN make

FROM registry.ci.openshift.org/ocp/4.18:base-rhel9
COPY --from=builder /go/src/github.com/openshift/shared-resources-operator/shared-resources-operator /usr/bin/
ENTRYPOINT ["/usr/bin/shared-resources-operator"]
LABEL io.k8s.display-name="OpenShift Projected Shared Resources Operator" \
	io.k8s.description="The Projected Shared Resources Operator installs and maintains Projected Shared Resources CSI Driver on a cluster."