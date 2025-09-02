# Threat Model MTV Integrations Questionnaire

Filling out all of the details in the threat model spreadsheet is very tedious and time consuming.
To facilitate better discussions that uncover security concerns earlier in the project lifecycle, we want
squads to use this questionnaire for their components/features to get a clearer understanding of what security concerns we are trying to
identify using the threat model.

So the approach is as follows:

-   Squads fill out this security design questionnaire for their components to create a baseline and keep it updated and include it for architecture reviews of updates to their components
-   Secure engineering squad uses these questionnaires for all components to create the overall threat model for RHACM

## Threat Model Questions

These questions will help us determine where security gaps may be located. Similar to the threat model spreadsheet, the questions are focused on some specific areas related to storage, data flows, etc.  Please remember the following when answering these questions:

1. Changes for the releases are tracked in github just like our code in other components.
2. The architecture diagrams can be created with any tools.  Pencil and paper diagrams are fine as long as you are submitting a picture and not the actual paper.  Feel free to keep the diagrams in this repository too.
3. Data flow diagrams must be created in Threat Dragon.  Work with the secure engineering team to make changes to your squads threat dragon data flow models.
4. Call out anything that you are unsure of.  Things that don't seem to clearly fit in the answers can still be listed.  Example, the policy-collection community has donated policies which could present a risk.  Are there other contributed resources that could be integrated into ACM in a similar way?

### Component Details

List the features provided by the squad. Highlight the features that are
new for this release.

- **Provider Manager Controller** - Integrates ACM managed clusters as MTV providers with automatic lifecycle management. Core feature.
- **MTV Plan Validating Webhook** - Enforces access control and authorization for migration plans through admission control. Core feature.
- **Cross-Cluster Authentication** - ManagedServiceAccount-based token management with 60-minute rotation. Core feature.
- **CNV Addon Integration** - Deploys Container Native Virtualization operator on managed clusters. Core feature.
- **MTV Addon Integration** - Deploys Migration Toolkit for Virtualization operator on hub clusters. Core feature.
- **Certificate Management** - TLS certificate watchers for secure webhook and metrics communications. Core feature.

What component(s) are being added to the product? List the component
(process/container) and the feature that it is associated with from the list above.

- **mtv-integrations-controller** - Provider Manager Controller (ManagedClusterReconciler)
  - Monitors ManagedCluster resources labeled with `acm/cnv-operator-install: "true"`
  - Creates and manages ManagedServiceAccounts with token rotation
  - Creates ClusterPermissions with cluster-admin level RBAC
  - Manages Provider secrets and resources in MTV namespace
- **mtv-integrations-webhook** - MTV Plan Validating Webhook
  - Validates Plan resources at `/validate-plan` endpoint
  - Impersonates users to check permissions on target namespaces
  - Enforces access control using kubevirtprojects ClusterView API
- **CNV Addon Controller** - Container Native Virtualization deployment
  - Deploys KubeVirt HyperConverged operator via ManifestWork
  - Targets clusters with `acm/cnv-operator-install: "true"` label
- **MTV Addon Controller** - Migration Toolkit for Virtualization deployment
  - Deploys MTV operator in openshift-mtv namespace on hub
  - Enables UI plugin, validation, and volume populator features

Link to architectural diagram(s) that shows the major components (One diagram per feature or one diagram for all features):

- [MTV Integrations Data Flow Diagram](architecture/threat-model-dataflow.md)
- [MTV Integrations System Architecture](THREAT-MODEL.md)

List components external to the local cluster that the processes listed above can interact with:

- **Managed Clusters** - ACM managed clusters registered as MTV providers
- **Kubernetes API Servers** - Both hub and managed cluster API servers
- **kubevirtprojects ClusterView API** - Cross-cluster namespace access validation
- **Container Registries** - Image pulls for operator deployments (quay.io, registry.redhat.io)
- **Certificate Authorities** - For TLS certificate validation and renewal
- **LDAP/OAuth Providers** - For user authentication context (inherited from Kubernetes)

### Data Flow

Where does data come from? (User provided, metrics collection, search collection, etc)

