# 📋 Step 1: Requirements - Foundry Healthcare Agents

📑 Requirements Overview

- [🎯 Project Overview](#-project-overview)
- [🚀 Functional Requirements](#-functional-requirements)
- [🔧 Operational Requirements](#-operational-requirements)
- [📋 Summary for Architecture Assessment](#-summary-for-architecture-assessment)
- [References](#references)

## 🎯 Project Overview

| Field                   | Value                                                                                      |
| ----------------------- | ------------------------------------------------------------------------------------------ |
| **Project Name**        | foundry-healthcare-agents                                                                  |
| **Primary Stakeholder** | Azure Trainer / Demo Presenter                                                             |
| **Industry**            | Healthcare                                                                                 |
| **Company Size**        | Mid-Market (demo context)                                                                  |
| **Scenario**            | Greenfield                                                                                 |
| **Environments**        | Dev (demo/PoC only)                                                                        |
| **Description**         | Healthcare-focused AI agent demo deploying Azure AI Foundry Hub, Project, and supporting infrastructure for training and demonstration purposes. |

### Business Context

This is a **demo/PoC workload** for training and presentation purposes. The scenario showcases Azure AI Foundry capabilities in a healthcare context, demonstrating how AI agents can assist with patient triage, appointment scheduling, clinical Q&A, and medication information. No real patient data (PHI) is used — all data is synthetic.

### Workload Pattern

**Interactive AI Agent** — conversational AI interactions at demo scale.

| Signal              | Value                                              |
| ------------------- | -------------------------------------------------- |
| Pattern             | Interactive AI Agent (Conversational)              |
| Interaction Model   | User ↔ AI Agent chat-based conversations           |
| Daily Users         | 1–10 (demo/training attendees)                     |
| Concurrent Users    | 1–5                                                |
| Request Pattern     | Bursty (during demos), idle otherwise              |
| Data Volume         | Minimal (synthetic healthcare data)                |

## 🚀 Functional Requirements

### Core Capabilities

| #   | Capability                          | Priority   | Acceptance Criteria                                                  |
| --- | ----------------------------------- | ---------- | -------------------------------------------------------------------- |
| 1   | Azure AI Foundry Hub deployment     | 🔴 Must    | Hub provisioned in swedencentral with managed identity               |
| 2   | Azure AI Foundry Project            | 🔴 Must    | Project connected to Hub, accessible via portal                      |
| 3   | AI Model deployment (GPT-4o)        | 🔴 Must    | Model deployed and callable from the Project                         |
| 4   | Agent configuration — Patient Triage | 🟡 Should  | Agent responds to symptom descriptions with triage guidance          |
| 5   | Agent configuration — Appointment   | 🟡 Should  | Agent handles appointment scheduling queries                         |
| 6   | Agent configuration — Clinical Q&A  | 🟡 Should  | Agent answers general clinical questions                             |
| 7   | Agent configuration — Medication    | 🟢 Could   | Agent provides medication information and interactions               |
| 8   | Supporting infrastructure           | 🔴 Must    | Storage, Key Vault, App Insights, Log Analytics deployed             |

### Azure Services in Scope

| Service                        | SKU / Tier        | Region          | Purpose                              |
| ------------------------------ | ----------------- | --------------- | ------------------------------------ |
| Azure AI Foundry Hub           | Basic             | swedencentral   | Central AI workspace hub             |
| Azure AI Foundry Project       | —                 | swedencentral   | Project workspace for agents         |
| Azure OpenAI Service           | S0                | swedencentral   | GPT-4o model hosting                 |
| Storage Account                | Standard_LRS      | eastus2         | Hub data storage                     |
| Key Vault                      | Standard          | eastus2         | Secrets and key management           |
| Application Insights           | —                 | eastus2         | Agent telemetry and monitoring       |
| Log Analytics Workspace        | PerGB2018         | eastus2         | Centralized logging                  |

### Network Security

| Control                     | Required | Notes                                            |
| --------------------------- | -------- | ------------------------------------------------ |
| Private endpoints           | ❌       | Not required for demo/PoC                        |
| VNet integration            | ❌       | Not required for demo/PoC                        |
| Public endpoints acceptable | ✅       | Acceptable for demo workload                     |
| WAF required                | ❌       | No web-facing endpoints requiring WAF            |

### Recommended Security Controls

| Control               | Recommended | User Confirmed | Notes                                    |
| --------------------- | ----------- | -------------- | ---------------------------------------- |
| Managed Identity      | Yes         | Yes            | System-assigned for all services         |
| Private Endpoints     | No          | No             | Demo workload — public access acceptable |
| WAF                   | No          | No             | No public web endpoints                  |
| Key Vault for Secrets | Yes         | Yes            | Store API keys and connection strings    |
| Diagnostic Settings   | Yes         | Yes            | Route to Log Analytics                   |
| TLS 1.2 Minimum       | Yes         | Yes            | Always recommended                       |
| Encryption at Rest    | Yes         | Yes            | Platform default (Microsoft-managed)     |
| Network Isolation     | No          | No             | Not required for demo scale              |

## 🔧 Operational Requirements

### Scale & Performance

| Metric              | Value                        |
| ------------------- | ---------------------------- |
| Daily Users         | 1–10                         |
| Concurrent Users    | 1–5                          |
| Monthly Budget      | ~$100–300 USD                |
| Data Sensitivity    | Synthetic (no real PHI)      |

### Availability & Recovery

| Metric       | Value                              |
| ------------ | ---------------------------------- |
| SLA Target   | 99.5% (Relaxed — demo workload)   |
| RTO          | 24 hours                           |
| RPO          | 12 hours                           |
| Backup       | Not required (demo data)           |

### Compliance & Governance

| Framework        | Required | Notes                                   |
| ---------------- | -------- | --------------------------------------- |
| HIPAA            | ❌       | No real PHI — synthetic data only       |
| SOC 2            | ❌       | Demo workload                           |
| ISO 27001        | ❌       | Demo workload                           |
| Azure Policy     | ❌       | No policy enforcement for demo          |

### Regions

| Purpose                | Region          | Reason                              |
| ---------------------- | --------------- | ----------------------------------- |
| AI Services (Foundry)  | swedencentral   | Azure OpenAI model availability     |
| Supporting Infra       | eastus2         | Primary Azure region                |

### Required Tags

| Tag               | Value                        |
| ----------------- | ---------------------------- |
| `Environment`     | AZD environment name         |
| `ManagedBy`       | `Bicep`                      |
| `Project`         | `foundry-healthcare-agents`  |
| `SecurityControl` | `Ignore`                     |

## 📋 Summary for Architecture Assessment

### Handoff Summary

| Aspect               | Key Points                                                                                       |
| -------------------- | ------------------------------------------------------------------------------------------------ |
| Critical Constraints | Demo budget (~$300/month max), smallest viable SKUs, no real PHI data                            |
| Key Decisions        | Dual-region (swedencentral for AI, eastus2 for infra), public endpoints acceptable, no VNet      |
| Open Risks           | GPT-4o quota availability in swedencentral, AI Foundry preview feature stability                 |
| Recommended Pattern  | Interactive AI Agent with Azure AI Foundry Hub + Project                                         |

### Requirements Completeness

| Section                  | Status | Notes                                        |
| ------------------------ | ------ | -------------------------------------------- |
| Project Overview         | ✅     | Complete — demo/PoC healthcare AI scenario   |
| Functional Requirements  | ✅     | Complete — all services and capabilities     |
| Operational Requirements | ✅     | Complete — relaxed SLA, minimal budget       |

---

## References

- [Azure AI Foundry documentation](https://learn.microsoft.com/azure/ai-studio/)
- [Azure OpenAI Service](https://learn.microsoft.com/azure/ai-services/openai/)
- [Azure Verified Modules](https://aka.ms/avm)

---

> 📝 Generated by **az-02-Validations** agent | Step 1 of 5
