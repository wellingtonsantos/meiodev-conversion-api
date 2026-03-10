___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "meio_dev_endpoint_tag",
  "version": 1,
  "securityGroups": [],
  "displayName": "Meio Dev - Envio para Endpoint",
  "categories": [
    "ANALYTICS",
    "CONVERSIONS"
  ],
  "brand": {
    "id": "meio-dev-gtm-templates",
    "displayName": "Meio Dev"
  },
  "description": "Tag que envia dados para um endpoint configurável. Ao disparar, faz uma requisição (GET ou POST) para a URL informada com os parâmetros que você configurar. Ideal para integrações customizadas, webhooks e envio de eventos para seu próprio backend.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "GROUP",
    "name": "endpoint",
    "displayName": "Configuração do endpoint",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "TEXT",
        "name": "endpointUrl",
        "displayName": "URL do endpoint",
        "simpleValueType": true,
        "valueValidators": [
          {
            "type": "NON_EMPTY",
            "errorMessage": "Informe a URL do endpoint para onde os dados serão enviados."
          }
        ],
        "valueHint": "https://seu-servidor.com/api/eventos",
        "help": "URL completa do endpoint que receberá os dados quando a tag disparar. Ex: https://api.seudominio.com/webhook ou https://seu-servidor.com/collect",
        "alwaysInSummary": true
      },
      {
        "type": "SELECT",
        "name": "requestMethod",
        "displayName": "Método da requisição",
        "macrosInSelect": false,
        "selectItems": [
          { "value": "GET", "displayValue": "GET (parâmetros na URL)" },
          { "value": "POST", "displayValue": "POST (dados no corpo, JSON)" }
        ],
        "simpleValueType": true,
        "defaultValue": "POST",
        "help": "POST é o recomendado para enviar dados. Requer hospedar o script meio-dev-gtm-post.js (incluído no pacote) e informar a URL abaixo.",
        "alwaysInSummary": true
      },
      {
        "type": "TEXT",
        "name": "postScriptUrl",
        "displayName": "URL do script de envio POST",
        "simpleValueType": true,
        "valueHint": "https://seu-dominio.com/meio-dev-gtm-post.js",
        "help": "Obrigatório quando método é POST. URL do arquivo meio-dev-gtm-post.js hospedado no seu servidor ou CDN. Faça o upload do arquivo incluído no pacote e informe a URL aqui.",
        "enablingConditions": [
          { "paramName": "requestMethod", "paramValue": "POST", "type": "EQUALS" }
        ],
        "valueValidators": [
          {
            "type": "NON_EMPTY",
            "errorMessage": "Informe a URL do script de envio POST.",
            "enablingConditions": [
              { "paramName": "requestMethod", "paramValue": "POST", "type": "EQUALS" }
            ]
          }
        ]
      },
      {
        "type": "CHECKBOX",
        "name": "includePageData",
        "displayName": "Incluir dados da página",
        "checkboxText": "Enviar URL, referrer, título e timestamp automaticamente",
        "simpleValueType": true,
        "defaultValue": true,
        "help": "Quando marcado, adiciona aos dados enviados: page_url (URL atual), page_referrer (origem), page_title (título) e timestamp (data/hora do disparo)."
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "payload",
    "displayName": "Dados a enviar (payload)",
    "groupStyle": "ZIPPY_OPEN_ON_PARAM",
    "subParams": [
      {
        "type": "SIMPLE_TABLE",
        "name": "payloadParams",
        "displayName": "Parâmetros",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Nome do parâmetro",
            "name": "paramName",
            "type": "TEXT",
            "valueHint": "ex: event_name, user_id"
          },
          {
            "defaultValue": "",
            "displayName": "Valor",
            "name": "paramValue",
            "type": "TEXT",
            "valueHint": "texto ou variável GTM",
            "macrosInSelect": true
          }
        ],
        "newRowButtonText": "Adicionar parâmetro",
        "notSetText": "Nenhum parâmetro adicional. Use \"Incluir dados da página\" ou adicione abaixo.",
        "help": "Cada linha vira um parâmetro na requisição. Valores podem ser texto fixo ou variáveis do GTM (clique no ícone de variável para escolher)."
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const sendPixel = require('sendPixel');
const encodeUriComponent = require('encodeUriComponent');
const getUrl = require('getUrl');
const getReferrerUrl = require('getReferrerUrl');
const readTitle = require('readTitle');
const getTimestampMillis = require('getTimestampMillis');
const injectScript = require('injectScript');
const callInWindow = require('callInWindow');
const queryPermission = require('queryPermission');

// Validar endpoint
if (!data.endpointUrl || data.endpointUrl.trim() === '') {
  data.gtmOnFailure();
  return;
}

var endpointUrl = data.endpointUrl.trim();
var payload = {};

// Dados da página (opcional)
if (data.includePageData) {
  try {
    var pageUrl = getUrl();
    if (pageUrl) payload.page_url = pageUrl;
  } catch (e) {}
  try {
    var referrer = getReferrerUrl();
    if (referrer) payload.page_referrer = referrer;
  } catch (e) {}
  try {
    var title = readTitle();
    if (title) payload.page_title = title;
  } catch (e) {}
  try {
    var ts = getTimestampMillis();
    if (ts != null) payload.timestamp = ts;
  } catch (e) {}
}

// Parâmetros configurados pelo usuário
if (data.payloadParams && data.payloadParams.length > 0) {
  for (var i = 0; i < data.payloadParams.length; i++) {
    var row = data.payloadParams[i];
    var name = row.paramName;
    var value = row.paramValue;
    if (name && name.toString().trim() !== '') {
      var key = name.toString().trim();
      payload[key] = (value !== undefined && value !== null) ? value.toString() : '';
    }
  }
}

var isPost = data.requestMethod === 'POST';

if (isPost) {
  // POST: injetar script e chamar meioDevSendPost(endpointUrl, payload, onSuccess, onFailure)
  if (!data.postScriptUrl || data.postScriptUrl.trim() === '') {
    data.gtmOnFailure();
    return;
  }
  var scriptUrl = data.postScriptUrl.trim();
  if (queryPermission('inject_script', scriptUrl)) {
    injectScript(scriptUrl, onPostScriptLoaded, data.gtmOnFailure, scriptUrl);
  } else {
    data.gtmOnFailure();
  }
} else {
  // GET: montar query string e enviar via sendPixel
  var baseUrl = endpointUrl;
  var hasQuery = baseUrl.indexOf('?') !== -1;
  if (!hasQuery && baseUrl.lastIndexOf('/') === baseUrl.length - 1) {
    baseUrl = baseUrl.slice(0, -1);
  }
  var params = [];
  for (var k in payload) {
    if (payload.hasOwnProperty(k)) {
      params.push(encodeUriComponent(k) + '=' + encodeUriComponent(payload[k]));
    }
  }
  var queryString = params.join('&');
  var finalUrl = baseUrl + (queryString ? (hasQuery ? '&' : '?') + queryString : '');
  sendPixel(finalUrl, function() {
    data.gtmOnSuccess();
  }, function() {
    data.gtmOnFailure();
  });
}

function onPostScriptLoaded() {
  callInWindow('meioDevSendPost', endpointUrl, payload, data.gtmOnSuccess, data.gtmOnFailure);
}


___TESTS___

scenarios:
- name: Envio GET para endpoint
  code: "const mockData = {\n  endpointUrl: 'https://api.exemplo.com/eventos',\n  requestMethod: 'GET',\n  includePageData: false,\n  payloadParams: [{ paramName: 'event_name', paramValue: 'page_view' }]\n};\nrunCode(mockData);\nassertApi('sendPixel').wasCalled();\n"
- name: Envio POST requer script
  code: "const mockData = {\n  endpointUrl: 'https://api.exemplo.com/eventos',\n  requestMethod: 'POST',\n  postScriptUrl: 'https://cdn.exemplo.com/meio-dev-gtm-post.js',\n  includePageData: false,\n  payloadParams: []\n};\nrunCode(mockData);\nassertApi('injectScript').wasCalled();\n"


___NOTES___

Meio Dev - Envio para Endpoint v1
Método GET: envia parâmetros na query string via sendPixel. Método POST: envia JSON no corpo; é necessário hospedar o arquivo meio-dev-gtm-post.js e informar sua URL na configuração da tag.
