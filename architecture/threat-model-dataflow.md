# MTV Integrations - Threat Model Data Flow Diagram

This diagram illustrates the key data flows, trust boundaries, and potential threat vectors within the MTV Integrations system.

```mermaid
graph TD
    A["User/Admin"] -->|Creates/Updates| B["MTV Plan Resource"]
    B --> C["MTV Plan Webhook<br/>/validate-plan"]
    C -->|Impersonates User| D["User Impersonation<br/>Auth Context"]
    D -->|Checks Access| E["kubevirtprojects<br/>ClusterView API"]
    E -->|Access Decision| F{"Authorization<br/>Check Result"}
    F -->|Denied| G["Webhook Denial<br/>Plan Rejected"]
    F -->|Allowed| H["Plan Accepted<br/>Migration Proceeds"]
    
    I["ACM ManagedCluster<br/>with CNV Label"] -->|Reconcile Trigger| J["Provider Manager<br/>Controller"]
    J -->|Creates| K["ManagedServiceAccount<br/>60min Token Rotation"]
    K -->|Generates| L["Authentication Secret<br/>ca.crt + token"]
    J -->|Creates| M["ClusterPermission<br/>cluster-admin RBAC"]
    J -->|Creates| N["Provider Secret<br/>MTV Namespace"]
    N -->|References| L
    J -->|Creates| O["Provider Resource<br/>MTV Registration"]
    O -->|Uses| N
    
    P["Certificate Manager"] -->|Provides TLS| Q["Webhook Server<br/>Port 9443"]
    Q --> C
    P -->|Provides TLS| R["Metrics Server<br/>Port 8443/8080"]
    
    S["Leader Election"] -->|Coordinates| J
    T["Health/Readiness<br/>Probes"] -->|Monitor| J
    
    U["Container Runtime"] -->|Runs as| V["Non-root User<br/>UID 65532"]
    V --> J
    V --> Q
    
    W["External Threats"] -.->|Network Attack| Q
    W -.->|Privilege Escalation| J
    W -.->|Token Theft| L
    W -.->|Certificate Compromise| P
    
    style W fill:#ff9999
    style G fill:#ff9999
    style L fill:#ffffcc
    style N fill:#ffffcc
    style M fill:#ffcccc
```

## Diagram Legend

### Components
- **Yellow**: Sensitive secrets and authentication data
- **Light Red**: High-privilege components (cluster-admin permissions)
- **Red**: Threats and security failures
- **Blue**: Standard components and normal operations

### Trust Boundaries
1. **User → Webhook**: TLS-protected admission control
2. **Controller → Cluster APIs**: Authenticated service account access
3. **Cross-cluster**: Token-based authentication with CA validation
4. **Container Runtime**: Non-root execution with security contexts

### Key Security Controls
- Token rotation (60-minute intervals)
- TLS encryption for all communications
- RBAC-based authorization
- User impersonation for permission validation
- Certificate-based authentication
- Non-root container execution

### Threat Vectors (Dotted Red Lines)
- Network-based attacks on webhook endpoints
- Privilege escalation attempts in controllers
- Token theft from authentication secrets
- Certificate compromise for TLS bypass
