# Meio Dev - Envio para Endpoint

Modelo de tag do [Google Tag Manager](https://tagmanager.google.com) (Community Template Gallery) que envia dados para um endpoint configurável.

## O que faz

- **GET**: envia parâmetros na query string (via pixel).
- **POST**: envia JSON no corpo da requisição (requer hospedar o script `meio-dev-gtm-post.js` e informar a URL na configuração da tag).

Configuração: URL do endpoint, inclusão opcional de dados da página (URL, referrer, título, timestamp) e tabela de parâmetros customizados com suporte a variáveis GTM.

## Arquivos

- `template.tpl` – definição do modelo para a Galeria.
- `meio-dev-gtm-post.js` – script a ser hospedado no seu domínio quando usar o método POST.
- `metadata.yaml` – metadados e versões para a Galeria.

## Uso na Galeria

Este repositório segue os requisitos da [Galeria de modelos da comunidade do GTM](https://support.google.com/tagmanager/answer/12291073). Para instalar o modelo a partir da Galeria, use o Gerenciador de tags e adicione um novo modelo pela Galeria.

## Licença

Apache License 2.0 – veja [LICENSE](LICENSE).
