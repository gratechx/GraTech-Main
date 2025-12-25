# 🚀 GraTech Platform - Quick Commands Reference

**Last Updated**: December 25, 2025  
**Your Live API**: https://gratech-api.lemondune-e5f760db.uaenorth.azurecontainerapps.io

---

## 🔐 Azure Login

```powershell
# Login to government account
az login --tenant gratechksa.onmicrosoft.com

# Verify account
az account show

# List subscriptions
az account list --output table
```

---

## 📊 Check API Status

```powershell
# Health check
curl https://gratech-api.lemondune-e5f760db.uaenorth.azurecontainerapps.io/health

# API Documentation
start https://gratech-api.lemondune-e5f760db.uaenorth.azurecontainerapps.io/docs

# List models
curl https://gratech-api.lemondune-e5f760db.uaenorth.azurecontainerapps.io/api/models
```

```bash
# Using PowerShell
Invoke-WebRequest -Uri "https://gratech-api.lemondune-e5f760db.uaenorth.azurecontainerapps.io/health" | Select-Object -ExpandProperty Content | ConvertFrom-Json
```

---

## 🔄 View Logs

```powershell
# Real-time logs (follow)
az containerapp logs show `
  --name gratech-api `
  --resource-group rg-gratech-prod `
  --follow

# Last 100 lines
az containerapp logs show `
  --name gratech-api `
  --resource-group rg-gratech-prod `
  --tail 100
```

---

## 🔄 Restart/Update App

```powershell
# Restart the app
az containerapp restart `
  --name gratech-api `
  --resource-group rg-gratech-prod

# Update environment variables
az containerapp update `
  --name gratech-api `
  --resource-group rg-gratech-prod `
  --set-env-vars NEW_VAR=value

# Update image (after new build)
az containerapp update `
  --name gratech-api `
  --resource-group rg-gratech-prod `
  --image gratechregistry.azurecr.io/gratech-api:latest
```

---

## ⚖️ Scale Up/Down

```powershell
# Scale to 2-5 replicas (auto-scale)
az containerapp update `
  --name gratech-api `
  --resource-group rg-gratech-prod `
  --min-replicas 2 `
  --max-replicas 5

# Scale to 1 replica (development)
az containerapp update `
  --name gratech-api `
  --resource-group rg-gratech-prod `
  --min-replicas 1 `
  --max-replicas 1

# Check current scale
az containerapp show `
  --name gratech-api `
  --resource-group rg-gratech-prod `
  --query "properties.template.scale"
```

---

## 📦 Deploy New Version

```powershell
# Option 1: Quick deploy from source
cd deploy-package
az containerapp up `
  --name gratech-api `
  --resource-group rg-gratech-prod `
  --location uaenorth `
  --environment gratech-env `
  --source . `
  --target-port 8000 `
  --ingress external

# Option 2: Build and push Docker image
docker build -t gratechregistry.azurecr.io/gratech-api:latest .
docker push gratechregistry.azurecr.io/gratech-api:latest

# Then update Container App
az containerapp update `
  --name gratech-api `
  --resource-group rg-gratech-prod `
  --image gratechregistry.azurecr.io/gratech-api:latest
```

---

## 🌐 Custom Domain Setup

```powershell
# Add custom domain (after DNS configuration)
az containerapp hostname add `
  --name gratech-api `
  --resource-group rg-gratech-prod `
  --hostname api.gratech.sa

# List hostnames
az containerapp hostname list `
  --name gratech-api `
  --resource-group rg-gratech-prod

# Remove hostname
az containerapp hostname delete `
  --name gratech-api `
  --resource-group rg-gratech-prod `
  --hostname api.gratech.sa
```

### DNS Configuration Required:
```
Type: CNAME
Name: api
Value: gratech-api.lemondune-e5f760db.uaenorth.azurecontainerapps.io
TTL: 3600
```

---

## 💰 Cost Management

```powershell
# View current costs
az consumption usage list `
  --start-date (Get-Date).AddDays(-30).ToString("yyyy-MM-dd") `
  --end-date (Get-Date).ToString("yyyy-MM-dd") `
  --output table

# Check resource usage
az monitor metrics list `
  --resource /subscriptions/9c0f7def-dc37-4ec3-a979-27f674177fec/resourceGroups/rg-gratech-prod/providers/Microsoft.App/containerApps/gratech-api `
  --metric "Requests" `
  --output table
```

---

## 🔍 Troubleshooting

### Check App Status
```powershell
az containerapp show `
  --name gratech-api `
  --resource-group rg-gratech-prod `
  --query "{name:name, status:properties.provisioningState, fqdn:properties.configuration.ingress.fqdn}" `
  --output table
```

### Check Revisions
```powershell
# List all revisions
az containerapp revision list `
  --name gratech-api `
  --resource-group rg-gratech-prod `
  --output table

# Activate specific revision
az containerapp revision activate `
  --name gratech-api `
  --resource-group rg-gratech-prod `
  --revision <revision-name>
```

### View Events
```powershell
az containerapp show `
  --name gratech-api `
  --resource-group rg-gratech-prod `
  --query "properties.latestRevisionName"
```

---

## 🗑️ Clean Up (Careful!)

