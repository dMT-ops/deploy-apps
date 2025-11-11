# Auto-MultiAppRemote.ps1 - Instalação Remota de Múltiplos Aplicativos
# Execute com: irm "https://github.com/dMT-ops/deploy-apps/raw/main/Scripts/Auto-MultiAppRemote.ps1" | iex

# CONFIGURAÇÕES GLOBAIS
$GitHubBase = "https://github.com/dMT-ops/deploy-apps/raw/main"
$ProgramasDir = "C:\Programas"
$LogFile = "C:\MultiAppRemote.log"

# CATÁLOGO DE APLICATIVOS
$AppCatalog = @{
    "2xClient" = @{
        Name = "2X Client"
        SetupFile = "2xclient-x64.msi"
        DesktopName = "Instalar2XClient.exe"
    }
    "Java" = @{
        Name = "Java Runtime 8"
        SetupFile = "4-jre-8u231-windows-x64.exe"
        DesktopName = "InstalarJava.exe"
    }
    "Chrome" = @{
        Name = "Google Chrome"
        SetupFile = "5-ChromeSetup.exe"
        DesktopName = "InstalarChrome.exe"
    }
    "7Zip" = @{
        Name = "7-Zip"
        SetupFile = "7z2401-x64.exe"
        DesktopName = "Instalar7Zip.exe"
    }
    "AnyDesk" = @{
        Name = "AnyDesk"
        SetupFile = "AnyDesk_Diagonal.exe"
        DesktopName = "InstalarAnyDesk.exe"
    }
    "FortiClient" = @{
        Name = "FortiClient VPN"
        SetupFile = "FortiClientVPN.exe"
        DesktopName = "InstalarFortiClient.exe"
    }
    "NDDPrint" = @{
        Name = "NDD Print Agent"
        SetupFile = "nddPrintAgentSetup-x64_5.19.6.exe"
        DesktopName = "InstalarNDDPrint.exe"
    }
    "Office" = @{
        Name = "Microsoft Office"
        SetupFile = "OfficeSetup.exe"
        DesktopName = "InstalarOffice.exe"
    }
    "GoTo" = @{
        Name = "GoTo Meeting"
        SetupFile = "GoToSetup.exe"
        DesktopName = "InstalarGoTo.exe"
    }
    "FoxitPDF" = @{
        Name = "Foxit PDF Reader"
        SetupFile = "FoxitPDFReader20241_L10N_Setup_Prom.exe"
        DesktopName = "InstalarFoxitPDF.exe"
    }
    "EPSKit" = @{
        Name = "EPS Kit"
        SetupFile = "epskit_x64.exe"
        DesktopName = "InstalarEPSKit.exe"
    }
}

# FUNÇÃO DE LOG
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$timestamp - $Message" | Out-File $LogFile -Append
    Write-Host "$timestamp - $Message" -ForegroundColor Gray
}

# FUNÇÃO PARA EXIBIR MENU DE APLICATIVOS
function Show-AppMenu {
    Clear-Host
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "    🚀 DEPLOY-APPS - INSTALADOR REMOTO" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📱 APLICATIVOS DISPONÍVEIS:" -ForegroundColor Yellow
    Write-Host ""
    
    $i = 1
    $appKeys = @()
    
    foreach ($appKey in $AppCatalog.Keys) {
        $app = $AppCatalog[$appKey]
        Write-Host "   $i. $($app.Name)" -ForegroundColor White
        $appKeys += $appKey
        $i++
    }
    
    Write-Host ""
    Write-Host "   A. TODOS os aplicativos" -ForegroundColor Green
    Write-Host ""
    
    return $appKeys
}

