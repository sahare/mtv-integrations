# Threat Dragon Model for MTV Integrations

## Overview

This directory contains the Threat Dragon threat model for the MTV Integrations project, providing a visual and interactive way to analyze security threats using the STRIDE methodology.

## Files

### `mtv-integrations-threat-model.json`
Complete Threat Dragon model file containing:
- **16 mapped threats** from our STRIDE analysis
- **Visual diagram** with all system components
- **Data flows** and trust boundaries
- **Threat details** with mitigations and severity ratings

## How to Use

### Option 1: OWASP Threat Dragon Desktop
1. **Download**: Install [OWASP Threat Dragon](https://owasp.org/www-project-threat-dragon/) desktop application
2. **Open Model**: File → Open → Select `mtv-integrations-threat-model.json`
3. **View Diagram**: Explore the visual representation of system architecture
4. **Review Threats**: Click on components to see associated threats and mitigations

### Option 2: Threat Dragon Web Version
1. **Visit**: https://www.threatdragon.org/
2. **Import**: Use "Import Model" and upload `mtv-integrations-threat-model.json`
3. **Analyze**: Review threats and generate reports

### Option 3: Visual Studio Code Extension
1. **Install**: "Threat Dragon" extension in VS Code
2. **Open**: The JSON file will be recognized and provide threat modeling capabilities

## Model Structure

### Components Modeled

#### External Entities
- **User/Admin**: Administrative users creating MTV migration plans
- **Managed Clusters**: ACM managed clusters registered as MTV providers

#### Processes  
- **MTV Plan Webhook**: Validating admission webhook (`/validate-plan`)
- **Provider Manager Controller**: ManagedClusterReconciler managing provider lifecycle
- **Container Runtime**: Execution environment for controller and webhook

#### Data Stores
- **Provider Secrets**: Authentication tokens, CA certificates, kubeconfig data
- **ClusterPermissions**: RBAC configurations with cluster-admin privileges  
- **TLS Certificates**: X.509 certificates for secure communications

#### Data Flows
- Plan creation and validation flows
- Provider registration and secret management
- TLS authentication and container execution flows

### Threats Mapped

| ID | Threat | Component | Severity | STRIDE Category |
|----|--------|-----------|----------|-----------------|
| T001 | Service Account Token Impersonation | Provider Secrets | High | Spoofing |
| T002 | User Impersonation in Webhook | User/Admin | Medium | Spoofing |
| T003 | Certificate Authority Compromise | TLS Certificates | High | Spoofing |
| T004 | Provider Secret Manipulation | Provider Secrets | High | Tampering |
| T005 | Plan Resource Modification | Plan Creation Flow | Medium | Tampering |
| T006 | ClusterPermission Escalation | ClusterPermissions | **Critical** | Elevation of Privilege |
| T008 | Secret Exposure in Logs | Provider Secrets | High | Information Disclosure |
| T009 | Memory Dumps Containing Secrets | Provider Secrets | High | Information Disclosure |
| T010 | Network Traffic Interception | Managed Clusters | Medium | Information Disclosure |
| T011 | Webhook Endpoint Flooding | MTV Plan Webhook | Medium | Denial of Service |
| T012 | Controller Resource Exhaustion | Provider Manager Controller | Medium | Denial of Service |
| T013 | Certificate Renewal Failure | TLS Certificates | High | Denial of Service |
| T014 | Container Escape to Host | Container Runtime | **Critical** | Elevation of Privilege |
| T015 | RBAC Bypass Through Dynamic Client | Provider Manager Controller | High | Elevation of Privilege |
| T016 | Webhook Admission Controller Bypass | MTV Plan Webhook | High | Elevation of Privilege |

## Features

### Interactive Analysis
- **Visual Threat Mapping**: See exactly where each threat affects the system
- **Clickable Components**: Access detailed threat information and mitigations
- **Data Flow Analysis**: Understand trust boundaries and security controls

### Report Generation
- **Threat Reports**: Generate comprehensive threat analysis reports
- **Risk Assessment**: Export prioritized threat lists
- **Mitigation Tracking**: Monitor implementation of security controls

### Collaborative Review
- **Team Review**: Share model with security and development teams
- **Version Control**: Track changes to threat model over time
- **Integration**: Compatible with CI/CD security analysis workflows

## Security Analysis Summary

### Critical Threats (Immediate Action Required)
- **T006**: ClusterPermission Escalation - Full cluster compromise risk
- **T014**: Container Escape to Host - Host system compromise risk

### High Priority Threats (8 total)
Focus areas: Token security, certificate management, secret protection, RBAC controls

### Medium Priority Threats (6 total)  
Monitoring and operational security improvements

## Best Practices

### Regular Updates
- **Monthly Reviews**: Update threat model with new features or changes
- **Incident Integration**: Add new threats discovered through security incidents
- **Mitigation Tracking**: Update implementation status of security controls

### Team Usage
- **Security Reviews**: Use during architecture and security design reviews
- **Developer Training**: Help developers understand security implications
- **Compliance**: Support security audit and compliance requirements

## Integration with Development Workflow

### CI/CD Integration
- Include threat model reviews in pull request processes
- Automate threat model validation during security scans
- Generate security documentation from threat model data

### Security Testing
- Use threat model to guide penetration testing focus areas
- Map security test cases to identified threats
- Validate mitigation effectiveness through testing

## Support and Resources

### Documentation
- [Main Threat Model](THREAT-MODEL.md): Complete STRIDE analysis document
- [Security Overview](SECURITY.md): Security documentation index
- [Architecture Diagram](architecture/threat-model-dataflow.md): Visual data flow analysis

### Tools and Training
- [OWASP Threat Dragon Documentation](https://owasp.org/www-project-threat-dragon/)
- [STRIDE Methodology Guide](https://docs.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats)
- [Threat Modeling Best Practices](https://owasp.org/www-community/Threat_Modeling)

---

**Last Updated**: $(date)  
**Model Version**: 2.2.0  
**Next Review**: $(date +30 days)

