# FUNÇÃO PARA VERIFICAR CONEZÃO COM A INTERNET
function Test-InternetConnection {
    try {
        # Caso não tenha conexão com a internet, retorna um erro
        $null = Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# PRIMEIRA VERIFICAÇÃO DE INTERNET ANTES DE INICIAR O SCRIPT
    Write-Host "Conectado à internet!"

    # CONFIGURANDO A BARRA DE PROGRESSO

    # Função para enxugar a repetição de código para chamar a barra de progresso e atualia-la
    function Write-ProgressHelper {
        param (
            [int]$StepNumber,
            [string]$Message
        )
        $percent = ([int](($StepNumber/$steps)*100))
        $Message = "$percent% - $Message"
        # Cria uma barra de progresso com titulo, status que descreve oq está sendo feito e a porcetagem do progresso
        Write-Progress -Activity 'Configurações automáticas Geolan' -Status $Message -PercentComplete (($StepNumber / $steps) * 100)
    }

    # Busca nas próximas linhas todas as ocorrências de "Write-ProgressHelper" e faz uma contagem na variável $steps
    $script:steps = ([System.Management.Automation.PsParser]::Tokenize((gc "$PSScriptRoot\$($MyInvocation.MyCommand.Name)"), [ref]$null) | where { $_.Type -eq 'Command' -and $_.Content -eq 'Write-ProgressHelper' }).Count

    $stepCounter = 0

    Write-ProgressHelper -Message 'Ajustando regras para criação de restauração' -StepNumber ($stepCounter++)
    # Desabilitando o tempo padrão para criação de pontos de restauração
    Set-ItemProperty -Force -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "SystemRestorePointCreationFrequency" -Type DWord -Value 0

    Write-ProgressHelper -Message 'Habilitando a restauração do PC' -StepNumber ($stepCounter++)
    # Habilita a restauração de sistema para o driver C:
    Enable-ComputerRestore -Drive "C:\"
    Start-Sleep -Seconds 5

    Write-ProgressHelper -Message 'Separando 10% de espaço do disco C: para restauração' -StepNumber ($stepCounter++)
    # Dimensiona o espaço usado para restauração em 10%
    vssadmin resize shadowstorage /for=C: /on=C: /MaxSize=10%
    Start-Sleep -Seconds 5

    Write-ProgressHelper -Message 'Criando um ponto de restauração Pre-Geolan' -StepNumber ($stepCounter++)
    # Cria o poonto de restauração antes de instalar todos os programas e configurar
    Checkpoint-Computer -Description "Pre-Geolan" -RestorePointType "APPLICATION_INSTALL"
    Start-Sleep -Seconds 5


    Write-ProgressHelper -Message 'Preparando o Download...' -StepNumber ($stepCounter++)
    # Função para enxugar a repetição de download
    function Download {
        param (
            [string]$url,
            [string]$dst
        )
        Invoke-WebRequest -URI $url -OutFile $dst
        Start-Sleep -Seconds 5
    }
    Start-Sleep -Seconds 5

    Write-ProgressHelper -Message 'Baixando o Google Chrome' -StepNumber ($stepCounter++)
    # INSTALANDO TODOS OS SOFTWARES BÁSICOS
    # Baixando o Google Chrome
    Download "https://dl.google.com/chrome/install/latest/chrome_installer.exe" "$Home\Downloads\ChromeSetup.exe"

    Write-ProgressHelper -Message 'Instalando o Google Chrome' -StepNumber ($stepCounter++)
    # Instalando o Google Chrome
    Invoke-Expression "$HOME\Downloads\ChromeSetup.exe /silent /install"


    Write-ProgressHelper -Message 'Baixando o Firefox' -StepNumber ($stepCounter++)
    # Baixando o Firefox
    Download "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=pt-BR" "$Home\Downloads\Firefox Installer.exe"

    Write-ProgressHelper -Message 'Instalando o Firefox' -StepNumber ($stepCounter++)
    # Instalando Firefox
    Invoke-Expression "& '$Home\Downloads\Firefox Installer.exe' /s"


    Write-ProgressHelper -Message 'Baixando o Winrar' -StepNumber ($stepCounter++)
    # Baixando o Winrar
    Download "https://www.rarlab.com/rar/winrar-x64-620br.exe" "$Home\Downloads\winrar-x64-620br.exe"

    Write-ProgressHelper -Message 'Instalando o Winrar' -StepNumber ($stepCounter++)
    # Instalando Winrar
    Invoke-Expression "$Home\Downloads\winrar-x64-620br.exe /s"


    Write-ProgressHelper -Message 'Baixando o AdobeReader' -StepNumber ($stepCounter++)
    # Baixando o AdobeReader
    Download "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2300320269/AcroRdrDC2300320269_pt_BR.exe" "$Home\Downloads\AcroRdrDC2300320269_pt_BR.exe"

    Write-ProgressHelper -Message 'Instalando o AdobeReader' -StepNumber ($stepCounter++)
    # Instalando AdobeReader
    Invoke-Expression "$Home\Downloads\AcroRdrDC2300320269_pt_BR.exe /sAll /rs /msi EULA_ACCEPT=YES"


    Write-ProgressHelper -Message 'Baixando o Java' -StepNumber ($stepCounter++)
    # Baixando o Java
    Download "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=244054_89d678f2be164786b292527658ca1605" "$Home\Downloads\jre-8u381-windows-x64.exe"

    Write-ProgressHelper -Message 'Instalando o Java' -StepNumber ($stepCounter++)
    # Instalando Java
    Invoke-Expression "$Home\Downloads\jre-8u381-windows-x64.exe /s"



    # PERSONALIZANDO O WINDOWS

    # DESATIVANDO NOTIFICAÇÕES INUTEIS

    Write-ProgressHelper -Message 'Desabilitando notificações inúteis' -StepNumber ($stepCounter++)
    # Adiciona/altera a chave de registro para desativar a opção "Mostrar notificações na tela de bloqueio"
    Set-ItemProperty -Force -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" -Type DWord -Value 0

    Write-ProgressHelper -Message 'Desabilitando notificações inúteis' -StepNumber ($stepCounter++)
    # Adiciona/altera a chave de registro para desativar a opção "Mostrar lembretes e chamadas VoIP na tela de bloqueio"
    Set-ItemProperty -Force -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK" -Type DWord -Value 0

    Write-ProgressHelper -Message 'Desabilitando notificações inúteis' -StepNumber ($stepCounter++)
    # Adiciona/altera a chave de registro para desativar a opção "Mostrar a experiência de boas-vindas do Windows após atualizações e ocasionalmente ao fazer logon para realçar novidades e sugestões"
    Set-ItemProperty -Force -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Type DWord -Value 0

    Write-ProgressHelper -Message 'Desabilitando notificações inúteis' -StepNumber ($stepCounter++)
    # Adiciona uma chave de registro para desativar a opção "Sugerir como posso concluir a configuração do dispositivo para aproveitar ao máximo o windows"
    New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "UserProfileEngagement"
    Set-ItemProperty -Force -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Type DWord -Value 0

    Write-ProgressHelper -Message 'Desabilitando notificações inúteis' -StepNumber ($stepCounter++)
    # Adiciona/altera a chave de registro para desativar a opção "Obter dicas, truques e sugestões de como usar o Windows"
    Set-ItemProperty -Force -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0


    # OTIMIZANDO APARÊNCIA DO WINDOWS

    Write-ProgressHelper -Message 'Otimizando aparência do Windows' -StepNumber ($stepCounter++)
    # Desativa 8 opções e são as seguintes: "Abrir caixas de combinação", "Animar controles e elementos no Windows", "Esmaecer itens de menu após clicados", "Esmaecer ou deslizar Dicas de ferramenta para exibição", "Esmaecer ou deslizar menus para a exibição", "Mostrar sombras sob janelas", "Mostrar sombras sob ponteiro do mouse" e "Rolar caixas de listagem suavemente"
    Set-ItemProperty -Force -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary ([byte[]]@(0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))

    Write-ProgressHelper -Message 'Otimizando aparência do Windows' -StepNumber ($stepCounter++)
    # Desativa "Animações na barra de tarefas"
    Set-ItemProperty -Force -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value 0

    Write-ProgressHelper -Message 'Otimizando aparência do Windows' -StepNumber ($stepCounter++)
    # Desativa "Animar janelas ao minimizar e maximizar"
    Set-ItemProperty -Force -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type DWord -Value 0

    Write-ProgressHelper -Message 'Otimizando aparência do Windows' -StepNumber ($stepCounter++)
    # Desativa o Aero Peek
    Set-ItemProperty -Force -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name EnableAeroPeek -Value 0

    Write-ProgressHelper -Message 'Otimizando aparência do Windows' -StepNumber ($stepCounter++)
    # Desativa "Mostrar retângulo de seleção translúcido"
    Set-ItemProperty -Force -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ListviewAlphaSelect -Value 0

    Write-ProgressHelper -Message 'Otimizando aparência do Windows' -StepNumber ($stepCounter++)
    # Desativa "Usar sombras subjacentes para rótulos de ícones na área de trabalho"
    Set-ItemProperty -Force -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ListviewShadow -Value 0

    Write-ProgressHelper -Message 'Otimizando aparência do Windows' -StepNumber ($stepCounter++)
    # Ativa "Mostrar contéudo da janela ao arrastar"
    Set-ItemProperty -Force -Path "HKCU:\Control Panel\Desktop" -Name DragFullWindows -Type String -Value 1

    Write-ProgressHelper -Message 'Otimizando aparência do Windows' -StepNumber ($stepCounter++)
    # Ativa "Mostrar miniaturas ao invés de ícones"
    Set-ItemProperty -Force -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Type DWord -Value 0

    Write-ProgressHelper -Message 'Otimizando aparência do Windows' -StepNumber ($stepCounter++)
    # Ativa "Salvar visualizações de miniaturas da barra de tarefas"
    Set-ItemProperty -Force -Path "HKCU:\SOFTWARE\Microsoft\Windows\DWM" -Name "AlwaysHibernateThumbnails" -Type DWord -Value 1

    Write-ProgressHelper -Message 'Otimizando aparência do Windows' -StepNumber ($stepCounter++)
    # Ativa "Usar fontes de tela com cantos arredondados"
    Set-ItemProperty -Force -Path "HKCU:\Control Panel\Desktop" -Name FontSmoothing -Type String -Value 2

    Write-ProgressHelper -Message 'Otimizando aparência do Windows' -StepNumber ($stepCounter++)
    # Desativa "Permitir conexões de Assistência Remota para este computador"
    Set-ItemProperty -Force -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0

    Write-ProgressHelper -Message 'Otimizando aparência do Windows' -StepNumber ($stepCounter++)
    # Desabilita Otmização de Entrega
    Set-ItemProperty -Force -Path "Registry::HKEY_USERS\S-1-5-20\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings" -Name "DownloadMode" -Type DWord -Value 0

    # CONFIGURAR PERSONALIZAÇÃO

    Write-ProgressHelper -Message 'Personalizando o Windows' -StepNumber ($stepCounter++)
    # Esconder botão da Cortana na barra de tarefas
    Set-ItemProperty -Force -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCortanaButton" -Type DWord -Value 0

    Write-ProgressHelper -Message 'Personalizando o Windows' -StepNumber ($stepCounter++)
    # Esconder botão de Visão de Tarefas na barra de tarefas
    Set-ItemProperty -Force -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0

    Write-ProgressHelper -Message 'Personalizando o Windows' -StepNumber ($stepCounter++)
    # Deixa apenas o ícone pesquisar na barra de tarefas
    Set-ItemProperty -Force -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 1

    Write-ProgressHelper -Message 'Personalizando o Windows' -StepNumber ($stepCounter++)
    # Deixa icone e texto em noticias e interesses
    Set-ItemProperty -Force -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Type DWord -Value 0

    Write-ProgressHelper -Message 'Personalizando o Windows' -StepNumber ($stepCounter++)
    # Desabilita "Abrir em focalizar" do "Noticias e interesses"
    Set-ItemProperty -Force -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarOpenOnHover" -Type DWord -Value 0

    Write-ProgressHelper -Message 'Personalizando o Windows' -StepNumber ($stepCounter++)
    # Organiza os aplicativos fixados na barra de tarefas
    # Cria o atalho do Google Chrome
    $ws = New-Object -ComObject WScript.Shell;
    $s = $ws.CreateShortcut("$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Google Chrome.lnk");
    $s.TargetPath = "C:\Program Files\Google\Chrome\Application\chrome.exe";
    $s.Save();

    Write-ProgressHelper -Message 'Personalizando o Windows' -StepNumber ($stepCounter++)
    # Cria o atalho do Firefox
    $ws = New-Object -ComObject WScript.Shell;
    $s = $ws.CreateShortcut("$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Firefox.lnk");
    $s.TargetPath = "C:\Program Files\Mozilla Firefox\firefox.exe";
    $s.Save();

    Write-ProgressHelper -Message 'Personalizando o Windows' -StepNumber ($stepCounter++)
    # Cria o atalho do Microsoft Edge
    $ws = New-Object -ComObject WScript.Shell;
    $s = $ws.CreateShortcut("$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Microsoft Edge.lnk");
    $s.TargetPath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe";
    $s.Save();

    Write-ProgressHelper -Message 'Personalizando o Windows' -StepNumber ($stepCounter++)
    # Cria o atalho do Microsoft Edge
    $ws = New-Object -ComObject WScript.Shell;
    $s = $ws.CreateShortcut("$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Explorador de Arquivos.lnk");
    $s.TargetPath = "C:\windows\explorer.exe";
    $s.Save();

    Write-ProgressHelper -Message 'Personalizando o Windows' -StepNumber ($stepCounter++)
    # Alterando registro para criar os atalhos na barra de tarefas
    Set-ItemProperty -Force -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Name "Favorites" -Type Binary -Value ([byte[]]@(0x00,0x50,0x01,0x00,0x00,0x3a,0x00,0x1f,0x80,0xc8,0x27,0x34,0x1f,0x10,0x5c,0x10,0x42,0xaa,0x03,0x2e,0xe4,0x52,0x87,0xd6,0x68,0x26,0x00,0x01,0x00,0x26,0x00,0xef,0xbe,0x12,0x00,0x00,0x00,0x2a,0xf3,0x36,0x51,0xa8,0x13,0xd9,0x01,0x2d,0x34,0xfa,0x80,0xa8,0x13,0xd9,0x01,0x4c,0x42,0xd1,0x5d,0x28,0xe0,0xd9,0x01,0x14,0x00,0x56,0x00,0x31,0x00,0x00,0x00,0x00,0x00,0x25,0x57,0xd6,0x94,0x11,0x00,0x54,0x61,0x73,0x6b,0x42,0x61,0x72,0x00,0x40,0x00,0x09,0x00,0x04,0x00,0xef,0xbe,0x93,0x55,0x56,0x66,0x25,0x57,0xd7,0x94,0x2e,0x00,0x00,0x00,0x72,0xa2,0x01,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x11,0xd7,0x70,0x00,0x54,0x00,0x61,0x00,0x73,0x00,0x6b,0x00,0x42,0x00,0x61,0x00,0x72,0x00,0x00,0x00,0x16,0x00,0xbe,0x00,0x32,0x00,0x0d,0x09,0x00,0x00,0x24,0x57,0xf1,0x8a,0x20,0x00,0x47,0x4f,0x4f,0x47,0x4c,0x45,0x7e,0x31,0x2e,0x4c,0x4e,0x4b,0x00,0x00,0x54,0x00,0x09,0x00,0x04,0x00,0xef,0xbe,0x25,0x57,0xfd,0x94,0x25,0x57,0xfd,0x94,0x2e,0x00,0x00,0x00,0xc1,0xa4,0x01,0x00,0x00,0x00,0x17,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xe3,0xd4,0x79,0x00,0x47,0x00,0x6f,0x00,0x6f,0x00,0x67,0x00,0x6c,0x00,0x65,0x00,0x20,0x00,0x43,0x00,0x68,0x00,0x72,0x00,0x6f,0x00,0x6d,0x00,0x65,0x00,0x2e,0x00,0x6c,0x00,0x6e,0x00,0x6b,0x00,0x00,0x00,0x1c,0x00,0x12,0x00,0x00,0x00,0x2b,0x00,0xef,0xbe,0x8e,0x53,0xd2,0x5d,0x28,0xe0,0xd9,0x01,0x1c,0x00,0x1a,0x00,0x00,0x00,0x1d,0x00,0xef,0xbe,0x02,0x00,0x43,0x00,0x68,0x00,0x72,0x00,0x6f,0x00,0x6d,0x00,0x65,0x00,0x00,0x00,0x1c,0x00,0x22,0x00,0x00,0x00,0x1e,0x00,0xef,0xbe,0x02,0x00,0x55,0x00,0x73,0x00,0x65,0x00,0x72,0x00,0x50,0x00,0x69,0x00,0x6e,0x00,0x6e,0x00,0x65,0x00,0x64,0x00,0x00,0x00,0x1c,0x00,0x00,0x00,0x00,0x56,0x01,0x00,0x00,0x3a,0x00,0x1f,0x80,0xc8,0x27,0x34,0x1f,0x10,0x5c,0x10,0x42,0xaa,0x03,0x2e,0xe4,0x52,0x87,0xd6,0x68,0x26,0x00,0x01,0x00,0x26,0x00,0xef,0xbe,0x12,0x00,0x00,0x00,0x2a,0xf3,0x36,0x51,0xa8,0x13,0xd9,0x01,0x2d,0x34,0xfa,0x80,0xa8,0x13,0xd9,0x01,0x68,0x6d,0x84,0x64,0x28,0xe0,0xd9,0x01,0x14,0x00,0x56,0x00,0x31,0x00,0x00,0x00,0x00,0x00,0x25,0x57,0xfd,0x94,0x11,0x00,0x54,0x61,0x73,0x6b,0x42,0x61,0x72,0x00,0x40,0x00,0x09,0x00,0x04,0x00,0xef,0xbe,0x93,0x55,0x56,0x66,0x25,0x57,0xfd,0x94,0x2e,0x00,0x00,0x00,0x72,0xa2,0x01,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x81,0xcf,0x1d,0x01,0x54,0x00,0x61,0x00,0x73,0x00,0x6b,0x00,0x42,0x00,0x61,0x00,0x72,0x00,0x00,0x00,0x16,0x00,0xc4,0x00,0x32,0x00,0xed,0x03,0x00,0x00,0x1f,0x57,0x65,0x96,0x20,0x00,0x46,0x69,0x72,0x65,0x66,0x6f,0x78,0x2e,0x6c,0x6e,0x6b,0x00,0x48,0x00,0x09,0x00,0x04,0x00,0xef,0xbe,0x25,0x57,0x04,0x95,0x25,0x57,0x04,0x95,0x2e,0x00,0x00,0x00,0x6d,0xa4,0x00,0x00,0x00,0x00,0x1e,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0c,0x30,0x55,0x00,0x46,0x00,0x69,0x00,0x72,0x00,0x65,0x00,0x66,0x00,0x6f,0x00,0x78,0x00,0x2e,0x00,0x6c,0x00,0x6e,0x00,0x6b,0x00,0x00,0x00,0x1a,0x00,0x12,0x00,0x00,0x00,0x2b,0x00,0xef,0xbe,0xeb,0xcf,0x86,0x64,0x28,0xe0,0xd9,0x01,0x1a,0x00,0x2e,0x00,0x00,0x00,0x1d,0x00,0xef,0xbe,0x02,0x00,0x33,0x00,0x30,0x00,0x38,0x00,0x30,0x00,0x34,0x00,0x36,0x00,0x42,0x00,0x30,0x00,0x41,0x00,0x46,0x00,0x34,0x00,0x41,0x00,0x33,0x00,0x39,0x00,0x43,0x00,0x42,0x00,0x00,0x00,0x1a,0x00,0x22,0x00,0x00,0x00,0x1e,0x00,0xef,0xbe,0x02,0x00,0x55,0x00,0x73,0x00,0x65,0x00,0x72,0x00,0x50,0x00,0x69,0x00,0x6e,0x00,0x6e,0x00,0x65,0x00,0x64,0x00,0x00,0x00,0x1a,0x00,0x00,0x00,0x00,0x52,0x01,0x00,0x00,0x3a,0x00,0x1f,0x80,0xc8,0x27,0x34,0x1f,0x10,0x5c,0x10,0x42,0xaa,0x03,0x2e,0xe4,0x52,0x87,0xd6,0x68,0x26,0x00,0x01,0x00,0x26,0x00,0xef,0xbe,0x12,0x00,0x00,0x00,0x2a,0xf3,0x36,0x51,0xa8,0x13,0xd9,0x01,0x2d,0x34,0xfa,0x80,0xa8,0x13,0xd9,0x01,0x25,0xd0,0x58,0x6b,0x28,0xe0,0xd9,0x01,0x14,0x00,0x56,0x00,0x31,0x00,0x00,0x00,0x00,0x00,0x25,0x57,0x07,0x95,0x11,0x00,0x54,0x61,0x73,0x6b,0x42,0x61,0x72,0x00,0x40,0x00,0x09,0x00,0x04,0x00,0xef,0xbe,0x93,0x55,0x56,0x66,0x25,0x57,0x07,0x95,0x2e,0x00,0x00,0x00,0x72,0xa2,0x01,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x25,0x52,0xd3,0x00,0x54,0x00,0x61,0x00,0x73,0x00,0x6b,0x00,0x42,0x00,0x61,0x00,0x72,0x00,0x00,0x00,0x16,0x00,0xc0,0x00,0x32,0x00,0x86,0x09,0x00,0x00,0x24,0x57,0x06,0x85,0x20,0x00,0x4d,0x49,0x43,0x52,0x4f,0x53,0x7e,0x31,0x2e,0x4c,0x4e,0x4b,0x00,0x00,0x56,0x00,0x09,0x00,0x04,0x00,0xef,0xbe,0x25,0x57,0x0a,0x95,0x25,0x57,0x0a,0x95,0x2e,0x00,0x00,0x00,0x92,0xd0,0x03,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x2b,0x31,0x4c,0x00,0x4d,0x00,0x69,0x00,0x63,0x00,0x72,0x00,0x6f,0x00,0x73,0x00,0x6f,0x00,0x66,0x00,0x74,0x00,0x20,0x00,0x45,0x00,0x64,0x00,0x67,0x00,0x65,0x00,0x2e,0x00,0x6c,0x00,0x6e,0x00,0x6b,0x00,0x00,0x00,0x1c,0x00,0x12,0x00,0x00,0x00,0x2b,0x00,0xef,0xbe,0x9d,0xa4,0x5a,0x6b,0x28,0xe0,0xd9,0x01,0x1c,0x00,0x1a,0x00,0x00,0x00,0x1d,0x00,0xef,0xbe,0x02,0x00,0x4d,0x00,0x53,0x00,0x45,0x00,0x64,0x00,0x67,0x00,0x65,0x00,0x00,0x00,0x1c,0x00,0x22,0x00,0x00,0x00,0x1e,0x00,0xef,0xbe,0x02,0x00,0x55,0x00,0x73,0x00,0x65,0x00,0x72,0x00,0x50,0x00,0x69,0x00,0x6e,0x00,0x6e,0x00,0x65,0x00,0x64,0x00,0x00,0x00,0x1c,0x00,0x00,0x00,0x00,0xa8,0x01,0x00,0x00,0x3a,0x00,0x1f,0x80,0xc8,0x27,0x34,0x1f,0x10,0x5c,0x10,0x42,0xaa,0x03,0x2e,0xe4,0x52,0x87,0xd6,0x68,0x26,0x00,0x01,0x00,0x26,0x00,0xef,0xbe,0x12,0x00,0x00,0x00,0x2a,0xf3,0x36,0x51,0xa8,0x13,0xd9,0x01,0x2d,0x34,0xfa,0x80,0xa8,0x13,0xd9,0x01,0x5c,0xae,0xe6,0xb7,0x56,0xea,0xd9,0x01,0x14,0x00,0x56,0x00,0x31,0x00,0x00,0x00,0x00,0x00,0x32,0x57,0x9c,0x8c,0x11,0x00,0x54,0x61,0x73,0x6b,0x42,0x61,0x72,0x00,0x40,0x00,0x09,0x00,0x04,0x00,0xef,0xbe,0x93,0x55,0x56,0x66,0x32,0x57,0x9c,0x8c,0x2e,0x00,0x00,0x00,0x72,0xa2,0x01,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xa4,0xfd,0x24,0x00,0x54,0x00,0x61,0x00,0x73,0x00,0x6b,0x00,0x42,0x00,0x61,0x00,0x72,0x00,0x00,0x00,0x16,0x00,0x16,0x01,0x32,0x00,0x97,0x01,0x00,0x00,0x87,0x4f,0x07,0x49,0x20,0x00,0x46,0x49,0x4c,0x45,0x45,0x58,0x7e,0x32,0x2e,0x4c,0x4e,0x4b,0x00,0x00,0x84,0x00,0x09,0x00,0x04,0x00,0xef,0xbe,0x32,0x57,0x9c,0x8c,0x32,0x57,0x9c,0x8c,0x2e,0x00,0x00,0x00,0x24,0xdd,0x03,0x00,0x00,0x00,0x0e,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x5a,0x00,0x00,0x00,0x00,0x00,0x58,0x9c,0x44,0x00,0x46,0x00,0x69,0x00,0x6c,0x00,0x65,0x00,0x20,0x00,0x45,0x00,0x78,0x00,0x70,0x00,0x6c,0x00,0x6f,0x00,0x72,0x00,0x65,0x00,0x72,0x00,0x20,0x00,0x28,0x00,0x32,0x00,0x29,0x00,0x2e,0x00,0x6c,0x00,0x6e,0x00,0x6b,0x00,0x00,0x00,0x40,0x00,0x73,0x00,0x68,0x00,0x65,0x00,0x6c,0x00,0x6c,0x00,0x33,0x00,0x32,0x00,0x2e,0x00,0x64,0x00,0x6c,0x00,0x6c,0x00,0x2c,0x00,0x2d,0x00,0x32,0x00,0x32,0x00,0x30,0x00,0x36,0x00,0x37,0x00,0x00,0x00,0x1c,0x00,0x12,0x00,0x00,0x00,0x2b,0x00,0xef,0xbe,0x5c,0xd5,0xed,0xb7,0x56,0xea,0xd9,0x01,0x1c,0x00,0x42,0x00,0x00,0x00,0x1d,0x00,0xef,0xbe,0x02,0x00,0x4d,0x00,0x69,0x00,0x63,0x00,0x72,0x00,0x6f,0x00,0x73,0x00,0x6f,0x00,0x66,0x00,0x74,0x00,0x2e,0x00,0x57,0x00,0x69,0x00,0x6e,0x00,0x64,0x00,0x6f,0x00,0x77,0x00,0x73,0x00,0x2e,0x00,0x45,0x00,0x78,0x00,0x70,0x00,0x6c,0x00,0x6f,0x00,0x72,0x00,0x65,0x00,0x72,0x00,0x00,0x00,0x1c,0x00,0x22,0x00,0x00,0x00,0x1e,0x00,0xef,0xbe,0x02,0x00,0x55,0x00,0x73,0x00,0x65,0x00,0x72,0x00,0x50,0x00,0x69,0x00,0x6e,0x00,0x6e,0x00,0x65,0x00,0x64,0x00,0x00,0x00,0x1c,0x00,0x00,0x00,0xff))

    Write-ProgressHelper -Message 'Criando um ponto de restauração Geolan' -StepNumber ($stepCounter++)
    # Cria o ponto de restauração após instalar todos os programas
    Checkpoint-Computer -Description "Geolan" -RestorePointType "MODIFY_SETTINGS"

    Write-ProgressHelper -Message 'Ajustando regras para criação de restauração' -StepNumber ($stepCounter++)
    # Remove a chave de registro que diminuia o tempo para criação de novos pontos de restauração
    Remove-ItemProperty -Force -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "SystemRestorePointCreationFrequency"

    pause