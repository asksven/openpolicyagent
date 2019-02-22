package kubernetes.admission

import data.kubernetes.namespaces

import input.request.object.metadata.annotations as annotations

deny[msg] {
    input.request.kind.kind = "Namespace"
    input.request.operation = "DELETE"
    missing_required_annotations[msg]
}

# Require no "protected" annotation or protected="no" to allow namespace deletion 
missing_required_annotations[msg] {
    annotation = namespaces[input.request.namespace].metadata.annotations["protected"]
    not annotation = "no"
    msg = "Namespaces annotated with protected=yes can not be deleted"
}
