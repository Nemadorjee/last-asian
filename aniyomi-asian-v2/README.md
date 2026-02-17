# Aniyomi Asian Extensions Repository

This is a custom Aniyomi extension repository containing:
- **Javguru**
- **JavGG**
- **MissAV**
- **SupJav**

## Usage in Aniyomi

1.  Go to **Settings > Browse > Extension Repos**.
2.  Tap **Add**.
3.  Enter the URL: `https://raw.githubusercontent.com/<YOUR_USERNAME>/<REPO_NAME>/main/index.min.json`

## Updates

To update the extensions, run the `download_extensions.ps1` PowerShell script in this directory. It will fetch the latest versions from the upstream source and regenerate `index.min.json`.

```powershell
.\download_extensions.ps1
```
