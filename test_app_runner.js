// Enables XMLHttpRequest (required by elm-lang/http) in node environment
global.XMLHttpRequest = require('xhr2').XMLHttpRequest

const Elm = require('./test_app')

Elm.TestApp.worker({
  creds: {
    accessKeyId: process.env.PAAPI_ACCESS_KEY_ID,
    secretAccessKey: process.env.PAAPI_SECRET_ACCESS_KEY,
  },
  tag: "elm-paapi-test-22",
})