# FUNÇÃO PARA SELECIONAR APLICATIVOS
function Select-Applications {
    $appKeys = Show-AppMenu
    
    while ($true) {
        $choice = Read-Host "`nSelecione os aplicativos (ex: 1, 1-3, A para todos)"
        
        if ($choice -eq 'A' -or $choice -eq 'a') {
            Write-Log "Usuário selecionou: TODOS os aplicativos"
            return $AppCatalog.Keys
        }
        
        # Processar seleção múltipla
        $selectedApps = @()
        $selections = $choice -split ',' | ForEach-Object { $_.Trim() }
        
        foreach ($sel in $selections) {
            if ($sel -match '^(\d+)-(\d+)$') {
                # Range (ex: 1-3)
                $start = [int]$matches[1]
                $end = [int]$matches[2]
                for ($i = $start; $i -le $end; $i++) {
                    if ($i -ge 1 -and $i -le $appKeys.Count) {
                        $selectedApps += $appKeys[$i-1]
                    }
                }
            } elseif ($sel -match '^\d+$') {
                # Número único
                $index = [int]$sel
                if ($index -ge 1 -and $index -le $appKeys.Count) {
                    $selectedApps += $appKeys[$index-1]
                }
            }
        }
        
        $selectedApps = $selectedApps | Select-Object -Unique
        
        if ($selectedApps.Count -gt 0) {
            Write-Host "`n✅ Aplicativos selecionados:" -ForegroundColor Green
            foreach ($appKey in $selectedApps) {
                Write-Host "   • $($AppCatalog[$appKey].Name)" -ForegroundColor White
            }
            
            $confirm = Read-Host "`nConfirmar seleção? (S/N)"
            if ($confirm -match '^[Ss]$') {
                Write-Log "Aplicativos selecionados: $($selectedApps -join ', ')"
                return $selectedApps
            }
        } else {
            Write-Host "❌ Seleção inválida. Tente novamente." -ForegroundColor Red
        }
    }
}

# FUNÇÃO PARA BAIXAR APLICATIVOS
function Download-Applications {
    param([array]$SelectedApps)
    
    Write-Host "📥 Baixando aplicativos selecionados..." -ForegroundColor Yellow
    Write-Log "Iniciando download de $($SelectedApps.Count) aplicativos"
    
    $downloadResults = @{}
    $successCount = 0
    
    foreach ($appKey in $SelectedApps) {
        $app = $AppCatalog[$appKey]
        $localPath = "$ProgramasDir\$($app.SetupFile)"
        
        Write-Host "   📦 $($app.Name)..." -NoNewline -ForegroundColor Gray
        
        try {
            Invoke-WebRequest "$GitHubBase/Programas/$($app.SetupFile)" -OutFile $localPath -ErrorAction Stop
            Write-Host " ✅" -ForegroundColor Green
            Write-Log "Download concluído: $($app.Name)"
            $downloadResults[$appKey] = $true
            $successCount++
        } catch {
            Write-Host " ❌" -ForegroundColor Red
            Write-Host "      Erro: $($_.Exception.Message)" -ForegroundColor Red
            Write-Log "ERRO no download do $($app.Name): $($_.Exception.Message)"
            $downloadResults[$appKey] = $false
        }
    }
    
    Write-Host ""
    Write-Host "📊 Download concluído: $successCount/$($SelectedApps.Count) aplicativos baixados" -ForegroundColor $(if ($successCount -eq $SelectedApps.Count) { "Green" } else { "Yellow" })
    
    return $downloadResults
}

