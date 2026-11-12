# 🛡️ ThreadWatch — AWS Threat Detection & Auto-Remediation Pipeline

![AWS](https://img.shields.io/badge/AWS-Cloud-orange) ![Terraform](https://img.shields.io/badge/IaC-Terraform-purple) ![Lambda](https://img.shields.io/badge/Serverless-Lambda-yellow) ![MITRE](https://img.shields.io/badge/MITRE-ATT%26CK-red)

ThreadWatch is a production-grade, serverless cloud security automation pipeline that automatically detects, investigates, and remediates AWS security threats in real-time using MITRE ATT&CK intelligence. It consumes AWS GuardDuty findings and turns them into automated incident response.

---

## 🏗️ Architecture

```
GuardDuty Finding
      ↓
EventBridge (severity >= 7 filter)
      ↓
Lambda (threadwatch-alert-processor)
      ↓
┌─────────────────────────────────┐
│  THREAT INTELLIGENCE ENGINE     │
│  • MITRE ATT&CK Mapping         │
│  • Dynamic Risk Scoring (0-100) │
│  • CloudTrail Correlation       │
└─────────────────────────────────┘
      ↓
┌─────────────────────────────────┐
│  AUTO-REMEDIATION ENGINE        │
│  • IAM: Full lockdown           │
│  • EC2: Forensic isolation      │
│  • S3: Public access block      │
└─────────────────────────────────┘
      ↓
┌─────────────────────────────────┐
│  INCIDENT MANAGEMENT            │
│  • DynamoDB audit trail         │
│  • CloudWatch custom metrics    │
│  • SNS email alerting           │
└─────────────────────────────────┘
```

---

## ✨ Features

### 🔍 Threat Intelligence
- **MITRE ATT&CK mapping** - every finding tagged with technique ID and tactic
- **Dynamic risk scoring** - 0-100 score based on finding type and severity
- **CloudTrail correlation** - last 10 API calls from compromised entity

### ⚡ Automated Remediation

| Finding Type | Severity | Action |
|-------------|----------|--------|
| IAMUser/UnauthorizedAccess | 7+ | Disable access keys, detach policies |
| IAMUser/UnauthorizedAccess | 9+ | Full lockout (keys + policies + groups + console) |
| EC2/CryptoCurrency | 7+ | Isolate to quarantine security group + forensic tags |
| EC2/Backdoor | 9+ | Isolate + stop instance for forensic analysis |
| S3/BucketPublicAccess | 7+ | Block public access + apply deny policy |

### 📊 Observability
- **DynamoDB** incident log with 90-day TTL
- **CloudWatch** custom metrics namespace (`ThreadWatch/AutoRemediation`)
- **SNS** professional IR report with MITRE context

---

## 🛠️ Tech Stack

- **AWS GuardDuty** - Threat detection
- **AWS EventBridge** - Serverless event routing
- **AWS Lambda** (Node.js 20.x) - Auto-remediation engine
- **AWS DynamoDB** - Incident audit trail
- **AWS CloudTrail** - Forensic activity correlation
- **AWS CloudWatch** - Custom security metrics
- **AWS SNS** - Alert delivery
- **Terraform** - Infrastructure as Code

---

## 📧 Sample Alert Output

```
🟠 THREADWATCH AUTO-REMEDIATION REPORT 🟠
══════════════════════════════════════

THREAT INTELLIGENCE
───────────────────
MITRE ATT&CK: T1078 - Valid Accounts
Tactic:       Defense Evasion
Risk Score:   70/100

FINDING DETAILS
───────────────
Type:     UnauthorizedAccess:IAMUser/MaliciousIPCaller
Severity: 7/10
Account:  123456789012
Region:   eu-north-1

AUTOMATED RESPONSE
──────────────────
🔑 Disabled access key: AKIA...
📋 Detached policy: AdministratorAccess
🚫 Console access revoked
```

---

## 🚨 Reference Incident

This pipeline was built around a **Severity 8 GuardDuty finding** (`UnauthorizedAccess:IAMUser`) detected in a live AWS environment.

**Timeline:**
1. GuardDuty detected `UnauthorizedAccess:IAMUser` - Severity 8
2. EventBridge routed the finding to Lambda in < 1 second
3. Lambda calculated Risk Score: 80/100, MITRE: T1078
4. CloudTrail correlation retrieved last 10 API calls from compromised user
5. All access keys disabled automatically
6. Incident logged to DynamoDB with full forensic context
7. MITRE-enriched IR report delivered via email

---

## 🏗️ Deploy with Terraform

```bash
# Clone the repository
git clone https://github.com/Naveenbtnk/Threadwatch.git
cd Threadwatch

# Package the Lambda code (Terraform expects lambda.zip)
cd lambda && zip -r ../lambda.zip . && cd ..

# Configure the alert email (required)
echo 'alert_email = "you@example.com"' > terraform.tfvars

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy all infrastructure
terraform apply

# Import existing resources (if already deployed manually)
terraform import aws_guardduty_detector.main <detector-id>
terraform import aws_sns_topic.security_alerts <sns-arn>
terraform import aws_dynamodb_table.incidents threadwatch-incidents
terraform import aws_lambda_function.threadwatch_processor threadwatch-alert-processor
```

The default region is `eu-north-1`; override it with `aws_region` in `terraform.tfvars`.

---

## 📁 Project Structure

```
Threadwatch/
├── lambda/
│   └── index.mjs          # Threat intelligence + auto-remediation engine
├── main.tf                # Terraform infrastructure definition
├── variables.tf           # Configuration variables
├── outputs.tf             # Output values
├── .gitignore             # Excludes sensitive files
└── README.md              # This file
```

---

## 🔐 Security Considerations

- Terraform state excluded from version control
- AWS credentials never stored in code
- Least privilege IAM roles for Lambda execution
- Severity-based response tiers (notify only vs auto-remediate)
- DynamoDB TTL ensures automatic data expiry after 90 days
- All sensitive config via Lambda environment variables
