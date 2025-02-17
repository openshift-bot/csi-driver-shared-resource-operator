all: build
.PHONY: all

# Include the library makefile
include $(addprefix ./vendor/github.com/openshift/build-machinery-go/make/, \
	golang.mk \
	targets/openshift/deps-gomod.mk \
	targets/openshift/images.mk \
	targets/openshift/bindata.mk \
)

# Run core verification and all self contained tests.
#
# Example:
#   make check
check: | verify test-unit
.PHONY: check

IMAGE_REGISTRY?=registry.svc.ci.openshift.org

# This will call a macro called "build-image" which will generate image specific targets based on the parameters:
# $0 - macro name
# $1 - target name
# $2 - image ref
# $3 - Dockerfile path
# $4 - context directory for image build
# It will generate target "image-$(1)" for building the image and binding it as a prerequisite to target "images".
$(call build-image,shared-resources-operator,$(IMAGE_REGISTRY)/ocp/4.7:shared-resources-operator,./Dockerfile,.)

# generate bindata targets
# $0 - macro name
# $1 - target suffix
# $2 - input dirs
# $3 - prefix
# $4 - pkg
# $5 - output
$(call add-bindata,generated,./assets/...,assets,generated,pkg/generated/bindata.go)

clean:
	$(RM) shared-resources-operator
.PHONY: clean

GO_TEST_PACKAGES :=./pkg/... ./cmd/...

# Deploy csi-driver-shared-resource-operator to the cluster
#
# Deployment can be tuned using the following environment variables:
#
# - OPERATOR_IMAGE: the image for the operator to deploy
# - DRIVER_IMAGE: the image for the CSI driver
# - NODE_REGISTRAR_IMAGE: the image for the csi node registrar
# - LOG_LEVEL: log level for the operator
deploy:
	# temporary creation of CSIDriver object until we merge this operator into the CSO
	oc apply -f ./csi-driver-yaml-that-will-live-in-cluster-storage-operator.yaml
	hack/deploy.sh

# Run e2e tests. TODO - actually write e2e tests in golang
test-e2e:
	hack/e2e.sh

.PHONY: test-e2e
