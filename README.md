# Deploy da proposta TODA no EasyPanel

Pacote pronto para publicar a proposta comercial em domínio próprio.

## Arquivos

| Arquivo | Função |
|---|---|
| `index.html` | A proposta completa, autocontida (CSS e JS embutidos, sem dependência externa) |
| `Dockerfile` | Imagem nginx alpine servindo o HTML |
| `nginx.conf` | Compressão, cabeçalhos de segurança e cache controlado |
| `robots.txt` | Bloqueia indexação por buscadores |
| `.dockerignore` | Mantém a imagem enxuta |

O `index.html` não depende de rede: fontes são do sistema, o favicon é SVG embutido
e não há nenhuma requisição a CDN. Funciona offline e não vaza acesso para terceiros.

---

## Passo 1 — Enviar os arquivos

**Opção A — GitHub (recomendada, permite atualizar com um clique)**

```bash
cd C:/Users/lucas/Documents/github/saas-arquitetura/deploy
git init
git add .
git commit -m "Proposta TODA para Todaka"
git branch -M main
git remote add origin https://github.com/SEU-USUARIO/proposta-toda.git
git push -u origin main
```

**Opção B — Upload direto**

No EasyPanel, ao criar o serviço, escolha a origem **Upload** e envie esta pasta
compactada em `.zip`.

---

## Passo 2 — Criar o serviço no EasyPanel

1. Abra o EasyPanel e entre no **Projeto** desejado (ou crie um novo)
2. **+ Service** → **App**
3. Nome do serviço: `proposta-todaka`
4. Aba **Source**:
   - Origem: **GitHub** (ou **Git** / **Upload**, conforme o passo 1)
   - Repositório: `SEU-USUARIO/proposta-toda`
   - Branch: `main`
   - **Build Path:** `/` — se você subiu só a pasta `deploy`.
     Se subiu o projeto inteiro, use `/deploy`
5. Aba **Build**:
   - Método: **Dockerfile**
   - Caminho do Dockerfile: `Dockerfile`
6. Clique em **Deploy** e acompanhe o log até aparecer o build concluído

---

## Passo 3 — Apontar o domínio

### 3.1 No seu provedor de DNS

Crie um registro **A** apontando para o IP do VPS:

| Tipo | Nome | Valor | TTL |
|---|---|---|---|
| A | `proposta` | `IP.DO.SEU.VPS` | 3600 |

Isso publica em `proposta.seudominio.com.br`.

**Sugestão:** use um subdomínio por cliente — `todaka.verttatech.com.br` — assim a mesma
estrutura serve as próximas propostas sem conflito.

### 3.2 Conferir a propagação

Só siga adiante quando o domínio já resolver para o IP correto:

```bash
nslookup proposta.seudominio.com.br
```

### 3.3 No EasyPanel

1. Abra o serviço → aba **Domains**
2. **Add Domain**
3. Host: `proposta.seudominio.com.br`
4. **Port: 80** (é a porta que o nginx escuta dentro do contêiner)
5. Marque **HTTPS** — o EasyPanel emite o certificado Let's Encrypt automaticamente
6. Salve

> **Ordem importa.** O certificado só é emitido se o domínio já apontar para o servidor.
> Se você marcar HTTPS antes de o DNS propagar, a emissão falha e é preciso remover e
> recriar o domínio depois.

---

## Passo 4 — Proteger com senha (opcional, recomendado)

A proposta traz valores comerciais. Mesmo com `noindex`, a URL é adivinhável.

No serviço → aba **Advanced** → **Basic Auth** → adicione usuário e senha.
O cliente recebe o link junto com as credenciais.

---

## Atualizar a proposta depois

1. Edite `saas-arquitetura/proposta-toda.html` (é o arquivo de trabalho)
2. Regere o `index.html` autocontido:

```bash
cd C:/Users/lucas/Documents/github/saas-arquitetura
bash deploy/build.sh
```

3. `git add . && git commit -m "ajuste" && git push`
4. No EasyPanel, clique em **Deploy** no serviço

---

## Verificação final

Depois de publicado, confira:

- [ ] `https://proposta.seudominio.com.br` abre com o cadeado de segurança
- [ ] A capa aparece dourada com TODA em preto
- [ ] "Preparado para Todaka" está na capa
- [ ] O botão **Salvar PDF** gera o A4 corretamente
- [ ] No celular, o layout não rola para os lados
- [ ] `https://proposta.seudominio.com.br/robots.txt` responde com `Disallow: /`
