# Plexo 360 — Site (Deploy Automático)

Repositório do site **Plexo 360**, publicado automaticamente no **Cloudflare Pages**.

🔗 **https://plexo360.pages.dev**

## Como publicar uma atualização

1. Edite normalmente o arquivo `Plexo360 (3).html` no Desktop.
2. Dê **dois cliques** em `atualizar-e-publicar.bat`.
3. Pronto. Em ~1 minuto a nova versão está no ar.

O script faz tudo sozinho:
- Copia a versão mais recente do Desktop para `index.html`
- Incrementa a versão do cache (para os usuários receberem a atualização)
- Envia ao GitHub → o Cloudflare publica automaticamente

## Estrutura

| Arquivo | Função |
|---------|--------|
| `index.html` | O app (gerado a partir de `Plexo360 (3).html`) |
| `manifest.json` | Configuração do app instalável (PWA) |
| `service-worker.js` | Cache offline; versão incrementada a cada deploy |
| `_headers` | Regras de cache do Cloudflare |
| `plexo-icon-*.png` | Ícones do app |
| `atualizar-e-publicar.bat` | Publicação com um clique |
