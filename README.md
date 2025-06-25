# Gemini Shell Scripts - CLI & GUI para a IA do Google

Uma coleção de scripts simples em Bash que permite interagir com a API do Google Gemini de duas formas:
1.  **`gemini.sh`**: Uma interface de linha de comando (CLI) rápida e eficiente.
2.  **`gemini-gui.sh`**: Uma interface gráfica (GUI) minimalista e amigável, baseada em Zenity.

Faça perguntas, peça códigos, gere textos e muito mais, seja diretamente do seu terminal ou através de uma janela gráfica simples.

## ✨ Funcionalidades

### CLI (`gemini.sh`)
- **Leve e Rápido:** Um único arquivo de script, sem necessidade de instalar pacotes Python ou SDKs complexos.
- **Dependências Mínimas:** Utiliza apenas `curl` e `jq`.
- **Fácil de Usar:** Sintaxe direta: `gemini "Sua pergunta aqui"`.
- **Feedback Visual:** Exibe uma mensagem de "pensando..." enquanto aguarda a resposta da API.

### GUI (`gemini-gui.sh`)
- **Interface Gráfica Minimalista:** Usa `Zenity` para criar uma experiência de "perguntar e responder" com apenas duas janelas.
- **Interação Contínua:** Após cada resposta, permite fazer uma "Nova Pergunta" ou "Sair", criando um fluxo de conversa.
- **Independente do Terminal:** Uma vez iniciado, toda a interação ocorre através das janelas gráficas.
- **Dependências Comuns:** Requer `curl`, `jq` e `zenity`, ferramentas padrão em muitos ambientes de desktop Linux.

### Ambos os Scripts
- **Customizável:** Altere facilmente o modelo de IA (ex: `gemini-1.5-pro-latest`) ou as instruções de prompt dentro de cada script.
- **Engenharia de Prompt Embutida:** Por padrão, instrui a IA a fornecer respostas curtas e diretas, ideais para o contexto de uso.

## 📋 Pré-requisitos

Antes de começar, você precisará de:

### 1. Chave de API do Google (API Key)
- Obtenha sua chave gratuita no **[Google AI Studio](https://aistudio.google.com/app/apikey)**.

**Como gerar sua chave de API no Google AI Studio**
- Acesse o site do [Google AI Studio](https://aistudio.google.com/app/apikey).
- Faça login com sua conta Google.
- No painel, clique em **"Create API Key"** ou **"Criar chave de API"**.
- Dê um nome para a chave, por exemplo: `gemini-scripts`.
- Copie o valor da chave gerada — ela será usada para autenticar suas requisições.
- Guarde essa chave com segurança e não a compartilhe publicamente.

**Importante:** A chave é gratuita, mas tem limites diários de uso. Caso atinja o limite, aguarde até o reset, que geralmente ocorre no próximo dia.

### 2. Ferramentas de Linha de Comando

As dependências variam ligeiramente entre o script CLI e o GUI.

#### Dependências para o CLI (`gemini.sh`):
Você precisará do `curl` e `jq`.

- **Debian/Ubuntu/Mint:**
  ```bash
  sudo apt update && sudo apt install -y curl jq
  ```
- **Fedora/CentOS/RHEL:**
  ```bash
  sudo dnf install -y curl jq
  ```
- **Arch/CachyOS/Manjaro:**
  ```bash
  sudo pacman -S --noconfirm curl jq
  ```
- **macOS (com Homebrew):**
  ```bash
  brew install curl jq
  ```

#### Dependências para o GUI (`gemini-gui.sh`):
Você precisará de **todas as dependências do CLI** e mais o `zenity`.

- **Debian/Ubuntu/Mint:**
  ```bash
  sudo apt update && sudo apt install -y curl jq zenity
  ```
- **Fedora/CentOS/RHEL:**
  ```bash
  sudo dnf install -y curl jq zenity
  ```
- **Arch/CachyOS/Manjaro:**
  ```bash
  sudo pacman -S --noconfirm curl jq zenity
  ```

## 🚀 Instalação e Configuração

Siga estes passos para deixar tudo funcionando.

1.  **Clone este repositório (ou apenas baixe os scripts `gemini.sh` e `gemini-gui.sh`):**
    ```bash
    # Exemplo: git clone https://github.com/SEU_USUARIO/SEU_REPOSITORIO.git
    # cd SEU_REPOSITORIO
    ```

2.  **Dê permissão de execução aos scripts:**
    ```bash
    chmod +x gemini.sh gemini-gui.sh
    ```

3.  **Configure sua Chave de API:**
    Defina sua chave como uma variável de ambiente. **Substitua `SUA_CHAVE_API_AQUI` pela sua chave real.**
    ```bash
    export GEMINI_API_KEY="SUA_CHAVE_API_AQUI"
    ```
    **IMPORTANTE:** Para tornar essa configuração permanente, adicione a linha `export GEMINI_API_KEY="..."` ao final do seu arquivo de configuração de shell (como `~/.bashrc`, `~/.zshrc` ou `~/.profile`) e recarregue o terminal ou execute `source ~/.bashrc`.

4.  **(Opcional, mas Recomendado) Torne os comandos globais:**
    Para poder chamar os scripts de qualquer diretório, mova-os para um local que esteja no seu `PATH`. É uma boa prática renomeá-los para remover a extensão `.sh`.
    ```bash
    sudo mv gemini.sh /usr/local/bin/gemini
    sudo mv gemini-gui.sh /usr/local/bin/gemini-gui
    ```

## 💡 Como Usar

### Usando a CLI (`gemini`)
A sintaxe é muito simples. Passe sua pergunta como um argumento entre aspas.

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

### Usando a GUI (`gemini-gui`)
Execute o comando sem argumentos para iniciar a interface gráfica.

```bash
gemini-gui
```
- Uma janela aparecerá para você digitar sua pergunta.
- Após enviar, uma barra de progresso será exibida.
- Por fim, a resposta aparecerá em uma nova janela com dois botões:
    - **"Nova Pergunta"**: Permite que você inicie o ciclo novamente.
    - **"Sair"**: Encerra a aplicação.

## 🔧 Customização

Você pode facilmente customizar os scripts editando as variáveis no topo dos arquivos `gemini.sh` e `gemini-gui.sh`:

-   `MODEL_NAME`: Altere o modelo de IA a ser usado. O padrão é `"gemini-1.5-flash-latest"`. Para mais poder de raciocínio, você pode tentar `"gemini-1.5-pro-latest"`.
-   `PROMPT_TEXT`: Modifique as instruções padrão para alterar o comportamento da IA (o "tom" da resposta, o formato, etc.).

## 📄 Licença

Este projeto está sob a licença MIT. Sinta-se à vontade para usar, modificar e distribuir.
