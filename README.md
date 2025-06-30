# Gemini Shell Scripts - CLI & GUI para a IA do Google

![License](https://img.shields.io/badge/license-MIT-green.svg)
![Go](https://img.shields.io/badge/language-Go-blueviolet.svg)
![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow.svg)
![Build](https://img.shields.io/github/actions/workflow/status/marcelositr/gemini-shell/ci.yml?branch=main)
![Shellably](https://img.shields.io/badge/feito%20com-%F0%9F%A4%96%20x%20%F0%9F%92%BB-critical)

[![Último commit](https://img.shields.io/github/last-commit/marcelositr/gemini-shell)](https://github.com/marcelositr/gemini-shell/commits/main)
[![Releases](https://img.shields.io/github/v/release/marcelositr/gemini-shell?label=release)](https://github.com/marcelositr/gemini-shell/releases)
[![Issues](https://img.shields.io/github/issues/marcelositr/gemini-shell)](https://github.com/marcelositr/gemini-shell/issues)
[![Stars](https://img.shields.io/github/stars/marcelositr/gemini-shell?style=social)](https://github.com/marcelositr/gemini-shell/stargazers)
[![Wiki](https://img.shields.io/badge/Documentação-Wiki-blueviolet)](https://github.com/marcelositr/gemini-shell/wiki)


Uma coleção de scripts simples em Bash para interagir com a API do Google Gemini através de uma interface de linha de comando (`gemini.sh`) ou uma interface gráfica (`gemini-gui.sh`).

Converse com a IA do Google diretamente do seu terminal ou através de uma interface gráfica amigável e minimalista.

![Gemini Shell Banner](https://github.com/marcelositr/gemini-bash/blob/main/images/geminishell.png?raw=true)

## ✨ Funcionalidades Principais

*   **Duas Formas de Uso:** Uma CLI rápida para scripts e fluxos de trabalho no terminal, e uma GUI amigável para interação visual.
*   **Leve e Rápido:** Um único arquivo de script para cada versão, sem dependências complexas como Python ou SDKs.
*   **Fácil de Instalar:** Requer apenas ferramentas comuns como `curl`, `jq` e `zenity` (para a GUI).
*   **Customizável:** Altere facilmente o modelo de IA (`gemini-1.5-pro`, `gemini-1.5-flash`, etc.) ou as instruções de prompt dentro dos scripts.

## 🚀 Comece a Usar em 3 Passos

1.  **Obtenha sua Chave de API gratuita** no **[Google AI Studio](https://aistudio.google.com/app/apikey)**.

2.  **Clone o repositório** e dê permissão de execução aos scripts:
    ```bash
    git clone https://github.com/marcelositr/gemini-bash.git
    cd gemini-bash
    chmod +x gemini.sh gemini-gui.sh
    ```
    *(Lembre-se de usar a URL do seu repositório)*

3.  **Siga o guia de instalação na Wiki** para configurar sua chave de API e instalar as dependências.
    > ➡️ **[Guia Completo de Instalação e Configuração (Wiki)](https://github.com/marcelositr/gemini-bash/wiki)**

## 💡 Como Usar

### CLI (`gemini`)
```bash
./gemini.sh "crie um comando em python para iniciar um servidor web simples"
```

### GUI (`gemini-gui`)
```bash
./gemini-gui.sh
```

## 📚 Documentação Completa (Wiki)

Para guias aprofundados, exemplos, dicas de customização e solução de problemas, **visite nossa Wiki oficial**:

> ### ➡️ **[Acessar a Wiki do Projeto](https://github.com/marcelositr/gemini-bash/wiki)**

**Páginas populares na Wiki:**
*   [Usando a Ferramenta CLI](https://github.com/marcelositr/gemini-bash/wiki/Usando-a-Ferramenta-CLI)
*   [Usando a Ferramenta GUI](https://github.com/marcelositr/gemini-bash/wiki/Usando-a-Ferramenta-GUI)
*   [Customização e Uso Avançado](https://github.com/marcelositr/gemini-bash/wiki/Customizacao-e-Uso-Avancado)
*   [Solução de Problemas e FAQ](https://github.com/marcelositr/gemini-bash/wiki/Solucao-de-Problemas-e-FAQ)

## 📄 Licença

Este projeto está sob a licença MIT. Sinta-se à vontade para usar, modificar e distribuir.

---
Created by [@marcelositr](https://github.com/marcelositr)

