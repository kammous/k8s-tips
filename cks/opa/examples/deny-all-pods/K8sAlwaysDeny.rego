package k8salwaysdeny

violation[{"msg": msg}] {
    1 > 0
    msg := input.parameters.message
}