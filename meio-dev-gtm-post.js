/**
 * Meio Dev - Script de envio POST para GTM
 * Hospede este arquivo em seu servidor ou CDN e informe a URL no template.
 * O template chama: window.meioDevSendPost(endpointUrl, payloadObject, onSuccess, onFailure)
 */
(function(global) {
  function sendPost(endpointUrl, payload, onSuccess, onFailure) {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', endpointUrl, true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        if (xhr.status >= 200 && xhr.status < 300) {
          if (typeof onSuccess === 'function') onSuccess();
        } else {
          if (typeof onFailure === 'function') onFailure();
        }
      }
    };
    xhr.onerror = function() {
      if (typeof onFailure === 'function') onFailure();
    };
    xhr.send(JSON.stringify(payload));
  }
  global.meioDevSendPost = sendPost;
})(typeof window !== 'undefined' ? window : this);
