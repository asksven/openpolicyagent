# Namespaces require certain labels to be deletable

Experimental: does not work atm

1. Deploy: `kubectl apply -f k8srequiredlabels_template.yaml` and `kubectl apply -f ns_must_have_label_to_allow_deletion.yaml`
2. Test: Create a ns and try deleting it; this should fail as the ns does not have the `delete-ok` label
