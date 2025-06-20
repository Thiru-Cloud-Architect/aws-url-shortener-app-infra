# AWS URL Shortener App (Terraform + Node.js Lambda)
A lightweight, serverless URL-shortener built using AWS Lambda, API Gateway, and DynamoDB, fully provisioned via Terraform.

--- 

## Project Structure
```bash
.
├── lambda/
│   ├── index.js
│   └── package.json
└── terraform/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf    
    ├── backend.tf    
    └── terraform.tfvars
```

---

## Features
- POST /shorten – Create a short URL (6-character random code) for any long URL. Requires         authorization:AUTH_TOKEN header.
- GET /get_original_url/{code} – Redirects to the original long URL. `Secure: requires static auth token & IAM-based access`
- Fully defined with Terraform + GitHub Actions CI/CD.

---

## Backlog & Future Enhancements
### APP:
- Branded/custom domain	Use go.mydomain.com instead of default API URL (using Route53 doamin and TLS with AWS ACM) | Medium Priority
- CORS / front-end enablement | Support a single-page UI | Low Priority
- Securing lambda code within the private vpc network with flow log enabled | High Priority << This is something of an unwanted engineering and it wont help the stuff >>
- URL expiration (TTL)	Automatically clean up stale short URLs	| Medium Priority

---

### Security & Governance
- Rate limiting / WAF |	Protect against malicious or excessive traffic	| High Priority
- IAM-based authentication	Add Cognito/STS instead of static bearer token	| High Priority
- Auth Token – Keep AUTH_TOKEN secret and rotate regularly | High Priority
- IAM Scoped Roles – The Lambda only needs read/write to the specific DynamoDB table | Medium Priority

---

### Observability
- Monitoring & Alerts	CloudWatch alarms on 5xx, URL mis-pattern, etc. | Medium Priority
- GitHub Actions → Lambda CI	Auto-deploy Node.js function on updates	| Medium Priority
- GitHub Actions → code push to run terraform plan and PR to approve and start the terrafrom apply. Basically to isolate both with reviews | High Priority

---

### Malicious Traffic Mitigation | Next Steps on securing 
- Add AWS WAF for IP throttling
- Validate/whitelist URL payloads and block SQL/XSS patterns
- Rate-limit short code usage via API Gateway usage plans

---

## How to Build the App
- Step:1 Build/deploy the Lambda ZIP (index.js + package.json + node_modules) to S3.
- Step 2 Apply Terraform: 

```bash 
cd terraform/ 
terraform init 
terraform plan 
terraform apply -auto-approve 
```

### How to use the App | Test endpoints via curl or Postman: 
    
### To make short url (POST)
    
```bash        
curl -X POST https://<api-id>.execute-api.ap-south-1.amazonaws.com/shorten \
    -H "Content-Type:application/json" \ 
    -H "authorization: $AUTH_TOKEN" \ 
    -d '{"URL":"https://www.babbel.com"}' 
```

### To get the original URL (GET)

```bash 
curl -i https://<api-id>.execute-api.ap-south-1.amazonaws.com/get_original_url/<shortCode_generated>        
```