- **User creates Plan resources** - Users create MTV migration plans via CLI or UI
- **ManagedCluster labeling** - Administrators label clusters with `acm/cnv-operator-install: "true"`
- **Certificate data** - cert-manager or external certificate authorities provide TLS certificates
- **Token data** - ManagedServiceAccount controller generates service account tokens
- **User authentication context** - Kubernetes API server provides user identity for webhook impersonation
- **Cluster metadata** - ACM provides managed cluster connection details (URLs, CA certificates)

Use threat dragon as the model for your Data Flow diagram for each component. Include protocol/security details. This needs to show components on the Hub, on the managed clusters, and those deployed external to RHACM e.g., GitHub, AWS S3 etc.

- Threat dragon json file: `mtv-integrations-threat-model.json`
- [Provider Manager Controller Data Flow](architecture/threat-model-dataflow.md)
- [MTV Plan Webhook Data Flow](architecture/threat-model-dataflow.md)
- [Complete System Architecture](MTV-Integrations-ThreatDragon-Report.md)

Is there an external entry point into RHACM (route/external ip) owned by this squad? **Yes**

If yes,

- How is security (TLS/Ciphers/Certificates) managed/configured?
  - **Webhook Endpoint**: TLS 1.3 encryption on port 9443 with mutual TLS authentication
  - **Certificate Management**: Automated certificate watching and reloading via cert-manager integration
  - **Cipher Suites**: Modern TLS 1.3 cipher suites, HTTP/2 disabled by default to prevent CVE-2023-44487
  - **Certificate Validation**: Full certificate chain validation with CA certificate verification

For external components associated with your squad:

- Are connections made to the external components? **Yes**

    - If yes, How are these connections secured/configured?
      - **Managed Clusters**: TLS-encrypted connections using service account tokens and CA certificates
      - **kubevirtprojects API**: HTTPS with user impersonation and Kubernetes RBAC validation
      - **Container Registries**: HTTPS with pull secrets managed by ACM (`open-cluster-management-image-pull-credentials`)
      - **Certificate Authorities**: HTTPS for OCSP/CRL validation (if configured)

- Does the external component connect to RHACM? **Partially**

    - If yes, how is that connection configured and authenticated?
      - **Managed Clusters**: Authenticate to hub using ManagedServiceAccount tokens (60-minute rotation)
      - **Certificate Authorities**: May perform OCSP validation callbacks (optional)

- How are certificates managed?
  - **Automatic Renewal**: cert-manager integration with automatic certificate lifecycle management
  - **Certificate Watchers**: Real-time certificate reloading without service restart
  - **CA Validation**: Managed cluster CA certificates validated and stored in Provider secrets
  - **Expiration Monitoring**: Certificate expiration tracking and alerting capabilities

### Data at Rest 

Is any data persisted?
- **Yes, in Kubernetes etcd:**
  - **Provider Secrets**: Authentication tokens, CA certificates, kubeconfig connection data
  - **ClusterPermissions**: RBAC configurations granting cluster-admin privileges
  - **TLS Certificates**: Webhook and metrics server certificates and private keys
  - **ManagedServiceAccounts**: Service account specifications and status
  - **Provider Resources**: MTV provider registrations and metadata
  - **Plan Resources**: Migration plan specifications (validated by webhook)

Are credentials or customer PII/SPI being collected?
- **Service Account Tokens**: JWT tokens for cross-cluster authentication (60-minute rotation)
- **TLS Private Keys**: Certificate private keys for webhook and metrics server authentication
- **CA Certificates**: Cluster certificate authority public keys for trust validation
- **Kubeconfig Data**: Complete cluster access configurations including endpoints and certificates
- **User Context**: Temporary user identity information during webhook impersonation (not persisted)
- **Pull Secrets**: Container registry credentials copied to managed clusters as `open-cluster-management-image-pull-credentials`

If yes:

-  **Who has access to the credentials?** 
   - Users with `get/list` permissions on secrets in the MTV integrations namespace (`openshift-mtv`)
   - Users with `get/list` permissions on secrets in managed cluster namespaces
   - Cluster administrators with full cluster access
   - The MTV integrations controller service account
