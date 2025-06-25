# Gemini CLI - Simples Interface de Linha de Comando para a IA do Google

Um script simples em Bash (`gemini.sh`) que permite interagir com a API do Google Gemini diretamente do seu terminal. Faça perguntas, peça códigos, gere textos e muito mais, de forma rápida e eficiente.

## ✨ Funcionalidades

- **Leve e Rápido:** Um único arquivo de script, sem necessidade de instalar pacotes Python ou SDKs complexos.
- **Dependências Mínimas:** Utiliza apenas `curl` e `jq`, ferramentas padrão em ambientes Linux e macOS.
- **Fácil de Usar:** Sintaxe direta: `gemini "Sua pergunta aqui"`.
- **Customizável:** Altere facilmente o modelo de IA (ex: `gemini-1.5-pro-latest`) ou as instruções de prompt dentro do script.
- **Feedback Visual:** Exibe uma mensagem de "pensando..." enquanto aguarda a resposta da API.
- **Engenharia de Prompt Embutida:** Por padrão, instrui a IA a fornecer respostas curtas e diretas, ideais para o terminal.

## 📋 Pré-requisitos

Antes de começar, você precisará de:

1.  **Chave de API do Google (API Key):**
    - Obtenha sua chave gratuita no **[Google AI Studio](https://aistudio.google.com/app/apikey)**.

  ### Como gerar sua chave de API no Google AI Studio

    1. Acesse o site do [Google AI Studio](https://aistudio.google.com/app/apikey).
    2. Faça login com sua conta Google.
    3. No painel, clique em **"Create API Key"** ou **"Criar chave de API"**.
    4. Dê um nome para a chave, por exemplo: `gemini-cli`.
    5. Copie o valor da chave gerada — ela será usada para autenticar suas requisições.
    6. Guarde essa chave com segurança e não a compartilhe publicamente.

    **Importante:** A chave é gratuita, mas tem limites diários de uso. Caso atinja o limite, aguarde até o reset que ocorre geralmente no próximo dia.

2.  **Ferramentas `curl` e `jq`:**
    - A maioria dos sistemas já possui `curl`. Para instalar `jq`:
      - **Debian/Ubuntu:**
        ```bash
        sudo apt update && sudo apt install -y jq
        ```
      - **Fedora/CentOS/RHEL:**
        ```bash
        sudo dnf install -y jq
        ```
      - **Arch/CachyOS/Manjaro:**
        ```bash
        sudo pacman -S jq
        ```
      - **macOS (com Homebrew):**
        ```bash
        brew install jq
        ```

## 🚀 Instalação e Configuração

Siga estes passos para deixar tudo funcionando.

1.  **Clone este repositório (ou apenas baixe o script `gemini.sh`):**
    ```bash
    # Exemplo: git clone https://github.com/SEU_USUARIO/SEU_REPOSITORIO.git
    # cd SEU_REPOSITORIO
    ```

2.  **Dê permissão de execução ao script:**
    ```bash
    chmod +x gemini.sh
    ```

3.  **Configure sua Chave de API:**
    Defina sua chave como uma variável de ambiente. **Substitua `SUA_CHAVE_API_AQUI` pela sua chave real.**
    ```bash
    export GEMINI_API_KEY="SUA_CHAVE_API_AQUI"
    ```
    **IMPORTANTE:** Para tornar essa configuração permanente, adicione a linha `export GEMINI_API_KEY="..."` ao final do seu arquivo de configuração de shell (como `~/.bashrc`, `~/.zshrc` ou `~/.profile`) e recarregue o terminal ou execute `source ~/.bashrc`.

4.  **(Opcional, mas Recomendado) Torne o comando global:**
    Para poder chamar o script de qualquer diretório apenas com `gemini` (em vez de `./gemini.sh`), mova-o para um local que esteja no seu `PATH`:
    ```bash
    sudo mv gemini.sh /usr/local/bin/gemini
    ```

## 💡 Como Usar

A sintaxe é muito simples. Se você tornou o comando global, use `gemini`. Caso contrário, use `./gemini.sh` dentro do diretório do projeto.

**Exemplo 1: Pergunta simples**
```bash
gemini "Qual a capital do Japão?"
```

**Exemplo 2: Pedido de código**
```bash
gemini "crie um comando em python para iniciar um servidor web simples na porta 8000"
```

**Exemplo 3: Criatividade**
```bash
gemini "sugira 3 nomes para um podcast sobre tecnologia e café"
```

## 🔧 Customização

Você pode facilmente customizar o script editando as variáveis no topo do arquivo `gemini.sh`:

-   `MODEL_NAME`: Altere o modelo de IA a ser usado. O padrão é `"gemini-1.5-flash-latest"`. Para mais poder de raciocínio, você pode tentar `"gemini-1.5-pro-latest"`.
-   `PROMPT_TEXT`: Modifique as instruções padrão para alterar o comportamento da IA (o "tom" da resposta, o formato, etc.).

## 📄 Licença

Este projeto está sob a licença MIT. Sinta-se à vontade para usar, modificar e distribuir.
