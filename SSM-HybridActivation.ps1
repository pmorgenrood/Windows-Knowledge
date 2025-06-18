# Install only the required AWS PowerShell modules if not already installed
if (-not (Get-Module -ListAvailable -Name AWS.Tools.SimpleSystemsManagement)) {
    Write-Host "Installing required AWS PowerShell modules..."
    Install-Module -Name AWS.Tools.SimpleSystemsManagement -Force -Scope CurrentUser
    Install-Module -Name AWS.Tools.Common -Force -Scope CurrentUser
    Install-Module -Name AWS.Tools.IdentityManagement -Force -Scope CurrentUser
}

# Import the required modules
Import-Module AWS.Tools.SimpleSystemsManagement
Import-Module AWS.Tools.Common
Import-Module AWS.Tools.IdentityManagement

# Set AWS credentials
$AccessKeyId = "AKIA"
$SecretAccessKey = ""
Set-AWSCredential -AccessKey $AccessKeyId -SecretKey $SecretAccessKey -StoreAs SSMRegistration
Initialize-AWSDefaultConfiguration -ProfileName SSMRegistration

# # Create IAM Role if it doesn't exist
# $json = '{
#     "Version": "2012-10-17",
#     "Statement": {
#         "Effect": "Allow",
#         "Principal": {"Service": "ssm.amazonaws.com"},
#         "Action": "sts:AssumeRole"
#     }
# }'

# try {
#     Get-IAMRole -RoleName SSMHybrid
#     Write-Host "Role SSMHybrid already exists"
# } catch {
#     Write-Host "Creating new role SSMHybrid"
#     New-IAMRole -RoleName SSMHybrid -AssumeRolePolicyDocument $json
#     Register-IAMRolePolicy -RoleName SSMHybrid -PolicyArn "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

##EDIT THE VARS BELOW##
#Create new Activation and store in Parameter Store
$Region = "af-south-1"
$DefaultInstanceName = "LaptopManaged"
$IAMRole = "SSMHybrid"
$RegistrationLimit = 1
$Activation = New-SSMActivation -DefaultInstanceName $DefaultInstanceName -IamRole $IAMRole -RegistrationLimit $RegistrationLimit -Region $Region

#####Do not edit from here####
$code = $Activation.ActivationCode
$id = $Activation.ActivationId

Write-Host "Activation created:"
Write-Host "Activation ID: $id"
Write-Host "Activation Code: $code"

$dir = $env:TEMP + "\ssm"
New-Item -ItemType directory -Path $dir -Force
Set-Location $dir

Write-Host "Downloading SSM Agent installer..."
# Import BitsTransfer module if not already loaded
if (-not (Get-Module -Name BitsTransfer)) {
    Import-Module BitsTransfer
}
# Use BITS to download the file (faster and supports resume)
Start-BitsTransfer -Source "https://amazon-ssm-eu-west-1.s3.eu-west-1.amazonaws.com/latest/windows_amd64/AmazonSSMAgentSetup.exe" -Destination "$dir\AmazonSSMAgentSetup.exe" -DisplayName "SSM Agent Download" -Priority High

Write-Host "Installing SSM Agent..."
Start-Process .\AmazonSSMAgentSetup.exe -ArgumentList @("/q", "/log", "install.log", "CODE=$code", "ID=$id", "REGION=$Region") -Wait
Start-Sleep 3

Write-Host "Registration details:"
Get-Content ($env:ProgramData + "\Amazon\SSM\InstanceData\registration")

Write-Host "SSM Agent service status:"
Get-Service -Name "AmazonSSMAgent"
