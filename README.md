AWS URL Shortener App (Terraform + Node.js Lambda)
A lightweight, serverless URL-shortener built using AWS Lambda, API Gateway, and DynamoDB, fully provisioned via Terraform.

📦 Project Structure
.
├── lambda/
│   ├── index.js
│   └── package.json
└── terraform/
    ├── main.tf
    ├── variables.tf
    └── terraform.tfvars

🚀 Features
    - POST /shorten – Create a short URL (6-character random code) for any long URL.
        Requires authorization: AUTH_TOKEN header.
    - GET /get_original_url/{code} – Redirects to the original long URL.
        Secure: requires static auth token & IAM-based access.
    - Fully defined with Terraform + GitHub Actions CI/CD.

🗂 Backlog & Future Enhancements
APP:
    - Branded/custom domain	Use go.mydomain.com instead of default API URL (using Route53 doamin and TLS with AWS ACM)	High
    - CORS / front-end enablement | Support a single-page UI	Low
    - Securing lambda code within the private vpc network with flow log enabled
    - URL expiration (TTL)	Automatically clean up stale short URLs	Medium
    - Click counter analytics	Track URL usage & popular links	Medium ## I need to analyse this
    - Custom shortcodes	Make vanity links (e.g., go/my-offer)	High

Security & Governance
    - Rate limiting / WAF	Protect against malicious or excessive traffic	High
    - IAM-based authentication	Add Cognito/STS instead of static bearer token	High
    - Auth Token – Keep AUTH_TOKEN secret and rotate regularly
    - IAM Scoped Roles – The Lambda only needs read/write to the specific DynamoDB table

Observability
    - Monitoring & Alerts	CloudWatch alarms on 5xx, URL mis-pattern, etc.	Medium
    - GitHub Actions → Lambda CI	Auto-deploy Node.js function on updates	Medium
    - GitHub Actions → code push to run terraform plan and PR to approve and start the terrafrom apply. Basically to isolate both with reviews


** Malicious Traffic Mitigation **
    - Add AWS WAF for IP throttling
    - Validate/whitelist URL payloads and block SQL/XSS patterns
    - Rate-limit short code usage via API Gateway usage plans

How to Build the App
    Step:1 Build/deploy the Lambda ZIP (index.js + package.json + node_modules) to S3.
    Step 2 Apply Terraform: bash cd terraform/ terraform init terraform plan and terraform apply -auto-approve 

How to use the App
    Test endpoints via curl or Postman: 
    
    ```bash curl -X POST -H "Content-Type:application/json" \ -H "authorization: $AUTH_TOKEN" \ -d '{"URL":"https://example.com"}' \ https://<api-id>.execute-api.ap-south-1.amazonaws.com/shorten

    curl -i https://<api-id>.execute-api.ap-south-1.amazonaws.com/get_original_url/<shortCode> ```