```powershell
# Delete the app (CAREFUL!)
az containerapp delete `
  --name gratech-api `
  --resource-group rg-gratech-prod `
  --yes

# Delete entire resource group (VERY CAREFUL!)
az group delete `
  --name rg-gratech-prod `
  --yes
```

---

## 🔐 Secrets Management

```powershell
# Add secret
az containerapp secret set `
  --name gratech-api `
  --resource-group rg-gratech-prod `
  --secrets newsecret=secretvalue

# List secrets
az containerapp secret list `
  --name gratech-api `
  --resource-group rg-gratech-prod

# Remove secret
az containerapp secret remove `
  --name gratech-api `
  --resource-group rg-gratech-prod `
  --secret-names newsecret
```

---

## 📋 List All Resources

```powershell
# All resources in resource group
az resource list `
  --resource-group rg-gratech-prod `
  --output table

# Container Apps only
az containerapp list `
  --resource-group rg-gratech-prod `
  --output table

# Container Registries
az acr list `
  --resource-group rg-gratech-prod `
  --output table
```

---

## 🧪 Test API Endpoints

### Health Check
```powershell
Invoke-RestMethod -Uri "https://gratech-api.lemondune-e5f760db.uaenorth.azurecontainerapps.io/health"
```

### List Models
```powershell
Invoke-RestMethod -Uri "https://gratech-api.lemondune-e5f760db.uaenorth.azurecontainerapps.io/api/models"
```

### Chat (POST)
```powershell
$body = @{
    model = "claude-opus-4-5"
    messages = @(
        @{
            role = "user"
            content = "مرحباً! كيف حالك؟"
        }
    )
} | ConvertTo-Json

Invoke-RestMethod `
    -Uri "https://gratech-api.lemondune-e5f760db.uaenorth.azurecontainerapps.io/api/chat" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

---

## 🔄 Git Operations

```powershell
# Check status
git status

# Pull latest
git pull origin main

# Commit and push
git add .
git commit -m "Your message"
git push origin main

# View history
git log --oneline -10

# View remote
git remote -v
```

---

## 📁 Project Structure

```
gratech/
├── src/                    # Backend source code
│   ├── main.py            # FastAPI app
│   └── api/
│       └── gateway.py     # AI Gateway
├── config/                 # Configuration
│   └── models.json        # Model definitions
├── comet-x-browser/       # Browser extension
├── docs/                   # Documentation
├── evidence/              # Perplexity incident evidence
├── legal/                 # Legal documents
├── deploy-package/        # Clean deployment folder
├── .env.production        # Environment variables (local)
├── Dockerfile            # Docker configuration
├── requirements.txt      # Python dependencies
├── setup.ps1             # Local setup script
├── deploy-azure.ps1      # Azure deployment script
└── README.md             # Main documentation
```

---

## 🆘 Emergency Commands

### App Not Responding
```powershell
# 1. Check logs
az containerapp logs show -n gratech-api -g rg-gratech-prod --tail 50

# 2. Restart
az containerapp restart -n gratech-api -g rg-gratech-prod

# 3. Check status
az containerapp show -n gratech-api -g rg-gratech-prod --query "properties.runningStatus"
```

### High Costs
```powershell
# Scale down to 1 replica
az containerapp update -n gratech-api -g rg-gratech-prod --min-replicas 1 --max-replicas 1
```

### Need to Rollback
```powershell
# List revisions
az containerapp revision list -n gratech-api -g rg-gratech-prod --output table

# Activate previous revision
az containerapp revision activate -n gratech-api -g rg-gratech-prod --revision <previous-revision>
```

---

## 📞 Useful Links

- **Azure Portal**: https://portal.azure.com
- **Resource Group**: https://portal.azure.com/#@gratechksa.onmicrosoft.com/resource/subscriptions/9c0f7def-dc37-4ec3-a979-27f674177fec/resourceGroups/rg-gratech-prod
- **Container App**: https://portal.azure.com/#@gratechksa.onmicrosoft.com/resource/subscriptions/9c0f7def-dc37-4ec3-a979-27f674177fec/resourceGroups/rg-gratech-prod/providers/Microsoft.App/containerApps/gratech-api
- **Git Repo**: https://dev.azure.com/grar00t/gratech/_git/gratech
- **API Docs**: https://gratech-api.lemondune-e5f760db.uaenorth.azurecontainerapps.io/docs
- **Website**: https://www.gratech.sa

---

## 💡 Pro Tips

1. **Always check logs first** when troubleshooting
2. **Use `--dry-run`** flag when testing destructive commands
3. **Tag your images** with version numbers (e.g., `v1.0.0`)
4. **Set up alerts** in Azure Monitor for production
5. **Keep backups** of your `.env.production` file
6. **Document changes** in git commit messages
7. **Test locally** before deploying to production

---

## 🇸🇦 Support

- **Email**: admin@gratech.sa
- **Git Issues**: Create issue in Azure DevOps
- **Azure Support**: Open ticket in Azure Portal

---

**Last Deployment**: December 25, 2025  
**Status**: ✅ Live and Running  
**Next Review**: Connect API to gratech.sa

🚀 **Keep building the future!** 💚
