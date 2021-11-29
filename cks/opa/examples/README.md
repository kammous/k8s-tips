# Installation
[Instalation guide](https://open-policy-agent.github.io/gatekeeper/website/docs/install/)

```
kubectl create -f https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/course-content/opa/gatekeeper.yaml
```
Create a ConstraintTeamplate and a Template to deny pod creation when no lalab has been set.
```
k apply -f https://github.com/killer-sh/cks-course-environment/blob/master/course-content/opa/deny-all/alwaysdeny_template.yaml
k apply -f https://github.com/killer-sh/cks-course-environment/blob/master/course-content/opa/deny-all/all_pod_always_deny.yaml
```
https://v1-21.docs.kubernetes.io/blog/2019/08/06/opa-gatekeeper-policy-and-governance-for-kubernetes/

## References
- https://www.youtube.com/watch?v=RDWndems-sk
- [Intro: Open Policy Agent Gatekeeper](https://www.youtube.com/watch?v=Yup1FUc2Qn0)
- [Deep Dive: Open Policy Agent](https://www.youtube.com/watch?v=n94_FNhuzy4&feature=youtu.be)

- [A curated list of OPA related tools, frameworks and articles](https://github.com/anderseknert/awesome-opa)
- [Excellent OPA training courses](https://academy.styra.com/)
- https://play.openpolicyagent.org/