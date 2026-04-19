# Backup için gerekli klasörleri oluşturma
New-Item -ItemType Directory -Path "C:\Backups\Full"
New-Item -ItemType Directory -Path "C:\Backups\Diff"
New-Item -ItemType Directory -Path "C:\Backups\Log"

# gMSA hesabına bu klasörler için yazma yetkisi verme
$acl = Get-Acl "C:\Backups"
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("buraklab\gmsaSQL$","FullControl","ContainerInherit,ObjectInherit","None","Allow")
$acl.SetAccessRule($rule)
Set-Acl "C:\Backups" $acl