# FUNÇÃO PARA OBTER DESKTOP DO USUÁRIO
function Get-RemoteUserDesktop {
    param([string]$ComputerName)
    
    try {
        # Tentar via WMI primeiro
        $loggedInUser = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ComputerName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty UserName
        
        if ($loggedInUser) {
            $userName = $loggedInUser.Split('\')[-1]
            $userDesktopPath = "\\$ComputerName\C$\Users\$userName\Desktop"
            
            if (Test-Path $userDesktopPath) {
                Write-Log "Desktop do usuário encontrado: $userDesktopPath"
                return $userDesktopPath
            }
        }
        
        # Fallback: buscar em todas as pastas de usuário
        $usersPath = "\\$ComputerName\C$\Users"
        if (Test-Path $usersPath) {
            $userFolders = Get-ChildItem $usersPath -Directory -ErrorAction SilentlyContinue | Where-Object { 
                $_.Name -notin @('Public', 'Default', 'All Users', 'Administrator') -and
                (Test-Path "$usersPath\$($_.Name)\Desktop" -ErrorAction SilentlyContinue)
            }
            
            foreach ($userFolder in $userFolders) {
                $desktopPath = "$usersPath\$($userFolder.Name)\Desktop"
                if (Test-Path $desktopPath) {
                    Write-Log "Desktop encontrado para usuário: $($userFolder.Name)"
                    return $desktopPath
                }
            }
        }
        
        return $null
    } catch {
        Write-Log "ERRO ao buscar Desktop em $ComputerName : $($_.Exception.Message)"
        return $null
    }
}

# FUNÇÃO PARA TRANSFERIR APLICATIVOS PARA MÁQUINAS REMOTAS
function Transfer-AppsToRemote {
    param([string]$ComputerName, [array]$SelectedApps, [hashtable]$DownloadResults)
    
    try {
        Write-Log "Iniciando transferência para: $ComputerName"
        
        # Criar pasta Programas na máquina remota
        $remoteProgramasDir = "\\$ComputerName\C$\Programas"
        Write-Host "      📁 Criando pasta Programas..." -NoNewline -ForegroundColor Gray
        
        try {
            New-Item -Path $remoteProgramasDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
            Write-Host " ✅" -ForegroundColor Green
        } catch {
            Write-Host " ❌" -ForegroundColor Red
            Write-Log "ERRO: Não foi possível criar pasta Programas em $ComputerName"
            return $false
        }
        
        # Copiar aplicativos para Programas
        $programasCopied = 0
        foreach ($appKey in $SelectedApps) {
            if (-not $DownloadResults[$appKey]) { continue }
            
            $app = $AppCatalog[$appKey]
            $sourcePath = "$ProgramasDir\$($app.SetupFile)"
            $destPath = "$remoteProgramasDir\$($app.SetupFile)"
            
            try {
                Copy-Item $sourcePath $destPath -Force -ErrorAction Stop
                $programasCopied++
            } catch {
                Write-Log "AVISO: Não foi possível copiar $($app.Name) para Programas em $ComputerName"
            }
        }
        
        # Copiar para Desktop do usuário
        Write-Host "      🖥️  Copiando para Área de Trabalho..." -NoNewline -ForegroundColor Gray
        $desktopCopied = 0
        $userDesktopPath = Get-RemoteUserDesktop -ComputerName $ComputerName
        
        if ($userDesktopPath -and (Test-Path $userDesktopPath)) {
            foreach ($appKey in $SelectedApps) {
                if (-not $DownloadResults[$appKey]) { continue }
                
                $app = $AppCatalog[$appKey]
                $sourcePath = "$ProgramasDir\$($app.SetupFile)"
                $destPath = "$userDesktopPath\$($app.DesktopName)"
                
                try {
                    Copy-Item $sourcePath $destPath -Force -ErrorAction SilentlyContinue
                    if (Test-Path $destPath) {
                        $desktopCopied++
                    }
                } catch {
                    # Ignora erros individuais de cópia
                }
            }
        }
        
        # Fallback para Desktop público
        if ($desktopCopied -eq 0) {
            $publicDesktop = "\\$ComputerName\C$\Users\Public\Desktop"
            if (Test-Path $publicDesktop) {
                foreach ($appKey in $SelectedApps) {
                    if (-not $DownloadResults[$appKey]) { continue }
                    
                    $app = $AppCatalog[$appKey]
                    $sourcePath = "$ProgramasDir\$($app.SetupFile)"
                    $destPath = "$publicDesktop\$($app.DesktopName)"
                    
                    try {
                        Copy-Item $sourcePath $destPath -Force -ErrorAction SilentlyContinue
                        if (Test-Path $destPath) {
                            $desktopCopied++
                        }
                    } catch {
                        # Ignora erros individuais de cópia
                    }
                }
            }
        }
        
        if ($desktopCopied -gt 0) {
            Write-Host " ✅ ($desktopCopied apps)" -ForegroundColor Green
        } else {
            Write-Host " ⚠ (apenas Programas)" -ForegroundColor Yellow
        }
        
        # Considerar sucesso se pelo menos um arquivo foi copiado para Programas
        if ($programasCopied -gt 0) {
            Write-Log "SUCESSO: $programasCopied/$($SelectedApps.Count) apps transferidos para $ComputerName"
            return $true
        } else {
            Write-Log "FALHA: Nenhum app transferido para $ComputerName"
            return $false
        }
        
    } catch {
        Write-Host " ❌" -ForegroundColor Red
        Write-Log "ERRO na transferência para $ComputerName : $($_.Exception.Message)"
        return $false
    }
}

# FUNÇÃO PARA TESTAR CONEXÃO COM MÁQUINAS
function Test-MachinesConnection {
    param([array]$Computers)
    
    Write-Host "🔍 Verificando máquinas online..." -ForegroundColor Yellow
    Write-Log "Iniciando teste de conexão com $($Computers.Count) máquinas"
    
    $onlineComputers = @()
    $offlineComputers = @()
    
    $i = 0
    foreach ($computer in $Computers) {
        $computer = $computer.Trim()
        if (-not $computer) { continue }
        
        $i++
        Write-Host "   [$i/$($Computers.Count)] $computer... " -NoNewline -ForegroundColor Gray
        
        if (Test-Connection -ComputerName $computer -Count 1 -Quiet -ErrorAction SilentlyContinue) {
            Write-Host "✅ ONLINE" -ForegroundColor Green
            $onlineComputers += $computer
            Write-Log "ONLINE: $computer"
        } else {
            Write-Host "📴 OFFLINE" -ForegroundColor Red
            $offlineComputers += $computer
            Write-Log "OFFLINE: $computer"
        }
    }
    
    Write-Host ""
    Write-Host "📊 Resultado do scan:" -ForegroundColor Cyan
    Write-Host "   ✅ Online: $($onlineComputers.Count)" -ForegroundColor Green
    Write-Host "   📴 Offline: $($offlineComputers.Count)" -ForegroundColor Red
    Write-Host ""
    
    return $onlineComputers
}

# FUNÇÃO PRINCIPAL
function Main {
    try {
        # CRIAR PASTA BASE
        Write-Host "📁 Preparando ambiente local..." -ForegroundColor Yellow
        Write-Log "Iniciando script DEPLOY-APPS"
        New-Item -Path $ProgramasDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
        Write-Host "   ✅ Pasta criada: $ProgramasDir" -ForegroundColor Green

        # SELECIONAR APLICATIVOS
        $selectedApps = Select-Applications
        
        # BAIXAR APLICATIVOS
        Write-Host ""
        $downloadResults = Download-Applications -SelectedApps $selectedApps
        
        # VERIFICAR SE HOUVE SUCESSO NOS DOWNLOADS
        $successfulDownloads = ($downloadResults.GetEnumerator() | Where-Object { $_.Value }).Count
        if ($successfulDownloads -eq 0) {
            Write-Host "❌ Nenhum aplicativo foi baixado com sucesso. Abortando." -ForegroundColor Red
            return
        }

        # CARREGAR MÁQUINAS
        Write-Host ""
        Write-Host "📋 Carregando lista de máquinas..." -ForegroundColor Yellow
        try {
            $allComputers = (Invoke-WebRequest "$GitHubBase/Config/maquinas.txt").Content -split "`n" | Where-Object { $_ -and $_.Trim() }
            Write-Host "   ✅ $($allComputers.Count) máquinas encontradas no arquivo" -ForegroundColor Green
            Write-Log "Lista de máquinas carregada: $($allComputers.Count) máquinas"
        } catch {
            Write-Host "   ❌ Erro ao carregar lista de máquinas: $($_.Exception.Message)" -ForegroundColor Red
            throw
        }

        # TESTAR CONEXÃO COM MÁQUINAS
        $onlineComputers = Test-MachinesConnection -Computers $allComputers
        
        if ($onlineComputers.Count -eq 0) {
            Write-Host "❌ Nenhuma máquina online encontrada. Abortando." -ForegroundColor Red
            return
        }

        # CONFIRMAR INÍCIO DA TRANSFERÊNCIA
        Write-Host ""
        Write-Host "🚀 PRONTO PARA INICIAR TRANSFERÊNCIA!" -ForegroundColor Cyan
        Write-Host "   📱 Aplicativos: $successfulDownloads selecionados" -ForegroundColor White
        Write-Host "   🌐 Máquinas: $($onlineComputers.Count) online" -ForegroundColor White
        Write-Host ""
        Write-Host "💡 Os aplicativos serão copiados para:" -ForegroundColor Yellow
        Write-Host "   📁 C:\Programas\ (pasta na máquina remota)" -ForegroundColor Gray
        Write-Host "   🖥️  Área de Trabalho (como 'Instalar[NomeApp].exe')" -ForegroundColor Gray
        Write-Host ""
        
        $confirm = Read-Host "Iniciar transferência? (S/N)"
        if ($confirm -notmatch '^[Ss]$') {
            Write-Host "Transferência cancelada pelo usuário" -ForegroundColor Yellow
            return
        }

        # INICIAR TRANSFERÊNCIA
        Write-Host ""
        Write-Host "🔧 INICIANDO TRANSFERÊNCIA REMOTA..." -ForegroundColor Cyan
        Write-Log "Iniciando transferência para $($onlineComputers.Count) máquinas online"
        
        $successCount = 0
        $errorCount = 0
        
        $i = 0
        foreach ($computer in $onlineComputers) {
            $i++
            Write-Host ""
            Write-Host "[$i/$($onlineComputers.Count)] ⚡ $computer" -ForegroundColor Yellow
            
            $transferResult = Transfer-AppsToRemote -ComputerName $computer -SelectedApps $selectedApps -DownloadResults $downloadResults
            
            if ($transferResult) {
                Write-Host "   ✅ TRANSFERÊNCIA CONCLUÍDA" -ForegroundColor Green
                $successCount++
            } else {
                Write-Host "   ❌ FALHA NA TRANSFERÊNCIA" -ForegroundColor Red
                $errorCount++
            }
        }

        # RESUMO FINAL
        Write-Host ""
        Write-Host "===============================================" -ForegroundColor Cyan
        Write-Host "           📊 RESUMO FINAL - DEPLOY-APPS" -ForegroundColor Cyan
        Write-Host "===============================================" -ForegroundColor Cyan
        
        Write-Host "📱 APLICATIVOS TRANSFERIDOS:" -ForegroundColor Yellow
        foreach ($appKey in $selectedApps) {
            if ($downloadResults[$appKey]) {
                $app = $AppCatalog[$appKey]
                Write-Host "   ✅ $($app.Name)" -ForegroundColor Green
            }
        }
        
        Write-Host ""
        Write-Host "🌐 TRANSFERÊNCIA REMOTA:" -ForegroundColor Yellow
        Write-Host "   ✅ Sucesso: $successCount" -ForegroundColor Green
        Write-Host "   ❌ Falhas: $errorCount" -ForegroundColor Red
        Write-Host "   📴 Offline: $($allComputers.Count - $onlineComputers.Count)" -ForegroundColor Gray
        Write-Host "   📊 Total de máquinas: $($allComputers.Count)" -ForegroundColor White

        Write-Host ""
        Write-Host "🎯 PRÓXIMOS PASSOS:" -ForegroundColor Cyan
        Write-Host "   1. Os instaladores estão na Área de Trabalho das máquinas" -ForegroundColor White
        Write-Host "   2. Usuários devem executar os arquivos 'Instalar[NomeApp].exe'" -ForegroundColor White
        Write-Host "   3. A instalação é silenciosa e automática" -ForegroundColor White
        Write-Host ""
        Write-Host "📄 Log detalhado: $LogFile" -ForegroundColor Gray

    } catch {
        Write-Host ""
        Write-Host "💥 ERRO CRÍTICO: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log "ERRO CRÍTICO: $($_.Exception.Message)"
    }
}

# EXECUTAR SCRIPT PRINCIPAL
Main

Write-Host ""
Write-Host "Pressione Enter para finalizar..." -ForegroundColor Yellow
Read-Host