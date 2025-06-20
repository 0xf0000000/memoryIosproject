# MemoryIos

Aplicativo iOS com interface gráfica que permite inspecionar, buscar e modificar a memória de processos em execução.

## Funcionalidades

* Listagem de processos com PID
* Busca de padrões de memória (hexadecimal, string, número, fuzzy)
* Escrita de novos valores na memória
* Visualização de memória com formato hexadecimal e ASCII
* Editor de memória flutuante (janela sobreposta)
* Relatório de crashes persistente
* Modo de fundo colorido com arco-íris animado

## Telas

* **Processes**: visualização e seleção de processos
* **Memory**: busca, visualização e modificação de memória
* **Settings**: ajustes visuais (modo arco-íris)
* **Crash Report**: exibição de relatórios de falha

## Componentes principais

* `MemoryEditor.swift`: lógica de leitura, escrita e busca em memória via funções nativas (`task_for_pid`, `mach_vm_read`, `mach_vm_write`, `vm_region_64`)
* `MemoryEditorView.swift`: interface gráfica para busca e edição de memória
* `FloatingWindow.swift`: janela flutuante arrastável com conteúdo customizável
* `CrashReportView.swift`: exibição e limpeza de relatórios de crash
* `ProcessInfo.swift`: modelo de processo com PID e nome
* `MemoryView.swift`: busca rápida com entrada de PID e atalho para processos conhecidos
* `ContentView.swift`: interface principal com abas e efeitos visuais
* `AppDelegate.swift`: configuração de handler de exceções para relatórios de crash
* `My App.swift`: configuração da aplicação e gestos globais

## Requisitos

* iOS com suporte a SwiftUI
* Permissões adequadas para leitura de memória de outros processos (jailbreak ou permissões especiais)

## Inicialização

A aplicação é iniciada em `MemoryHackerApp` (annotado com `@main`) e exibe a `ContentView`, contendo abas para as principais funcionalidades.

## Esquema de URL

* Suporte para abrir a janela flutuante diretamente via URL com esquema:
  `memoryeditor://<PID>`

## Observações

Este projeto pode requerer permissões especiais ou execução em dispositivos com jailbreak para funcionar corretamente, devido às limitações do sandbox da Apple em acesso à memória de outros processos.
