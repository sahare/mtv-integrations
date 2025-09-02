# MTV Integrations - Architecture Diagrams

This document provides information about the visual diagrams available for the MTV Integrations project.

## Available Diagrams

### 📊 Data Flow Diagram
**File**: `dataflow.png` (128K)  
**Source**: [architecture/threat-model-dataflow.md](architecture/threat-model-dataflow.md)  
**Purpose**: Illustrates data flows, trust boundaries, and threat vectors

**Key Elements**:
- User authentication and authorization flows
- Cross-cluster communication patterns
- Secret and certificate management
- Trust boundaries and security controls
- Identified threat vectors (dotted red lines)
- Security control points

**Color Coding**:
- **Yellow**: Sensitive secrets and authentication data
- **Light Red**: High-privilege components (cluster-admin permissions)
- **Red**: Threats and security failures
- **Blue**: Standard components and normal operations

### 🏗️ System Architecture Diagram  
**File**: `architecture.png` (56K)  
**Source**: [architecture/mtv-integrations-architecture.md](architecture/mtv-integrations-architecture.md)  
**Purpose**: Shows overall system architecture and component relationships

**Key Elements**:
- **ACM Hub Cluster**: Core MTV integrations components
- **Managed Clusters**: Target clusters with deployed operators
- **External Systems**: Container registries, CAs, storage
- Component relationships and dependencies
- Security boundaries and trust zones

**Color Coding**:
- **Blue**: Controller components
- **Green**: Webhook and secure components  
- **Orange**: Secrets and sensitive data
- **Purple**: ACM core components
- **Red Border**: Sensitive/high-risk components
- **Green Border**: Secure/validated components
- **Gray Border**: External systems

## Usage in Documentation

### Threat Modeling
- **Data Flow Diagram**: Used in threat model reports and security assessments
- **Architecture Diagram**: Used in architectural reviews and system documentation

### Security Reviews
- Both diagrams referenced in security questionnaires and compliance documentation
- Visual aids for explaining security controls and threat vectors
- Component relationship mapping for RBAC and permission analysis

### Development and Operations
- Architecture diagram for onboarding new team members
- Data flow diagram for understanding authentication and authorization flows
- Reference material for troubleshooting and system maintenance

## Diagram Generation

### Source Files
- **Data Flow**: Generated from Mermaid diagram in [architecture/threat-model-dataflow.md](architecture/threat-model-dataflow.md)
- **Architecture**: Generated from Mermaid diagram in [architecture/mtv-integrations-architecture.md](architecture/mtv-integrations-architecture.md)

### Regeneration Process
```bash
# Install Mermaid CLI (if needed)
npm install -g @mermaid-js/mermaid-cli

# Generate data flow diagram
npx -p @mermaid-js/mermaid-cli mmdc -i dataflow.mmd -o dataflow.png -w 1200 -H 800 -b white

# Generate architecture diagram  
npx -p @mermaid-js/mermaid-cli mmdc -i architecture.mmd -o architecture.png -w 1400 -H 1000 -b white
```

### Diagram Specifications
- **Format**: PNG with white background
- **Data Flow**: 1200x800 resolution for detailed flow visualization
- **Architecture**: 1400x1000 resolution for complex system overview
- **Quality**: High resolution suitable for documentation and presentations

## Integration with Other Documents

### Threat Model Documentation
- [THREAT-MODEL.md](THREAT-MODEL.md) - References both diagrams
- [MTV-Integrations-ThreatDragon-Report.md](MTV-Integrations-ThreatDragon-Report.md) - Uses diagrams in security analysis
- [mtv-integrations-threat-model.json](mtv-integrations-threat-model.json) - Interactive Threat Dragon model

### Security Questionnaires
- [ACM-SecurityDesignQuestionnaire-MTV-Integrations.md](ACM-SecurityDesignQuestionnaire-MTV-Integrations.md) - References architecture diagrams
- [ThreatModel-MTV-Integrations-SecurityDesignQuestionnaire.md](ThreatModel-MTV-Integrations-SecurityDesignQuestionnaire.md) - Uses both diagrams for component analysis

### Architecture Documentation
- [architecture/README.md](architecture/README.md) - Main architecture documentation
- [SECURITY.md](SECURITY.md) - Security documentation index with diagram references

## Maintenance

### Regular Updates
- **When to Update**: After any architectural changes or new security findings
- **Review Frequency**: Monthly for accuracy, immediately after major changes
- **Version Control**: Diagrams tracked in git alongside source Mermaid files

### Quality Assurance
- Verify all components are represented accurately
- Ensure security annotations match current threat model
- Validate color coding and legend consistency
- Check resolution and readability for presentations

---

**Last Updated**: $(date)  
**Diagram Versions**: 
- dataflow.png: v1.0 (128K)
- architecture.png: v1.0 (56K)
