### Method 1: The Fileless One-Liner (Recommended)
You can run the script directly from PowerShell without having to download or keep the `.bat` file on your system. 

Open **PowerShell** or **Command Prompt** and paste the following command:

```powershell
powershell -NoProfile -Command "irm 'https://raw.githubusercontent.com/Useless007/logwipe/refs/heads/main/logwipe.bat' -OutFile $env:TEMP\logwipe.bat; Start-Process $env:TEMP\logwipe.bat -Wait; rm $env:TEMP\logwipe.bat"
```
