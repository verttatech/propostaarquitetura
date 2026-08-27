# Deploy da proposta TODA no EasyPanel

Pacote pronto para publicar a proposta comercial em domínio próprio.

A página é um **orçamento interativo**: a cliente marca as telas que quer agora e vê o
total, a economia, o prazo e as parcelas se atualizarem na hora. As trinta e quatro telas
já construídas entram sem cobrança; o cardápio lista apenas as vinte que ainda serão
feitas.

## Arquivos

| Arquivo | Função |
|---|---|
| `orcamento-toda.html` | **Arquivo de trabalho** — é aqui que se edita o conteúdo e os preços |
| `index.html` | Gerado pelo `build.sh`: a página autocontida (CSS e JS embutidos, sem dependência externa) |
| `build.sh` | Embrulha o arquivo de trabalho com o `<head>` (meta tags, favicon, prévia de compartilhamento) |
| `Dockerfile` | Imagem nginx alpine servindo o HTML |
| `nginx.conf` | Compressão, cabeçalhos de segurança e cache controlado |
| `proposta-implantacao.pdf` | A proposta comercial: 8 páginas, com sumário executivo, premissas, termos e aceite |
| `o-que-acrescenta.pdf` | Complemento: 3 páginas com os módulos que podem entrar depois |
| `*.html` de mesmo nome | Arquivos de trabalho dos PDFs — folhas A4 explícitas |
| `build-pdf.sh` | Regenera os dois PDFs e **falha** se alguma folha transbordar |
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

1. Edite `orcamento-toda.html` (é o arquivo de trabalho, dentro deste próprio repositório)
2. Regere o `index.html` autocontido:

```bash
bash build.sh
```

3. `git add . && git commit -m "ajuste" && git push`
4. No EasyPanel, clique em **Deploy** no serviço

### O link da escolha

Quando a cliente marca as telas, a seleção é gravada no próprio endereço da página
(`.../#s=venda,cadastro,contrato`). Isso faz três coisas:

- **Ela pode repassar.** O botão *Copiar o link da escolha* devolve um endereço que abre
  com exatamente as mesmas telas marcadas — serve para ela mandar ao sócio antes de
  decidir, ou para devolver a você já fechado.
- **O WhatsApp sai pronto.** O botão *Enviar no WhatsApp* abre o aplicativo com a lista
  das telas, o total, as parcelas, o prazo e o link, tudo formatado.
- **O PDF é o documento.** *Salvar em PDF* imprime só as telas escolhidas mais o resumo
  com data, prazo, parcelas e validade — os controles somem na impressão.

Nada disso precisa de servidor: é tudo no navegador dela. Por isso o link também funciona
se você mandar para outra pessoa.

> Os identificadores usados no link são os `data-id` de cada tela. Se você renomear um
> deles, os links antigos deixam de reconhecer aquela tela — mude só se precisar.

### Os dois PDFs

Além da página interativa, o repositório traz dois documentos fechados, feitos para serem
enviados juntos:

- **`proposta-implantacao.pdf`** — a proposta comercial completa, em oito páginas: sumário
  executivo, o que já está construído, escopo, investimento, prazo, premissas, exclusões,
  termos e condições e bloco de aceite com assinatura. **Sem a inteligência artificial.**
- **`o-que-acrescenta.pdf`** — o catálogo do que pode entrar depois, precificado, com as regras
  de contratação e uma sugestão de ordem.

> O escopo segue o que foi efetivamente proposto e discutido na reunião de 20/08: a base da
> plataforma, clientes e projetos, obras, portal do cliente e financeiro já entregues, mais as
> cinco telas que respondem às dores que ela levantou. A camada de assinaturas — que permite
> revender a plataforma a outros arquitetos — **não estava naquela proposta** e por isso ficou
> no catálogo de complementos.

A separação é proposital: a proposta fica curta e fechada, e a lista de opcionais não compete
com ela na hora da decisão.

```bash
bash build-pdf.sh
```

Os HTML de origem definem folhas A4 explícitas (`.capa` e `.pagina`), então a quebra de página
é decidida no documento e não pelo navegador. O script confere isso documento a documento: se
o PDF sair com mais páginas do que o HTML define, alguma folha transbordou e o build **falha**
em vez de entregar um documento desalinhado.

Depois do deploy, os dois ficam em `https://seu-dominio/proposta-implantacao.pdf` e
`https://seu-dominio/o-que-acrescenta.pdf`.

### Mexer nos preços

Cada tela é um `<label class="item">` com os atributos que mandam na conta:

| Atributo | O que faz |
|---|---|
| `data-tab` | Preço de tabela, o valor riscado |
| `data-preco` | Preço cobrado, já com os 30% |
| `data-ess="1"` | Marca a tela como essencial: vem selecionada e entra no atalho "Só o essencial" |
| `checked` | Deixa a tela pré-selecionada ao abrir a página |

O total, a economia, o prazo e as parcelas são calculados a partir desses atributos —
não existe nenhum valor fixo no JavaScript. Depois de mexer, rode `bash build.sh`
de novo.

---

## Verificação final

Depois de publicado, confira:

- [ ] `https://proposta.seudominio.com.br` abre com o cadeado de segurança
- [ ] A capa aparece dourada com TODA em preto
- [ ] A barra de total fica fixa no rodapé e acompanha a rolagem
- [ ] Marcar e desmarcar uma tela muda o total na hora
- [ ] O atalho **Só o essencial** deixa oito telas marcadas, somando R$ 29.400
- [ ] O atalho **Selecionar tudo** soma R$ 107.000
- [ ] Desmarcar parte do grupo de assinaturas faz aparecer o aviso âmbar
- [ ] O botão **Salvar PDF** gera o A4 só com as telas marcadas
- [ ] No celular, o layout não rola para os lados
- [ ] `https://proposta.seudominio.com.br/robots.txt` responde com `Disallow: /`