-  **Who has access to the data?** 
   - Same as above, plus users with access to Plan resources for migration data
   - Users with access to kubevirtprojects ClusterView for namespace access validation
-  **How is the data stored/encrypted?** 
   - Stored in Kubernetes etcd with cluster-level encryption at rest
   - TLS encryption for all data in transit
   - No additional application-level encryption beyond Kubernetes native capabilities

Do you have a database component? **No**

If yes:

-   What, if any, configuration is in place to limit the number of requests to the component?
-   What, if any, logging is done on database level operations?

### Logging

While much of code is controllers that operate on custom resources, and these API requests are therefore logged by the Kubernetes API server, we must still be certain that we are capturing [Events of Interest](https://source.redhat.com/departments/it/it-information-security/wiki/security_logging_and_monitoring_what_and_how#jive_content_id_Events_of_Interest) for the purpose of providing our customers with the greatest level of detail on security status of their environments.
For convenience these Events of Interest are listed below:

1. Creation, Updating, Accessing, or Deletion of [Red Hat Restricted Data or PII](https://source.redhat.com/departments/it/enterprise-architecture/mojo_content/red_hat_data_classifications#jive_content_id_RHRestrictedPII)
2. Creation and Deletion of System-level objects
3. Administrative actions taken by any individual with higher level privileges (e.g., admin, super user, root, etc)
4. Grant, Modify, or Revoke access for a user or a group of users
5. Application or process startup, shutdown, or restart
6. User Login, Logout events
7. Any attempts of Invalid Logins into an application or host
8. All authorization failures (e.g., trying to run 'sudo' command on a host when the user is not in sudoers list)
9. Any attempts of stopping, deletion, or tampering with Audit Trails/Logs themselves
10. Initiation of acceptance a network connection (e.g., VPC/SSH connections) along with IP Address captured
11. Any warnings or errors

_Any events associated with a **user should also include IP address of the user**_

With that information provided, does/do your component(s) do any explicit logging operations? **Yes**

If yes please list the component(s) and what operations are logged:

- **mtv-integrations-controller**
    - ManagedCluster reconciliation events (creation, update, deletion of provider resources)
    - ManagedServiceAccount creation and token rotation events
    - ClusterPermission creation and modification events (includes user context)
    - Provider secret creation, updates, and synchronization events
    - Certificate renewal and validation events
    - Errors and warnings during controller operations
    - Finalizer addition/removal events for cleanup operations

- **mtv-integrations-webhook**
    - Plan validation requests and responses (includes user identity and IP via Kubernetes audit)
    - User impersonation attempts and results
    - Authorization failures for namespace access validation
    - kubevirtprojects ClusterView API access attempts
    - Webhook certificate validation events
    - All admission control decisions (allow/deny) with user attribution
    - Errors and warnings during webhook operations

**Note**: Additional security event logging is provided by:
- Kubernetes API server audit logs (captures all API operations with user attribution)
- Controller runtime structured logging with request IDs and user context
- Certificate watcher events for TLS certificate lifecycle management

Are these logs capable of forwarding to Splunk through configuration of the [Splunk universal forwarder](https://docs.splunk.com/Documentation/Forwarder/8.1.0/Forwarder/Abouttheuniversalforwarder)? **Yes**  
[Kubernetes logging architectures](https://kubernetes.io/docs/concepts/cluster-administration/logging/#cluster-level-logging-architectures)

### Operators

**Last Reviewed**: $(date)

Please read the following for context/clarification on this section:
[Secure Operators Deployment Guide](https://source.redhat.com/groups/public/product-security/content/product_security_wiki/operators_secure_deployment_guide)

Operators often have higher privileges than is typical which means we must take special care to securely deploy them. This section will help to ensure we are minimizing the risk of malicious actions, such as privilege escalation, through our operators.

Please list the following for each component:

**MTV Integrations Controller**

- Cluster-scoped Operators

| **Operator** | **Roles** | **ClusterRoles** |
|--------------|-----------|------------------|
| mtv-integrations-controller | N/A | [{"apiGroups":["cluster.open-cluster-management.io"],"resources":["managedclusters"],"verbs":["get","list","watch"]},{"apiGroups":["cluster.open-cluster-management.io"],"resources":["managedclusters/status"],"verbs":["get"]},{"apiGroups":["cluster.open-cluster-management.io"],"resources":["managedclusters/finalizers"],"verbs":["update"]},{"apiGroups":["authentication.open-cluster-management.io"],"resources":["managedserviceaccounts"],"verbs":["get","list","watch","create","update","patch","delete"]},{"apiGroups":["authentication.open-cluster-management.io"],"resources":["managedserviceaccounts/status"],"verbs":["get","update","patch"]},{"apiGroups":["rbac.open-cluster-management.io"],"resources":["clusterpermissions"],"verbs":["get","list","watch","create","update","patch","delete"]},{"apiGroups":["rbac.open-cluster-management.io"],"resources":["clusterpermissions/status"],"verbs":["get","update","patch"]},{"apiGroups":[""],"resources":["secrets"],"verbs":["get","list","watch","create","update","patch","delete"]},{"apiGroups":[""],"resources":["namespaces"],"verbs":["get","list","watch","create"]},{"apiGroups":["apiextensions.k8s.io"],"resources":["customresourcedefinitions"],"verbs":["get","list","watch"]},{"apiGroups":["coordination.k8s.io"],"resources":["leases"],"verbs":["get","list","create","update","patch","watch","delete"]},{"apiGroups":[""],"resources":["events"],"verbs":["create","patch"]}] |

- Namespace-scoped Operators

| **Operator** | **Roles** | **ClusterRoles** |
|--------------|-----------|------------------|
|              |           |                  |

**MTV Plan Webhook**

- Cluster-scoped Operators

| **Operator** | **Roles** | **ClusterRoles** |
|--------------|-----------|------------------|
| mtv-integrations-webhook | N/A | [{"apiGroups":["clusterview.open-cluster-management.io"],"resources":["kubevirtprojects"],"verbs":["get","list"]},{"apiGroups":["forklift.konveyor.io"],"resources":["plans"],"verbs":["get","list","watch"]},{"apiGroups":["admissionregistration.k8s.io"],"resources":["validatingadmissionwebhooks"],"verbs":["get","list","watch"]},{"apiGroups":[""],"resources":["events"],"verbs":["create","patch"]},{"apiGroups":["authorization.k8s.io"],"resources":["subjectaccessreviews"],"verbs":["create"]},{"apiGroups":["authentication.k8s.io"],"resources":["tokenreviews"],"verbs":["create"]}] |

- Namespace-scoped Operators

| **Operator** | **Roles** | **ClusterRoles** |
|--------------|-----------|------------------|
|              |           |                  |

For each Cluster-scoped Operator please provide justification for why this is necessary.

- **mtv-integrations-controller**
    - **Justification**: Requires cluster scope to monitor ManagedCluster resources across all namespaces, create ManagedServiceAccounts in managed cluster namespaces, manage ClusterPermissions (cluster-level RBAC), and access Provider CRDs that may not be namespace-scoped. Cross-cluster authentication requires cluster-level secret management across multiple namespaces.

- **mtv-integrations-webhook**
    - **Justification**: Requires cluster scope as a validating admission webhook that must validate Plan resources in any namespace where they are created. Must access kubevirtprojects ClusterView resources that are cluster-scoped for cross-cluster namespace validation. Admission webhooks inherently require cluster-level permissions.

Do you make use of OperatorGroup objects to ensure only one operator within a namespace owns a particular CustomResourceDefinition?
    If no please follow the [Descoping Plan](https://hackmd.io/wVfLKpxtSN-P0n07Kx4J8Q)

- **mtv-integrations-controller**
  - Deployed as a standard Kubernetes Deployment with controller-runtime, not via OLM, so OperatorGroup is not applicable
  - Uses leader election to ensure only one active controller instance

- **mtv-integrations-webhook**
  - Deployed as a ValidatingAdmissionWebhook, not an OLM operator, so OperatorGroup is not applicable
  - Single webhook endpoint with multiple replicas for high availability

For each Containerfile is a numeric USER value set? Please list the cases where it is not below:

- **All containers run with numeric USER 65532 (non-root)**

For each podSpec is runAsNonRoot defined and set to true? If no, please list in which cases and provide a justification below:

- **All pods have runAsNonRoot: true**
- **SecurityContext includes runAsUser: 65532**
- **No root execution required for any MTV Integrations components**

Do any of your operators require hostPath usage? If yes, please list the operators below:

- **No hostPath usage required**

### RBAC

**Last Reviewed**: $(date)

What are the behavior differences between users with the following roles taking actions controlled by RBAC for your components?

| Action | ocm:Cluster-Manager-Admin | Admin | Edit | View |
|---|---|---|---|---|
| ManagedCluster labeling (acm/cnv-operator-install) | create, read, update, delete | create, read, update, delete | create, read, update, delete | read |
| Provider.forklift.konveyor.io | create, read, update, delete | create, read, update, delete | create, read, update, delete | read |
| Plan.forklift.konveyor.io (via webhook) | create, read, update, delete (with namespace validation) | create, read, update, delete (with namespace validation) | create, read, update, delete (with namespace validation) | read |
| ManagedServiceAccount.authentication.open-cluster-management.io | create, read, update, delete | No access | No access | No access |
| ClusterPermission.rbac.open-cluster-management.io | create, read, update, delete | No access | No access | No access |

| Action | ocm:Cluster-Manager-Admin | Admin | Edit | View |
|---|---|---|---|---|
| Provider Secrets (openshift-mtv namespace) | create, read, update, delete | create, read, update, delete | create, read, update, delete | read |
| kubevirtprojects.clusterview.open-cluster-management.io | read (for webhook validation) | read (for webhook validation) | read (for webhook validation) | read |

**Note**: The webhook performs additional authorization checks by impersonating the requesting user and validating their access to target namespaces using the kubevirtprojects ClusterView API, regardless of their RBAC permissions on Plan resources.

### API List

**Last Reviewed**: $(date)

Do you have any managed cluster components that access the hub cluster through an API?
**Yes** - ManagedServiceAccounts created by the controller generate tokens that managed clusters use to authenticate back to the hub.

If yes, please list the API endpoints that are accessed by each component below:

- **ManagedServiceAccount tokens (created by mtv-integrations-controller)**
  - Hub service accessed: kube-apiserver
    - API endpoint: `/api/v1/namespaces/{managed_cluster_name}/secrets` (for Provider secret creation)
    - API endpoint: `/apis/forklift.konveyor.io/v1/namespaces/openshift-mtv/providers` (for Provider registration)
    - API endpoint: `/apis/cluster.open-cluster-management.io/v1/managedclusters/{cluster_name}` (for cluster status updates)
    - API endpoint: `/api/v1/namespaces/{managed_cluster_name}/secrets/{cluster_name}-mtv` (for authentication secret updates)

- **Webhook impersonation (mtv-integrations-webhook)**
  - Hub service accessed: kube-apiserver (with user impersonation)
    - API endpoint: `/apis/clusterview.open-cluster-management.io/v1/kubevirtprojects` (for namespace access validation)
    - API endpoint: `/apis/authorization.k8s.io/v1/subjectaccessreviews` (for permission checking)
    - API endpoint: `/apis/authentication.k8s.io/v1/tokenreviews` (for token validation)

For each component have any new API endpoints changed since the last threat model version?

- [X] I have verified that either there are no new API endpoints accessing the hub cluster or have added the new component(s) 
and endpoint(s) to the list above. I recognize this information is needed by customer for API call filtering.

### FIPS Readiness

**Last Reviewed**: $(date)

Please check off each area after you review the checklist for **ALL** components in this threat model.  For any areas that FIPS Approved items are not used, outline the details and the effort to update those to meet compliance.

[Details on the checklist](https://gitlab.cee.redhat.com/crypto/team/-/wikis/FIPS/FIPS-Compliance-Checklist). VPN required.

- [X] Reviewed and understand FIPS Compliance. The algorithm an application wants to use is FIPS approved, the module it uses is FIPS certified, the algorithm implementation in the module was FIPS certified, and the use of it is consistent with the module's security policy. Then we can say it is FIPS compliant.
- [X] Reviewed the Behavior section. Must use openssl or gnutls, otherwise with NSS and libgcrypt the application needs to do work to select the correct compliant algorithm.
- [X] Reviewed The Checklist. Check key creation, key sizes, random number creation, use of specific ciphers/TLS.
- [X] Reviewed FIPS 140-2 Approved Algorithms. See link above for the list, but if you stick with OpenSSL it will enforce approved algorithm usage.
- [X] Validate no issues with external dependencies. Make sure you have no dependencies pulled into your images that can do cryptography that could break FIPS approval.

**Notes for MTV Integrations**:

- **TLS Implementation**: Uses Go's crypto/tls package which uses OpenSSL in FIPS mode when available
- **Certificate Handling**: All certificate operations use standard Go crypto packages (crypto/x509, crypto/rsa, crypto/ecdsa)
- **Token Generation**: Service account tokens generated by Kubernetes use FIPS-compliant algorithms
- **Random Number Generation**: Uses crypto/rand for secure random number generation
- **No Custom Cryptography**: No custom cryptographic implementations, relies entirely on Kubernetes and Go standard library FIPS-compliant implementations

**FIPS Environment Testing**:
- All components build with `GOEXPERIMENT=strictfipsruntime` and `CGO_ENABLED=1`
- No static linking that would bypass FIPS module validation
- TLS 1.3 with FIPS-approved cipher suites only
- Successfully tested in downstream FIPS-enabled environments

Note: The downstream golang builds will always use a FIPS ready compiler. Upstream/midstream builds do not so any runtime testing must use a downstream build.

## Runtime Analysis

Be aware that more questions are not being asked because they can be calculated by analyzing your new components on a running environment. Be
sure to follow these guidelines when performing your new work items:

-   **Least privilege** - Components must use a service account with role/clusterrole bindings that you configure that obey the security principle of **least privilege**.

    **Current Status**: ⚠️ **NEEDS IMPROVEMENT**
    - ClusterPermissions currently grant cluster-admin privileges to ManagedServiceAccounts
    - Controller has broad permissions but scoped to necessary resources
    - Webhook has minimal required permissions for admission control
    
    **Action Required**: Implement least privilege RBAC to replace cluster-admin permissions with minimal required permissions for MTV operations.

-   **TLS** - Any communications that are not secured need to be highlighted as risky with a justification and a plan to move to secure communications.

    **Current Status**: ✅ **COMPLIANT**
    - All webhook communications use TLS 1.3
    - All cross-cluster communications encrypted with TLS
    - Certificate management automated with cert-manager
    - HTTP/2 disabled by default to prevent CVE-2023-44487

-   **SCC** - Use OpenShift's **restricted** SCC - justify otherwise

    **Current Status**: ✅ **COMPLIANT**
    - All components use OpenShift's restricted SCC
    - No privileged containers required
    - runAsNonRoot: true for all pods
    - No hostPath, hostNetwork, or hostPID usage

-   **Runs As** - A container should run as the **OpenShift generated user id**, justify otherwise.

    **Current Status**: ✅ **COMPLIANT**
    - All containers run as UID 65532 (non-root)
    - No containers require root privileges
    - SecurityContext properly configured for non-root execution

**Security Control Summary**:
```
Pod: mtv-integrations-controller-xxx
SCC: restricted
Containers:
    manager -- uid=65532 gid=65532 groups=65532
```

```
Pod: mtv-integrations-webhook-xxx
SCC: restricted  
Containers:
    webhook -- uid=65532 gid=65532 groups=65532
```

**Identified Security Improvements Needed**:
1. **Implement least privilege RBAC** - Replace cluster-admin ClusterPermissions with minimal required permissions
2. **Enhance container security** - Add AppArmor/SELinux profiles, seccomp filtering, read-only root filesystem
3. **Improve secret protection** - Implement secret scrubbing in logs, memory protection, integrity validation
4. **Deploy network security** - Implement network policies and segmentation
5. **Enhance audit logging** - Add comprehensive security event logging and tamper-evident forwarding

Secure engineering automation could detect and create issues in these areas in the future.
